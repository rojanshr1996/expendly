# Expendly — Rapid Expense Capture & Smart Defaults
## Feature Requirements Specification

**Document Type:** Product & UX Feature Requirements  
**Application:** Expendly  
**Platform:** Flutter Mobile Application  
**Primary Goal:** Make daily expense recording significantly faster by making **Rapid Entry + Smart Defaults** the core transaction-capture experience.

---

## 1. Overview

Expendly currently requires users to manually create each transaction individually. This can become tedious when users have several expenses to record throughout the day or enter all expenses at the end of the day.

This feature introduces a faster expense-capture system centered around:

1. **Quick Add / One-Tap Recording**
2. **Rapid Entry Mode**
3. **Daily Entry / Batch Expense Entry**
4. **Repeat Expense from Recent Transactions**
5. **Smart Defaults**

The goal is not simply to reduce the number of taps in the existing transaction form. The goal is to create a dedicated **expense capture workflow** optimized for speed while preserving the existing detailed transaction model.

### Core UX principle

> **Don't make users fill out transactions. Let them capture expenses.**

The app should automatically handle information that can be inferred or remembered and expose advanced details only when necessary.

---

# 2. Product Goals

## 2.1 Primary Goals

- Reduce the time required to record a single expense.
- Make recording multiple expenses in succession extremely fast.
- Allow users to record several expenses without repeatedly opening and closing forms.
- Automatically remember frequently used transaction values.
- Minimize unnecessary taps and fields.
- Preserve full transaction details and data integrity.
- Maintain Expendly's offline-first and privacy-first architecture.
- Make the new workflow compatible with existing transaction history, reports, budgets, accounts, and categories.

## 2.2 Success Criteria

The implementation should aim for:

- A common expense can be recorded in **2–3 primary interactions**.
- A sequence of 5 expenses can be recorded without returning to the dashboard.
- The amount input remains the primary focus during Rapid Entry.
- Users should not have to repeatedly select today's date.
- Users should not have to repeatedly select the same account.
- Users should not have to repeatedly select the same category when context makes it predictable.
- Existing detailed transaction entry must remain available.
- No financial data should leave the device as part of this feature.

---

# 3. Scope

## 3.1 Included

### Quick Add
- Floating Quick Add action.
- Minimal expense-entry interface.
- Amount-first workflow.
- Smart category/account defaults.
- Save and Save & Add Another actions.

### Rapid Entry
- Continuous transaction entry.
- Persistent amount input.
- Automatic defaults between transactions.
- Fast category selection.
- Save without leaving Rapid Entry.
- Running list of transactions entered during the session.
- Edit/remove before finalizing where appropriate.

### Daily Entry
- Batch entry for multiple expenses.
- Date-focused expense capture.
- Add several expenses in one session.
- Review before committing.
- Bulk save.
- Support for expenses entered after the fact.

### Repeat Expense
- Repeat recent transactions.
- Repeat frequently used transactions.
- One-tap duplicate.
- Allow amount/date modification before saving when needed.

### Smart Defaults
- Remember recently used account.
- Suggest recently/frequently used category.
- Default date to today.
- Default transaction type to expense.
- Remember relevant input preferences.
- Apply defaults intelligently without preventing manual override.

---

# 4. Out of Scope

The following are not required as part of this feature:

- Cloud synchronization.
- AI-based expense classification.
- Bank transaction import.
- SMS parsing.
- Receipt OCR.
- Voice expense entry.
- Automatic bank integration.
- Automatic recurring transaction generation.

These may be considered separately in future versions.

---

# 5. UX Strategy

The feature should use a layered interaction model.

## Layer 1 — Fastest path

For ordinary expenses:

**Quick Add → Amount → Save**

The app supplies:

- Date
- Account
- Category
- Currency
- Transaction type

using smart defaults.

## Layer 2 — Rapid Entry

For multiple expenses:

**Rapid Entry → Amount → Category → Save → Amount → Category → Save**

The user remains in the same screen.

## Layer 3 — Daily Entry

For users who prefer entering expenses in batches:

**Daily Entry → Add multiple expenses → Review → Save All**

## Layer 4 — Full Transaction

For unusual or complex transactions:

**Quick Add → More Details → Full transaction form**

The existing detailed transaction workflow should remain accessible.

---

# 6. Feature 1 — Quick Add / One-Tap Recording

## 6.1 Purpose

Provide the fastest possible method for recording a normal expense.

The Quick Add action should be available from the primary dashboard and other appropriate transaction-focused screens.

## 6.2 Entry Point

Use the existing primary floating action button or equivalent primary action.

Recommended behavior:

**Tap + → Quick Expense Entry**

Do not open the existing full transaction form by default.

---

## 6.3 Quick Expense UI

Recommended structure:

```text
┌─────────────────────────────┐
│        Add Expense          │
│                             │
│          ₹ 350              │
│                             │
│       🍔 Food               │
│       Today · Cash          │
│                             │
│   [Save] [Add Another]      │
│                             │
│       More Details          │
└─────────────────────────────┘
```

The amount should receive focus immediately.

## 6.4 Required User Input

The minimum required user input should normally be:

- Amount

Category may be automatically selected or suggested.

## 6.5 Automatically Determined Values

The system should automatically determine:

- Transaction type = Expense
- Date = Today
- Account = Smart default
- Category = Smart default/suggestion
- Currency = Active account/app currency

## 6.6 Save Behavior

When the user taps **Save**:

1. Validate amount.
2. Apply smart defaults.
3. Create transaction.
4. Persist transaction locally.
5. Update relevant state.
6. Close Quick Add.
7. Return to previous screen.
8. Show lightweight confirmation.

The confirmation must not interrupt the workflow unnecessarily.

---

# 7. Feature 2 — Rapid Entry Mode

## 7.1 Purpose

Rapid Entry is the **centerpiece of this feature set**.

It is designed specifically for users who need to enter multiple expenses quickly.

Examples:

- Entering all expenses at night.
- Entering expenses after a shopping trip.
- Entering several small cash transactions.
- Recording a day's transactions.
- Migrating historical transactions.

---

## 7.2 Entry Points

Rapid Entry should be accessible through:

- Quick Add → Add Another
- Quick Add → Rapid Entry
- Dashboard → Rapid Entry
- Daily Entry → Continue in Rapid Entry

The exact navigation should follow Expendly's existing architecture and navigation patterns.

---

## 7.3 Rapid Entry Principles

Rapid Entry must:

- Keep the user on one screen.
- Keep the amount field immediately accessible.
- Avoid repeated navigation.
- Reuse smart defaults.
- Remember the last selected category.
- Remember the last selected account.
- Allow fast category changes.
- Allow the user to continue indefinitely.
- Provide immediate confirmation after each saved item.
- Prevent accidental loss of entered transactions.

---

## 7.4 Recommended UI

```text
┌─────────────────────────────┐
│ ← Rapid Entry          ✓    │
├─────────────────────────────┤
│                             │
│ Today                       │
│ 4 expenses · ₹1,240         │
│                             │
│ ┌─────────────────────────┐ │
│ │ ₹350                    │ │
│ │ 🍔 Food          ✓      │ │
│ └─────────────────────────┘ │
│                             │
│ ┌─────────────────────────┐ │
│ │ ₹120                    │ │
│ │ ☕ Coffee        ✓      │ │
│ └─────────────────────────┘ │
│                             │
├─────────────────────────────┤
│                             │
│        ₹ ______             │
│                             │
│  Food   Transport   Other   │
│                             │
│ [Save]      [More]          │
└─────────────────────────────┘
```

The exact visual implementation should follow the existing Expendly design system.

---

# 8. Rapid Entry Interaction Flow

## 8.1 Initial Entry

1. User opens Rapid Entry.
2. Amount field receives focus.
3. Keyboard/numeric keypad opens if appropriate.
4. Smart defaults are loaded.
5. User enters amount.
6. Category is suggested.
7. User taps Save.

## 8.2 After Save

Immediately after saving:

1. Transaction is persisted.
2. Transaction appears in the session list.
3. Running total updates.
4. Amount field resets.
5. Keyboard remains available.
6. Smart defaults remain active.
7. User can enter the next expense.

The user should **not** be returned to the dashboard.

---

# 9. Rapid Entry Category Behavior

Category selection must be optimized for speed.

Recommended priority:

1. Current smart category.
2. Recent categories.
3. Frequently used categories.
4. Full category picker.

Example:

```text
Food    Transport    Shopping    Bills
```

If the current category is correct, the user does nothing.

If incorrect, the user changes it with one tap.

---

# 10. Rapid Entry Account Behavior

The account should default to the most appropriate account based on the user's previous behavior.

Example:

```text
Cash
```

If the user normally records a sequence of cash expenses, the next transaction should continue using Cash.

The user must always be able to override the account.

Account selection should not occupy primary visual space unless the user needs to change it.

---

# 11. Rapid Entry Session State

The system should maintain a temporary Rapid Entry session.

Session information may include:

- Session start time.
- Target date.
- Number of transactions.
- Total amount.
- Current account.
- Current category.
- Pending edits.
- Saved transaction IDs.

Example:

```text
Rapid Entry
8 expenses
Total: ₹2,840
```

The session should be resilient against accidental navigation where possible.

---

# 12. Rapid Entry Exit Behavior

When leaving Rapid Entry, the app should distinguish between:

### No unsaved data

Exit immediately.

### Unsaved input exists

Show a confirmation:

> You have an unsaved expense. Leave without saving?

Options:

- Continue Editing
- Save
- Discard

### Already saved transactions

Do not ask the user to confirm merely because the session contains previously saved transactions.

Those transactions are already persisted.

---

# 13. Rapid Entry Editing

Recently added transactions should be editable directly from the session list.

Example:

```text
₹350 · Food
₹120 · Transport
₹800 · Shopping
```

Tap an item → edit.

Supported edits:

- Amount
- Category
- Account
- Date
- Notes
- Other existing transaction fields

The edit experience should reuse the existing transaction editor where practical.

---

# 14. Rapid Entry Delete

Each session transaction may support:

- Swipe to delete.
- Long press.
- More menu.

Deletion should follow the existing Expendly deletion and undo behavior.

If Expendly has an undo mechanism, use it consistently.

---

# 15. Feature 4 — Daily Entry / Batch Expense Entry

## 15.1 Purpose

Daily Entry is intended for users who do not record expenses immediately.

Instead of requiring them to reconstruct the day through repeated navigation, provide a dedicated batch-entry workflow.

---

## 15.2 Entry Point

Possible entry points:

- Dashboard → Daily Entry
- Quick Add → Daily Entry
- Transactions → Daily Entry

The user should be able to select the date before entering expenses.

---

# 16. Daily Entry UI

Recommended structure:

```text
┌─────────────────────────────┐
│ ← Daily Entry               │
│                             │
│ Sunday, Aug 23              │
│ 5 expenses · ₹1,840         │
│                             │
│ Lunch          ₹350         │
│ Bus             ₹40         │
│ Coffee          ₹90         │
│ Groceries      ₹850         │
│ Movie          ₹510         │
│                             │
│ [+ Add Expense]             │
│                             │
│       [Save All]            │
└─────────────────────────────┘
```

---

# 17. Daily Entry Workflow

1. User selects a date.
2. Existing expenses for that date may be displayed.
3. User starts adding expenses.
4. Each expense uses smart defaults.
5. New expenses appear in the daily list.
6. User can edit or delete entries.
7. Running total updates.
8. User finishes the session.

If transactions are persisted immediately, **Save All** should be interpreted as finishing the session/reviewing rather than delaying database persistence.

---

# 18. Daily Entry Date Handling

The date should be explicit.

Default:

**Today**

User may select:

- Yesterday
- Previous dates
- Calendar date

Changing the date should update the default transaction date for subsequently created entries.

Do not silently change already-created transactions when the date is changed.

---

# 19. Daily Entry and Rapid Entry Relationship

These should share the same underlying transaction-entry engine.

Conceptually:

```text
              Transaction Capture Engine
                         │
             ┌───────────┴───────────┐
             │                       │
        Rapid Entry              Daily Entry
             │                       │
      Continuous capture       Date-focused capture
```

Do not implement two independent transaction systems.

Both should reuse:

- Smart Defaults
- Validation
- Category selection
- Account selection
- Transaction repository
- Transaction creation use case
- UI components
- State management

---

# 20. Feature 7 — Repeat Recent Expense

## 20.1 Purpose

Allow users to quickly record an expense similar to one they have already entered.

Examples:

- Coffee every morning.
- Daily bus fare.
- Lunch.
- Parking.
- Regular grocery purchases.

---

# 21. Recent Expense UI

A Quick Add screen may display:

```text
Recent

☕ Coffee        ₹120
🍔 Lunch         ₹350
🚌 Bus            ₹40
🛒 Groceries     ₹850
```

Tapping an item should create a new transaction using its values.

---

# 22. Repeat Behavior

When repeating a transaction:

### Copy

- Category
- Account
- Currency
- Transaction type
- Relevant tags
- Optional recurring metadata where appropriate

### Update automatically

- Date → current selected date
- Created timestamp → now

### Amount

The amount should normally be copied.

However, the user should have an easy way to modify it before saving.

Recommended behavior:

**Tap recent expense → amount focused**

Example:

```text
Coffee
₹ 120

[Save]
```

The amount can immediately be replaced.

---

# 23. Frequent vs Recent Expenses

These are different concepts.

### Recent

Transactions ordered by recent usage.

### Frequent

Transactions that appear repeatedly over time.

A future implementation may calculate frequency using local transaction history.

Example:

```text
Quick Add

Frequent
☕ Coffee       ₹120
🚌 Bus           ₹40
🍔 Lunch        ₹350

Recent
🛒 Groceries    ₹850
🎬 Movie        ₹500
```

The initial version may implement Recent first and add Frequency after reliable usage data is available.

---

# 24. Repeat Transaction Safety

Repeating an expense must always create a **new transaction**.

It must never mutate the original transaction.

For example:

Original:

```text
Aug 22 · Coffee · ₹120
```

Repeat:

```text
Aug 23 · Coffee · ₹120
```

The two transactions must have different IDs.

---

# 25. Smart Defaults

## 25.1 Purpose

Smart Defaults are the mechanism that makes Rapid Entry genuinely fast.

The user should configure values once and then benefit from them repeatedly.

---

# 26. Default Priority Model

Smart Defaults should follow a clear precedence hierarchy.

Recommended priority:

```text
Explicit user selection
        ↓
Current Rapid Entry selection
        ↓
Contextual/date-specific preference
        ↓
Recent value
        ↓
Frequently used value
        ↓
Account/app default
        ↓
System fallback
```

Explicit user choices must always override automatic defaults.

---

# 27. Default Date

For normal Quick Add:

**Today**

For Daily Entry:

**Selected date**

For Rapid Entry:

**Current session date**

If the user changes the date during a session, the new date becomes the default for subsequent transactions.

Existing transactions remain unchanged.

---

# 28. Default Account

Account selection should follow:

1. User explicitly selected account.
2. Account selected earlier in current Rapid Entry session.
3. Recently used account.
4. Default account configured by user.
5. First valid active account.

Example:

If the user records:

```text
Cash → Food → ₹200
Cash → Transport → ₹50
Cash → Coffee → ₹120
```

the next transaction should default to:

**Cash**

without requiring another selection.

---

# 29. Default Category

Category suggestions should follow:

1. Explicitly selected category.
2. Current Rapid Entry category.
3. Recently used category.
4. Frequently used category.
5. User's configured default category.
6. No category if confidence is insufficient.

Do not aggressively guess categories if the system cannot make a reasonable determination.

A wrong default can be more frustrating than requiring one extra tap.

---

# 30. Category Continuation in Rapid Entry

A particularly important optimization:

After saving:

```text
₹350 · Food
```

the next entry should retain:

```text
Food
```

until the user changes it.

This is useful when entering several expenses from the same category.

Example:

```text
₹150 · Food
₹250 · Food
₹320 · Food
```

The user only changes the amount.

---

# 31. Smart Default Visibility

Defaults should be visible but not intrusive.

Example:

```text
₹ _______

Food · Cash · Today
```

The user should be able to understand what will be saved.

Avoid hiding critical values completely.

---

# 32. Smart Default Override

Every default must be manually changeable.

The user must never be locked into:

- Category
- Account
- Date
- Currency
- Other transaction metadata

A default is a suggestion, not a permanent value.

---

# 33. Learning Behavior

The first implementation should avoid complex machine learning.

Use deterministic local behavior.

Examples:

- Last used account.
- Last used category.
- Most frequently used category.
- Most frequently used account.
- Most recent transaction.

This is:

- Fast.
- Offline.
- Predictable.
- Easy to test.
- Privacy-preserving.
- Easy to debug.

---

# 34. Smart Default Storage

Smart-default preferences should be stored locally.

Possible stored values:

```text
lastUsedAccountId
lastUsedExpenseCategoryId
lastRapidEntryAccountId
lastRapidEntryCategoryId
lastDailyEntryDate
recentTransactionIds
```

Do not duplicate transaction data unnecessarily.

Where possible, derive recent/frequent information from the transaction repository.

---

# 35. Default Reset

Users should be able to reset smart defaults if necessary.

Potential setting:

**Reset Quick Entry Preferences**

This should clear learned preferences without deleting transaction data.

---

# 36. Quick Add vs Full Add

The application should clearly distinguish the two experiences.

### Quick Add

Optimized for:

- Speed
- Common transactions
- Minimal information
- Repeated use

### Full Add

Optimized for:

- Complex transactions
- Detailed records
- Unusual cases
- Advanced metadata

Recommended navigation:

```text
Quick Add
   │
   ├── Save
   │
   ├── Add Another
   │
   ├── Rapid Entry
   │
   └── More Details
             │
             ▼
      Full Transaction
```

---

# 37. Data Model Requirements

The feature should reuse the existing transaction entity wherever possible.

Do not introduce a separate transaction model for Rapid Entry.

The transaction record should continue to support the existing Expendly requirements.

Additional optional metadata may be introduced for:

- Capture source
- Rapid Entry session ID

These fields should only be added if they provide real product or analytics value.

Because Expendly is privacy-first, analytics-oriented metadata should not be introduced merely for telemetry.

---

# 38. Transaction Capture Source

If useful for internal behavior and debugging, transactions may optionally identify their capture source:

```text
quick_add
rapid_entry
daily_entry
repeat_expense
full_entry
```

This should be considered an internal/local field and should not be sent to external services.

---

# 39. Architecture Requirements

The implementation must follow Expendly's existing clean architecture.

Recommended separation:

```text
Presentation
    ↓
State Management
    ↓
Use Cases
    ↓
Repositories
    ↓
Local Database
```

The UI must not directly manipulate database tables.

---

# 40. Suggested Use Cases

The implementation may introduce/reuse use cases such as:

```text
CreateExpense
CreateExpensesBatch
GetRecentExpenses
GetFrequentExpensePatterns
GetQuickEntryDefaults
UpdateQuickEntryDefaults
RepeatExpense
UpdateExpense
DeleteExpense
```

Names should follow the project's existing naming conventions.

Do not create duplicate use cases if equivalent functionality already exists.

---

# 41. State Management

Rapid Entry should have dedicated presentation state rather than relying on scattered widget-local state.

State may include:

```text
selectedDate
selectedAccount
selectedCategory
amount
enteredTransactions
sessionTotal
sessionCount
isSaving
validationError
unsavedAmount
```

The exact state model must follow the existing Expendly BLoC/Cubit architecture.

---

# 42. Database Transactions

Each saved expense must be persisted reliably.

For Daily Entry or batch operations, use a database transaction when multiple records must be committed atomically.

Expected behavior:

- Either all requested records are created successfully.
- Or the operation fails safely without leaving a partially committed batch where atomicity is required.

The implementation must follow the capabilities of the existing Drift/SQLite layer.

---

# 43. Validation

Rapid Entry must preserve all existing transaction validation rules.

Minimum:

- Amount must be valid.
- Amount must be greater than zero unless the existing model explicitly permits another behavior.
- Account must exist and be active.
- Category must exist and be valid where required.
- Date must be valid.
- Currency must be compatible with the account/model.

Validation errors must be concise and actionable.

Do not display large form-level error messages for simple amount-entry mistakes.

---

# 44. Performance Requirements

Rapid Entry is a high-frequency workflow.

The implementation must avoid:

- Unnecessary database reloads.
- Full dashboard rebuilds after every transaction.
- Recreating expensive dependency graphs.
- Unnecessary animations.
- Blocking UI operations.
- Repeated database queries for the same default.

After saving an expense, the next amount should be ready immediately.

---

# 45. Keyboard and Focus Behavior

When Rapid Entry starts:

- Amount input should receive focus.
- Numeric keyboard should be used where appropriate.
- After saving, amount input should regain focus.
- Keyboard should remain open.

The user should not need to tap the amount field for every transaction.

If the user dismisses the keyboard manually, do not force it open repeatedly.

---

# 46. Accessibility

The feature must support:

- Screen readers.
- Adequate touch targets.
- Clear semantic labels.
- Sufficient text contrast.
- Dynamic text scaling where supported.
- Non-color-only feedback.
- Predictable focus order.

The Quick Add and Save actions must remain easy to identify.

---

# 47. Error Handling

If saving fails:

1. Keep the entered amount.
2. Keep selected category/account.
3. Do not silently discard the transaction.
4. Show a concise error.
5. Allow retry.

Example:

> Couldn't save expense. Try again.

Do not reset the form after a failed save.

---

# 48. Accidental Duplicate Prevention

Rapid Entry must not create duplicate transactions because of:

- Double taps.
- Slow database responses.
- Repeated button presses.
- UI rebuilds.

The Save action should have a short-lived submitting state.

Once the transaction is successfully saved:

- Clear the current amount.
- Enable the next entry.
- Prevent duplicate submission of the same input.

---

# 49. Undo

Where compatible with Expendly's existing design, newly saved expenses should support a short undo action.

Example:

> Expense added · ₹350  
> **Undo**

Undo should delete/revert only the newly created transaction.

It must not interfere with other transactions entered during Rapid Entry.

---

# 50. Empty States

Rapid Entry:

```text
No expenses yet.

Enter your first expense below.
```

Recent:

```text
No recent expenses yet.

Your recent expenses will appear here
after you start recording transactions.
```

Daily Entry:

```text
No expenses recorded for this date.

Add your first expense below.
```

---

# 51. UX Microcopy

Keep text short and action-oriented.

Recommended labels:

- Quick Add
- Rapid Entry
- Daily Entry
- Add Another
- Save
- Save All
- Repeat
- Recent
- More Details
- Undo
- Edit
- Delete
- Change Category
- Change Account

Avoid verbose instructions inside the transaction flow.

---

# 52. Recommended Navigation

The preferred user journey is:

```text
Dashboard
   │
   └── [+]
        │
        ├── Quick Add
        │     │
        │     ├── Save
        │     ├── Add Another
        │     └── More Details
        │
        ├── Rapid Entry
        │
        └── Daily Entry
```

Recent/repeat expenses should be accessible from Quick Add and Rapid Entry without creating a separate complicated navigation hierarchy.

---

# 53. Example User Scenarios

## Scenario A — Single Expense

User buys coffee for ₹120.

Flow:

```text
Tap +
→ ₹120
→ Food/Coffee already suggested
→ Save
```

Target: minimal interaction.

---

## Scenario B — Five Expenses

User records:

```text
Lunch       ₹350
Bus          ₹40
Coffee       ₹90
Groceries   ₹850
Movie       ₹500
```

Flow:

```text
Rapid Entry
→ ₹350 → Save
→ ₹40  → Save
→ ₹90  → Save
→ ₹850 → Save
→ ₹500 → Save
→ Done
```

No repeated navigation.

---

## Scenario C — Same Category

User is entering several food expenses.

```text
Food
₹120 → Save
₹250 → Save
₹180 → Save
₹320 → Save
```

Category remains selected automatically.

---

## Scenario D — Repeat Expense

User regularly spends ₹40 on bus fare.

Flow:

```text
Quick Add
→ Recent: Bus ₹40
→ Tap Bus
→ Save
```

No manual amount/category selection required.

---

## Scenario E — End-of-Day Entry

User wants to enter yesterday's expenses.

Flow:

```text
Daily Entry
→ Select Yesterday
→ Rapid Entry
→ Add expenses
→ Review
→ Done
```

All new entries inherit the selected date.

---

# 54. Edge Cases

The implementation must handle:

### Account deleted/deactivated

If a saved smart default references an unavailable account:

- Ignore it.
- Select another valid account.
- Do not crash.

### Category deleted/deactivated

Same behavior as account.

### No accounts

Show the existing account setup flow.

### No categories

Use the existing category creation/setup behavior.

### Currency changes

Do not blindly copy incompatible currency values.

### Date changes

Only future entries use the new date.

### App backgrounding

Persist already-created transactions immediately.

Unsaved amount should be preserved where feasible.

### App termination

Already-saved transactions must remain safe.

Unsaved input may be restored if the architecture supports it reliably.

---

# 55. Security and Privacy

This feature must preserve Expendly's privacy-first philosophy.

Requirements:

- No financial data should be sent to an external service.
- Smart defaults must be calculated locally.
- Recent transactions must be stored locally.
- No cloud dependency should be introduced.
- No analytics event should contain transaction amounts, descriptions, categories, account names, or other financial details.
- Do not introduce telemetry solely to measure personal spending behavior.

---

# 56. Testing Requirements

## Unit Tests

Test:

- Default account resolution.
- Default category resolution.
- Date resolution.
- Recent transaction retrieval.
- Repeat transaction creation.
- Batch creation.
- Duplicate-save prevention.
- Invalid amount handling.
- Deleted account/category fallback.
- Rapid Entry state transitions.

## Repository Tests

Test:

- Transaction creation.
- Batch transaction creation.
- Repeat transaction creation.
- Transaction updates.
- Transaction deletion.
- Recent transaction queries.
- Frequency queries if implemented.

## Widget Tests

Test:

- Quick Add rendering.
- Amount focus.
- Save action.
- Add Another action.
- Rapid Entry list.
- Category selection.
- Account selection.
- Daily date selection.
- Recent expense selection.
- Error states.

## Integration Tests

Test complete workflows:

1. Quick Add → Save.
2. Quick Add → Add Another.
3. Rapid Entry → 5 transactions.
4. Daily Entry → previous date → multiple transactions.
5. Repeat recent transaction.
6. Edit a Rapid Entry transaction.
7. Delete a Rapid Entry transaction.
8. Failed save → retry.
9. App restart after saved Rapid Entry transactions.

---

# 57. Acceptance Criteria

## Quick Add

- [ ] Quick Add is accessible from the primary dashboard.
- [ ] Amount is the primary input.
- [ ] Amount field receives focus automatically.
- [ ] Date defaults correctly.
- [ ] Account defaults correctly.
- [ ] Category defaults/suggests correctly.
- [ ] Save creates exactly one transaction.
- [ ] Save does not create duplicates.
- [ ] Failed saves preserve entered information.
- [ ] Full transaction details remain accessible.

## Rapid Entry

- [ ] Rapid Entry is accessible from Quick Add.
- [ ] Amount remains the primary input.
- [ ] Keyboard remains available after saving.
- [ ] User can add multiple transactions continuously.
- [ ] Previous category can be retained.
- [ ] Previous account can be retained.
- [ ] Running total updates correctly.
- [ ] Transaction count updates correctly.
- [ ] Transactions are persisted safely.
- [ ] Transactions can be edited.
- [ ] Transactions can be deleted.
- [ ] Exiting with unsaved input is handled safely.
- [ ] Duplicate submissions are prevented.

## Daily Entry

- [ ] User can select a date.
- [ ] Selected date applies to new entries.
- [ ] Existing transactions can be displayed where appropriate.
- [ ] Multiple transactions can be entered without repeated navigation.
- [ ] Running daily total is correct.
- [ ] Batch/review workflow is clear.
- [ ] Existing transactions are not modified accidentally when changing date.

## Repeat Expense

- [ ] Recent transactions are displayed.
- [ ] Tapping a recent expense creates a new transaction workflow.
- [ ] Original transaction is never modified.
- [ ] Date updates to the active entry date.
- [ ] Amount can be changed.
- [ ] Account/category can be changed.
- [ ] Duplicate transaction IDs are never generated.

## Smart Defaults

- [ ] Explicit user choices always override defaults.
- [ ] Defaults are calculated locally.
- [ ] Invalid defaults are safely ignored.
- [ ] Deleted accounts/categories do not cause failures.
- [ ] Defaults remain consistent during Rapid Entry.
- [ ] Users can reset Quick Entry preferences.

---

# 58. Implementation Strategy

Implement incrementally rather than building every feature simultaneously.

## Phase 1 — Transaction Capture Foundation

- Refactor/reuse transaction creation logic.
- Ensure creation is accessible through a single reliable use case.
- Establish smart-default resolver.
- Establish reusable amount-entry component.
- Establish reusable category/account selector components.

## Phase 2 — Quick Add

- Build minimal Quick Add.
- Implement amount-first interaction.
- Implement smart defaults.
- Add Save.
- Add Add Another.

## Phase 3 — Rapid Entry

- Build Rapid Entry state.
- Add continuous transaction creation.
- Add running totals.
- Add session transaction list.
- Add edit/delete.
- Add exit/unsaved handling.

## Phase 4 — Daily Entry

- Add date selection.
- Reuse Rapid Entry capture engine.
- Add daily summary/review.
- Add batch workflow where appropriate.

## Phase 5 — Recent/Repeat

- Add recent transaction retrieval.
- Add Repeat action.
- Add amount editing before save.
- Add frequent transactions only after recent functionality is stable.

## Phase 6 — Optimization

- Measure interaction complexity manually.
- Remove unnecessary taps.
- Improve keyboard/focus behavior.
- Improve animations and transitions.
- Optimize database queries.
- Verify state rebuild performance.

---

# 59. Architecture Principle

The most important implementation decision is:

> **Rapid Entry must be a mode of the existing transaction system, not a separate transaction system.**

There should be one authoritative transaction creation path.

For example:

```text
Quick Add ───────┐
Rapid Entry ─────┤
Daily Entry ─────┼──→ CreateExpenseUseCase
Repeat Expense ──┤
Full Entry ──────┘
                         ↓
                    Repository
                         ↓
                    Drift/SQLite
```

This prevents inconsistent business logic between different entry screens.

---

# 60. Design System Requirements

The new screens must use the existing Expendly design system.

Do not introduce:

- New arbitrary colors.
- New typography styles.
- New button styles.
- New spacing systems.
- New corner-radius conventions.
- New iconography without justification.

The Rapid Entry interface should feel like a natural extension of Expendly rather than a separate mini-application.

---

# 61. Performance Target

The perceived interaction should feel immediate.

After a successful save:

```text
Save
 ↓
Transaction appears
 ↓
Amount resets
 ↓
Next amount ready
```

There should be no unnecessary loading screen between transactions.

Database operations must remain asynchronous without blocking the UI.

---

# 62. Recommended Final Experience

The ideal Expendly experience should be:

### One expense

```text
+ → 350 → Save
```

### Multiple expenses

```text
Rapid Entry
→ 350 → Save
→ 120 → Save
→ 450 → Save
→ 80  → Save
→ Done
```

### Repeated expense

```text
+ → Recent → Coffee ₹120 → Save
```

### End-of-day expenses

```text
Daily Entry
→ Select date
→ Rapid Entry
→ Enter all expenses
→ Done
```

The system should quietly handle:

```text
Date
Account
Category
Currency
Validation
Persistence
Recent values
Defaults
Totals
```

while keeping the user's attention primarily on the **amount**.

---

# 63. Definition of Done

This feature is complete when:

- Quick Add provides a genuinely faster alternative to the existing full transaction form.
- Rapid Entry is the primary high-volume transaction capture workflow.
- Users can enter multiple expenses without leaving the capture screen.
- Smart defaults substantially reduce repeated selections.
- Daily Entry supports efficient end-of-day recording.
- Recent expenses can be repeated quickly.
- All workflows use the same transaction/domain logic.
- Data remains fully offline.
- Existing transactions, reports, budgets, accounts, and categories continue to work correctly.
- Unit, widget, repository, and integration tests cover the new behavior.
- UI follows the existing Expendly design system.
- No duplicate transaction creation occurs from rapid interaction.
- Failed operations do not silently lose user input.
- The implementation has been reviewed for unnecessary complexity and refactored where appropriate.

---

# 64. Core Product Principle

The feature should ultimately make users feel that Expendly is **helping them record expenses rather than asking them to fill out forms**.

The hierarchy should therefore be:

**Amount first → Smart defaults → One-tap save → Continuous capture → Details only when needed.**

Rapid Entry + Smart Defaults should remain the central design principle across all future expense-capture improvements.
