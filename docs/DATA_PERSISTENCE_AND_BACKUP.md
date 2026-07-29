# Data Durability & Backup Strategy

How Expendly keeps user financial data alive across app updates, "Clear data", uninstall,
device loss, and device migration — while staying offline-first.

Scope: `lib/core/database/app_database.dart` (drift/SQLite),
`lib/core/services/data_export_import_service.dart`, `encryption_service.dart`,
`secure_storage_service.dart`, `preference_service.dart`, and the platform backup
configuration in `android/` and `ios/`.

---

## 1. The problem, stated precisely

The drift database lives at `getApplicationDocumentsDirectory()/expendly.sqlite` — inside
the app sandbox. Everything in the sandbox is owned by the OS installer, not by us:

| Event | `expendly.sqlite` | `shared_preferences` | Keychain / EncryptedSharedPrefs | Files in `Download/Expendly` |
|---|---|---|---|---|
| App update (store / sideload same signature) | survives | survives | survives | survives |
| Force stop / crash / OS kill | survives | survives | survives | survives |
| Android "Clear cache" | survives | survives | survives | survives |
| **Android "Clear storage / data"** | **deleted** | **deleted** | **deleted** | survives |
| **Uninstall (Android)** | **deleted** | **deleted** | **deleted** | survives (public dir) |
| **Uninstall (iOS)** | **deleted** | **deleted** | Keychain **may survive**¹ | **deleted** (app sandbox) |
| Reinstall + Android Auto Backup / D2D transfer | restored² | restored² | **not restored**³ | n/a |
| Restore from iCloud/iTunes device backup | restored | restored | restored (same Apple ID) | n/a |
| New device, no OS backup | gone | gone | gone | gone |
| Device lost / bricked | gone | gone | gone | gone |

¹ iOS keychain items are not guaranteed to be purged on uninstall and are not guaranteed to
be kept either. Never treat the keychain as the only copy of anything.
² Only if Auto Backup is enabled, the user has ≤25 MB of app data, and Google Backup is on.
³ Android Keystore keys are hardware-bound and never leave the device, so
`encryptedSharedPreferences: true` blobs restore as **undecryptable garbage**.

**Conclusion: no purely local mechanism can survive "Clear data" or uninstall.**
Durability must come from (a) OS-managed backup and (b) an artifact the user owns that lives
outside the sandbox. We do both, in layers.

---

## 2. The layered strategy

Ordered cheapest-to-implement first. Each layer covers failures the one above it cannot.

| # | Layer | Covers | User action needed | Status |
|---|---|---|---|---|
| L0 | Correct DB location + migrations | app updates, crashes | none | done |
| L1 | OS-managed backup (Android Auto Backup, iOS iCloud device backup) | uninstall→reinstall, device migration | none | **to do** — §4 |
| L2 | Automatic local snapshot to a public/user-visible directory | Android "Clear data", uninstall | none (opt-out) | **to do** — §5 |
| L3 | Manual encrypted export (`.expendly`) | anything, incl. device loss if the user moved the file off-device | user exports | partially done — §6 |
| L4 | Automatic export to user cloud (Drive / iCloud Drive / any provider via share sheet) | device loss, theft, bricked device | one-time setup | **to do** — §7 |
| L5 | Backup-health nagging + restore-on-first-launch detection | user never backs up; silent data loss | responds to prompt | **to do** — §8 |

Non-goal: a server-side sync backend. The SRS commits to offline-first with no network data
layer, so "cloud" here always means *the user's own cloud storage*, written as an opaque
encrypted file. We never see the plaintext and we run no account system.

### The rule that makes all of this coherent

> **The database file is a cache of the user's data, not the system of record.
> The encrypted backup artifact is the system of record.**

Anything that cannot be reconstructed from a `.expendly` backup does not durably exist.
That means every new table must be added to the export payload in the same change — see §9.

---

## 3. L0 — Get the local database right first

Already in place, listed so it does not regress:

- DB path is `getApplicationDocumentsDirectory()/expendly.sqlite`. **Never** move it to
  `getTemporaryDirectory()` or `getApplicationCacheDirectory()` — the OS deletes those under
  storage pressure without telling us.
- On Android, `getApplicationDocumentsDirectory()` maps to internal `app_flutter/`, which is
  private and included in Auto Backup by default. Do not "fix" this by moving the DB to
  external storage: it would become world-readable and lose the Auto Backup inclusion.
- `schemaVersion` is bumped and an `onUpgrade` branch added for every schema change
  (`if (from < N)`), and existing branches are never edited. A migration that throws on a
  real user's DB is indistinguishable from data loss — drift aborts the open and the app is
  bricked until reinstall.
- Money is integer cents. Do not reintroduce doubles; a lossy round-trip through backup
  is silent corruption.

### Two additions worth making

**a. WAL checkpointing before backup reads.** `NativeDatabase` runs in WAL mode, so recent
writes may live in `expendly.sqlite-wal` rather than the main file. Any code that copies the
raw `.sqlite` file (L2, L4) must first force a checkpoint, or it will copy a stale DB:

```dart
// AppDatabase
/// Flushes the WAL into the main database file so the file on disk is
/// self-contained and safe to copy for backup.
Future<void> checkpointForBackup() async {
  await customStatement('PRAGMA wal_checkpoint(TRUNCATE);');
}
```

**b. Corruption guard on open.** If the DB is unreadable, we want a controlled "restore from
backup?" screen, not a crash loop:

```dart
Future<int> integrityCheck() async {
  final rows = await customSelect('PRAGMA integrity_check;').get();
  return rows.first.data.values.first == 'ok' ? 0 : 1;
}
```

Call it once during bootstrap in `main.dart`; on failure route to the restore flow (§8.3)
instead of throwing.

---

## 4. L1 — OS-managed backup (free, zero user effort)

### 4.1 Android Auto Backup

Not configured today: [AndroidManifest.xml](android/app/src/main/AndroidManifest.xml) declares
no `allowBackup` / `fullBackupContent` / `dataExtractionRules`, so we inherit the platform
default (backup enabled, everything included). Make it explicit and correct, because the
default includes files that *break* on restore.

Create `android/app/src/main/res/xml/backup_rules.xml` (Android 11 and below):

```xml
<?xml version="1.0" encoding="utf-8"?>
<full-backup-content>
    <!-- drift database: getApplicationDocumentsDirectory() -> app_flutter/ -->
    <include domain="file" path="app_flutter/expendly.sqlite"/>
    <!-- shared_preferences (currency, onboarding, theme) -->
    <include domain="sharedpref" path="FlutterSharedPreferences.xml"/>

    <!-- Keystore-wrapped blobs restore as undecryptable garbage: exclude -->
    <exclude domain="sharedpref" path="FlutterSecureStorage.xml"/>
    <!-- WAL/SHM are meaningless without the exact same DB instance -->
    <exclude domain="file" path="app_flutter/expendly.sqlite-wal"/>
    <exclude domain="file" path="app_flutter/expendly.sqlite-shm"/>
</full-backup-content>
```

And `android/app/src/main/res/xml/data_extraction_rules.xml` (Android 12+, covers both
cloud backup and device-to-device transfer):

```xml
<?xml version="1.0" encoding="utf-8"?>
<data-extraction-rules>
    <cloud-backup>
        <include domain="file" path="app_flutter/expendly.sqlite"/>
        <include domain="sharedpref" path="FlutterSharedPreferences.xml"/>
        <exclude domain="sharedpref" path="FlutterSecureStorage.xml"/>
        <exclude domain="file" path="app_flutter/expendly.sqlite-wal"/>
        <exclude domain="file" path="app_flutter/expendly.sqlite-shm"/>
    </cloud-backup>
    <device-transfer>
        <include domain="file" path="app_flutter/expendly.sqlite"/>
        <include domain="sharedpref" path="FlutterSharedPreferences.xml"/>
        <exclude domain="sharedpref" path="FlutterSecureStorage.xml"/>
    </device-transfer>
</data-extraction-rules>
```

Wire both into the `<application>` tag:

```xml
<application
    android:allowBackup="true"
    android:fullBackupContent="@xml/backup_rules"
    android:dataExtractionRules="@xml/data_extraction_rules"
    ...>
```

Consequences to design around:

- The restored DB arrives **without** the master AES key and **without** the security PIN,
  because we exclude `FlutterSecureStorage.xml`. The app must handle "DB present, keychain
  empty" by generating a fresh master key and re-running PIN setup rather than locking the
  user out. See §8.2.
- Auto Backup is best-effort: it runs roughly daily, only on unmetered networks while
  charging and idle, is capped at 25 MB per app, and silently does nothing if the user has
  Google Backup off. It is a nice-to-have, never the plan.
- Test it explicitly — see §10.

### 4.2 iOS

The app sandbox `Documents/` directory is included in iCloud and iTunes/Finder device
backups by default, so `expendly.sqlite` and `shared_preferences` already ride along.
Keep it that way:

- Do **not** set `NSURLIsExcludedFromBackupKey` on the DB file.
- Keep the DB in `Documents/`, not `Library/Caches/`.
- Keychain items use `KeychainAccessibility.first_unlock`, which is backed up and restorable
  to the *same* Apple ID. If a PIN must survive migration, that is the mechanism; do not
  assume it, and never make the PIN a prerequisite for reading the data.
- `UIFileSharingEnabled` and `LSSupportsOpeningDocumentsInPlace` are already `true` in
  [Info.plist](ios/Runner/Info.plist), so exported backups in `Documents/Expendly` are
  reachable from the Files app. Note this also means those exports are user-visible — which
  is the point — so they must always be encrypted.

iCloud device backup does **not** save the user from uninstall on a device with backups
disabled, and iOS deletes the sandbox on uninstall regardless. L2 and L3 remain mandatory.

---

## 5. L2 — Automatic local snapshot outside the sandbox

The single highest-value fix for "Clear data" and Android uninstall. Same artifact as the
manual export, written automatically to a directory the OS installer does not own.

### 5.1 Where the snapshot goes

`_getExportDirectory()` already resolves the right places:

- **Android:** `/storage/emulated/0/Download/Expendly` — public, survives uninstall and
  "Clear data". On API 29+ `MediaStore`/scoped storage means no `WRITE_EXTERNAL_STORAGE`
  permission is needed to write into `Download/`. Keep the existing
  `getDownloadsDirectory()` fallback for OEMs with an unusual layout.
- **iOS:** `Documents/Expendly` — sandbox-bound, so it does *not* survive uninstall, but it
  is user-visible in Files and rides iCloud device backups. On iOS, L2 is a convenience;
  L4 is the layer that actually protects the data.

Write snapshots to a `snapshots/` subfolder so they are distinguishable from user-initiated
exports, and keep a stable name plus a small rotation:

```
Download/Expendly/
├── expendly_backup_1737012345678.expendly     # user-initiated (L3)
└── snapshots/
    ├── expendly_auto_latest.expendly          # always the newest, stable filename
    ├── expendly_auto_20260728_0913.expendly
    ├── expendly_auto_20260727_2140.expendly
    └── expendly_auto_20260726_1802.expendly   # keep N = 5, delete oldest
```

A stable `_latest` name matters: it is what the restore flow (§8.3) looks for without asking
the user to pick a file, and it keeps a cloud-sync folder from accumulating garbage.

### 5.2 When it runs

Trigger on **meaningful mutation, debounced**, not on a timer — a timer either fires when
nothing changed or misses the write that mattered.

- Subscribe to `TransactionEvents.transactionUpdated` (the existing app-wide notifier bus).
- Debounce 30 s, and additionally rate-limit to at most one snapshot per hour unless
  `force: true`.
- Also snapshot on `AppLifecycleState.paused` if the DB is dirty since the last snapshot —
  backgrounding is the last moment we are guaranteed to run.
- Always run off the UI path. The payload build is a handful of `SELECT`s plus AES-CBC over
  a JSON string; for realistic transaction volumes this is single-digit milliseconds, but
  keep it `await`ed in a service, never inside a `build()`.

Rate-limit state (`last_snapshot_at`, `last_snapshot_row_count`) belongs in
`PreferenceService`, not in memory — the process dies between sessions.

### 5.3 Shape of the service

New file `lib/core/services/auto_backup_service.dart`, registered manually in
`configureDependencies()` as a lazy singleton per §4 of CLAUDE.md:

```dart
/// Writes encrypted snapshots of the database to a user-visible directory that
/// survives "Clear data" and (on Android) uninstall.
@lazySingleton
class AutoBackupService {
  AutoBackupService(this._db, this._exportService, this._preferenceService);

  static const int _keepSnapshots = 5;
  static const Duration _debounce = Duration(seconds: 30);
  static const Duration _minInterval = Duration(hours: 1);

  Timer? _debounceTimer;

  /// Starts listening for data mutations. Call once from bootstrap.
  void start() => TransactionEvents.transactionUpdated.addListener(_onDataChanged);

  /// Must be called from the owning lifecycle observer's dispose.
  void stop() {
    TransactionEvents.transactionUpdated.removeListener(_onDataChanged);
    _debounceTimer?.cancel();
  }

  void _onDataChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounce, () => snapshotIfDue());
  }

  /// Writes a snapshot when enough time has passed, or always when [force].
  Future<BackupSnapshotResult> snapshotIfDue({bool force = false}) async { ... }
}
```

Return a small result object (`BackupSnapshotResult`) with path, timestamp, and record
counts, so the settings screen can show real backup health (§8.1). Per CLAUDE.md §9, the
service emits no display copy — the page maps a `BackupMessage` enum through `context.l10n`.

### 5.4 Failure handling

A failed snapshot must never surface as a user-facing error or block a save. Log at warning,
record `last_snapshot_error` in preferences, and let the backup-health UI report "last backup
N days ago" — that is the honest signal, and it is actionable. Silently swallowing the error
with no visible staleness indicator is the one unacceptable option.

Disk-full and permission-denied are the realistic failures. Write to a `.tmp` file and
rename into place so a truncated write never replaces a good `_latest` snapshot.

---

## 6. L3 — Manual encrypted export: gaps to close

`DataExportImportService` already exports and imports an AES-256 `.expendly` payload. Four
correctness problems make it unsafe as the system of record today.

### 6.1 The payload is incomplete

Exported: `categories`, `budgets`, `transactions`. Missing: `subcategories`, `tags`,
`transactionTags`, `attachments`, `recurringTransactions`, `userProfiles`. Those tables are
registered in `@DriftDatabase` (`userProfiles` was added in schema v5 for the profile
feature), so a restore silently drops whatever they hold — the user's profile, recurring
rules, and tagging.

Fix: export every table, in FK-safe order, and treat "new table without a matching export
entry" as an incomplete change (§9).

### 6.2 Attachments are file paths, not files

`attachments` stores paths into the sandbox. Those paths are dead after reinstall. Either
inline the bytes as base64 in the payload (simple, bloats the file, risks the 25 MB Auto
Backup cap) or emit a `.zip` container with `payload.json.enc` plus an `attachments/` folder.
Prefer the container — decide before shipping attachment support, since it changes the file
format.

### 6.3 Import is destructive and unversioned

`importEncryptedData` deletes all transactions and budgets *inside* a transaction (good), but:

- It offers no merge mode. Importing an older backup onto a device with newer data destroys
  the newer data with no warning. Add an explicit user choice: **Replace** (current behaviour,
  requires confirmation) vs **Merge** (insert rows whose natural key is absent).
- `insertOnConflictUpdate` with explicit `id`s means IDs from the backup overwrite unrelated
  rows in merge mode. For merge, match on a natural key — `(timestamp, amount, categoryId, note)`
  for transactions — and let SQLite assign new IDs.
- `'version': 1` is written but never checked on import. Validate it and reject a payload
  from a newer app version with a localized "update the app to restore this backup" message
  rather than half-importing it. Keep an upgrade path for older versions.
- The `data['app'] != 'Expendly' && data['categories'] == null` guard uses `&&`, so a payload
  from a different app that happens to contain a `categories` key passes. Make it strict:
  reject unless `app == 'Expendly'` **and** `version` is known.

### 6.4 Default-key exports are not portable

With no passphrase, the payload is encrypted with the master key from `SecureStorageService`.
That key is device-bound and excluded from Android Auto Backup — so a keyless backup is
**undecryptable on a new device**, which is exactly the scenario backups exist for.

This is the most important issue in this document.

Options, in order of preference:

1. **Require a passphrase for any export intended to leave the device**, and derive the key
   from it. Make the passphrase field required rather than optional in the export sheet.
2. For automatic snapshots (L2), where no user is present to type a passphrase, derive the key
   from a **recovery phrase** generated once during onboarding and shown to the user to save
   (the wallet model). Store it in secure storage for convenience, but the user's copy is the
   real one.
3. Keep the device master key only for backups explicitly labelled device-local.

Also replace SHA-256-of-passphrase key derivation (`keyFromPassphrase`) with a proper KDF —
PBKDF2-HMAC-SHA256 at ≥100k iterations with a random per-file salt, stored in the payload
header. A bare SHA-256 of a human passphrase is brute-forceable at enormous rates, and these
files sit in a public `Download/` folder. While changing the format, move from AES-CBC to
AES-GCM so tampering is detectable instead of producing garbage plaintext; bump the payload
version and keep a v1 read path.

Target header for v2:

```json
{
  "app": "Expendly",
  "version": 2,
  "kdf": { "algo": "pbkdf2-sha256", "iterations": 120000, "salt": "<base64>" },
  "cipher": "aes-256-gcm",
  "iv": "<base64>",
  "ciphertext": "<base64>",
  "tag": "<base64>"
}
```

---

## 7. L4 — Automatic backup to the user's own cloud

The only layer that survives a lost, stolen, or dead device. Because the artifact is already
an opaque encrypted blob, we do not need a backend or an account system — we need somewhere
off-device to put the file.

Three approaches, cheapest first:

**a. Share-sheet handoff (no new dependency).** After an export, hand the file to the platform
share sheet; the user picks Drive, iCloud Drive, Files, WhatsApp, email. Zero configuration,
but manual every time. Good as the immediate improvement over "file saved to Downloads".

**b. Cloud-folder placement (Android).** Let the user pick a directory once with
`SAF`/`ACTION_OPEN_DOCUMENT_TREE`, persist the URI permission, and have L2 write `_latest`
there. If they pick a Drive-synced or Dropbox-synced folder, snapshots leave the device with
no further action. iOS has no equivalent grant model; use the iCloud Drive container instead
(`NSUbiquitousContainers` + a document-scoped folder), which is a larger piece of work.

**c. Explicit provider integration (Google Drive `appDataFolder` / iCloud KVS).** Most
reliable, most work: OAuth, quota handling, conflict resolution, and a Google Cloud project.
Use Drive's hidden `appDataFolder` so backups don't clutter the user's Drive and are scoped
to the app. Only pursue this if backup reliability becomes a product differentiator.

Recommendation: ship (a) now, (b) for Android behind a settings toggle, defer (c).

Whatever the transport, the file leaving the device must be encrypted with a passphrase or
recovery-phrase-derived key (§6.4). Uploading a device-master-key-encrypted file to cloud
storage produces a backup that cannot be restored — worse than no backup, because the user
believes they are covered.

---

## 8. L5 — Making it visible: backup health, restore, and PIN recovery

Backups that users don't know about don't get used. Three UI surfaces.

### 8.1 Backup health in Settings

Replace the current fire-and-forget export tiles with a status block that states the truth:

- `Last backup: 2 hours ago · 348 transactions` (green), or
- `Last backup: 12 days ago` (amber), or
- `No backup yet — your data exists only on this device` (red), with a primary CTA.

Source from `PreferenceService` (`last_snapshot_at`, `last_snapshot_count`,
`last_snapshot_error`). Amounts and timestamps use the mono typography tokens per CLAUDE.md §7;
all copy through `context.l10n`.

### 8.2 First-launch restore detection

On a fresh install, before onboarding, check for a restorable artifact:

1. Does `Download/Expendly/snapshots/expendly_auto_latest.expendly` exist? (Android post-uninstall
   or post-"Clear data" — the common case.)
2. Did Auto Backup restore `expendly.sqlite` with rows but leave secure storage empty?
   (`db has transactions && secureStorage.getSecurityPin() == null`)
3. Otherwise offer "Restore from file" in onboarding, not buried in Settings.

Case 2 needs explicit handling or the app is unusable after an OS restore: the data is there
but the PIN gate has no PIN and the master key is gone. Correct behaviour is to treat it as
"restored device" — generate a fresh master key, keep the data, and walk the user through
setting a new PIN. Never wipe the DB because the keychain is empty, and never lock the user
out of their own restored data.

Concretely, in bootstrap:

```dart
// Data survived but device-bound secrets did not: OS-level restore or keychain purge.
final hasData = await db.hasAnyTransactions();
final hasPin  = await secureStorage.getSecurityPin() != null;
if (hasData && !hasPin) {
  await preferenceService.setPendingRestoreSetup(true); // route to PIN re-setup
}
```

### 8.3 Restore flow requirements

- Show what is in the backup before applying it: export date, transaction count, date range.
- Require explicit confirmation for **Replace**, wording the destruction plainly.
- Take a pre-restore snapshot of the current DB first, so a bad restore is undoable.
- Wrap the whole restore in one drift transaction (already done) and verify with
  `integrityCheck()` afterwards.
- On failure, leave the existing data untouched and show a localized error — never a
  half-imported DB.

### 8.4 Prompt at the right moment

Ask once, when the data is worth protecting: after the 10th transaction, or 7 days of use.
"Your data lives only on this device. Set up automatic backups?" Do not ask during onboarding
when the user has nothing to lose and no reason to care.

---

## 9. Rules to follow when changing data code

Binding for anything under `lib/core/database/` and `lib/core/services/`:

1. **Every new table or column ships with its export/import mapping in the same change.**
   A table in `@DriftDatabase` that is absent from `exportEncryptedData` is a data-loss bug,
   not a backlog item.
2. **Every schema change bumps `schemaVersion` and adds a new `onUpgrade` branch.** Never edit
   an existing branch — users are mid-migration-chain on real devices.
3. **Bump the payload `version` on any backup format change**, and keep a read path for every
   previously shipped version. Users restore year-old backups.
4. **Never put anything device-bound in the critical path of decrypting a backup.** Keystore
   keys, keychain items, and device IDs do not survive the events backups protect against.
5. **Backups are written atomically** (`.tmp` + rename) and after
   `PRAGMA wal_checkpoint(TRUNCATE)` if the raw DB file is being copied.
6. **`SecureStorageService` is never the only copy of data the user cannot recreate.** It is a
   cache for secrets, not storage for records.
7. **No `try/catch` that swallows a backup failure without recording it** where the backup-health
   UI can see it.
8. Round-trip tests are mandatory: any change to export or import ships with a test that seeds
   a DB, exports, wipes, imports, and asserts full equality — see §10.

---

## 10. Verification checklist

Automated (`test/core/services/`):

- [ ] Round-trip: seed all 9 tables → export → `AppDatabase.forTesting(NativeDatabase.memory())`
      fresh → import → assert row-for-row equality including cents.
- [ ] Import rejects a tampered ciphertext (GCM tag failure), a wrong passphrase, a truncated
      file, and a payload with an unknown `version`.
- [ ] Import with a v1 payload still works after the v2 format lands.
- [ ] Merge mode does not duplicate rows when importing the same backup twice (idempotent).
- [ ] Migration chain: open a v1-schema fixture DB and migrate to current, asserting no data loss
      at each step.
- [ ] Snapshot rotation keeps exactly N files and always leaves `_latest` valid.

Manual, per platform, before any release that touches this code:

- [ ] **Android "Clear storage"** → relaunch → restore prompt appears and recovers the data.
- [ ] **Android uninstall → reinstall** → `Download/Expendly/snapshots/` survived and restore works.
- [ ] **Android Auto Backup:** `adb shell bmgr backupnow com.expendly.app`, uninstall, reinstall,
      `adb shell bmgr restore <token>` → data present, PIN re-setup prompted, no crash.
- [ ] **Android device-to-device** transfer path (or `data_extraction_rules` inspection at minimum).
- [ ] **iOS:** export → open Files app → the `.expendly` file is visible in `Expendly/` and can be
      copied to iCloud Drive; reinstall and restore from it.
- [ ] **iOS device backup restore** to the same Apple ID → data and PIN intact.
- [ ] Restore a backup made with a passphrase **on a different device** — this is the test that
      catches §6.4 regressions, and the one most likely to be skipped.
- [ ] App update over an existing install (`flutter build` + install same signature) → no data loss,
      no migration error.

Then, per CLAUDE.md §15:

```
flutter analyze
flutter test
```

---

## 11. Implementation order

1. §4 Android backup rules + iOS confirmation. Half a day, immediate benefit, no UI.
2. §6.1 complete the export payload (all 9 tables). Everything else is worthless without it.
3. §6.4 passphrase/recovery-phrase key derivation + PBKDF2 + AES-GCM, payload v2. This is the
   correctness fix that makes backups actually restorable.
4. §8.2 first-launch restore detection and the "data without PIN" path.
5. §5 `AutoBackupService` with rotation and debounce.
6. §8.1 backup-health UI and §8.4 the prompt.
7. §6.3 merge mode and version validation.
8. §7 share-sheet handoff, then Android SAF folder.

Items 1–4 close the actual data-loss holes. 5–8 reduce how often a user has to think about it.
