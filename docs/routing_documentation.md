# KaratCore ERP — Routing & Responsive Navigation Documentation

Technical documentation detailing **GoRouter** setup, `ShellRoute` layout integration, responsive navigation behavior, and dynamic breadcrumbs.

---

## 🚦 Navigation Routes Registry

All application routes are defined in `AppRoutes` (`lib/core/routing/routes.dart`):

| Route Path | Associated Page | Section Header |
| :--- | :--- | :--- |
| `/splash` | `SplashPage` | Unauthenticated |
| `/login` | `LoginPage` | Unauthenticated |
| `/dashboard` | `DashboardPage` | Core Operations |
| `/customers` | `CustomersPage` | Core Operations |
| `/customers/:id` | `CustomerDetailsPage` | Core Operations |
| `/kyc` | `KycPage` | Core Operations |
| `/ornaments` | `OrnamentsPage` | Jewellery & Assets |
| `/loans` | `LoansPage` | Jewellery & Assets |
| `/loans/:id` | `LoanDetailsPage` | Jewellery & Assets |
| `/accounting` | `AccountingPage` | Finance & Analytics |
| `/expenses` | `ExpensesPage` | Finance & Analytics |
| `/income` | `IncomePage` | Finance & Analytics |
| `/reports` | `ReportsPage` | Finance & Analytics |
| `/notifications` | `NotificationsPage` | System & Admin |
| `/staff` | `StaffPage` | System & Admin |
| `/settings` | `SettingsPage` | System & Admin |
| `/profile` | `ProfilePage` | System & Admin |
| `/help` | `HelpPage` | System & Admin |

---

## 📱 Responsive Layout Adaptation

The application shell automatically adapts its navigation paradigm according to viewport width (`BuildContext` breakpoints):

```
+----------------------------------------------------------------+
| Desktop (>1024px)  : Collapsible Sidebar + Top Bar + Body      |
| Tablet (600-1024px): Navigation Rail + Top Bar + Body         |
| Mobile (<600px)    : Top Bar + Body + Bottom Navigation        |
+----------------------------------------------------------------+
```

---

## 🥖 Breadcrumb State Management

Breadcrumbs are dynamically calculated based on current URL path using `breadcrumbProvider` (`lib/core/routing/breadcrumbs.dart`).

When navigation occurs in `_AppShell`:
```dart
WidgetsBinding.instance.addPostFrameCallback((_) {
  updateBreadcrumbsForPath(ref, widget.currentPath);
});
```
This updates `KcBreadcrumbBar` in `KcTopBar` seamlessly.
