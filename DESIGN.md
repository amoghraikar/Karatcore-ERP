# KaratCore ERP — Enterprise Design System Specification (DESIGN.md)

> Inspired by the precision of **Linear**, the financial depth of **Stripe**, the dark-mode craftsmanship of **Supabase**, and the luxury typography of **Apple**.

---

## 💎 1. Core Brand Identity & Aesthetics

KaratCore ERP is an enterprise-grade luxury jewellery management & gold loan platform. Its visual language balances **heavy institutional trust** with **modern high-velocity tech execution**.

* **Primary Mood**: Executive, trustworthy, ultra-crisp, tactile, and responsive.
* **Avoid "Vibecoded" Artifacts**:
  * ❌ No random pastel colors, unconstrained rounded corners, or default browser inputs.
  * ❌ No hardcoded static pixel heights/widths that break on mobile screens (`<600px`).
  * ❌ No generic red/blue alert boxes without proper neutral backing and border contrast.
  * ✅ Curated HSL/HEX luxury tokens, strict typography hierarchy, responsive layout rules, and micro-animated feedback.

---

## 🎨 2. Color Palette & Token System

### Brand Core Tokens
```yaml
colors:
  # Primary Brand Palette
  navy-deep: "#0B1F3F"         # Primary brand dark canvas & high-contrast headers
  navy-surface: "#0F2942"      # Elevation surface for dark containers
  gold-primary: "#D97706"      # Primary action gold / high-value accents
  gold-light: "#F59E0B"        # Gold highlight & active tab states
  gold-subdued: "rgba(217, 119, 6, 0.12)" # Soft gold badge & chip backing

  # Functional Colors
  emerald-success: "#059669"  # Verified KYC, Active Loans, Positive Cashflow
  emerald-subdued: "rgba(5, 150, 105, 0.12)"
  rose-danger: "#DC2626"      # Overdue Loans, Penalty Interest, Rejected KYC
  rose-subdued: "rgba(220, 38, 38, 0.12)"
  amber-warning: "#D97706"     # Expiring Documents, Approaching Loan Dues
  indigo-info: "#2563EB"       # Information notices, System updates

  # Light Mode Surfaces (Default)
  canvas-bg: "#F8FAFC"         # Page background (Slate 50)
  card-surface: "#FFFFFF"      # White card surface
  card-border: "#E2E8F0"       # Hairline border (Slate 200)
  text-primary: "#0F172A"      # Main text (Slate 900)
  text-secondary: "#475569"    # Subtitles & field labels (Slate 600)
  text-muted: "#94A3B8"        # Placeholders & disabled text (Slate 400)

  # Dark Mode Surfaces
  dark-canvas-bg: "#0B132B"    # Dark theme root canvas
  dark-card-surface: "#1C2541" # Dark theme elevated card
  dark-card-border: "rgba(255, 255, 255, 0.08)"
```

---

## 🔤 3. Typography & Hierarchy

KaratCore ERP pairs **Sora** (Geometrical display font for headings) with **Inter** (High-legibility sans-serif for numbers, tables, and form inputs).

```yaml
typography:
  display-heading:
    fontFamily: "Sora, sans-serif"
    fontSize: 26px
    fontWeight: 800
    lineHeight: 1.2
    letterSpacing: -0.5px
    usage: "Main Page Headers (KcPageHeader)"

  title-large:
    fontFamily: "Sora, sans-serif"
    fontSize: 20px
    fontWeight: 700
    lineHeight: 1.3
    letterSpacing: -0.3px
    usage: "Section Titles & Card Headers"

  title-medium:
    fontFamily: "Inter, sans-serif"
    fontSize: 16px
    fontWeight: 600
    lineHeight: 1.4
    usage: "Data Table Headers & Sub-headings"

  body-regular:
    fontFamily: "Inter, sans-serif"
    fontSize: 14px
    fontWeight: 400
    lineHeight: 1.5
    usage: "General Body Text & Description Paragraphs"

  numeric-tabular:
    fontFamily: "Inter, sans-serif"
    fontSize: 15px
    fontWeight: 700
    fontFeatureSettings: "tnum" # Tabular figures for aligned currency values
    usage: "Prices (₹), Interest Rates (%), Loan Balances"
```

---

## 📱 4. Mobile Responsive Layout Architecture

Every layout and page in KaratCore ERP MUST adhere to responsive layout rules:

### Breakpoint Matrix
* **Mobile (`<600px`)**: Single-column vertical stacks, 100% width buttons, wrapped page headers (`KcPageHeader`), 2-line stacked search bars (`KcSearchBarFilter`), bottom navigation bar (`KcBottomNavigation`), and horizontal scrolling data tables.
* **Tablet (`600px - 1024px`)**: 2-column metric cards, collapsable navigation drawer.
* **Desktop (`>1024px`)**: Multi-column grid layouts, persistent sidebar drawer (`KcSidebar`), and inline action button rows.

### Responsive Component Guidelines
1. **Page Headers**: Always use `KcPageHeader(title: ..., actions: [...])`. Never use inline `Row(children: [Text, Button])` without checking `context.isMobile`.
2. **Search & Filter Bars**: Always use `KcSearchBarFilter(onSearch: ..., onFilter: ...)`.
3. **Form Fields**: On mobile (`context.isMobile`), stack multi-field rows (`Row(children: [Expanded(Field1), Expanded(Field2)])`) into vertical `Column`s.
4. **Metric Cards**: Wrap metric grids with `crossAxisCount: context.isMobile ? 1 : 4`.
5. **Data Tables**: Wrap `DataTable` or `Table` widgets in `SingleChildScrollView(scrollDirection: Axis.horizontal)` with `minWidth: 850`.

---

## 🧩 5. Atomic Component Standards

### 1. Action Buttons
* **Primary Button (`KcPrimaryButton`)**: Solid gold/navy background, rounded radius (10px), 48px touch height, white bold text, subtle press scale animation.
* **Outlined Button (`KcOutlinedButton`)**: 1px hairline border, transparent background, soft hover state.

### 2. Status Badges (`KcStatusBadge`)
* Pill-shaped (12px padding), 11px font size, uppercase 800 weight font.
* Emerald for **Active / Verified**, Rose for **Overdue / Liquidated**, Amber for **Pending**.

### 3. Metric Cards (`KcMetricCard`)
* White/dark card backing with subtle hairline border (`Border.all(color: outline.withValues(alpha: 0.3))`).
* Large bold numeric value in tabular figures format (`KcFormatters.inr(...)`).
* Icon badge on top-right corner with 12% alpha tinted background.

---

## 🚀 6. Operational & Code Hygiene Rules

1. **No Hardcoded Store Names**: Always read business profile dynamically from `ref.watch(businessProfileProvider)` or `ref.watch(authStateProvider).session`.
2. **Zero Lint Warnings**: Every Flutter file MUST pass `flutter analyze` with 0 errors and 0 warnings.
3. **No Swallowed Exceptions**: Backend and frontend API calls must return clear user-friendly error feedback via `KcToast` or error states.
