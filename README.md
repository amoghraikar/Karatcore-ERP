# KaratCore ERP — Enterprise Jewellery Management System

[![Flutter Version](https://img.shields.io/badge/Flutter-3.24+-02569B?logo=flutter)](https://flutter.dev)
[![Dart Version](https://img.shields.io/badge/Dart-3.5+-0175C2?logo=dart)](https://dart.dev)
[![Backend](https://img.shields.io/badge/Backend-FastAPI%20%7C%20Python-009688?logo=fastapi)](https://fastapi.tiangolo.com)
[![Database](https://img.shields.io/badge/Database-Supabase%20PostgreSQL-3ECF8E?logo=supabase)](https://supabase.com)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20API--Wired-emerald)](https://flutter.dev)

> **KaratCore ERP** is a modern, enterprise-grade jewellery business management system built with Flutter & Dart (Frontend) and Python FastAPI (Backend). Designed for jewellery retailers, wholesalers, goldsmiths, and gold loan providers.

---

## ✨ Implemented Features & Production Capabilities

### 🔐 1. Real Authentication & Security Gateway
- **Production Store Owner Registration & Login**: Integrated with `ApiClient` REST repositories (`ApiAuthRepository`).
- **2FA OTP Verification**: Mandatory 6-digit OTP verification flow on login/registration via **SMS / Email 6-digit OTP**, **Authenticator App (TOTP)**, or **Backup Emergency Codes**.
- **Backend Notification Service**: Python `NotificationService` supporting real SMS delivery (Twilio / Fast2SMS) and real email delivery via SMTP.
- **Session & Access Control**: Granular Role-Based Access Control (RBAC), branch selection, screen lock timer, and session expiry handling.

### 📊 2. Dynamic Executive Dashboard & Analytics
- **Live Dynamic KPI Cards**: Real-time business revenue, outstanding pledge loans, interest collected, active customers, and overdue loan metrics derived directly from reactive state.
- **Interactive Charts (`fl_chart`)**: Live weekly revenue trends, gold collateral purity distribution (24K, 22K, 18K), and monthly transaction volume.
- **Store Business Health Score**: Automated collateral LTV protection index and liquidity safety ratio.
- **Interactive Navigation**: Tapping any KPI card opens its target feature module (Customers, Loans, Accounting Ledger).

### 👥 3. Customer CRM & KYC Compliance
- **Customer Directory**: Full-featured customer registry connected to `ApiCustomerRepository` with status badges, multi-attribute searching, and filtering.
- **Customer 360° Profile**: Single-page view of customer info, transaction history, active loans, linked ornaments, and KYC status.
- **KYC Verification Engine**: Multi-step KYC onboarding wizard, document verification card, identity audit trail, and compliance status tracking (Verified, Pending, Rejected, Expired).

### 💎 4. Ornaments & Stock Inventory
- **Ornament Catalog**: Detailed item management with purity classification (24K, 22K, 18K), metal types (Gold, Silver, Platinum), weight (gross/net), and valuation (`ValuationService`).
- **Inventory Logistics**: Category management, storage location tracking (safes, counters, vaults), barcode generation (`BarcodeService`), and stock movement audit history.

### 💰 5. Gold & Pledge Loan Management
- **Loan Lifecycle Engine**: End-to-end loan management (Active, Overdue, Closed, Liquidated).
- **Loan Details & Schedule**: Interest calculation (`LoanCalculationService`), collateral item association, payment schedule ledger, and audit history.
- **Loan Operations**: Principal & interest payment recording, loan renewals, settlement calculation, and collateral release management.

### 📖 6. Double-Entry Accounting System
- **Chart of Accounts**: Hierarchical account mapping connected to `ApiAccountingRepository`.
- **Financial Books & Ledgers**: Cash Book, Bank Book, General Ledger, Accounts Receivable, and Accounts Payable.
- **Financial Statements**: Trial Balance, Profit & Loss (P&L) Statement, Balance Sheet, and Cash Flow Statement.
- **Journal Entries & Periods**: Double-entry journal entry creation and accounting period closure controls (`AccountingPeriodSelector`).

### 📑 7. Income, Expenses & Enterprise Reports
- **Income & Expense Tracking**: Expense logging, income categorizations, and payment mode tracking.
- **Reporting Hub**: Categorized report generation across Executive Overview, Customer, KYC, Inventory, Loan, Payment, Accounting, Profitability, Risk, Operational, and Audit domains.

---

## 🎨 Design System & UI Components

KaratCore ERP features a luxury jewellery-tailored design system (`KcDesignSystem`) built with Vanilla Flutter components:

- **Palette**: Navy (`#0B1F3F`), Luxury Gold (`#E3B83B`), Emerald (`#059669`), Slate neutrals, and Dark mode adaptivity.
- **Typography**: Google Fonts **Sora** (Headings) + **Inter** (Body text).
- **Adaptive Shell (`_AppShell`)**: Responsive drawer navigation across Desktop (>1024px), Tablet, and Mobile views.
- **Atomic UI Component Library (`lib/shared/widgets/`)**: Standardized inputs, buttons, cards, data tables, search bars, filters, and status badges.

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
    ├── core/                  # Global Infrastructure
    │   ├── config/            # EnvConfig
    │   ├── network/           # ApiClient, ApiEndpoints, ApiConfig
    │   ├── theme/             # Theme Data
    │   └── routing/           # AppRouter, AppRoutes
    ├── shared/                # Universal Design System Components & Models
    └── features/              # 18 Domain Feature Modules
        ├── accounting/  ├── audit/       ├── auth/         ├── customers/
        ├── dashboard/   ├── expenses/    ├── help/         ├── income/
        ├── kyc/         ├── loans/       ├── notifications/├── ornaments/
        ├── profile/     ├── reports/     ├── security/     ├── settings/
        └── staff/
```

---

## ⚙️ Environment & API Setup

1. **Backend Environment ([backend/.env](file:///Users/zeus/Documents/karatcore%20erp/karatcore_erp/backend/.env.example))**:
   Copy `.env.example` to `.env` and fill in your production credentials:
   ```env
   # Database (Supabase PostgreSQL)
   DATABASE_URL=postgresql://postgres.[REF]:[PASSWORD]@aws-0-ap-south-1.pooler.supabase.com:6543/postgres
   SUPABASE_URL=https://[REF].supabase.co
   SUPABASE_KEY=your_supabase_anon_key

   # Real SMS Gateway (Twilio / Fast2SMS)
   SMS_PROVIDER=twilio
   TWILIO_ACCOUNT_SID=your_twilio_account_sid
   TWILIO_AUTH_TOKEN=your_twilio_auth_token

   # Real Email SMTP Server (Gmail App Password)
   SMTP_HOST=smtp.gmail.com
   SMTP_PORT=587
   SMTP_USER=your_email@gmail.com
   SMTP_PASSWORD=your_gmail_app_password
   ```

2. **Frontend API URL ([lib/core/network/api_config.dart](file:///Users/zeus/Documents/karatcore%20erp/karatcore_erp/lib/core/network/api_config.dart))**:
   ```bash
   flutter run -d chrome --dart-define=API_URL=http://localhost:8000/api/v1
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

## 🚀 Getting Started

### 1. Prerequisites
- Flutter SDK `^3.24.0+`
- Dart SDK `^3.5.0`
- Python `3.10+` (for backend execution)

### 2. Installation & Execution
```bash
# Frontend setup
flutter pub get

# Run Web App
flutter run -d chrome

# Run Static Code Analysis
flutter analyze
```
