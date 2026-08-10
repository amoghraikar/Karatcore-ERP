# KaratCore ERP — Enterprise Jewellery Management System

[![Flutter Version](https://img.shields.io/badge/Flutter-3.24+-02569B?logo=flutter)](https://flutter.dev)
[![Dart Version](https://img.shields.io/badge/Dart-3.5+-0175C2?logo=dart)](https://dart.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Feature--First%20Clean-emerald)](https://flutter.dev)
[![Milestone](https://img.shields.io/badge/Milestone-Foundation%20Architecture%20v1.0.0-gold)](#-current-milestone-status)
[![Platforms](https://img.shields.io/badge/Platforms-Android%20|%20iOS%20|%20Windows%20|%20macOS%20|%20Linux%20|%20Web-blue)](#-target-platforms)

> **KaratCore ERP** is a modern, enterprise-grade jewellery business management system built with Flutter & Dart using a modular, feature-first clean architecture. Designed for jewellery retailers, wholesalers, and gold loan providers.

---

## 🚩 Current Milestone Status

**Milestone 1: Foundation Architecture (v1.0.0+1)** — **COMPLETED**

The foundation architecture, core design system, responsive navigation shell, role-based authorization model, mock data layer, and 18 core domain modules have been fully structured and implemented.

---

## ✨ Implemented Features & Modules

### 🔐 1. Authentication & Security Domain
- **Authentication Flows**: Splash screen, Multi-factor Login, OTP Verification, Forgot & Reset Password wizards.
- **Session & Access Control**: Branch selection, screen lock timer, session expiry handling, and access-denied safeguards.
- **Role-Based Authorization (`AuthorizationService`)**: Granular permission checking across routes and UI components based on active staff roles.

### 📊 2. Dashboard & Executive Analytics
- **KPI Metrics**: Real-time business revenue, active pledge loans, gold inventory weight, and customer growth cards.
- **Interactive Charts**: Transaction trends and revenue breakdown powered by `fl_chart`.
- **Quick Action Bar**: One-click shortcuts for creating customers, initiating loans, and logging ornaments.

### 👥 3. Customer CRM & KYC Compliance
- **Customer Directory**: Full-featured customer registry with status badges, multi-attribute searching, and filtering.
- **Customer 360° Profile**: Single-page view of customer info, transaction history, active loans, linked ornaments, and KYC status.
- **KYC Verification Engine**: Multi-step KYC onboarding wizard, document verification card, identity audit trail, and compliance status tracking (Verified, Pending, Rejected, Expired).

### 💎 4. Ornaments & Stock Inventory
- **Ornament Catalog**: Detailed item management with purity classification (24K, 22K, 18K), metal types (Gold, Silver, Platinum), weight (gross/net), and valuation.
- **Inventory Logistics**: Category management, storage location tracking (safes, counters, vaults), and stock movement audit history.

### 💰 5. Gold & Pledge Loan Management
- **Loan Lifecycle Engine**: End-to-end loan management (Active, Overdue, Closed, Liquidated).
- **Loan Details & Schedule**: Interest calculation, collateral item association, payment schedule ledger, and audit history.
- **Loan Operations**: Principal & interest payment recording, loan renewals, settlement calculation, and collateral release management.

### 📖 6. Double-Entry Accounting System
- **Chart of Accounts**: Hierarchical account mapping with account detail ledgers.
- **Financial Books & Ledgers**: Cash Book, Bank Book, General Ledger, Accounts Receivable, and Accounts Payable.
- **Financial Statements**: Trial Balance, Profit & Loss (P&L) Statement, Balance Sheet, and Cash Flow Statement.
- **Journal Entries & Periods**: Double-entry journal entry creation and accounting period closure controls.

### 📑 7. Income, Expenses & Enterprise Reports
- **Income & Expense Tracking**: Expense logging, income categorizations, and payment mode tracking.
- **Reporting Hub**: Categorized report generation across Executive Overview, Customer, KYC, Inventory, Loan, Payment, Accounting, Profitability, Risk, Operational, and Audit domains.

### 🛡️ 8. Staff Management, Security & Audit
- **Staff Management**: Employee directory, staff profile, branch & department management, and role assignment.
- **RBAC Matrix**: Interactive permission matrix editor and custom role builder.
- **Audit & Security**: System-wide audit log trail, security event monitoring, active session overview.

---

## 🎨 Design System & UI Components

KaratCore ERP features a luxury jewellery-tailored design system (`KcDesignSystem`) built with Vanilla Flutter components:

- **Palette**: Navy (`#0B1F3F`), Luxury Gold (`#E3B83B`), Emerald (`#059669`), Slate neutrals, and Dark mode adaptivity.
- **Typography**: Google Fonts **Sora** (Headings) + **Inter** (Body text).
- **Adaptive Shell (`_AppShell`)**:
  - **Desktop (>1024px)**: Collapsible Sidebar + Top Navigation Bar + Dynamic Breadcrumbs.
  - **Tablet (600px–1024px)**: Navigation Rail + Top Bar.
  - **Mobile (<600px)**: Top Bar + Bottom Navigation.
- **Atomic UI Component Library (`lib/shared/widgets/`)**:
  - `KcPrimaryButton`, `KcSecondaryButton`, `KcOutlinedButton`
  - `KcTextField`, `KcPasswordField`, `KcDropdown`, `KcDatePicker`, `KcSearchBarUI`, `KcFilters`
  - `KcCard`, `KcMetricCard`, `KcDashboardCard`, `KcDocumentUploadCard`, `KcTimelineCard`, `KcProfileCard`
  - `KcDataTable`, `KcPagination`, `KcStatusBadge`, `KcEmptyState`, `KcErrorState`, `KcSkeletonLoader`

---

## 🏛 Architecture Overview

```
lib/
├── core/                  # Global Infrastructure
│   ├── config/            # AppConfig, AppConstants, DesignTokens
│   ├── constants/         # ColorTokens, SpacingTokens, RadiusTokens, ShadowTokens, Typography
│   ├── theme/             # Light & Dark Theme Data, ThemeModeNotifier
│   ├── routing/           # GoRouter Router, AppRoutes, BreadcrumbProvider
│   ├── services/          # LoggerService, StorageService
│   ├── utils/             # Formatters (INR currency, Dates), Validators
│   └── errors/            # Failure, AppException hierarchy
├── shared/                # Universal Design System Components & Models
│   ├── components/        # KcBrandMark, KcAvatar, KcBreadcrumbBar
│   ├── models/            # BreadcrumbItem, UserSession
│   └── widgets/           # Reusable UI widgets (buttons, inputs, cards, feedback, dialogs, nav, tables)
└── features/              # 18 Domain Feature Modules
    ├── accounting/  ├── audit/       ├── auth/         ├── customers/
    ├── dashboard/   ├── expenses/    ├── help/         ├── income/
    ├── kyc/         ├── loans/       ├── notifications/├── ornaments/
    ├── profile/     ├── reports/     ├── security/     ├── settings/
    ├── showcase/    └── staff/
        ├── presentation/  # Feature pages & screens
        ├── widgets/       # Feature-specific components
        ├── providers/     # State management (Riverpod)
        ├── models/        # Data models & DTOs
        ├── services/      # Service interfaces & logic
        └── repository/    # Repository pattern implementations
```

---

## 🧪 Quality Assurance & Testing

The repository includes comprehensive automated unit and widget test suites under `test/`:

- **App Initialization**: `test/app_test.dart`
- **Customer CRM**: `test/customer_test.dart`
- **Ornaments Inventory**: `test/inventory_test.dart`
- **KYC Verification**: `test/kyc_test.dart`
- **Loan Lifecycle**: `test/loan_test.dart`
- **Accounting Engine**: `test/accounting_test.dart`
- **UI Components**: `test/widget_test.dart`

To execute the test suite:
```bash
flutter test
```

---

## 📚 Technical Documentation Index

Detailed architectural specs and developer guidelines are available in the [`docs/`](file:///Users/zeus/Documents/karatcore%20erp/karatcore_erp/docs) directory:

- 📐 [Folder Structure Guide](file:///Users/zeus/Documents/karatcore%20erp/karatcore_erp/docs/folder_structure.md)
- 🗺 [Routing Architecture](file:///Users/zeus/Documents/karatcore%20erp/karatcore_erp/docs/routing_documentation.md)
- 🎨 [Theme & Design System Documentation](file:///Users/zeus/Documents/karatcore%20erp/karatcore_erp/docs/theme_documentation.md)
- 🛠 [Local Developer Setup Guide](file:///Users/zeus/Documents/karatcore%20erp/karatcore_erp/docs/setup_guide.md)

---

## 🚀 Getting Started

### 1. Prerequisites
- Flutter SDK `^3.5.0` (Recommended `3.24.0+`)
- Dart SDK `^3.5.0`

### 2. Installation & Run
```bash
# Install dependencies
flutter pub get

# Run on Web (Chrome)
flutter run -d chrome

# Run on macOS Desktop
flutter run -d macos

# Run Static Code Analysis
flutter analyze
```

