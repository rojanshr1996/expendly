# Expense Sharing (Budget Splitting) — Feature Requirements & Implementation Plan

## 1. Feature Overview

The **Expense Sharing** feature allows users to split expenses with multiple people for various occasions. Users can create events, add participants, track who paid for what, and automatically calculate who owes whom. All data will be stored **locally** using the existing `drift` (SQLite) database approach — no backend data sync required.

### Key Capabilities
- **Event Management**: Create, edit, and delete expense-sharing events.
- **Participant Management**: Add participants by name (and optionally by email).
- **Expense Tracking within Events**: Record individual expenses within an event, specifying who paid and how much.
- **Participant-First Splitting**: Select which participants are involved in each expense before splitting.
- **Dynamic Percentage Splitting**: Assign specific percentages to specific people; the remainder is shared equally among the other selected participants.
- **Email Notifications**: Send breakdown summaries via native `mailto:` links (100% free, no backend).
- **Data Export**: Export event details, expenses, and final settlements as a `.csv` file.

---

## 2. Detailed Requirements

### 2.1 Event Creation & Management
* **Basic Fields**: Event Name, Description.
* **Additional Fields**:
  * **Date/Date Range**: When the event took place.
  * **Category/Type**: Selectable icons — Trip, Dinner, Home, Party (horizontally scrollable chips, as shown in the `new_sharing_event` reference).
  * **Status**: ACTIVE / SETTLED / RECURRING (displayed as a badge on the event card).
* **Actions**: Users must be able to Edit event details or Delete the event entirely (along with all its associated expenses and splits).

### 2.2 Participant Management
* **Adding Participants**: 
  * Require a `Name` (Mandatory).
  * Request an `Email Address` (Optional).
* **Participant State**: Participants exist locally within the scope of a specific event.
* **Owner**: The first participant ("You") is always auto-added as the event owner and cannot be removed.
* **Visual Identity**: Each participant gets a colored circular avatar with their initial (color assigned from a predefined palette — secondary, tertiary, surface-bright).

### 2.3 Expense Tracking & Splitting Logic
* **Adding an Expense**:
  * `Amount Spent` (hero-style large input at the top).
  * `Paid By` (dropdown selector from the event's participant list).
  * `Description/Title` of the expense (e.g., "Dinner at Luigi's").
* **Advanced Splitting Mechanism (Participant Selection + Percentage/Equal Splitting)**:
  1. **Select Involved Participants**: First, the user selects which participants are actually involved in the expense (checkbox list). By default, all event participants are selected.
  2. **Split Mode Toggle**: An "Equally" toggle switch controls the split mode:
     * **Equally ON (default)**: The amount is divided equally among all selected participants.
     * **Equally OFF**: The user can assign a **custom percentage** (or fixed amount) to specific selected participants.
  3. **Equal Remainder**: When custom percentages are assigned, the system automatically calculates the remaining percentage of the bill and **splits it equally** among the rest of the *selected* participants who don't have a custom percentage.
  * *Example*: Alice, Bob, Charlie, and Dave are in an event. Only Alice, Bob, and Charlie share a $100 dinner (Dave is deselected). The user specifies Alice pays 40%. The remaining 60% ($60) is automatically split equally among Bob and Charlie (30% / $30 each). Dave pays $0.
* **Settlement Calculation**: The app must calculate the net balances — who owes whom and how much — to settle all debts within the event optimally (minimizing the number of transactions).

### 2.4 Notifications (Email Integration)
* **Goal**: Send the final split amount, total spent, and who owes whom.
* **Implementation Strategy: Native `mailto:` links**
  * Use the `url_launcher` package to generate a `mailto:` link with a pre-filled Subject and Body containing the settlement summary.
  * When the user taps the "Send via Email" button, it opens their native email app (e.g., Gmail, Apple Mail) with the contents pre-filled.
  * *Why*: 100% free, no backend integration or third-party APIs, aligns with the local-only data architecture.

### 2.5 Export Functionality
* Users can tap an "Export to CSV" button on the **Export & Settle** screen.
* The CSV should include: Event Name, Participant Names, Individual Expenses, Total Spent, and Final Balances (Who owes Whom).

---

## 3. UI/UX Design Specification

### 3.1 Design System Reference

All screens follow the **"Lumina Wallet / Modern Fiscal"** design system defined in `design/stitch/stitch_expendly_split/modern_fiscal_core/DESIGN.md`. The key design tokens are:

| Token | Value | Usage |
|-------|-------|-------|
| **Background** | `#0e1513` | Base layer, all screen backgrounds |
| **Surface Container** | `#1a211f` | Bento card backgrounds |
| **Primary** | `#57f1db` / `#2dd4bf` | CTAs, positive amounts, active tabs, FABs |
| **Semantic Red** | `#fb7185` | Negative balances ("You owe"), amounts owed |
| **Semantic Green** | `#34d399` | Positive balances ("Owed to you") |
| **Glass Stroke** | `rgba(255, 255, 255, 0.05)` | 1px card borders |
| **Glass Overlay** | `rgba(14, 21, 19, 0.7)` | Frosted glass headers with backdrop blur |
| **Headline Font** | Hanken Grotesk 700, 22px | Screen titles |
| **Body Font** | Hanken Grotesk 500, 15px | Content text |
| **Label Font** | JetBrains Mono 500, 11px | Uppercase labels, date stamps |
| **Card Radius** | 12px (xl) | All bento cards |
| **Container Padding** | 24px | Card inner padding |
| **Gutter** | 16px | Space between cards |

### 3.2 Screen-by-Screen Design Plan

Each screen below references a design in `design/stitch/stitch_expendly_split/`. These are **reference only** — the final Flutter implementation should follow the same visual language as the existing currency/transaction flow in the app.

---

#### Screen 1: Groups List (`refined_groups_splits`)
**Purpose**: Main entry point — lists all shared events.

**Layout**:
- **TopAppBar**: App logo + "Groups" title + Search icon + More menu.
- **Header Section**: "Shared Events" subtitle + "+ New Event" outlined button (top-right).
- **Event Cards** (vertically stacked, each card contains):
  - Category icon (colored, rounded square) + Event name + Status badge (ACTIVE / SETTLED / RECURRING) + Member count.
  - Sub-card with "Total Spent" and "Your Share" (primary color for positive, semantic-red for negative).
  - Participant avatar row (overlapping circles with "+N" overflow count) + chevron to navigate.
- **Bottom Navigation**: Dashboard | Expenses | **Groups** (active, highlighted) | Settings.
- **FAB**: Primary-colored "+" button (bottom-right corner, above nav bar).

**Navigation**: Accessible from the bottom nav bar's "Groups" tab.

---

#### Screen 2: New Event (`new_sharing_event`)
**Purpose**: Create a new sharing event.

**Layout**:
- **TopAppBar**: Back arrow + "New Event" title + More menu.
- **Hero Text**: "Create a new event" (primary color, headline) + subtitle "Set up your event to start splitting expenses with friends."
- **Event Details Card** (bento card):
  - "EVENT NAME" label (JetBrains Mono, uppercase) + text input.
  - "CATEGORY" label + horizontally scrollable icon chips (Trip ✈️, Dinner 🍴, Home 🏠, Party 🎉) with selectable outline/filled states.
- **Participants Card** (bento card):
  - "Participants" title + "N Added" badge (primary color).
  - Name input + Email (optional) input + "+ Add" button (primary filled).
  - List of added participants: avatar circle + name + subtitle (email or "Owner") + ✕ remove button (except for "You" / Owner).
- **Sticky Bottom CTA**: "Create Event →" full-width primary button with glow shadow.

---

#### Screen 3: Event Detail (`event_trip_to_bali`)
**Purpose**: Dashboard for a specific event — shows expenses and balances.

**Layout**:
- **TopAppBar**: Back arrow + Event name ("Trip to Bali") + More menu (edit/delete).
- **Summary Card** (bento card with subtle primary gradient border):
  - "TOTAL SPEND" label + large amount in primary color.
  - Participant avatar row (overlapping circles + "+N" count + "N members").
- **Tab Bar**: **Expenses** | **Balances** (underline indicator on active tab).
- **Expenses Tab Content**:
  - Grouped by date ("TODAY", "YESTERDAY") — uppercase JetBrains Mono labels.
  - Each expense row (bento card): Category icon (colored, rounded square) + Title + "Paid by [Name]" subtitle + Amount (right-aligned, primary color) + "N shares" label.
- **Balances Tab Content**: (see Screen 5 below).
- **FAB**: Primary "+" button to add a new expense.
- **Bottom Navigation**: Same as Groups List.

---

#### Screen 4: Add Expense (`add_group_expense`)
**Purpose**: Add an expense within an event.

**Layout** (follows the existing "Add Transaction" flow):
- **TopAppBar**: Back arrow + "Add Expense" title + More menu.
- **Amount Hero Card** (bento card, centered):
  - "AMOUNT" label (uppercase) + large `$ 0.00` input (primary color, display-lg font).
- **Description Card** (bento card):
  - "DESCRIPTION" label + text input with icon prefix (📝).
- **Paid By Card** (bento card):
  - "PAID BY" label + dropdown select with person icon prefix + chevron.
- **Split Among Card** (bento card):
  - Header row: "SPLIT AMONG" label + "Equally" toggle switch (right-aligned).
  - Participant list: Avatar circle + Name + Checkbox (right-aligned).
  - When "Equally" is OFF: show a percentage/amount input field next to each checked participant.
- **Sticky Bottom CTA**: "Save Expense" full-width primary button with glow shadow.

---

#### Screen 5: Balances / Member View (`group_balances_member_view`)
**Purpose**: Shows per-member settlement details within an event.

**Layout**:
- **TopAppBar + Summary Card**: Same as Event Detail.
- **Tab Bar**: Expenses | **Balances** (active).
- **View Balances For**: Horizontal avatar selector — tap a member to see their perspective. Active member has a primary-colored ring around their avatar.
- **Net Position Card** (bento card with primary border):
  - "NET POSITION" label + "You are owed $245.00 overall" (primary color for positive, red for negative).
- **Settlements Section**:
  - "SETTLEMENTS" label.
  - Each settlement row (bento card):
    - Direction icon (↗ outgoing = red icon, ↓ incoming = green icon).
    - "[Person] owes you" or "You owe [Person]" + Reason ("For Villa & Dinner").
    - Amount (right-aligned, semantic-green for incoming, semantic-red for outgoing).
    - Action button: "Remind" (outlined) for debts owed to you, "Settle Up" (primary filled) for debts you owe.
- **FAB**: Primary "+" button.

---

#### Screen 6: Export & Settle (`export_settlement_summary`)
**Purpose**: Preview and export/email the settlement summary.

**Layout**:
- **TopAppBar**: Back arrow + "Expendly" branding + More menu.
- **Header**: "Export & Settle" title + Event name subtitle.
- **Settlement Summary Card** (bento card):
  - Icon (📋) + "Settlement Summary" title.
  - Two sub-cards side by side: "TOTAL EXPENSE" + amount | "YOUR SHARE" + amount (primary color).
- **Debts to Clear Section**:
  - "Debts to Clear" title + "N Pending" badge.
  - Each debt row (bento card):
    - Direction icon (↗ red or ↓ green) + Description ("You owe Sarah" / "Mike owes you") + Reason.
    - Amount (right-aligned, color-coded) + Status button ("Settle Up" / "Pending").
- **Two Bottom CTAs** (stacked):
  - "Export to CSV" — primary filled button (full width) with download icon.
  - "Send via Email" — outlined button (full width) with mail icon.

---

### 3.3 Navigation & User Flow

```
Bottom Nav "Groups" tab
    │
    ├── Groups List Screen (refined_groups_splits)
    │       │
    │       ├── [+ New Event] ──► New Event Screen (new_sharing_event)
    │       │                         │
    │       │                         └── [Create Event →] ──► Event Detail Screen
    │       │
    │       └── [Tap Event Card] ──► Event Detail Screen (event_trip_to_bali)
    │               │
    │               ├── Expenses Tab
    │               │       └── [FAB +] ──► Add Expense Screen (add_group_expense)
    │               │
    │               ├── Balances Tab (group_balances_member_view)
    │               │       ├── [Remind] ──► mailto: link
    │               │       └── [Settle Up] ──► Mark as settled
    │               │
    │               └── [⋮ Menu] ──► Edit Event / Delete Event / Export & Settle
    │                                   │
    │                                   └── Export & Settle Screen (export_settlement_summary)
    │                                           ├── [Export to CSV]
    │                                           └── [Send via Email] ──► mailto: link
    │
    └── Dashboard (Quick Action "Split Bill") ──► New Event Screen
```

### 3.4 Dashboard Integration
- Add a **"Split Bill"** quick-action button to the existing dashboard's action row.
- Optionally add a **"Recent Groups"** horizontal card carousel below the wallet balance section showing the top 2–3 active events with their total spend and your share.

---

## 4. Implementation Plan

### Phase 1: Local Database Architecture (Drift / SQLite)
Create new tables in the existing `drift` database schema:
* `SharingEventsTable`: id (autoIncrement), name, description, date, category, status (active/settled/recurring), createdAt.
* `EventParticipantsTable`: id, eventId (foreign key), name, email (nullable), isOwner, colorIndex.
* `GroupExpensesTable`: id, eventId (foreign key), title, amount, paidByParticipantId (foreign key), date, createdAt.
* `ExpenseSplitsTable`: id, expenseId (foreign key), participantId (foreign key), isSelected (boolean), customPercentage (nullable double), splitAmount (double).

### Phase 2: Core Logic & State Management
* **Participant‑First Selection**: Before any calculation, the app presents the full participant list and records which are *selected* (isSelected). Non‑selected participants are excluded and receive $0.
* **Percentage/Equal Logic**: A helper function receives the total amount, a map of `{participantId: customPercentage}` for selected participants, and the remaining selected participants. It calculates custom allocations first, then evenly distributes the remainder.
* **Debt Simplification Algorithm**:
  1. Calculate net balance for each participant: `Total Paid − Total Owed`.
  2. Separate into "Debtors" (negative balance) and "Creditors" (positive balance).
  3. Sort and greedily match Debtors to Creditors to generate simplified payout instructions.
* **State Management**: Use `flutter_bloc` (already in the project) — create `SharingEventBloc`, `GroupExpenseBloc`, and `SettlementCubit`.

### Phase 3: UI Development
Map each screen to the reference designs:

| Flutter Screen | Reference Design | Key Components |
|----------------|-----------------|----------------|
| `GroupsListPage` | `refined_groups_splits` | Event cards with status badges, avatar rows, bottom nav "Groups" tab |
| `NewEventPage` | `new_sharing_event` | Event details form, category chips, participant list with add/remove |
| `EventDetailPage` | `event_trip_to_bali` | Summary card, Expenses/Balances tab bar, expense list grouped by date, FAB |
| `AddExpensePage` | `add_group_expense` | Hero amount input, description, paid-by dropdown, split-among checkboxes, equally toggle |
| `BalancesView` | `group_balances_member_view` | Avatar selector, net position card, settlement rows with Remind/Settle actions |
| `ExportSettlePage` | `export_settlement_summary` | Summary card, debts list, Export CSV + Send Email buttons |

Additional screens:
* **Edit Event**: Reuse `NewEventPage` form pre-filled with existing data.
* **Delete Event**: Confirmation dialog from the event detail ⋮ menu.
* **Dashboard Integration**: Add "Split Bill" quick-action button + optional "Recent Groups" carousel.

### Phase 4: Export & Email
* **CSV Export**: Use `csv` + `path_provider` + `share_plus` to generate, save, and share the CSV file.
* **Email Summary**: Use `url_launcher` to construct a `mailto:` URI with pre-filled subject ("Expendly — [Event Name] Settlement") and body (formatted text summary of debts).

### Phase 5: Testing & Verification
* **Unit Tests**: Thoroughly test the percentage/equal remainder logic and debt simplification algorithm (edge cases: rounding, single participant, all custom percentages summing to 100%, etc.).
* **Widget Tests**: Validate form inputs, participant selection toggling, and real-time split recalculation.
* **Integration Tests**: Full flow — create event → add participants → add expenses → verify balances → export.
