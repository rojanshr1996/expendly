# Expendly — Application Coding Rules

Offline-first personal finance tracker. Flutter, Material 3, dark-only "Modern Fiscal Core"
design system. Requirements: [design/Expense_Tracker_SRS.md](design/Expense_Tracker_SRS.md).
Design tokens & visual language: [design/stitch/DESIGN.md](design/stitch/DESIGN.md).

These rules are binding for all new and modified code. Where existing code violates a rule,
the rule wins for anything you touch — fix it in-place rather than copying the violation.

---

## 1. Stack

| Concern | Choice | Notes |
|---|---|---|
| State management | `flutter_bloc` — **Cubit only** | No `Bloc`/events unless a feature genuinely needs an event stream |
| Architecture | Clean Architecture (presentation / domain / data) | Per feature, under `lib/features/<feature>/` |
| DI | `get_it` + `injectable` annotations | Registration is **manual** — see §4 |
| Routing | `auto_route` (`@RoutePage()`, `app_router.dart`) | Generated `app_router.gr.dart` |
| Local DB | `drift` (SQLite), `AppDatabase`, schema v5 | Offline-first; no network data layer |
| Responsiveness | `flutter_screenutil` (`.w`, `.h`, `.sp`, `.r`) | Design size `375×812` |
| Fonts | `google_fonts` (bundled, runtime fetching disabled) | Hanken Grotesk + JetBrains Mono |
| Loading UX | `skeletonizer` via `ShimmerExtension` | See §8 |
| i18n | `flutter_localizations` + ARB (`lib/l10n/app_en.arb`) | `context.l10n.<key>` |
| Charts | `fl_chart` | |
| Equality | `equatable` | All entities and states |

---

## 2. Directory Layout

```
lib/
├── core/                      # cross-feature only — never import from features/
│   ├── config/                # AppConfig, flavors, Firebase options factory
│   ├── constants/             # padding_constants, margin_constants, radius_constants
│   ├── database/              # drift AppDatabase, tables/, enums/
│   ├── di/                    # injection.dart (manual registrations) + generated config
│   ├── error/                 # Failure, exceptions
│   ├── events/                # TransactionEvents app-wide notifier bus
│   ├── extensions/            # context, padding, shimmer, amount formatting
│   ├── gen/                   # flutter_gen output — never hand-edit
│   ├── router/                # AppRouter + generated routes
│   ├── services/              # preference, secure storage, encryption, notification, remote config, export/import
│   ├── theme/                 # app_colors, app_typography, app_theme, app_spacing, app_radius, font_weights
│   ├── usecase/               # UseCase<Type, Params>, NoParams
│   ├── utils/                 # AppLogger
│   └── widgets/               # shared custom components (barrel: custom_widgets.dart)
├── features/<feature>/
│   ├── data/{datasources,models,repositories}
│   ├── domain/{entities,repositories,usecases}
│   └── presentation/{cubit,pages,widgets}
├── l10n/
└── main.dart, main_dev.dart, main_qa.dart, main_prod.dart
```

**Dependency direction is one-way:** `presentation → domain ← data`. `core` may not import
`features`. `domain` may not import Flutter, drift, or any data-layer type.

### Naming

- Files: `snake_case.dart`. Datasources end in `_local_datasource.dart` (not `_local_data_source.dart`).
- Pages: `<name>_page.dart` → `class XPage`. Route name is auto-derived (`Page` → `Route`).
- Cubits: `<feature>_cubit.dart` / `<feature>_state.dart`.
- Shimmers: `<screen>_shimmer.dart` → `class XShimmer`.
- Shared components: `app_*.dart` prefix (`AppButton`, `AppTextField`, `AppToggleTile`).
- Private widgets in the same file: leading underscore (`_MetricTile`).

---

## 3. Clean Architecture Rules

### Domain
- Entities extend `Equatable` with a complete `props` list. Immutable, `const` constructors.
- Repository contracts are abstract classes returning domain entities only.
- Use cases implement `UseCase<ReturnType, Params>` with a single `call(params)`; use
  `NoParams()` when there are no arguments. Annotate `@lazySingleton`.
- Never reference `drift`, `BuildContext`, or `Model` types here.

### Data
- `abstract class XLocalDataSource` + `@LazySingleton(as: XLocalDataSource) class XLocalDataSourceImpl`.
  Datasources own all drift queries and map rows → domain entities.
- `@LazySingleton(as: XRepository) class XRepositoryImpl` — thin delegation, no business logic,
  no drift imports.
- Models (`data/models/`) extend their entity and add `fromJson` / `toJson`. Only add a model
  when serialization is actually needed; otherwise datasources may build entities directly.
- **Money is stored as integer cents in the DB** and converted at the datasource boundary
  (`tx.amount / 100.0` in, `(amount * 100).round()` out). Never store doubles.

### Presentation
- Pages hold no business logic — they read state from a Cubit and delegate callbacks.
- Cross-feature access goes through a Cubit or `getIt`, never by importing another feature's
  datasource/repository implementation. Constructing a repository inline as a "fallback"
  (as some pages do today) is **not** an accepted pattern — fix the DI registration instead.

---

## 4. Dependency Injection

`configureDependencies()` in [lib/core/di/injection.dart](lib/core/di/injection.dart) performs
**manual, idempotent** registration. The generated `injection.config.dart` exists but is not
invoked. Therefore:

- Every new datasource / repository / use case / cubit **must be added manually** to
  `configureDependencies()`, guarded by `if (!getIt.isRegistered<T>())`.
- Keep the `@injectable` / `@LazySingleton(as: ...)` annotations on the class as well, so the
  generated config stays consistent for a future switch to `getIt.init()`.
- Lifetimes: services, datasources, repositories, use cases → `registerLazySingleton`.
  Cubits that hold screen-scoped state → `registerFactory`. Cubits that must be shared
  app-wide (`ProfileCubit`, `BudgetCubit`) → `registerLazySingleton`.
- Resolve with `getIt<T>()`. Do not add new `try { getIt<T>() } catch (_) { /* fallback */ }`
  blocks — a missing registration is a bug, not a runtime branch.

---

## 5. State Management (Cubit)

State classes live in `<feature>_state.dart`:

```dart
abstract class XState extends Equatable {
  const XState();
  @override
  List<Object?> get props => [];
}

class XInitial extends XState {}
class XLoading extends XState {}
class XLoaded  extends XState { final Data data; const XLoaded(this.data); ... }
class XError   extends XState { final String message; const XError(this.message); ... }
class XActionSuccess extends XState { final String message; const XActionSuccess(this.message); ... }
```

Rules:
- One `Loading` state per cubit; the page maps it to a **shimmer** (§8).
- Always `emit` a terminal state in `catch` — never leave a cubit stuck in `Loading`.
- Derived/filtered data belongs on the state (see `TransactionLoaded.filteredTransactions`),
  not recomputed in the widget tree.
- Provide with `BlocProvider(create: (_) => getIt<XCubit>()..load())`. Consume with
  `BlocBuilder` for rebuilds, `BlocListener` for toasts/navigation, `BlocSelector` when only
  one field of the state drives the rebuild.
- Cross-feature refresh uses the `TransactionEvents.transactionUpdated` notifier bus:
  subscribe in the constructor, **always** `removeListener` in `close()`, and guard callbacks
  with `if (!isClosed)`. Do not reach into another cubit directly from a cubit unless it is
  registered as a singleton and the intent is an explicit refresh.
- Cubits never touch `BuildContext`, `Navigator`, or widgets.
- Cubits never emit display copy. `XError` / `XActionSuccess` carry a **semantic identifier**
  (enum or key) that the page resolves through `context.l10n` — see §9.

---

## 6. Widgets, Rebuilds & Notifiers

### Prefer `StatelessWidget`
Extract every visually distinct block into its own `StatelessWidget` — a named public widget
in `presentation/widgets/` if reused or non-trivial, a private `_Foo` widget in the same file
if local. **Do not** write `Widget _buildSomething(BuildContext context)` helper methods;
they defeat const-ness and subtree rebuild skipping. Existing `_build*` methods should be
converted when the surrounding code is edited.

### Notifiers instead of `setState`
Local UI state (tab index, privacy toggle, selected chip, expanded flag, form step, picked
date) must use `ValueNotifier` + `ValueListenableBuilder` so only the dependent subtree
rebuilds. `setState` is permitted only when there is genuinely no narrower scope
(e.g. `initState`-driven async bootstrapping of the whole screen).

```dart
// ✅ scoped rebuild
final ValueNotifier<int> _currentTabNotifier = ValueNotifier<int>(0);

ValueListenableBuilder<int>(
  valueListenable: _currentTabNotifier,
  builder: (context, currentTab, _) => IndexedStack(index: currentTab, children: [...]),
)

// ❌ rebuilds the whole page
setState(() => _currentTab = index);
```

- A `StatefulWidget` that exists only to own notifiers is fine — **dispose every notifier**
  in `dispose()`.
- Pass a shared notifier down as a constructor field (e.g. `isPrivacyModeNotifier`) instead of
  re-lifting state or duplicating it per child.
- Mark constructors `const` wherever possible; `prefer_const_constructors` is an enabled lint.
- Wrap long/unbounded lists in `ListView.builder`; never `Column` + `List.generate` over
  unbounded data.

---

## 7. Theming, Typography & Design Tokens

**All styling comes from `BuildContext`.** `BuildContextExtension`
([lib/core/extensions/context_extensions.dart](lib/core/extensions/context_extensions.dart))
provides: `context.theme`, `context.colorScheme`, `context.textTheme`, `context.customColors`,
`context.customTypography`, `context.l10n`.

### Typography — hard rules
1. **Never construct a raw `TextStyle(fontSize: ..., fontWeight: ...)` for text that has a
   matching style** in [app_typography.dart](lib/core/theme/app_typography.dart). Use the
   token and `copyWith` only for color/one-off overrides.
2. **Never call `GoogleFonts.*` outside `app_typography.dart`.** Never hardcode
   `fontFamily: 'JetBrainsMono'` or `'HankenGrotesk'` — take it from `customTypography`.
3. **Never hardcode `FontWeight.w600`** — use `FontWeights.semiBold` etc. from
   [font_weights.dart](lib/core/theme/font_weights.dart).
4. If a needed style does not exist, **add it to `AppTypography` + `AppCustomTypography`**
   (field, `copyWith`, `lerp`, `dark`) and register it — do not inline it at the call site.

| Use for | Token |
|---|---|
| Page/section headlines | `context.textTheme.headlineLarge` / `headlineMedium` |
| Mobile hero headline | `context.customTypography.headlineLargeMobile` |
| Body copy | `context.textTheme.bodyLarge` / `bodyMedium` |
| Emphasised body | `context.customTypography.bodyLargeBold` |
| Card/list titles | `context.textTheme.titleMedium` |
| Metadata, captions | `context.textTheme.labelMedium` / `labelSmall` |
| **Any monetary amount, currency code, timestamp** | `context.customTypography.amountDisplay` / `amountLarge` / `labelMediumMono` / `headlineMediumMonoBold` / `headlineLargeMonoBold` (JetBrains Mono — mandatory) |

```dart
// ✅
Text(label, style: context.customTypography.labelMediumMono
    .copyWith(color: context.colorScheme.onSurfaceVariant));
Text(amount, style: context.customTypography.amountLarge);

// ❌
Text(label, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500));
Text(amount, style: GoogleFonts.jetBrainsMono(fontSize: 24.sp));
```

### Colors
- Use `context.colorScheme.*` for Material roles (`surface`, `primary`, `onSurfaceVariant`,
  `outline`, `outlineVariant`, `error`, `surfaceContainer*`).
- Use `context.customColors.*` for design-system-only roles: `surfaceLowest`, `surfaceLow`,
  `surfaceMid`, `semanticRed` (expense), `semanticGreen` (income), `glassStroke`.
- Direct `AppColors.X` references are allowed **only** inside `lib/core/theme/` and in
  `const` default parameter values where a context is unavailable. Everywhere else, go
  through context.
- Opacity: use `.withValues(alpha: 0.12)`. `withOpacity` is deprecated;
  `withAlpha((x * 255).round())` is legacy — prefer `withValues` in new code.
- Semantic meaning is fixed: **red = expense/outflow, green = income/inflow.**

### Spacing, radius, sizing
- Every dimension is responsive: `.w` (width/horizontal), `.h` (height/vertical), `.sp`
  (font size), `.r` (radius). Raw pixel literals in layout are not allowed.
- Vertical/horizontal gaps: `verticalMarginSmall`, `horizontalMarginMedium`, … from
  [margin_constants.dart](lib/core/constants/margin_constants.dart) (dominant convention),
  or `AppSpacing.gap*`. Pick one per file; do not mix within a widget.
- Padding: `padding_constants.dart` values (`symmetricPaddingMedium`, `horizontalPaddingLarge`)
  or the `PaddingExtension` helpers (`.defaultCanvasPadding()` = 24px canvas margin).
- Radius: prefer `AppRadius.borderDefault/borderMd/borderLg/borderXl`. `BorderRadius.circular(N.r)`
  is acceptable only for values outside the token scale.
- Layout rhythm from the design system: **24px** between major sections, **16px** between list
  items, **8px** between a label and its value, 24px screen side margins, content capped at
  `maxWidth: 600` for tablet.
- Shape language: buttons/inputs `8px`, cards/sheets `16px`, chips `24px`.

### Component reuse
Before writing new UI, check [lib/core/widgets/](lib/core/widgets/) (barrel:
`custom_widgets.dart`): `AppButton` (6 variants, `isLoading`), `AppTextField` (`isAmount`
switches to mono + numeric keyboard, auto-unfocus on tap outside), `AppToggleTile`,
`AppSelectionTile`, `AppProgressBar`, `CustomKeypad`, `CategoryPickerSheet`, `GlassContainer`,
`GlassHeader`, `AppEmptyState`, `AppLoadingIndicator`, `StatusComponents.showToast` /
`showConfirmationBottomSheet`, `CompactAmountText`, `ShimmerBox`.

Extend an existing component with a new optional parameter rather than forking it. New
shared components go in `core/widgets/` **and** get exported from `custom_widgets.dart`.
Shared components accept already-localized strings from the caller — no English default
parameter values (§9).
Cards and elevated surfaces use `GlassContainer` (1px `glassStroke` border, no drop shadows —
depth comes from tonal layers and blur).

---

## 8. Loading, Empty & Error States

Every screen that loads data must handle four branches:

```dart
if (state is XLoading) return const XShimmer();
if (state is XError)   return /* error view using colorScheme.error */;
if (state is XLoaded)  return data.isEmpty ? const AppEmptyState(...) : /* content */;
return const SizedBox.shrink();
```

- **Full-screen loading is always a shimmer**, never a `CircularProgressIndicator`. Build a
  `<screen>_shimmer.dart` `StatelessWidget` that mirrors the real layout with representative
  placeholder content, then `.animateShimmer()` on the root
  ([shimmer_extensions.dart](lib/core/extensions/shimmer_extensions.dart)).
- Shimmer bodies use `NeverScrollableScrollPhysics` and reuse the real widgets/`GlassContainer`
  so the skeleton matches the loaded layout.
- Inline/partial loading: `ShimmerBox(...).animateShimmer()` or `AppButton(isLoading: true)`.
- Empty states use `AppEmptyState` or a feature-specific empty view with a primary CTA.
- Errors surface via `StatusComponents.showToast(context, message: ..., isError: true)` for
  transient failures, or an inline error view for a failed page load.
- All titles, descriptions, CTA labels and error text in these branches are localized (§9).
  Shimmer placeholder text is the one exception — it is masked into bones and never read.

---

## 9. Localization — **Always use `context.l10n`, never static text**

**Every string a user can read must come from ARB.** No exceptions for "temporary" copy,
placeholders, error messages, or debug-looking labels. Add the key to
[lib/l10n/app_en.arb](lib/l10n/app_en.arb), run `rps generator build`, and read it via
`context.l10n.<key>`.

```dart
// ✅
Text(context.l10n.totalBalance)
AppTextField(labelText: context.l10n.phoneNumberOptional, hintText: context.l10n.phoneHint)
IconButton(tooltip: context.l10n.calendarView, ...)
StatusComponents.showToast(context, message: context.l10n.transactionSaved, isSuccess: true)

// ❌
Text('Total Balance')
AppTextField(labelText: 'Phone Number (Optional)', hintText: 'e.g. +1 234 567 8900')
IconButton(tooltip: 'Calendar View', ...)
StatusComponents.showToast(context, message: 'Transaction saved successfully')
```

### This applies to every user-visible surface

`Text` / `RichText` / `TextSpan` · button and FAB labels · `labelText`, `hintText`, `errorText`,
`helpText`, `counterText` · `tooltip` and `semanticLabel` · `AppBar` titles · bottom-sheet and
dialog titles, bodies, and confirm/cancel labels · `AppEmptyState` title/description/action ·
toast and snackbar messages · date/time picker `helpText` · chart axis and legend labels ·
validator return messages · notification titles and bodies.

### Naming & authoring keys

- Keys are `lowerCamelCase` and describe **meaning**, not location: `budgetSavedSuccessfully`,
  not `budgetPageToastText2`.
- Give every key an `@key` entry with a `description` so translators have context.
- Parameterise with ARB placeholders — never concatenate or interpolate at the call site:
  ```json
  "errorMessage": "Something went wrong: {message}",
  "@errorMessage": { "placeholders": { "message": { "type": "String" } } }
  ```
  ```dart
  Text(context.l10n.errorMessage(state.message))   // ✅
  Text('Error: ${state.message}')                  // ❌
  ```
- Use ARB `plural` / `select` for count- and gender-dependent copy rather than building the
  sentence in Dart (`{count, plural, =0{No transactions} =1{1 transaction} other{{count} transactions}}`).
- Reuse an existing key before adding a near-duplicate — the ARB already has ~660 keys.

### Strings outside the widget tree

Cubits, use cases, repositories, and datasources **must not** produce display copy — they have
no `BuildContext` (§5). Instead they emit a **semantic identifier**, and the presentation layer
maps it to `context.l10n`:

```dart
// ✅ cubit emits meaning
enum BudgetMessage { saved, removed, deleteFailed }
emit(const BudgetActionSuccess(BudgetMessage.saved));

// presentation resolves it
String _label(BuildContext context, BudgetMessage m) => switch (m) {
      BudgetMessage.saved        => context.l10n.budgetSaved,
      BudgetMessage.removed      => context.l10n.budgetRemoved,
      BudgetMessage.deleteFailed => context.l10n.budgetDeleteFailed,
    };

// ❌ cubit emits English
emit(const BudgetActionSuccess('Budget saved successfully'));
```

Raw exception text (`e.toString()`) is for `AppLogger` only — never surface it to the user.
Show a localized, user-safe message instead.

### Shared components take localized strings from the caller

Widgets in `core/widgets/` must not carry English default parameter values. Make the parameter
required, or nullable with the call site supplying `context.l10n.*`:

```dart
// ❌ status_components.dart
static Future<bool?> showConfirmationBottomSheet(BuildContext context, {
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
})

// ✅ — required, or resolve the fallback from context inside the component
  required String confirmLabel,
  required String cancelLabel,
```

### Narrow, explicit exceptions

Only these are allowed to be literals:

- **Skeletonizer shimmer placeholder text.** `Skeletonizer` masks glyphs into bones, so the
  string only reserves layout width and is never read. Keep it generic
  (`'Category Name'`) — never real product copy.
- **Non-linguistic tokens:** currency codes from data, category names from the DB, icon names,
  route paths, storage/preference keys, log messages, and test fixtures.
- **`design/` and generated files.**

Locale-sensitive values still go through their own facilities, not literals: currency symbols
from `PreferenceService.currencySymbol` (never a hardcoded `$`), amounts via the formatting
extensions (§10), and dates via `intl` `DateFormat` with the active locale — never a
hand-built `'Mon'` / `'Jan'` array.

Supported locales are declared in `main.dart`; adding a locale means adding
`lib/l10n/app_<code>.arb` with the full key set.

---

## 10. Formatting Money

Use [amount_formatting_extensions.dart](lib/core/extensions/amount_formatting_extensions.dart):
`amount.formatCurrency(symbol, isPrivacyMode: ..., compact: ..., showSign: ..., isIncome: ...)`,
or the `CompactAmountText` widget (handles compaction, overflow scaling, privacy mode and a
tap-to-reveal full-amount tooltip). Do not call `toStringAsFixed(2)` directly in widgets.
Privacy mode (`isPrivacyModeNotifier`) must be honoured by every widget that renders an amount.

---

## 11. Routing

- Pages reachable by route are annotated `@RoutePage()` and registered in
  [app_router.dart](lib/core/router/app_router.dart).
- Navigate with `context.router.push(const XRoute())`; pop results with
  `context.router.pop(true)`. Do not mix in raw `Navigator.push(MaterialPageRoute(...))` for
  routed pages.
- After an `await` on navigation, guard with `if (!mounted) return;` before using `context`
  (`use_build_context_synchronously` is enabled). Capture `context.read<XCubit>()` **before**
  the await.
- Tab content inside the dashboard shell is composed via `IndexedStack`, not routes.

---

## 12. Errors, Logging & Services

- Data layer throws `DatabaseException` / `CacheException`; domain-level results use
  `Failure` subclasses. Cubits convert to an `XError` state with a user-safe message.
- Log with `AppLogger.d/i/w/e/f` — never `print`. Logging is flavor-filtered
  (dev: everything, qa: info+, prod: warning+).
- Sensitive values (PIN, encryption keys) go through `SecureStorageService`; non-sensitive
  preferences through `PreferenceService` (which caches in memory for sync reads).
- Flavors: `main_dev.dart` / `main_qa.dart` / `main_prod.dart` all delegate to
  `bootstrapApp(AppConfig(...))` in `main.dart`. Gate flavor behaviour on
  `AppConfig.instance.isDev/isQa/isProd`.

---

## 13. Database

- Tables live in `lib/core/database/tables/`, enums in `enums/database_enums.dart`.
- Any schema change: bump `schemaVersion` **and** add an `onUpgrade` branch (`if (from < N)`)
  in [app_database.dart](lib/core/database/app_database.dart). Never mutate an existing
  migration branch.
- Foreign keys are enforced (`PRAGMA foreign_keys = ON`); default categories are seeded in
  `beforeOpen`.
- Regenerate after any drift/injectable/auto_route/ARB change:
  ```
  rps generator build      # dart run build_runner build --delete-conflicting-outputs
  ```
- Generated files (`*.g.dart`, `*.gr.dart`, `lib/core/gen/**`, `injection.config.dart`,
  `app_localizations*.dart`) are never hand-edited and are excluded from analysis.

---

## 14. Testing

- Tests mirror `lib/` under `test/` (`test/features/<feature>/presentation/pages/...`).
- Use `AppDatabase.forTesting(NativeDatabase.memory())` for data-layer tests.
- Cubit tests assert the emitted state sequence; widget tests wrap in `ScreenUtilInit` +
  `MaterialApp` with `AppTheme.darkTheme` and the localization delegates.
- Add or update tests when changing datasource queries, cubit state transitions, or shared
  `core/widgets` components.

---

## 15. Lints & Style

`analysis_options.yaml` is authoritative. Notably enforced: `prefer_const_constructors`,
`prefer_const_declarations`, `always_declare_return_types`, `curly_braces_in_flow_control_structures`,
`cancel_subscriptions`, `close_sinks`, `use_build_context_synchronously`,
`avoid_relative_lib_imports`.

- Imports: `dart:` → `package:` → relative, each group alphabetized, blank line between groups.
  Relative imports within the app (`../../core/...`); `package:expendly/...` is tolerated but
  relative is the convention.
- Public classes and non-obvious members carry `///` doc comments — match the density of the
  surrounding file.
- Run before considering work done:
  ```
  flutter analyze
  flutter test
  ```

---

## 16. Known Deviations (fix on touch, don't propagate)

- `dashboard_cash_flow_chart.dart` hardcodes `fontFamily: 'JetBrainsMono'` → use
  `context.customTypography`.
- Shimmer widgets and `settings_page.dart` / `final_setup_page.dart` build raw `TextStyle`s →
  replace with typography tokens.
- `all_transactions_page.dart`, `budgets_overview_page.dart`, `create_new_budget_page.dart`,
  `settings_page.dart`, `personal_profile_page.dart`, `profile_form_sheet.dart`,
  `modern_add_transaction_page.dart`, `dashboard_cash_flow_chart.dart` still use `setState` →
  migrate to `ValueNotifier`.
- `dashboard_page.dart` / `all_transactions_page.dart` contain `_Fallback*` DI escape hatches
  and inline repository construction → remove once DI registration is trusted.
- `_buildOverviewTab`-style helper methods → extract to `StatelessWidget`s.
- **Hardcoded user-facing strings still to move into ARB (§9):**
  - `app_update_guard.dart` — `'Update Now'`, `'Later'`, `'Update'`.
  - `all_transactions_page.dart` — `'SELECT MONTH & YEAR'`, `'Calendar View'`, `'List View'`,
    `'Clear Date Filter'`.
  - `modern_add_transaction_page.dart` — `'e.g. 5.00'`, `'Add note (optional)...'`.
  - `profile_form_sheet.dart` — `'Phone Number (Optional)'`, `'e.g. +1 234 567 8900'`.
  - `create_new_budget_page.dart` — `'Weekly'`, `'Monthly'`, `'Yearly'`.
  - `compact_amount_text.dart` — `'Full Exact Amount'`, `'Tap to see full amount'`.
  - `status_components.dart` — `confirmLabel = 'Confirm'`, `cancelLabel = 'Cancel'` defaults;
    `custom_keypad.dart` — `submitLabel = 'Done'` default.
  - `dashboard_cash_flow_chart.dart` — hardcoded weekday labels (`'Mn'`…`'Sn'`, `'N/A'`) →
    `intl` `DateFormat.E()` on the active locale.
  - `transaction_cubit.dart` / `budget_cubit.dart` — English strings emitted from cubits
    (`'Transaction saved successfully'`, `'Budget removed'`, `'Failed to delete budget: …'`)
    → emit a semantic identifier and resolve in the page.
