# KaratCore ERP — Foundation Architecture

[![Flutter Version](https://img.shields.io/badge/Flutter-3.24+-02569B?logo=flutter)](https://flutter.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Feature--First-emerald)](https://flutter.dev)
[![Target Platforms](https://img.shields.io/badge/Platforms-Android%20|%20iOS%20|%20Windows%20|%20macOS%20|%20Linux%20|%20Web-blue)](#target-platforms)

> **KaratCore ERP** is an enterprise-grade jewellery business management system built with Flutter & Dart using a modular, feature-first architecture.

---

## 🏛 Architecture Overview

KaratCore ERP follows a **Feature-First Clean Architecture** designed for high maintainability, zero-friction developer experience, and effortless modular scaling.

```
lib/
├── core/                  # Core infrastructure (Config, Constants, Theme, Routing, Utils, Extensions)
│   ├── config/            # AppConfig, AppConstants, DesignTokens
│   ├── constants/         # ColorTokens, SpacingTokens, RadiusTokens, ShadowTokens, Typography
│   ├── theme/             # Light & Dark Theme Data, ThemeModeNotifier
│   ├── routing/           # GoRouter Router, AppRoutes, BreadcrumbProvider
│   ├── services/          # LoggerService, StorageService
│   ├── utils/             # Formatters (INR currency, Dates), Validators
│   ├── errors/            # Failure, AppException
│   ├── extensions/        # Context, Num, String extensions
│   └── animations/        # Reusable entrance & motion utilities
├── shared/                # Universal design system components & models
│   ├── components/        # KcBrandMark, KcAvatar, KcBreadcrumbBar
│   ├── models/            # BreadcrumbItem, UserSession
│   └── widgets/           # Buttons, Inputs, Cards, Feedback, Dialogs, Navigation
└── features/              # Feature modules
    ├── auth/
    ├── dashboard/
    ├── customers/
    ├── kyc/
    ├── ornaments/
    ├── loans/
    ├── accounting/
    ├── expenses/
    ├── income/
    ├── reports/
    ├── notifications/
    ├── staff/
    ├── settings/
    ├── profile/
    └── help/
        ├── presentation/  # Pages & Page-specific widgets
        ├── widgets/       # Reusable feature widgets
        ├── providers/     # State management (Riverpod)
        ├── models/        # Data models / DTOs
        ├── services/      # Data services
        └── repository/    # Repository pattern interfaces
```

---

## 🎨 Theme & Design System

- **Primary Colors**: Navy (`#0B1F3F`), Luxury Gold (`#E3B83B`), Emerald Green (`#059669`).
- **Typography**: Google Fonts **Sora** (Headings) + **Inter** (Body text).
- **Responsive Layout**:
  - **Desktop (>1024px)**: Collapsible Navigation Sidebar + Top Bar.
  - **Tablet (600px–1024px)**: Navigation Rail + Top Bar.
  - **Mobile (<600px)**: Top Bar + Bottom Navigation.

---

## 🚀 Getting Started

### 1. Prerequisites
- Flutter SDK `^3.5.0`
- Dart SDK `^3.5.0`

### 2. Installation
```bash
git clone https://github.com/karatcore/karatcore_erp.git
cd karatcore_erp
flutter pub get
```

### 3. Running the Project
```bash
# Run on macOS / Desktop
flutter run -d macos

# Run on Web
flutter run -d chrome

# Run Analysis
flutter analyze

# Run Unit & Widget Tests
flutter test
```

---

## 📜 Code Quality & Guidelines

- **Zero Hardcoded Colors**: Always reference `Theme.of(context).colorScheme` or `KcColors`.
- **Zero Inline Spacing Magic Numbers**: Use `KcSpace` spacing constants and `context.pageGutter`.
- **Linting Rules**: Enforced via strict `analysis_options.yaml`.
