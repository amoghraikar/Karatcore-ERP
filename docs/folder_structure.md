# KaratCore ERP — Feature-First Folder Structure

Architectural documentation detailing the feature-first clean directory organization of **KaratCore ERP**.

---

## 🏗 Directory Overview

```
lib/
├── core/                  # Global Infrastructure
│   ├── animations/        # Reusable animations, hoverables, pressables, transition builders
│   ├── config/            # AppConfig, AppConstants, DesignTokens
│   ├── constants/         # ColorTokens, SpacingTokens, RadiusTokens, ShadowTokens, Typography
│   ├── errors/            # Failure models, AppException hierarchy
│   ├── extensions/        # BuildContext, Num, String extensions
│   ├── routing/           # GoRouter config, route paths, breadcrumb state management
│   ├── services/          # LoggerService, StorageService
│   ├── theme/             # Light & Dark Theme Data, ThemeModeNotifier
│   └── utils/             # INR currency & date formatters, form validators
├── shared/                # Design System Components & Shared Models
│   ├── components/        # KcBrandMark, KcAvatar, KcBreadcrumbBar
│   ├── models/            # BreadcrumbItem, UserSession
│   └── widgets/           # Reusable UI widgets (buttons, inputs, cards, feedback, dialogs, nav)
└── features/              # Modular Feature Domain Directories
    ├── accounting/
    ├── auth/
    ├── customers/
    ├── dashboard/
    ├── expenses/
    ├── help/
    ├── income/
    ├── kyc/
    ├── loans/
    ├── notifications/
    ├── ornaments/
    ├── profile/
    ├── reports/
    ├── settings/
    └── staff/
```

---

## 🎯 Modular Feature Blueprint

Every module inside `lib/features/<module>/` strictly enforces the 6-layer architecture:

```
<feature>/
├── presentation/          # Feature Pages & screen-specific widgets
├── widgets/               # Module-specific reusable components
├── providers/             # Riverpod state providers
├── models/                # Domain entities & data models
├── services/              # API & Data service interfaces
└── repository/            # Repository pattern implementations
```

### Scaling Rules
1. **Zero Cross-Feature Imports**: A feature module must NEVER import internal code directly from another feature.
2. **Shared Extraction**: Common widgets or data models shared by 2+ features MUST reside in `lib/shared/`.
3. **Core Independence**: `lib/core/` must remain completely independent of any feature domain logic.
