# Expendly — Tablet UI Implementation Plan

> **Goal:** Transform Expendly from a phone-first app into one that delivers a **native tablet experience** — not a scaled-up phone UI, but a purpose-built layout that exploits the extra screen real estate with multi-column layouts, persistent side panels, master-detail patterns, and a navigation rail.

---

## Table of Contents

1. [Design Philosophy](#1-design-philosophy)
2. [Breakpoint Strategy](#2-breakpoint-strategy)
3. [Responsive Infrastructure (New Files)](#3-responsive-infrastructure-new-files)
4. [Navigation Overhaul](#4-navigation-overhaul)
5. [Screen-by-Screen Tablet Layouts](#5-screen-by-screen-tablet-layouts)
   - [5.1 Dashboard (Overview Tab)](#51-dashboard-overview-tab)
   - [5.2 Transactions (Activity Tab)](#52-transactions-activity-tab)
   - [5.3 Budgets Overview Tab](#53-budgets-overview-tab)
   - [5.4 Reports & Analytics](#54-reports--analytics)
   - [5.5 Groups & Splits](#55-groups--splits)
   - [5.6 Settings](#56-settings)
   - [5.7 Categories Management](#57-categories-management)
   - [5.8 Add/Edit Transaction](#58-addedit-transaction)
   - [5.9 Create/Edit Budget](#59-createedit-budget)
   - [5.10 Onboarding Flow](#510-onboarding-flow)
   - [5.11 Profile Page](#511-profile-page)
   - [5.12 Group Detail & Sub-pages](#512-group-detail--sub-pages)
   - [5.13 Transaction Details](#513-transaction-details)
   - [5.14 Security / Splash / About / Help](#514-security--splash--about--help)
6. [Shared Widget Adaptations](#6-shared-widget-adaptations)
7. [Typography & Spacing Adjustments](#7-typography--spacing-adjustments)
8. [ScreenUtil Considerations](#8-screenutil-considerations)
9. [Implementation Phases](#9-implementation-phases)
10. [Testing Strategy](#10-testing-strategy)

---

## 1. Design Philosophy

The tablet layout follows these principles, inspired by the [design references](design/stitch/stitch_expendly_tablet/) but adapted to Expendly's actual feature set and data model:

| Principle | Description |
|---|---|
| **Flattened hierarchy** | Consolidate drill-down flows into side-by-side panels. Tapping a list item updates an adjacent detail pane instead of pushing a new route. |
| **Persistent context** | Summary cards, health panels, and insight blocks stay visible alongside the main content — no separate summary screens. |
| **Navigation rail** | Replace the floating bottom nav bar with a persistent left navigation rail (~220px expanded / ~72px collapsed). |
| **Bento grid layouts** | Use multi-column card grids instead of single-column stacks. Cards resize and reflow based on available width. |
| **Content-first density** | Tablet layouts show more data per viewport — larger charts, wider transaction rows with extra metadata columns, side-by-side form fields. |
| **Same design language** | Glassmorphic-Material hybrid, `GlassContainer`, teal primary, JetBrains Mono for amounts — the visual identity stays consistent, only the spatial arrangement changes. |

---

## 2. Breakpoint Strategy

### Breakpoint Tiers

| Tier | Width Range | Target Devices | Layout |
|---|---|---|---|
| **Compact** | < 600px | Phones (portrait) | Current single-column layout, bottom nav bar |
| **Medium** | 600px – 839px | Small tablets, large phones (landscape), foldables | Two-column where possible, bottom nav or condensed rail |
| **Expanded** | ≥ 840px | Standard tablets (iPad, 10"+ Android) | Full multi-column, navigation rail, master-detail |

### Implementation

```dart
// lib/core/responsive/breakpoints.dart

enum DeviceType { compact, medium, expanded }

class Breakpoints {
  static const double compact = 600;
  static const double expanded = 840;

  static DeviceType of(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= expanded) return DeviceType.expanded;
    if (width >= compact) return DeviceType.medium;
    return DeviceType.compact;
  }

  static bool isTablet(BuildContext context) =>
      of(context) != DeviceType.compact;

  static bool isExpanded(BuildContext context) =>
      of(context) == DeviceType.expanded;
}
```

> **IMPORTANT:** These breakpoints use **logical pixels** (not physical), matching Material 3's canonical window size classes. The `ScreenUtilInit` design size (375x812) remains for the compact tier — tablet tiers bypass ScreenUtil scaling for layout dimensions and use fixed dp values with their own spacing scale.

---

## 3. Responsive Infrastructure (New Files)

### 3.1 New Files to Create

| File | Purpose |
|---|---|
| `lib/core/responsive/breakpoints.dart` | `Breakpoints` class, `DeviceType` enum |
| `lib/core/responsive/responsive_builder.dart` | `ResponsiveBuilder` widget — a `LayoutBuilder` wrapper that provides `DeviceType` to children |
| `lib/core/responsive/adaptive_scaffold.dart` | `AdaptiveScaffold` — the app shell that switches between bottom nav (compact) and nav rail (medium/expanded) |
| `lib/core/responsive/responsive_extensions.dart` | Extension methods on `BuildContext` — `context.deviceType`, `context.isTablet`, `context.isExpanded` |
| `lib/core/responsive/tablet_spacing.dart` | Tablet-specific spacing constants (larger gutters, wider margins for expanded layouts) |
| `lib/core/widgets/master_detail_layout.dart` | Reusable `MasterDetailLayout` widget for list-detail pane patterns |
| `lib/core/widgets/adaptive_navigation_rail.dart` | The navigation rail widget with expanded/collapsed states |

### 3.2 ResponsiveBuilder Widget

```dart
/// Builds different widgets based on the current device type.
/// Falls back to [compact] for any tier without an explicit builder.
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context) compact;
  final Widget Function(BuildContext context)? medium;
  final Widget Function(BuildContext context)? expanded;

  const ResponsiveBuilder({
    super.key,
    required this.compact,
    this.medium,
    this.expanded,
  });

  @override
  Widget build(BuildContext context) {
    final type = Breakpoints.of(context);
    return switch (type) {
      DeviceType.expanded => (expanded ?? medium ?? compact)(context),
      DeviceType.medium   => (medium ?? compact)(context),
      DeviceType.compact  => compact(context),
    };
  }
}
```

### 3.3 MasterDetailLayout Widget

```dart
/// Reusable master-detail split pane for tablet layouts.
/// [masterFlex] and [detailFlex] control the column ratio (e.g. 1:2).
class MasterDetailLayout extends StatelessWidget {
  final Widget master;
  final Widget detail;
  final int masterFlex;
  final int detailFlex;
  final double gutterWidth; // defaults to 16px

  // ...
}
```

---

## 4. Navigation Overhaul

### 4.1 Current State

- `DashboardPage` uses `_FloatingBottomNavBar` with 4 items: Overview, Activity, Budgets, Settings.
- Tab content is managed via `IndexedStack`.
- Settings pushes a route (`context.router.push(SettingsRoute())`).
- Reports is accessed from the dashboard header, not a primary tab.
- Groups is accessed from the dashboard's "Recent Groups" section.

### 4.2 Tablet Navigation: AdaptiveScaffold

On **expanded** (>=840px) layouts, the `DashboardPage` replaces the bottom nav bar with a **persistent left navigation rail**:

```
+----------+--------------------------------------------------+
|          |                                                  |
| Expendly |          MAIN CONTENT AREA                       |
|          |          (IndexedStack of tabs)                  |
| -------- |                                                  |
| Dashboard|                                                  |
| Activity |                                                  |
| Budgets  |                                                  |
| Reports  |                                                  |
| Groups   |                                                  |
|          |                                                  |
|          |                                                  |
|          |                                                  |
| -------- |                                                  |
| Settings |                                                  |
|          |                                                  |
| [Avatar] |                                                  |
| User     |                                                  |
+----------+--------------------------------------------------+
```

**Key design decisions:**

| Aspect | Decision |
|---|---|
| **Rail width** | ~220px expanded (with labels), ~72px collapsed (icons only). User can toggle. Default to expanded on >=1024px, collapsed on 840-1024px. |
| **Rail items** | Dashboard, Transactions, Budgets, Reports, Groups — all as primary destinations. Settings pinned at bottom. |
| **Tablet gains 2 extra tabs** | Reports (currently only accessible from Dashboard header) and Groups (currently only accessible from Dashboard "Recent Groups") become **first-class navigation items** on tablet. |
| **Active indicator** | Left accent bar (4px wide, primary color) on the active item — matches the design reference. |
| **Brand header** | Expendly logo + icon at the top of the rail. |
| **User section** | Avatar + name at the bottom of the rail, above Settings. |
| **FAB** | The center floating FAB moves to the bottom of the navigation rail as a full-width "+ New Entry" button. |
| **Style** | The rail uses the same glassmorphic treatment as the current `_FloatingBottomNavBar` — translucent background, backdrop blur, glass stroke border. |

### 4.3 Compact (Phone) — No Changes

The existing `_FloatingBottomNavBar` continues to work as-is for compact layouts. No regressions.

### 4.4 Implementation in DashboardPage

The `DashboardPage.build()` method wraps the current `Scaffold` in a `ResponsiveBuilder`:

```dart
ResponsiveBuilder(
  compact: (context) => _buildCompactLayout(context), // current layout
  expanded: (context) => _buildExpandedLayout(context), // nav rail + wider content
)
```

The `_buildExpandedLayout` uses a `Row`:
- Left: `AdaptiveNavigationRail` (fixed width)
- Right: `Expanded` -> `IndexedStack` with the same tab content, but each tab renders its **tablet variant**

The `IndexedStack` children count increases from 3 to 5 on tablet (adding Reports and Groups as first-class tabs).

---

## 5. Screen-by-Screen Tablet Layouts

### 5.1 Dashboard (Overview Tab)

**Current (Compact):** Single column — DashboardHeader -> BentoGrid summary cards -> CashFlowChart -> RecentGroups -> RecentActivity. Constrained to `maxWidth: 600`.

**Tablet (Expanded):**

```
+---------------------------------------------------------------------+
|  FINANCIAL OVERVIEW                               [This Month v]    |
|  Welcome back, your net worth is up 2.4% this month.  [+ New Entry] |
+----------------+-------------------+--------------------------------+
| TOTAL BALANCE  |  MONTHLY INCOME   |  MONTHLY EXPENSES              |
| $45,231.89     |  $8,450.00        |  $3,120.45        82% of limit |
| ============== |  ========-------- |  ================--            |
+----------------+-------------------+--------------------------------+
|                                    |                                 |
|  Cash Flow                    ...  |  Categories                     |
|  +----------------------------+    |  +-----------------------+      |
|  |                            |    |  |    [Donut Chart]       |      |
|  |   [Line/Bar Chart]         |    |  |    Top Spent: Housing  |      |
|  |                            |    |  |                        |      |
|  | Jan  Feb  Mar  Apr  May    |    |  |  * Housing    45%      |      |
|  +----------------------------+    |  |  * Food       25%      |      |
|                                    |  |  * Transport  15%      |      |
|                                    |  +-----------------------+      |
+------------------------------------+---------------------------------+
|  Recent Transactions                                    View All     |
|  +---------------------------------------------------------------+  |
|  | Cart Whole Foods Market - Groceries - Today, 2:45 PM  -$142.50|  |
|  | Dollar Stripe Inc. - Income - Yesterday, 9:00 AM     +$2,450  |  |
|  | Bolt Pacific Gas & Electric - Utilities - Oct 24      -$84.20 |  |
|  +---------------------------------------------------------------+  |
+---------------------------------------------------------------------+
```

**Layout structure:**

| Zone | Content | Ratio |
|---|---|---|
| **Top row** | 3 summary metric cards in a `Row` (equal flex) | Full width |
| **Middle row** | `Row` — Cash Flow chart (flex: 5) + Categories donut (flex: 3) | ~62:38 split |
| **Bottom section** | Recent Transactions — full-width list with denser rows (icon + name + category + date + amount + payment method all on one row) | Full width |

**Key differences from mobile:**
- Remove `ConstrainedBox(maxWidth: 600)` — content fills available space with generous padding (32px sides)
- Summary cards are in a **horizontal row** instead of a bento grid stack
- Cash flow chart and categories donut sit **side by side** instead of stacked
- Recent transactions rows become denser with more metadata columns visible
- The `DashboardHeader` merges into the top of the content area (no pinned glassmorphic overlay needed — the nav rail handles navigation)
- "Recent Groups" section moves to its own tab (Groups), not shown on dashboard overview on tablet

**Files affected:**
- `lib/features/dashboard/presentation/pages/dashboard_page.dart` — add `ResponsiveBuilder` wrapper
- `lib/features/dashboard/presentation/widgets/dashboard_bento_grid.dart` — create tablet variant with horizontal row
- `lib/features/dashboard/presentation/widgets/dashboard_cash_flow_chart.dart` — widen, remove maxWidth constraint
- `lib/features/dashboard/presentation/widgets/dashboard_recent_activity.dart` — denser tablet row layout
- [NEW] `lib/features/dashboard/presentation/widgets/dashboard_tablet_header.dart` — inline header replacing the floating glass header
- [NEW] `lib/features/dashboard/presentation/widgets/dashboard_categories_donut.dart` — extracted donut chart widget for side-by-side layout

---

### 5.2 Transactions (Activity Tab)

**Current (Compact):** Full-screen list with filters (view mode toggle, month selector, calendar strip) at top, transaction list below. Tapping a transaction pushes `TransactionDetailsRoute`.

**Tablet (Expanded) — Master-Detail Pattern:**

```
+---------------------------+-----------------------------------------+
|  Transactions         =   |                                         |
|  +---------+---------+--+ |        Cart Icon                        |
|  | All | This Week |    | |      -$142.50                           |
|  | This Month | Custom  | |   Whole Foods Market                    |
|  +---------+---------+--+ |                                         |
|  +---------------------+  |   [Today, 10:42 AM] [Groceries] [*4209] |
|  | Search...            |  |                                         |
|  +---------------------+  |  +------------------+-------------------+|
|                           |  |  Location         |  Receipt          ||
|  +-- TODAY ------------+  |  |                   |                   ||
|  | == Whole Foods  -142 |  |  |  [Map View]       |  [Image Viewer]   ||
|  |                      |  |  |  3rd St & Fairfax |                   ||
|  | Dining: Blue B -6.50 |  |  |  Los Angeles, CA  |   View Image     ||
|  |                      |  |  +------------------+-------------------+|
|  | Income: Stripe +4250 |  |                                         |
|  +----------------------+  |  Notes & Tags                      Edit |
|                           |  +--------------------------------------+|
|  +-- YESTERDAY ---------+  |  | Weekly organic grocery run. Need to  ||
|  | Uber Ride       -24  |  |  | split cost of cleaning supplies.    ||
|  |                      |  |  +--------------------------------------+|
|  | Osteria Mozza  -185  |  |  [* shared] [* essentials] [+ add tag]  |
|  +----------------------+  |                                         |
|                           |  +-------------+ +----------------------+|
|                           |  | Report Issue | |    Split Expense     ||
|                           |  +-------------+ +----------------------+|
+---------------------------+-----------------------------------------+
         ~35%                              ~65%
```

**Layout structure:**

| Panel | Content | Width |
|---|---|---|
| **Master (left)** | Filter chips + search bar + scrollable transaction list grouped by date | Flex 35% (~350px) |
| **Detail (right)** | Selected transaction's full detail — amount, category, metadata chips, location map, receipt image, notes, tags, action buttons | Flex 65% |

**Key differences from mobile:**
- **No route push** when tapping a transaction — the detail pane updates inline via a `ValueNotifier<TransactionItem?>` or cubit selection state
- Transaction list items are more compact (single-line: icon + name + amount)
- Filter chips and search bar stay pinned at the top of the master pane
- The detail pane shows an empty/prompt state when nothing is selected
- Location and Receipt show **side by side** (2-col row) instead of stacked
- Action buttons ("Report Issue", "Split Expense") sit at the bottom of the detail pane

**Files affected:**
- `lib/features/transactions/presentation/pages/all_transactions_page.dart` — add `ResponsiveBuilder`, extract master/detail
- [NEW] `lib/features/transactions/presentation/widgets/transaction_master_list.dart` — tablet master pane
- [NEW] `lib/features/transactions/presentation/widgets/transaction_detail_panel.dart` — tablet inline detail pane (reuses logic from `transaction_details_page.dart`)
- `lib/features/transactions/presentation/pages/transaction_details_page.dart` — remains for compact (push route) + refactor shared content

---

### 5.3 Budgets Overview Tab

**Current (Compact):** Pinned `_TotalBudgetHealthCard` at top, scrollable budget cards below in a single column.

**Tablet (Expanded) — Two-Column Asymmetric Layout:**

```
+--------------------------------------------+-------------------------+
|  Budgets                                   |  Budget Health           |
|  Track and manage your spending limits.    |                         |
|                          [+ ADD BUDGET]    |  Total Budgeted $1,150  |
|                                            |  Total Spent      $810  |
+--------------------+-----------------------+  Remaining Pool   $339  |
|                    |                       |                         |
|  Groceries         |  Dining Out          |  +-----------------+    |
|  MONTHLY           |  MONTHLY              |  | [Bar Chart]     |    |
|  $480.00 of $500   |  $120.50 of $300      |  | Weekly History  |    |
|  ================- |  ======-----------    |  |                 |    |
|  ! Near Limit 96%  |  $179.50 remaining    |  +-----------------+    |
|                    |                       |                         |
+--------------------+-----------------------+  [VIEW HISTORY]         |
|                    |                       |                         |
|  Transport         |  Entertainment        |  +---------------------+|
|  MONTHLY           |  MONTHLY              |  | Adjust Grocery       ||
|  $165.00 of $150   |  $45.00 of $200       |  | Limit                ||
|  ================  |  ====---------------  |  | You consistently     ||
|  X Over by $15     |  $155.00 remaining    |  | near your grocery    ||
|                    |                       |  | limit. Consider      ||
|                    |                       |  | raising by $50.      ||
+--------------------+-----------------------+  +---------------------+|
         ~70% (2-column grid)                        ~30% (sidebar)    |
```

**Layout structure:**

| Zone | Content | Width |
|---|---|---|
| **Main area (left)** | Budget cards in a **2-column grid** (`GridView` or `Wrap`) | Flex ~70% |
| **Sidebar (right)** | Budget Health summary card (persistent) — total budgeted, spent, remaining, weekly bar chart, smart insight alerts | Flex ~30% (~280px min, sticky) |

**Key differences from mobile:**
- Budget cards go from single-column list to **2-column grid** — each card is a `GlassContainer` with icon, name, period, spent/limit, progress bar, and alert status
- `_TotalBudgetHealthCard` moves from a pinned overlay to a **persistent right sidebar**
- Sidebar adds a small weekly spending bar chart and contextual "smart insight" alerts (e.g., "Adjust Grocery Limit")
- "+ Add Budget" button moves to the top-right of the content header instead of the center FAB

**Files affected:**
- `lib/features/budgets/presentation/pages/budgets_overview_page.dart` — add `ResponsiveBuilder`, extract grid layout
- [NEW] `lib/features/budgets/presentation/widgets/budget_card_grid.dart` — 2-column budget card grid
- [NEW] `lib/features/budgets/presentation/widgets/budget_health_sidebar.dart` — persistent sidebar with summary + chart + insights

---

### 5.4 Reports & Analytics

**Current (Compact):** Full-screen page (`RefinedReportsPage`) accessed from Dashboard header. Single-column with period selector chips, summary metrics, and scrollable chart sections.

**Tablet (Expanded) — Three-Column Layout:**

```
+------------------+------------------------------------+------------------+
|  Reports         |  Spending Trends           3M|6M|1Y|  Insights        |
|                  |                                    |                  |
|  +-----------+   |  TOTAL SPENT (6M)    +12% vs prior|  * Dining out    |
|  | Spending  |   |  $14,285.50                       |    exceeded by   |
|  | Trends    |   |                                    |    15% this mo.  |
|  | Last 6 Mo.|   |  +----------------------------+   |                  |
|  +-----------+   |  |                            |   |  * Subscriptions |
|                  |  |    [Spline Chart]           |   |    reduced $45   |
|  +-----------+   |  |                            |   |    vs last mo.   |
|  | Category  |   |  |                            |   |                  |
|  | Breakdown |   |  |                            |   +------------------+
|  | This Month|   |  |                            |   |                  |
|  +-----------+   |  |                            |   |  Top Categories  |
|                  |  +----------------------------+   |                  |
|  +-----------+   |                                    |  +------------+ |
|  | Income    |   |                                    |  | [Donut]    | |
|  | vs Exp.   |   |                                    |  | Housing 42%| |
|  | Year to Dt|   |                                    |  +------------+ |
|  +-----------+   |                                    |                  |
+------------------+------------------------------------+------------------+
     ~20% (report       ~55% (main chart/data area)         ~25% (insights
      type list)                                              + categories)
```

**Layout structure:**

| Panel | Content | Width |
|---|---|---|
| **Left sidebar** | Scrollable list of report types — Spending Trends, Category Breakdown, Income vs Expenses. Each is a selectable card. | ~200px fixed |
| **Center** | The active report's main visualization — large chart, summary metrics, period selector chips | Flex fill |
| **Right sidebar** | Contextual insights (smart alerts) + top categories donut chart | ~240px fixed |

**Key differences from mobile:**
- Reports becomes a **first-class tab** in the navigation rail (not hidden behind a header button)
- Report type selection is a persistent left list instead of a tab bar or segmented control
- The chart gets **massive horizontal space** — the full center column — making trends much more legible
- Insights and category breakdowns are **always visible** in the right sidebar
- Period selector (3M/6M/1Y) stays in the center panel's header

**Files affected:**
- `lib/features/analytics/presentation/pages/refined_reports_page.dart` — add `ResponsiveBuilder`
- [NEW] `lib/features/analytics/presentation/widgets/report_type_sidebar.dart` — left report selection list
- [NEW] `lib/features/analytics/presentation/widgets/report_insights_sidebar.dart` — right insights panel
- [NEW] `lib/features/analytics/presentation/widgets/report_chart_panel.dart` — center chart area (extracted from current page)

---

### 5.5 Groups & Splits

**Current (Compact):** `GroupsListPage` with TabBar (Active/Settled) and `TabBarView` for event cards. Tapping an event pushes `EventDetailRoute`.

**Tablet (Expanded) — Multi-Panel Bento Layout:**

```
+------------------+--------------------+-------------------+------------------+
|  Active Groups + | TOTAL GROUP SPEND  | YOUR SHARE        |  Settle Up       |
|                  | $2,450.00          | $612.50           |                  |
|  +------------+  | Avatars +1         | Paid: $400        |  You owe Sarah   |
|  | Trip to    |  |                    | Owed: $212.50     |  $212.50         |
|  | Bali       |  |                    | ===========---    |  [Pay Now]       |
|  | 4 members  |  +--------------------+                   |                  |
|  | Updated 2h |  |                    +-------------------+  Balances        |
|  +------------+  |  Expenses  [Filter]|                   |                  |
|                  |                    |  Sarah            |  Sarah           |
|  +------------+  |  Villa Rental      |     Gets back $500|     Gets $500   |
|  | Dinner     |  |  $1,200.00        |                   |  You             |
|  | Party      |  |  Paid by Sarah    |  You              |     Owe $212.50 |
|  | 6 members  |  |  You owe $300     |     Owe $212.50   |  Mike            |
|  | Settled    |  |                    |                   |     Owes $287.50 |
|  +------------+  |  Car Rental       |  Mike             |     [Remind]     |
|                  |  $400.00           |     Owes $287.50  |                  |
|  +------------+  |  Paid by You      |                   |                  |
|  | Apartment  |  |  You lent $300    |                   |                  |
|  | Bills      |  |                    |                   |                  |
|  | 3 members  |  |                    |                   |                  |
|  +------------+  |                    |                   |                  |
+------------------+--------------------+-------------------+------------------+
     ~20% (groups       ~30% (expenses)        ~25% (summary)     ~25% (settle
      list)                                                         + balances)
```

**Layout structure:**

| Panel | Content |
|---|---|
| **Col 1 — Groups List** | Active groups list with add button. Selected group highlighted. |
| **Col 2 — Expenses** | Expense list for the selected group, with filter chip. Summary cards (Total Group Spend, Your Share) at top. |
| **Col 3 — Balances** | Per-member balance breakdown for the selected group. |
| **Col 4 — Settle Up** | Actionable settle-up card with "Pay Now" CTA. Individual balance reminders. |

> **NOTE:** Columns 3 and 4 can be combined into a single right sidebar at the medium breakpoint. The full 4-column spread applies at >=1024px.

**Key differences from mobile:**
- Groups becomes a **first-class tab** in the navigation rail
- **No route push** for event details — selecting a group updates columns 2-4 inline
- Eliminates 3-4 separate screens (Groups List -> Event Detail -> Balances -> Settle) into one consolidated view
- Tab bar (Active/Settled) can become a toggle chip in the groups list header

**Files affected:**
- `lib/features/groups/presentation/pages/groups_list_page.dart` — add `ResponsiveBuilder`
- [NEW] `lib/features/groups/presentation/widgets/groups_master_list.dart` — left groups list
- [NEW] `lib/features/groups/presentation/widgets/group_expense_panel.dart` — center expense list
- [NEW] `lib/features/groups/presentation/widgets/group_balance_panel.dart` — balance + settle sidebar
- `lib/features/groups/presentation/pages/event_detail_page.dart` — extract reusable content widgets

---

### 5.6 Settings

**Current (Compact):** Long scrollable list of settings sections (Profile, Security, Appearance, Data & Privacy, etc.) with a `LiquidGlassAppBar`.

**Tablet (Expanded) — Two-Column with Category Sidebar:**

```
+----------------------+------------------------------------------------------+
|  Settings            |                                                      |
|  Manage your account |  Avatar: Alex Mercer                                 |
|  and preferences.    |  alex.mercer@lumina.io                               |
|                      |  * Pro Tier                                          |
|  +----------------+  |                                                      |
|  | Account        |  |  Personal Information                               |
|  | Personal info  |  |  Update your basic details.                          |
|  | & tier         |  |                                                      |
|  +----------------+  |  +------------------+ +------------------+           |
|                      |  | FIRST NAME       | | LAST NAME        |           |
|  +----------------+  |  | Alex             | | Mercer           |           |
|  | Security       |  |  +------------------+ +------------------+           |
|  | 2FA & Devices  |  |                                                      |
|  +----------------+  |  +--------------------------------------+            |
|                      |  | EMAIL ADDRESS                         |            |
|  +----------------+  |  | alex.mercer@lumina.io                 |            |
|  | Appearance     |  |  +--------------------------------------+            |
|  | Theme & Layout |  |                                                      |
|  +----------------+  |  +--------------------------------------+            |
|                      |  | PHONE NUMBER                          |            |
|  +----------------+  |  | +1 (555) 019-2834                    |            |
|  | Data &         |  |  +--------------------------------------+            |
|  | Privacy        |  |                                      [Save Changes]  |
|  | Export & Mgmt  |  |                                                      |
|  +----------------+  |  -- Danger Zone ------------------------------------ |
|                      |  +--------------------------------------+            |
|                      |  | Delete Account                [DELETE]|            |
|                      |  | Permanently remove all your data.    |            |
|                      |  +--------------------------------------+            |
+----------------------+------------------------------------------------------+
       ~25% (sidebar)                    ~75% (content)
```

**Layout structure:**

| Panel | Content |
|---|---|
| **Left sidebar** | Settings category list — Account, Security, Appearance, Data & Privacy. Each is a selectable card. Header shows "Settings" title + subtitle. |
| **Right content** | The selected category's full form/content. Replaces inline when a different category is tapped. |

**Key differences from mobile:**
- No scrolling through all settings sections — category sidebar provides instant jump
- Form fields use **side-by-side layout** where appropriate (e.g., First Name + Last Name in a row)
- Profile header (avatar + name + email) moves to the top of the content area
- Settings no longer pushes a separate route on tablet — it's a tab in the navigation rail

**Files affected:**
- `lib/features/settings/presentation/pages/settings_page.dart` — add `ResponsiveBuilder`
- [NEW] `lib/features/settings/presentation/widgets/settings_category_sidebar.dart` — left sidebar
- [NEW] `lib/features/settings/presentation/widgets/settings_content_panel.dart` — right content area
- Existing setting widgets (`settings_tile.dart`, `settings_section_header.dart`) remain reusable

---

### 5.7 Categories Management

> Categories management is currently embedded within Settings or accessed contextually. On tablet, it can be surfaced as a sub-section within Settings or as part of the Budgets tab.

**Tablet (Expanded) — Three-Column Master-Detail-Editor:**

**Layout:** Left nav rail context area | Center: category card grid (2-3 columns) | Right: selected category detail/edit pane with budget slider, icon picker, subcategory list, spending alerts.

---

### 5.8 Add/Edit Transaction

**Current (Compact):** Full-screen form with type selector, amount input, category picker, date picker, note field, etc.

**Tablet (Expanded):**

The form stays as a **focused full-screen page** (pushed route) but uses the extra width:
- Two-column form layout: Amount + Type on the left, Category + Date + Note on the right
- Category picker grid shows more items per row (4-5 instead of 3)
- Custom keypad (if used) is positioned inline beside the amount field
- Form is centered with `maxWidth: 800` and generous padding
- Cancel/Save buttons are in the top-right header area

**Files affected:**
- `lib/features/transactions/presentation/pages/modern_add_transaction_page.dart` — add tablet layout variant

---

### 5.9 Create/Edit Budget

**Current (Compact):** Full-screen form for budget creation.

**Tablet (Expanded):**

Similar to Add Transaction — a centered form with wider layout:
- Budget name + amount fields side-by-side
- Category picker shows more columns
- Period selector (Weekly/Monthly/Yearly) uses larger pill buttons in a row
- `maxWidth: 700` centered with padding

**Files affected:**
- `lib/features/budgets/presentation/pages/create_new_budget_page.dart` — add tablet layout variant

---

### 5.10 Onboarding Flow

**Current (Compact):** Multi-step flow: Carousel -> Currency Setup -> Security Setup -> Final Setup. Already uses `maxWidth: 1024`.

**Tablet (Expanded):**

- Carousel page: Illustrations scale up, text blocks widen, step indicators are larger. Already partially handled by `maxWidth: 1024`.
- Currency Setup: Grid of currency options shows 4-5 columns instead of 2-3.
- Security Setup: PIN keypad is centered with wider surrounding padding.
- Final Setup: Wider form fields side-by-side.

> **TIP:** Onboarding is a low-priority tablet optimization since it's a one-time flow. The existing `maxWidth: 1024` constraint makes it functional on tablets. Refinements can come in a later phase.

---

### 5.11 Profile Page

**Current (Compact):** Scrollable profile form with avatar, name, email, phone fields.

**Tablet (Expanded):**

- Centered content with `maxWidth: 700`
- Form fields use side-by-side layout (First Name | Last Name)
- Avatar section gets more breathing room
- If accessed from the Settings tab, it renders as the Settings right-panel content (not a separate route)

---

### 5.12 Group Detail & Sub-pages

**Current (Compact):** `EventDetailPage` (expenses + balances), `AddExpensePage`, `ExpenseDetailsPage`, `ExportSettlePage`.

**Tablet (Expanded):**

On tablet, `EventDetailPage` content is **absorbed into the Groups tab's multi-panel layout** (section 5.5). The separate route is only used on compact.

- `AddExpensePage` — Opens as a **dialog/side sheet** on tablet instead of a full-screen push
- `ExpenseDetailsPage` — Renders inline in the expense panel
- `ExportSettlePage` — Opens as a dialog/bottom sheet

---

### 5.13 Transaction Details

**Current (Compact):** Full-screen page (`TransactionDetailsPage`) with amount, metadata, location, receipt, notes.

**Tablet (Expanded):**

On tablet, transaction details render **inline in the detail pane** of the Transactions master-detail layout (section 5.2). The full-screen route is only used on compact.

---

### 5.14 Security / Splash / About / Help

These pages are **layout-simple** and need minimal tablet adaptation:

| Page | Tablet Behavior |
|---|---|
| `SplashPage` | Centered branding, works at any width. No changes. |
| `SecurityVerificationPage` | PIN keypad centered with `maxWidth: 400`. Minor padding adjustment. |
| `AboutPage` | Centered content with `maxWidth: 600`. No changes. |
| `HelpSupportPage` | Centered content with `maxWidth: 600`. No changes. |
| `TermsConditionsPage` | Scrollable text, centered. No changes. |

---

## 6. Shared Widget Adaptations

### Widgets That Need Tablet Variants

| Widget | Current | Tablet Adaptation |
|---|---|---|
| `GlassContainer` | Fixed blur/radius | No changes needed — works at any size |
| `LiquidGlassAppBar` | Floats over content | Hidden on tablet (nav rail handles navigation). Show only on sub-pages that are pushed as full-screen routes. |
| `AppButton` | Full-width or inline | No changes needed |
| `AppTextField` | Full-width | No changes needed — parent Row handles side-by-side |
| `CompactAmountText` | Scaled with ScreenUtil | May need larger base size on tablet |
| `CategoryPickerSheet` | Modal bottom sheet | On tablet, could be a side sheet or inline dialog. Consider `showDialog` instead of `showModalBottomSheet` on expanded layouts. |
| `StatusComponents` (toasts, confirmation sheets) | Bottom sheet | On tablet, `showConfirmationBottomSheet` should become `showDialog` with `maxWidth: 480` for better centering on wide screens. |
| `CustomKeypad` | Full-width bottom keypad | On tablet, render as an inline component beside the amount field, not spanning full width. |

### New Shared Widgets

| Widget | Purpose |
|---|---|
| `AdaptiveNavigationRail` | The left nav rail with expanded/collapsed states, glassmorphic styling |
| `MasterDetailLayout` | Reusable split-pane with configurable ratios |
| `AdaptiveSheet` | Bottom sheet -> dialog adapter |
| `SidePanel` | Fixed-width sidebar container with glass styling for persistent context panels |

---

## 7. Typography & Spacing Adjustments

### Typography

Typography tokens from `AppTypography` remain the same — **no new tokens needed**. The existing scale works because ScreenUtil's `.sp` handling produces reasonable sizes on tablets. However:

- The `headlineLargeMobile` token should not be used on tablet — use `headlineLarge` instead
- Monetary amounts (`amountDisplay`, `amountLarge`) render well at current sizes on tablet
- Navigation rail labels use `labelMedium` from `textTheme`

### Spacing

| Context | Compact (Phone) | Expanded (Tablet) |
|---|---|---|
| Canvas side padding | 24px (`.defaultCanvasPadding()`) | 32px |
| Section vertical gap | 16px (`verticalMarginMedium`) | 24px |
| Card internal padding | 16px | 20-24px |
| Grid gutter (between cards) | 12px | 16px |
| Navigation rail width | N/A | 220px expanded / 72px collapsed |
| Master-detail gutter | N/A | 16-24px |

Add to `lib/core/responsive/tablet_spacing.dart`:

```dart
class TabletSpacing {
  static const double canvasPadding = 32.0;
  static const double sectionGap = 24.0;
  static const double cardPadding = 20.0;
  static const double gridGutter = 16.0;
  static const double railWidthExpanded = 220.0;
  static const double railWidthCollapsed = 72.0;
  static const double masterDetailGutter = 20.0;
}
```

---

## 8. ScreenUtil Considerations

The app currently uses `ScreenUtilInit` with `designSize: Size(375, 812)`.

### Problem

On a tablet (e.g., iPad with logical width of 1024px), ScreenUtil will scale 24.w to `24 * (1024 / 375) = ~65.5px`, which is excessively large for spacing and creates an "everything is bloated" effect.

### Solution

For **tablet layouts**, use **raw dp values** (not `.w`/`.h`/`.sp`) for layout dimensions. ScreenUtil scaling should only apply within compact-tier widgets:

1. **Tablet layout containers** (nav rail widths, column ratios, gutters) use fixed dp values from `TabletSpacing`.
2. **Widget internals** that are shared between compact and tablet (e.g., `GlassContainer` padding, `AppButton` heights) continue to use `.w`/`.h` — ScreenUtil's `splitScreenMode: true` partially mitigates bloating.
3. **Font sizes** — ScreenUtil's `minTextAdapt: true` prevents text from becoming too large. Monitor and add clamping if needed.
4. Consider configuring ScreenUtil with a tablet-specific design size (e.g., `Size(1024, 768)`) when `DeviceType.expanded` is detected, or disabling ScreenUtil scaling entirely for tablet by using `1.0` scale factors.

> **WARNING:** The ScreenUtil scaling on tablet needs careful testing. If `.w`/`.h` values produce bloated layouts on tablet-width screens, the recommended approach is to wrap tablet-specific layouts in a `MediaQuery` override that effectively neutralizes ScreenUtil scaling for those subtrees, or to conditionally use raw dp values.

---

## 9. Implementation Phases

### Phase 1: Foundation (Estimated: 3-4 days)

| # | Task | Priority |
|---|---|---|
| 1.1 | Create `lib/core/responsive/` directory with `breakpoints.dart`, `responsive_builder.dart`, `responsive_extensions.dart`, `tablet_spacing.dart` | Critical |
| 1.2 | Create `AdaptiveNavigationRail` widget with glassmorphic styling | Critical |
| 1.3 | Create `MasterDetailLayout` shared widget | Critical |
| 1.4 | Modify `DashboardPage` to use `ResponsiveBuilder` — show nav rail on tablet, bottom nav on phone | Critical |
| 1.5 | Add Reports and Groups as first-class nav rail destinations | High |
| 1.6 | Test ScreenUtil scaling on tablet and add mitigations | Critical |

### Phase 2: Primary Tab Screens (Estimated: 5-7 days)

| # | Task | Priority |
|---|---|---|
| 2.1 | Dashboard Overview — two-column layout (chart + categories side-by-side, horizontal summary cards) | Critical |
| 2.2 | Transactions — master-detail layout with inline detail pane | Critical |
| 2.3 | Budgets — 2-column card grid + Budget Health sidebar | Critical |
| 2.4 | Reports — three-column layout with report type sidebar + insights panel | High |
| 2.5 | Groups — multi-panel bento layout with inline event details | High |

### Phase 3: Secondary Screens (Estimated: 3-4 days)

| # | Task | Priority |
|---|---|---|
| 3.1 | Settings — category sidebar + content panel | High |
| 3.2 | Add Transaction — two-column form layout | Medium |
| 3.3 | Create Budget — wider form layout | Medium |
| 3.4 | Profile — side-by-side fields, centered layout | Medium |
| 3.5 | Categories Management — three-column layout | Medium |

### Phase 4: Polish & Shared Widgets (Estimated: 2-3 days)

| # | Task | Priority |
|---|---|---|
| 4.1 | `AdaptiveSheet` — bottom sheets to dialogs on tablet | High |
| 4.2 | Bottom sheet / modal adaptations for `CategoryPickerSheet`, `StatusComponents` | High |
| 4.3 | Group sub-pages (AddExpense, ExpenseDetails) as dialogs on tablet | Medium |
| 4.4 | Shimmer layouts for all tablet variants | High |
| 4.5 | Empty state layouts for tablet (wider, more horizontal) | Medium |
| 4.6 | Onboarding refinements (low priority) | Low |

### Phase 5: Testing & QA (Estimated: 2-3 days)

| # | Task | Priority |
|---|---|---|
| 5.1 | Test on iPad 10th gen (logical width ~1024px) | Critical |
| 5.2 | Test on iPad Mini (logical width ~744px — medium tier) | Critical |
| 5.3 | Test on iPad Pro 12.9" (logical width ~1024px landscape) | High |
| 5.4 | Test Android tablets (various widths) | High |
| 5.5 | Verify compact (phone) layouts are not regressed | Critical |
| 5.6 | Test landscape orientation on tablets | Medium |
| 5.7 | Accessibility / dynamic type on tablet | Medium |

---

## 10. Testing Strategy

### Automated

- Add widget tests for `ResponsiveBuilder` and `Breakpoints` utility
- Add widget tests for `AdaptiveNavigationRail` at different widths
- Add widget tests for each screen's tablet variant using `MediaQuery` overrides to simulate tablet widths
- Run existing tests to verify no compact regressions: `flutter test`

### Manual

- Deploy to physical iPad and Android tablet
- Verify every screen at compact (375px), medium (700px), and expanded (1024px) widths
- Verify orientation changes (portrait to landscape) don't break layouts
- Verify nav rail expand/collapse behavior
- Verify master-detail selection state persistence
- Verify all bottom sheets/dialogs adapt appropriately
- Verify ScreenUtil text sizes are readable and not bloated

### Device Matrix

| Device | Width (logical) | Tier | Priority |
|---|---|---|---|
| iPhone 15 | 393px | Compact | Regression |
| iPhone 15 Pro Max | 430px | Compact | Regression |
| iPad Mini | 744px | Medium | New |
| iPad 10th gen | 820px | Medium/Expanded | New |
| iPad Air / Pro 11" | 834px | Expanded | New |
| iPad Pro 12.9" | 1024px | Expanded | New |
| Samsung Galaxy Tab S9 | ~800px | Medium/Expanded | New |
| Pixel Tablet | ~840px | Expanded | New |

---

## Summary of New Files

```
lib/core/responsive/
  breakpoints.dart              # DeviceType enum, Breakpoints utility class
  responsive_builder.dart       # ResponsiveBuilder widget
  responsive_extensions.dart    # context.deviceType, context.isTablet
  tablet_spacing.dart           # TabletSpacing constants

lib/core/widgets/
  adaptive_navigation_rail.dart # Glassmorphic nav rail widget
  master_detail_layout.dart     # Reusable split-pane layout
  adaptive_sheet.dart           # Bottom sheet to dialog adapter
  side_panel.dart               # Fixed-width sidebar container

lib/features/dashboard/presentation/widgets/
  dashboard_tablet_header.dart      # Inline header for tablet (no glass overlay)
  dashboard_categories_donut.dart   # Extracted donut chart for side-by-side layout

lib/features/transactions/presentation/widgets/
  transaction_master_list.dart      # Tablet master pane
  transaction_detail_panel.dart     # Tablet inline detail pane

lib/features/budgets/presentation/widgets/
  budget_card_grid.dart             # 2-column budget card grid
  budget_health_sidebar.dart        # Persistent health sidebar

lib/features/analytics/presentation/widgets/
  report_type_sidebar.dart          # Left report selection list
  report_insights_sidebar.dart      # Right insights + categories panel
  report_chart_panel.dart           # Extracted center chart area

lib/features/groups/presentation/widgets/
  groups_master_list.dart           # Left groups list
  group_expense_panel.dart          # Center expense list
  group_balance_panel.dart          # Balance + settle sidebar

lib/features/settings/presentation/widgets/
  settings_category_sidebar.dart    # Left settings categories
  settings_content_panel.dart       # Right settings content area
```

**Total estimated effort: 15-21 days** for a single developer, assuming familiarity with the codebase.
