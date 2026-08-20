# KaratCore ERP — Enterprise Design System Specification (DESIGN.md)

> Modern, premium editorial visual language balancing **institutional enterprise trust** with **editorial craftsmanship**, tight typography hierarchy, restrained Karat Gold accents, warm tactile surfaces, and rich micro-animations.

---

## 💎 1. Core Brand Identity & Visual Aesthetic

KaratCore ERP balances **institutional enterprise trust** with **high-craft editorial precision**.

* **Primary Mood**: Refined, editorial, restrained, ultra-tactile, responsive, and precision-engineered.
* **Signature Aesthetic Elements**:
  * **Unified Typography Family**: Exclusive use of **Plus Jakarta Sans** for all headings, metrics, display titles, body text, inputs, and action controls for absolute visual harmony.
  * **Consistent Brand Mark Emblem**: Authoritative diamond emblem logo (`KcBrandMark`) across all navigation headers, sidebar, top bar, login layout, registration, and splash page.
  * **Micro-Dot Stipple Background**: Subtle dot matrix background pattern canvas for rich visual depth (`StippleDotPainter`).
  * **Restrained Karat Gold Accent**: Warm Karat Gold (`#B88A3B`) applied intentionally on key focal points, active state lines, badges, and metrics.
  * **Tactile Surface Layers**: Hairline borders (`#E5E5EA` light / `#2A2B2E` dark), borderless elevated containers, and shadow depth.
  * **Live Vault & Market Livestream**: Real-time 24K/22K/999 bullion rate ticker cards and LTV security progress indicators.
  * **⌘K Global Command Palette**: Modal quick-search palette for instant keyboard-first navigation across customers, loans, ornaments, ledgers, and actions.

---

## 🎨 2. Color Palette & Token System

### Brand Core Tokens (`color_tokens.dart`)
```yaml
colors:
  # Base Surface Canvas & Cards
  bg-light: "#F4F2ED"            # Warm off-white tactile canvas
  bg-dark: "#111214"             # Deep obsidian dark mode canvas
  surface-light: "#FFFFFF"       # Elevated crisp white container card
  surface-dark: "#1A1B1E"        # Elevated dark surface container
  border-light: "#E5E5EA"        # Hairline subtle light border
  border-dark: "#2A2B2E"         # Hairline subtle dark border

  # Brand Primary & Accents
  text-primary-light: "#111214"  # Deep charcoal primary text (Light)
  text-primary-dark: "#F4F2ED"   # Warm off-white primary text (Dark)
  text-secondary-light: "#6E6E73"# Subdued body & label text (Light)
  text-secondary-dark: "#98989D" # Subdued body & label text (Dark)
  gold-accent: "#B88A3B"        # Restrained Karat Gold accent
  gold-subdued: "rgba(184, 138, 59, 0.12)" # Tinted gold badge background

  # Functional Status Palette
  success-emerald: "#26745A"    # Verified KYC, Active Loans, Healthy LTV
  success-subdued: "rgba(38, 116, 90, 0.12)"
  danger-red: "#A94848"         # Overdue Loans, Penalty Dues, Failed Auth
  danger-subdued: "rgba(169, 72, 72, 0.12)"
  warning-amber: "#A97828"       # Approaching Due Dates, Pending KYC
  warning-subdued: "rgba(169, 120, 40, 0.12)"
```

---

## 🔤 3. Typography & Hierarchy

KaratCore ERP uses **Plus Jakarta Sans** exclusively across all typography levels for unified brand identity and clean editorial readability.

```yaml
typography:
  family: "Plus Jakarta Sans"

  display-large:
    fontSize: 56px
    fontWeight: 800
    lineHeight: 1.05
    letterSpacing: "-1.4px"
    usage: "Hero headers, major metric callouts"

  display-medium:
    fontSize: 42px
    fontWeight: 800
    lineHeight: 1.10
    letterSpacing: "-1.1px"
    usage: "Editorial section titles & login page headlines"

  headline-large:
    fontSize: 28px
    fontWeight: 700
    lineHeight: 1.20
    letterSpacing: "-0.6px"
    usage: "Main Page Headers (KcPageHeader)"

  title-large:
    fontSize: 18px
    fontWeight: 700
    letterSpacing: "-0.2px"
    usage: "Section Titles & Card Headers"

  body-medium:
    fontSize: 14px
    fontWeight: 400
    lineHeight: 1.45
    usage: "General Body Text, Input Labels, Descriptions"

  monospaced-badge:
    fontSize: 10px
    fontWeight: 700
    letterSpacing: "0.8px"
    textTransform: "uppercase"
    usage: "Category chips, status badges, action pills"
```

---

## 📱 4. Mobile & Desktop Navigation Architecture

* **Desktop (`>1024px`)**: Persistent slim navigation rail (`KcSidebar`) with gold active indicator lines, editorial top bar (`KcTopBar`) with ⌘K search trigger, and split grid views.
* **Tablet (`600px - 1024px`)**: Collapsible navigation rail and 2-column metric grids.
* **Mobile (`<600px`)**: Single-column vertical stacks, 100% width action buttons, mobile top bar with drawer launcher, and mobile bottom navigation sheet.

---

## 🧩 5. Atomic Components & Interaction Standards

### 1. Action Buttons
* **Primary Button (`KcPrimaryButton`)**: Deep charcoal/obsidian container, 10px rounded radius, uppercase **Plus Jakarta Sans** bold text, Karat Gold icon accent.
* **Outlined Button (`KcOutlinedButton`)**: Hairline border container, hover gold accent glow, uppercase typography.

### 2. Global Command Palette (`KcCommandPalette`)
* Invoked via `⌘ K` or `Ctrl K` from anywhere in the application.
* Instant fuzzy search across customers, gold loans, inventory, accounting ledgers, reports, and system actions.

### 3. Humane Error Handling
* Translates all backend and network exceptions into clear, friendly prose for store owners (e.g. *"Incorrect email/mobile or password. Please check your credentials and try again."*).

---

## 🚀 6. Code Hygiene & Verification Standards

1. **Single Font Family**: Every component strictly references **Plus Jakarta Sans**.
2. **Zero Lint Warnings**: `flutter analyze` MUST pass with 0 errors and 0 warnings.
3. **Automated Test Suite**: `flutter test` MUST pass all 13 unit and widget test suites.
