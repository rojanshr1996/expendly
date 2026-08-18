# 💰 Expendly

**Expendly** is a personal finance management and shared expense splitting mobile application built with Flutter, featuring an offline-first architecture, clean layered code structure, and a modern fiscal design system.

---

## 📖 About

**Expendly** is a privacy-first, offline personal finance tracker and group bill splitter built for people who want full control over their financial data — without ever sending it to the cloud.

Designed around the principle of **Fiscal Calm**, Expendly gives you a clear, distraction-free view of your income, expenses, budgets, and shared group costs — entirely on your device. Whether managing daily personal finances or splitting trip expenses with friends, there is no account required, no cloud sync, and no telemetry. Your data stays yours.

### Core Philosophy

| Pillar | Description |
| :--- | :--- |
| 🔒 **100% Offline & Private** | All financial data is stored strictly on-device. No cloud sync, no tracking, zero telemetry. |
| 📱 **Local-First Storage** | Transactions, group events, splits, and settings are persisted securely via Drift SQLite on Android & iOS. |
| 👥 **Smart Bill Splitting** | Effortlessly organize group events, split expenses (equal, exact, percentage with auto-balancing), and calculate simplified debt settlements. |
| 🏗️ **Modern Fiscal Architecture** | Built with Flutter Clean Architecture, `flutter_bloc` Cubits, and a custom fiscal design system. |
| 🎨 **Premium Design System** | Custom HSL color palettes, HankenGrotesk typography, and a responsive layout powered by `flutter_screenutil`. |

### Who is it for?

Expendly is ideal for individuals who:
- Want a **simple, fast, and beautiful** expense tracker and group bill splitter without signing up for an account.
- Split trips, dinners, household bills, and group events with friends, roommates, or family.
- Value **privacy** and don't want financial data sent to third-party servers.
- Prefer a **native mobile experience** over web-based budgeting and bill-splitting tools.

> *"Expendly • Designed for Fiscal Calm"*

---

## 🌟 Key Features

- 👥 **Smart Bill Splitting & Group Expenses**:
  - Create and manage events, trips, and shared group activities with custom categories and participant avatars.
  - Split expenses flexibly: **Equal split**, **Exact amounts** with intelligent auto-balancing of remainders, or **Percentage splits**.
  - Automated debt simplification engine minimizing the number of transactions needed to settle up.
  - Direct email reminders with personalized settlement details and creditor context.
  - Settle up debts with partial or full payments and export clean settlement reports.
- 📊 **Personal Finance & Analytics**: Track income and expenses with interactive charts, categorized spending breakdowns, and weekly/monthly summaries.
- 🎯 **Budget Planning**: Set category-specific budgets with visual progress indicators and overspend alerts.
- 📱 **Modern Fiscal Core Design**: Custom theme extensions, tailored HSL color palettes, liquid glass UI elements, and responsive typography scaling using `flutter_screenutil`.
- ⚡ **Offline-First Architecture**: High performance with zero runtime network dependencies for essential assets and font rendering.
- 🔀 **Multi-Flavor Support**: Built-in support for `dev`, `qa`, and `prod` environment configurations with flavor-specific app icons and branding banners.
- 🏗️ **Clean Architecture & BLoC**: Decoupled presentation, domain, and data layers powered by `flutter_bloc`.
- 💉 **Dependency Injection**: Automated service locator setup using `get_it` and `injectable`.
- 🧭 **Declarative Routing**: Strongly typed URL and deep-link navigation using `auto_route`.

---

## 🛠️ Technology Stack

| Component | Library / Framework |
| :--- | :--- |
| **Framework** | [Flutter](https://flutter.dev/) (SDK `>=3.0.0 <4.0.0`) |
| **Database** | [Drift](https://drift.simonbinder.eu/) (SQLite offline-first persistence) |
| **State Management** | [flutter_bloc](https://pub.dev/packages/flutter_bloc) |
| **Dependency Injection** | [get_it](https://pub.dev/packages/get_it) & [injectable](https://pub.dev/packages/injectable) |
| **Navigation & Routing** | [auto_route](https://pub.dev/packages/auto_route) |
| **Typography & Fonts** | [google_fonts](https://pub.dev/packages/google_fonts) (*bundled offline assets*) |
| **Screen Adaptation** | [flutter_screenutil](https://pub.dev/packages/flutter_screenutil) |
| **Script Automation** | [rps](https://pub.dev/packages/rps) (*Run Pub Scripts*) |
| **Icon Generation** | [flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons) |

---

## 📁 Project Structure

```text
lib/
├── core/
│   ├── ads/             # AdMob helpers, banners, and interstitial managers
│   ├── config/          # Environment flavor configuration (dev, qa, prod)
│   ├── database/        # Drift SQLite database, DAOs, and migrations
│   ├── di/              # Dependency injection setup (GetIt & Injectable)
│   ├── error/           # Core failures & exception handling
│   ├── extensions/      # BuildContext extensions (l10n, theme, colors)
│   ├── router/          # AutoRoute configuration & generated routes
│   ├── services/        # Local notification, backup, and preference services
│   ├── theme/           # Design tokens (Colors, Typography, Spacing, Radius)
│   └── widgets/         # Reusable liquid glass UI components & animated elements
├── features/
│   ├── splash/          # Animated splash screen & initial route guard
│   ├── dashboard/       # Financial summary, metric tiles, & transaction list
│   ├── transactions/    # Income/expense tracking & categorized ledger
│   ├── budgets/         # Budget planning, limits, and progress tracking
│   ├── analytics/       # Cashflow analysis, reports, and charts
│   ├── groups/          # Bill splitting, group events, debt calculation, & settlements
│   └── settings/        # Preferences, currency selection, security, & backup
├── l10n/                # Internationalization & localization delegates
├── main_dev.dart        # Development flavor entrypoint
├── main_qa.dart         # QA flavor entrypoint
├── main_prod.dart       # Production flavor entrypoint
└── main.dart            # Shared bootstrap initializer
```

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (version `>= 3.0.0`)
- Android Studio / Xcode for mobile emulators & device deployments

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/rojanshr1996/expendly.git
   cd expendly
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Generate code** (*AutoRoute & Injectable*):
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
   *or using the script runner:*
   ```bash
   dart run rps generator build
   ```

---

## 🎛️ Running Environment Flavors

Expendly supports three separate environment flavors:

### 🛠️ Development (`dev`)
```bash
flutter run -t lib/main_dev.dart --flavor dev
```

### 🧪 QA (`qa`)
```bash
flutter run -t lib/main_qa.dart --flavor qa
```

### 🚀 Production (`prod`)
```bash
flutter run -t lib/main_prod.dart --flavor prod
```

---

## 📜 Script Commands (`rps`)

This project uses [`rps`](https://pub.dev/packages/rps) for script execution. Available scripts in `pubspec.yaml`:

| Command | Action |
| :--- | :--- |
| `dart run rps generator build` | Runs `build_runner` to generate code for AutoRoute & Injectable. |
| `dart run rps buildapk` | Builds a production-ready Android release APK (`arm64`). |
| `dart run rps buildios` | Builds an iOS release IPA. |
| `dart run rps reset` | Cleans the build directory, gets dependencies, and regenerates code. |
| `dart run rps sonarTest` | Runs flutter tests with coverage output. |

---

## 🎨 Launcher Icons Configuration

App launcher icons are generated per flavor using `flutter_launcher_icons`:

```bash
# Generate dev icons
dart run flutter_launcher_icons -f flutter_launcher_icons-dev.yaml

# Generate QA icons
dart run flutter_launcher_icons -f flutter_launcher_icons-qa.yaml

# Generate Prod icons
dart run flutter_launcher_icons -f flutter_launcher_icons-prod.yaml
```

---

## 📄 License

This project is proprietary and intended for personal finance management. All rights reserved.
