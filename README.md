# KaratCore ERP — Enterprise Jewellery Management System

[![Flutter Version](https://img.shields.io/badge/Flutter-3.24+-02569B?logo=flutter)](https://flutter.dev)
[![Dart Version](https://img.shields.io/badge/Dart-3.5+-0175C2?logo=dart)](https://dart.dev)
[![Backend](https://img.shields.io/badge/Backend-FastAPI%20%7C%20Python-009688?logo=fastapi)](https://fastapi.tiangolo.com)
[![Database](https://img.shields.io/badge/Database-Supabase%20PostgreSQL-3ECF8E?logo=supabase)](https://supabase.com)
[![Design System](https://img.shields.io/badge/Design%20System-Premium%20Editorial-B88A3B)](file:///Users/zeus/Documents/karatcore%20erp/karatcore_erp/DESIGN.md)

> **KaratCore ERP** is a modern, enterprise-grade jewellery business management system built with Flutter & Dart (Frontend) and Python FastAPI (Backend). Designed for jewellery retailers, wholesalers, goldsmiths, and gold loan providers with a world-class premium editorial UI/UX.

---

## ✨ Production Capabilities & Design System

### 🎨 1. Premium Editorial UI/UX & Design Language
- **Unified Plus Jakarta Sans Typography**: Single primary typography family applied consistently across all headings, metrics, tables, inputs, buttons, and navigation elements.
- **Consistent KaratCore Brand Mark**: Standardized diamond emblem logo (`KcBrandMark`) across sidebar, top bar, login layout, registration, and splash page.
- **Humane Auth & Error Feedback**: Raw API codes and technical exceptions are cleanly formatted into friendly, helpful prose for store owners.
- **Live Vault & Bullion Showcase**: Dynamic, animated login showcase panel featuring live 24K/22K/999 gold and silver rate cards and vault LTV safety meters.
- **Micro-Animations (`flutter_animate`)**: Smooth entrance curves, gold active line indicators, hover highlights, and modal transitions.

### 🔍 2. ⌘K Global Command Palette
- **Instant Keyboard Navigation**: Press `⌘ K` (macOS) or `Ctrl K` (Windows/Linux) anywhere in the application to trigger the search palette.
- **Universal Search Engine**: Search customers, pledge loans, stock inventory, double-entry accounting ledgers, executive reports, and quick actions.

### 🔐 3. Authentication & Security Gateway
- **Store Owner Registration & Login**: Integrated with `ApiClient` REST repositories (`ApiAuthRepository`).
- **Dynamic Registered Store Profile**: Links registered store profile directly from PostgreSQL into settings, receipts, and system headers.
- **2FA OTP Verification**: Multi-factor authentication via **SMS / Email 6-digit OTP**, **Authenticator App (TOTP)**, or **Backup Emergency Codes**.
- **Session & Access Control**: Granular Role-Based Access Control (RBAC), branch selection, screen lock timer, and session expiry handling.

### 📱 4. Dynamic Mobile Responsive Layout Engine
- **Cross-Device Adaptivity**: Production-ready responsive views (`context.isMobile`) for desktop web, mobile browsers, and tablets.
- **Responsive Atomic Components**: [`KcPageHeader`](file:///Users/zeus/Documents/karatcore%20erp/karatcore_erp/lib/shared/widgets/navigation/kc_page_header.dart) and [`KcSearchBarFilter`](file:///Users/zeus/Documents/karatcore%20erp/karatcore_erp/lib/shared/widgets/navigation/kc_search_bar_filter.dart).
- **Mobile Navigation & App Sheet**: 4-tab mobile bottom navigation and 12-module launcher sheet (`KcMobileAppGridSheet`).

### 📊 5. Executive Dashboard & Analytics
- **Live KPI Cards**: Real-time revenue, outstanding pledge loans, interest collected, active customers, and overdue loan metrics.
- **Interactive Charts (`fl_chart`)**: Weekly revenue trends, gold purity breakdown (24K, 22K, 18K), and transaction velocity.
- **Business Health Score**: Automated collateral LTV protection index and liquidity safety ratio.

### 👥 6. Customer CRM & KYC Compliance
- **Customer Registry**: Connected to `ApiCustomerRepository` with status badges, multi-attribute search, and filtering.
- **KYC Onboarding Engine**: Multi-step KYC wizard, document verification cards, and identity audit trail.

### 💎 7. Ornaments & Stock Inventory
- **Ornament Catalog**: Item management with purity breakdown (24K, 22K, 18K), gross/net weight, and valuation (`ValuationService`).
- **Inventory Logistics**: Category management, safe/vault location tracking, barcode generation (`BarcodeService`), and audit history.

### 💰 8. Gold & Pledge Loan Management
- **Loan Lifecycle Engine**: Active, Overdue, Closed, and Liquidated loan tracking.
- **Loan Ledger & Schedule**: Simple interest calculation (`LoanCalculationService`), collateral association, payment recording, and release management.

### 📖 9. Double-Entry Accounting System
- **Financial Ledgers**: Cash Book, Bank Book, General Ledger, Accounts Receivable, and Accounts Payable.
- **Financial Statements**: Trial Balance, Profit & Loss (P&L) Statement, Balance Sheet, and Cash Flow Statement.

---

## 🏛 Architecture Overview

```
karatcore_erp/
├── backend/                   # Python FastAPI REST API Backend
│   ├── app/
│   │   ├── api/routes/        # Auth, Customers, Loans, Inventory, Accounting routes
│   │   ├── core/              # Config, Security, JWT Settings
│   │   ├── models/            # SQLAlchemy Database Models
│   │   ├── services/          # NotificationService, LoanService, KycService
│   │   └── main.py            # FastAPI Entry Point
│   ├── .env.example           # Environment Configuration Template
│   └── requirements.txt       # Python Dependencies
│
└── lib/                       # Flutter Frontend Application
    ├── core/                  # Global Infrastructure (Theme, Network, Routing)
    │   ├── constants/         # Color & Typography Tokens (Plus Jakarta Sans)
    │   ├── network/           # ApiClient, ApiEndpoints, ApiConfig
    │   ├── theme/             # Light & Dark ThemeData
    │   └── routing/           # AppRouter, AppRoutes
    ├── shared/                # Universal Design System Components & Models
    │   └── widgets/           # Buttons, Cards, Navigation, Command Palette
    └── features/              # 18 Domain Feature Modules
        ├── accounting/  ├── audit/       ├── auth/         ├── customers/
        ├── dashboard/   ├── expenses/    ├── help/         ├── income/
        ├── kyc/         ├── loans/       ├── notifications/├── ornaments/
        ├── profile/     ├── reports/     ├── security/     ├── settings/
        └── staff/
```

---

## ⚙️ Setup & Execution

### 1. Prerequisites
- Flutter SDK `^3.24.0+`
- Dart SDK `^3.5.0`
- Python `3.10+` (for FastAPI backend)

### 2. Frontend Execution
```bash
# Install dependencies
flutter pub get

# Run Web App
flutter run -d chrome

# Run Code Analysis (0 errors, 0 warnings)
flutter analyze

# Run Automated Test Suite
flutter test
```

### 3. Backend Execution
```bash
cd backend
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000
```

---

## 🧪 Quality Assurance & Testing

All 13 automated unit and widget test suites pass cleanly under `test/`:
```bash
flutter test
```
- `test/accounting_test.dart`: Trial balance & P&L calculations.
- `test/inventory_test.dart`: Valuation & barcode generation.
- `test/kyc_test.dart`: Compliance & document matching.
- `test/loan_test.dart`: Simple interest & payment allocation.
- `test/app_test.dart` & `test/widget_test.dart`: App shell & theme initialization.
