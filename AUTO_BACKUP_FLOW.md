# Expendly Auto Backup Architecture & Execution Flow

This document details the design, lifecycle triggers, encryption, notifications, and storage policies for Expendly's automatic backup mechanism.

---

## 1. Overview

Expendly is an offline-first personal financial management application. All transaction records, budgets, categories, subcategories, tags, recurring rules, user profile data, and attachments reside strictly on the user's device in a local SQLite database (`expendly.sqlite`).

The **Auto Backup System** (`AutoBackupService`) automatically generates hardware-encrypted snapshots of the complete database into a persistent, user-accessible directory (`Download/Expendly/auto-backup/` or `Documents/Expendly/auto-backup/`).

---

## 2. Triggers & Schedule

Auto backup execution is governed by a **2-day rate limit** (`Duration(days: 2)`), a **30-second debounce timer**, and **app lifecycle observation**.

```
[ Data Mutation (Add/Edit/Delete Transaction) ]
                       │
                       ▼
       [ Set snapshot_dirty = true ]
                       │
                       ▼
      [ Start 30-Second Debounce Timer ]
                       │
         ┌─────────────┴─────────────┐
         │                           │
  (30s Timer Expires)      (User Backgrounds App)
         │                           │
         └─────────────┬─────────────┘
                       ▼
            [ Check Rate Limit ]
      Is (Now - LastBackupAt) >= 2 Days?
         ┌─────────────┴─────────────┐
        YES                          NO
         │                           │
         ▼                           ▼
[ Execute Snapshot ]         [ Skip Snapshot ]
(Send Local Notifications)  (Log Rate-Limited Info)
```

### Detailed Event Flow

1. **App Bootstrap Registration & Launch Check** ([main.dart](file:///Users/rojanshrestha/Documents/rojan/personalProjects/expendly/lib/main.dart)):
   - `ExpendlyApp` initializes and attaches `WidgetsBindingObserver`.
   - `_startAutoBackup()` calls `getIt<AutoBackupService>().start()`.
   - `AutoBackupService.start()` verifies if `isAutoBackupEnabled` is `true`. If enabled:
     - It attaches a listener `_onDataChanged` to `TransactionEvents.transactionUpdated`.
     - It executes `_checkLaunchBackup()`, which probes the public `Download/Expendly/auto-backup/` folder. If the folder/file is missing or deleted from disk, it immediately recreates the folder structure and triggers `snapshotIfDue(force: true)` on startup.

2. **Data Mutation Listener & 30-Second Debounce**:
   - Whenever transactions are created, modified, or deleted in `TransactionCubit`, it broadcasts `TransactionEvents.notifyUpdated()`.
   - `AutoBackupService._onDataChanged()`:
     - Sets preference `snapshot_dirty = true`.
     - Starts a 30-second debounce timer (`_debounceTimer`).
     - Once 30 seconds elapse without any subsequent mutations, `snapshotIfDue()` is executed.

3. **App Backgrounding Trigger**:
   - If the user minimizes or switches away from the app before the 30-second timer expires, Flutter's `WidgetsBindingObserver` receives `AppLifecycleState.paused`.
   - `main.dart` forwards this event to `AutoBackupService.onAppPaused()`.
   - `onAppPaused()` checks `snapshot_dirty == true` and immediately invokes `snapshotIfDue()` without waiting for the timer.

4. **2-Day Rate-Limit Guard & Disk Validation**:
   - `snapshotIfDue()` compares `DateTime.now()` with `PreferenceService.lastSnapshotAt`.
   - Before skipping, it verifies if a readable auto backup file exists in the public `Download/Expendly/auto-backup/` directory. If the user deleted the directory or file on disk, rate-limiting is bypassed and the backup is regenerated immediately.

---

## 3. Local Push Notification Workflow

During auto backup execution, `AutoBackupService` interacts with `NotificationService` to inform the user via local push notifications (Notification ID `888`):

1. **In-Progress Notification**:
   - **Title**: `Auto Backup in Progress...`
   - **Body**: `Creating encrypted snapshot of your financial ledger...`

2. **Completion Notification**:
   - **Title**: `Auto Backup Completed`
   - **Body**: `Backup saved to: <absolute_file_path>`

3. **Failure Notification**:
   - **Title**: `Auto Backup Failed`
   - **Body**: `No security PIN set. Security PIN is required for auto backup.` (or exact error message).

---

## 4. Encryption & Security Model

- **Passphrase Encryption**: Snapshots are encrypted with **AES-256-GCM** using PBKDF2 key derivation (120,000 iterations, random salt) via the user's **4-digit Security PIN**.
- **Mandatory PIN Guard**: If no Security PIN has been configured, auto backup is blocked and an alert notification is emitted to prevent saving unencrypted or unrecoverable backup files.
- **SQLite WAL Checkpoint**: Prior to reading and serializing the database tables, `AppDatabase.checkpointForBackup()` executes `PRAGMA wal_checkpoint(TRUNCATE)` to flush WAL memory buffers into disk.

---

## 5. File-Based Restoration Flow (No User Lock)

- **File Selection**: Users can restore data by selecting any valid `.expendly` backup file via the native File Picker or by picking the latest auto-backup file.
- **Decoupled User Profile Import**: Restoration parses and imports all entities including `userProfiles` without enforcing any `userId` match restrictions, ensuring seamless restoration after clearing app data or reinstalling.
- **Passphrase Decryption**: Decryption relies on the user entering (or verifying) their 4-digit Security PIN. Raw text copy-paste functionality is removed.

---

## 6. Storage & File Rotation Policy

- **Directory Path**:
  - Android: `/storage/emulated/0/Download/Expendly/auto-backup/`
  - iOS: `Documents/Expendly/auto-backup/`
- **Atomic Writes**: Payload is written to a temporary `.tmp` file before renaming to `expendly_auto_YYYYMMDD_HHMM.expendly` to prevent partial or corrupted file writes.
- **Latest Symlink**: A copy is simultaneously written to `expendly_auto_latest.expendly` for fast detection on fresh application installs.
- **Rotation**: Retains a maximum of **2 timestamped snapshots** plus `_latest`, deleting older timestamped backups automatically.

---

## 7. Key Configuration Parameters

| Parameter | Value | Description |
| :--- | :--- | :--- |
| `_minInterval` | `Duration(days: 2)` | Minimum required interval between automatic backups |
| `_debounce` | `Duration(seconds: 30)` | Debounce window after transaction edit |
| `_keepSnapshots` | `2` | Number of timestamped snapshots retained |
| `_notificationId` | `888` | Notification channel ID for backup status updates |
