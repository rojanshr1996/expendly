# Rapid Expense Capture & Smart Defaults: Implementation Plan

## 1. Overview and Objective
This document outlines the phase-wise implementation plan to introduce **Rapid Expense Capture and Smart Defaults** into Expendly. The goal is to make recording expenses significantly faster by inferring default values and keeping the user's focus on the amount field. 

**Crucially**, this feature is an *addition*, not a replacement. The old behavior (full detailed transaction entry via `modern_add_transaction_page.dart`) will remain completely intact and readily accessible, ensuring complex transactions can still be recorded without disruption.

---

## 2. Impact Analysis
### Affected Areas
1. **Dashboard & Navigation (`dashboard_page.dart`):** We will add a new entry point for `QuickAddTransactionPage`. This could be achieved by introducing an expandable FAB (Speed Dial) or a long-press action on the existing FAB, so users can choose between "Quick Add" and "Detailed Add" (`ModernAddTransactionRoute`).
2. **Transaction Data & Domain Layer:** We will introduce new repositories/usecases (or extend existing ones) to query recent transactions and manage smart defaults locally (e.g., SharedPreferences or a local database table).
3. **Currency Pages (`currency_setup_page.dart` & `currency_selection_modal.dart`):** When the global or account currency is changed, the Rapid Entry/Quick Add smart defaults must be evaluated. Incompatible "recent" transactions shouldn't blindly carry over old currency values. We will add logic to clear or convert `lastUsedAccountId` or `recentTransactionIds` in the Quick Entry preferences when a major currency shift occurs.
4. **Routing (`app_router.dart`):** New routes will be introduced for `QuickAddTransactionPage`, `RapidEntryPage`, and `DailyEntryPage`.

### Unaffected Areas (Safe - Old Behavior Preserved)
1. **Existing Full Entry Flow:** `modern_add_transaction_page.dart` remains fully functional and will still be accessible as the primary complex-entry flow. The "More Details" button in Quick Add will also route directly to this page.
2. **Core Database Models:** The core `Transaction` entity will remain unchanged to prevent backward compatibility issues. 
3. **Budgets, Reports & History:** Because the transaction schema doesn't change, these modules will not break.

---

## 3. Phase-Wise Implementation Plan

### Phase 1: Transaction Capture Foundation & Smart Defaults
**Goal:** Prepare the data layer to support quick entry preferences and recent transactions.

*   **1.1 Local Preferences Storage:** Create `lib/core/preferences/quick_entry_preferences.dart` to store and retrieve Smart Defaults (e.g., `lastUsedAccountId`, `lastUsedCategoryId`, `lastDailyEntryDate`) using SharedPreferences.
*   **1.2 Domain Use Cases:**
    *   `GetRecentExpensesUseCase`: Retrieve the most recent X transactions.
    *   `GetQuickEntryDefaultsUseCase`: Resolve defaults based on the hierarchy (Explicit > Current Session > Contextual > Recent > Default).
    *   `UpdateQuickEntryDefaultsUseCase`: Update learned preferences after a save.
*   **1.3 Currency Page Integration:** Modify the logic inside `currency_selection_modal.dart` and `currency_setup_page.dart`. When a user updates the active currency, trigger an event to `QuickEntryPreferences` to flush or update `lastRapidEntryAccountId` and prevent recent expenses from loading with mismatched currency symbols.
*   **1.4 Shared UI Components:** Create a reusable amount-focused keypad widget in `lib/features/transactions/presentation/widgets/`.

### Phase 2: Quick Add Screen & Preserving Old Flow
**Goal:** Provide a 1-tap entry experience while keeping the detailed entry flow accessible.

*   **2.1 Dashboard Integration (`dashboard_page.dart`):** Update the FAB to a Speed Dial or add a secondary button.
    *   Action 1: "Quick Add" -> routes to `QuickAddTransactionRoute`.
    *   Action 2: "Detailed Transaction" -> routes to `ModernAddTransactionRoute` (preserving old behavior).
*   **2.2 UI Creation (`lib/features/transactions/presentation/pages/quick_add_page.dart`):**
    *   Design a minimal sheet or page focused entirely on the amount field.
    *   Buttons: `Save`, `Add Another` (enters Rapid Entry), `More Details` (navigates to `modern_add_transaction_page.dart` with pre-filled amount).
*   **2.3 Logic (`QuickAddCubit`):**
    *   Pre-fill Date (Today), Account, and Category based on Smart Defaults. Automatically focus the amount field.
    *   Ensure the displayed currency symbol correctly matches the app's current global currency.

### Phase 3: Rapid Entry Mode
**Goal:** Allow continuous entry of multiple expenses without leaving the screen.

*   **3.1 UI Creation (`lib/features/transactions/presentation/pages/rapid_entry_page.dart`):**
    *   Create a session view displaying a running list of entered transactions.
    *   Amount field remains persistently focused.
    *   Include a fast category selector (horizontal scrolling list).
*   **3.2 Logic (`RapidEntryCubit`):**
    *   Maintain a session state (list of unsaved/saved transactions, running total).
    *   When user hits "Save", add to session list, commit to DB, retain the current category (unless changed), and reset the amount field.
*   **3.3 Editing/Undo:** Allow tapping a session transaction to inline-edit. Implement an "Undo" snackbar for the last action.

### Phase 4: Daily Entry / Batch Mode
**Goal:** Optimized workflow for entering end-of-day expenses grouped by a specific date.

*   **4.1 UI Creation (`lib/features/transactions/presentation/pages/daily_entry_page.dart`):**
    *   Add a Date Picker header (Defaults to Today).
    *   List existing transactions for that date.
*   **4.2 Logic:**
    *   Override the "Today" smart default with the selected daily date.
    *   Changes to the date only affect new entries, not already saved ones.
*   **4.3 Integration:** Add an entry point in the Transactions tab for "Daily Entry".

### Phase 5: Recent & Repeat Expenses
**Goal:** One-tap duplication of common transactions.

*   **5.1 UI Addition:** Embed a "Recent" section at the bottom of the `QuickAddPage`.
*   **5.2 Interaction & Currency Safety:**
    *   Tapping a recent expense loads its category, account, and amount.
    *   **Currency Check:** If the recent transaction's currency differs from the active currency (due to a change in settings), do NOT blind-copy the currency. Instead, apply the active currency or alert the user.
*   **5.3 Safety:** Ensure `RepeatExpense` generates a *new* unique transaction ID.

### Phase 6: Optimization & Polish
**Goal:** Ensure the UX feels instant and performant.

*   **6.1 Performance Tuning:** Audit SQLite transactions to ensure Rapid Entry saves don't cause UI stutter.
*   **6.2 Testing:** Write widget tests for `QuickAddPage` and unit tests for the Smart Defaults resolution and Currency fallback logic.

---

## 4. Execution Rules & Guidelines
1. **Old Behavior is Default/Primary:** `modern_add_transaction_page.dart` must not be replaced. Both flows (`ModernAdd` and `QuickAdd`) must co-exist in the UI and routing.
2. **Strict Currency Handling:** Any changes made in the currency pages must automatically invalidate incompatible smart defaults. Never save a transaction with an inconsistent currency symbol/code.
3. **No Data Loss:** Rapid Entry sessions must cleanly handle app backgrounding. Already-saved transactions within a session must be persisted immediately.
4. **Offline First:** Smart Defaults must be calculated purely locally without any external API dependencies.
