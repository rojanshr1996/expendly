# Simple Expense Tracker Application (Flutter)
## Software Requirements Specification (SRS)

**Version:** 2.0  
**Platform:** Flutter (Android, iOS, Tablet)  
**Storage:** Local Database (SQLite/Isar)  
**App Type:** Offline-First Simple Expense Tracking Application  
**Reference Design:** Cashew App (Strict Expense Tracking Model)

---

# 1. Overview

## 1.1 Purpose

The purpose of this application is to provide users with a clean, fast, and intuitive expense tracking application. Inspired by lightweight design principles (such as those in the Cashew App), the application focuses strictly on daily cash flow, category-based spending, income logs, and straightforward budgeting.

To maintain simplicity, all complex personal finance and accounting features—such as **Net Worth, Assets, Liabilities, Balance Sheets, Financial Ratios, and Multi-Account Type Management**—have been completely omitted.

---

# 2. Core Objectives

## Primary Goals

- **Offline-First Operation:** All spending and income logs remain securely stored on the user's local device.
- **Fast Transaction Entry:** Minimal taps required to log daily expenses and income.
- **Category & Subcategory Budgeting:** Monitor spending against pre-defined or custom category budgets.
- **Visual Spending Analytics:** Clean pie charts, bar graphs, and heatmaps for daily/monthly trends.
- **Flexible Data Management:** Local backup, restore, and CSV/Excel import and export.
- **Secure Local Access:** Protection via PIN or Biometrics.

---

# 3. Technical Architecture

## Frontend
- **Framework:** Flutter
- **Design Language:** Material Design 3 (Responsive Layout, Dark/Light/AMOLED Modes, Dynamic Color support)
- **Target Platforms:** Android, iOS, Tablet

## Local Database
- **Option 1 (Preferred):** Isar (High performance, NoSQL, reactive queries, optimized for Flutter)
- **Option 2:** SQLite / sqflite (Relational structure, mature ecosystem)

## State Management & Architecture
- **State Management:** Riverpod / Bloc
- **Architecture Pattern:** Clean Architecture (Presentation, Domain, Data)

---

# 4. Authentication & Security

- **PIN Lock:** 4-digit or 6-digit numeric passcode.
- **Biometric Authentication:** Fingerprint scan and Face Recognition.
- **Security Options:** Auto-lock on app inactivity, toggle visibility of monetary totals.

---

# 5. Dashboard (Home Screen)

The Dashboard provides an immediate overview of daily and monthly spending habits without displaying personal net worth or total wealth statements.

## Summary Cards
- **Monthly Expenses:** Total spent in the current month.
- **Monthly Income:** Total earned in the current month.
- **Remaining Budget:** Real-time remaining balance for active spending budgets.
- **Cash Flow Summary:** Difference between monthly income and expenses.

## Quick Statistics & Charts
- **Today's Expense & Income:** Quick view of current day logs.
- **Expense Breakdown Chart:** Interactive Pie / Donut chart by category.
- **Daily Spending Pattern:** Bar chart or heatmap showing spending density over time.

---

# 6. Category & Subcategory Management

Organizing transactions through simple categories and subcategories.

## Expense Categories & Subcategories
- **Food & Dining:** Groceries, Restaurants, Coffee, Fast Food
- **Transportation:** Fuel, Public Transit, Taxi/Rideshare, Parking
- **Housing & Bills:** Rent, Electricity, Water, Internet, Phone
- **Entertainment:** Movies, Games, Streaming Subscriptions
- **Shopping:** Clothing, Electronics, Personal Care
- **Health:** Pharmacy, Doctor Visits
- **Education & Work:** Books, Courses, Office Supplies

## Income Categories
- Salary / Wages
- Freelance / Business
- Gifts & Allowances
- Refunds / Cashback
- Investment Dividends (logged simply as income)
- Other Income

---

# 7. Transaction Management

The core component of the app for logging and updating financial transactions.

## Transaction Types
1. **Expense:** Outflow of money.
2. **Income:** Inflow of money.

## Transaction Entry Fields
- **Amount** (Required)
- **Category & Subcategory** (Required)
- **Date & Time** (Defaults to current time)
- **Note / Description** (Optional)
- **Tags** (Optional, e.g., `#vacation`, `#work`)
- **Receipt Attachment** (Image capture/upload)

## Receipts
- Capture via camera or upload from gallery.
- Supported Formats: JPG, PNG, PDF.

---

# 8. Recurring Transactions & Bill Reminders

Automate periodic expenses and income entries.

- **Recurrence Frequencies:** Daily, Weekly, Monthly, Yearly.
- **Use Cases:** Monthly Rent, Internet Bills, Subscriptions, Salary.
- **Notifications:** Push reminders before scheduled bills or recurring entries execute.

---

# 9. Quick Entry & Bookmarks

- **One-Tap Shortcuts:** Save frequently repeated expenses (e.g., "$5 Coffee - Food").
- **Quick Add Floating Action Button (FAB):** Accessible from primary screens to log transactions instantly.

---

# 10. Budget Management

Simple category-based and periodic spending caps.

## Budget Types
- **Monthly Category Budget:** Set spending limits for specific categories (e.g., $300/month for Dining).
- **Overall Monthly Spending Cap:** Set a cap for total monthly expenditure.

## Monitoring & Alerts
- Progress bar showing percentage consumed.
- Visual alerts at 50%, 75%, 90%, and 100% threshold breach.

---

# 11. Search & Filter System

- **Text Search:** Filter transactions by notes, tags, or category names.
- **Advanced Filters:** 
  - Date Range (Today, This Week, Custom Range)
  - Transaction Type (Expense vs. Income)
  - Category / Subcategory
  - Amount Range

---

# 12. Reports & Visual Analytics

Visual representation of spending behavior.

## Expense Analytics
- **Category Breakdown:** Percentage and totals spent per category.
- **Subcategory Analysis:** Detailed breakdown inside each top category.
- **Spending Trends:** Line graph comparing weekly/monthly expense patterns over time.

## Income Analytics
- Income sources distribution and monthly comparison.

## Budget vs. Actual Report
- Comparison showing planned budget limits against actual spending totals.

---

# 13. Data Import & Export

## Export Capabilities
- **Formats:** CSV, Excel (.xlsx), PDF Summaries, JSON.
- **Options:** Export all transactions or filter by date range.

## Import Capabilities
- **Formats:** CSV, JSON.
- **Data Validation:** Prevents duplicates and handles missing category mappings gracefully.

---

# 14. Local Backup & Restore

- **Local Backup:** Save encrypted app database to local device storage.
- **Automatic Local Backups:** Configurable frequency (Daily, Weekly, Monthly).
- **Manual Restore:** Restore application state from backup files.

---

# 15. Multi-Currency Support

- Primary Base Currency selection.
- Manual exchange rate configuration for multi-currency transaction logging.

---

# 16. Application Settings

- **Appearance:** Light Mode, Dark Mode, AMOLED Pitch Black, System Default.
- **Formatting:** Date format, First day of week, Decimal precision.
- **Data & Storage:** Clear data, export/import options, local backups.
- **Security:** Toggle PIN/Biometric lock, change PIN.

---

# 17. Monetization & Ad Strategy

## Free Version
- Core expense and income logging features.
- Category budgets and spending reports.
- Supported by non-intrusive banner ads (Dashboard bottom, Reports footer) and limited interstitial ads (after exporting or restoring backups).
- **Strict Rule:** No advertisements during transaction entry or editing.

## Premium Version (In-App Purchase / Subscription)
- Completely ad-free experience.
- Encrypted local backup files (AES-256).
- Advanced analytics, PDF export customization, and extra visual themes.
- Custom homescreen widgets (Android/iOS).

---

# 18. Minimum Database Entities

1. `UserSettings` (Currency, Theme, Passcode Settings)
2. `Category` (ID, Name, Icon, Color, Type [Income/Expense])
3. `Subcategory` (ID, ParentCategoryID, Name)
4. `Transaction` (ID, Type, Amount, CategoryID, SubcategoryID, Timestamp, Note, AttachmentPath, Tags)
5. `Budget` (ID, CategoryID, TargetAmount, Period)
6. `RecurringTransaction` (ID, TransactionData, Frequency, NextDueDate)
7. `Attachment` (ID, TransactionID, FilePath)

---

# 19. Application Screen Architecture

```
START
│
├── Splash Screen
├── Security Verification (PIN / Biometrics)
└── Dashboard (Main View)
    │
    ├── Quick Add Transaction (+)
    │   ├── Add Expense Screen
    │   └── Add Income Screen
    │
    ├── Transactions Module
    │   ├── All Transactions List
    │   ├── Transaction Details
    │   └── Search & Filter Screen
    │
    ├── Budgets Module
    │   ├── Budget Overview
    │   └── Create / Edit Budget Screen
    │
    ├── Reports & Analytics Module
    │   ├── Expense Category Breakdown
    │   ├── Monthly Spending Trends
    │   └── Budget vs Actual Reports
    │
    └── Settings & Data Module
        ├── Category Management Screen
        ├── Recurring Transactions / Reminders
        ├── Import & Export Data Screen
        ├── Local Backup & Restore Screen
        ├── Premium Upgrade Screen
        └── Security & App Preferences
```
