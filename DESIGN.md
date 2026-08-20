# KaratCore ERP — Enterprise Design System Specification (DESIGN.md)

> Inspired by the award-winning creative execution of **incredibles.dev** (Awwwards / FWA / CSSDA), combined with the precision of **Linear**, the financial depth of **Stripe**, and high-craft editorial dark-mode minimalism.

---

## 💎 1. Core Brand Identity & Visual Aesthetic

KaratCore ERP balances **institutional enterprise trust** with **award-winning creative tech craftsmanship**.

* **Primary Mood**: Bold, high-craft, editorial, brutalist-refined, ultra-tactile, and responsive.
* **Signature Aesthetic Elements (Incredibles.dev Style)**:
  * **Giant Editorial Headings**: Ultra-bold grotesk/geometric display typography with tight tracking (`-1.2px`) and compact line-height (`1.05 - 1.1`).
  * **Micro-Dot Stipple Background**: Subtle dot matrix background patterns (`#EAEAEC` with `#CCCCCC` 1px stipple grid) for high visual texture.
  * **Uppercase Monospaced Badges**: Crisp uppercase micro-labels (`1X WEBBY AWARD • 5X FWA`, `PRICING`, `START A CONVERSATION`) in high-contrast monospaced font with dot separators.
  * **Hot Pink / Electric Magenta Accent**: Signature accent dot (`#FF2D55`) on lowercase details, badges, and active state indicators.
  * **Stark High-Contrast Card Blocks**: Alternating crisp white cards (`#FFFFFF`) and dark charcoal cards (`#18181B`) with high contrast text.
  * **Dark Mono Pill Buttons**: Solid black/charcoal pill buttons (`border-radius: 9999px`) with uppercase monospaced text (`REQUEST A QUOTE`, `SIGN IN`).

---

## 🎨 2. Color Palette & Token System

### Brand Core Tokens
```yaml
colors:
  # Base Surface Canvas (Incredibles.dev Light / Dark Stipple)
  stipple-bg: "#EAEAEC"         # Stipple dot grid background canvas
  canvas-card-light: "#FFFFFF"   # Pure white elevated card block
  canvas-card-dark: "#18181B"    # Deep charcoal block container
  card-border: "rgba(0, 0, 0, 0.08)"
  dark-card-border: "rgba(255, 255, 255, 0.12)"

  # Primary Brand Palette & Accents
  charcoal-primary: "#121212"   # Stark high-contrast main text & dark pills
  pink-accent: "#FF2D55"        # Signature Incredibles.dev hot pink dot accent
  gold-primary: "#D97706"       # Jewellery gold accent / high-value metal indicators
  gold-light: "#F59E0B"         # Gold highlight & active tab states
  gold-subdued: "rgba(217, 119, 6, 0.12)"

  # Functional Status Palette
  emerald-success: "#059669"   # Verified KYC, Active Loans, Positive Cashflow
  emerald-subdued: "rgba(5, 150, 105, 0.12)"
  rose-danger: "#DC2626"       # Overdue Loans, Penalty Interest, Rejected KYC
  rose-subdued: "rgba(220, 38, 38, 0.12)"
  amber-warning: "#D97706"      # Expiring Documents, Approaching Dues
  indigo-info: "#2563EB"        # System Notices & Information

  # Typography Grays
  text-primary: "#121212"       # Dark high-contrast primary text
  text-secondary: "#52525B"     # Subtitles & body descriptions (Zinc 600)
  text-muted: "#A1A1AA"         # Disabled text & subtle metadata (Zinc 400)
  text-inverse: "#FAFAFA"       # White text on dark cards
```

---

## 🔤 3. Typography & Hierarchy

KaratCore ERP pairs **Sora / Grotesk** (Ultra-bold display font for headlines) with **JetBrains Mono / Space Mono** (Monospaced uppercase micro-badges and metadata) and **Inter** (High-legibility sans-serif for numbers, tables, and form inputs).

```yaml
typography:
  editorial-headline:
    fontFamily: "Sora, 'Plus Jakarta Sans', sans-serif"
    fontSize: 42px
    fontWeight: 800
    lineHeight: 1.08
    letterSpacing: "-1.2px"
    usage: "Hero headers, major section intros, high-impact statements"

  display-heading:
    fontFamily: "Sora, sans-serif"
    fontSize: 26px
    fontWeight: 800
    lineHeight: 1.2
    letterSpacing: "-0.5px"
    usage: "Main Page Headers (KcPageHeader)"

  monospaced-badge:
    fontFamily: "JetBrains Mono, monospace"
    fontSize: 11px
    fontWeight: 700
    letterSpacing: "0.8px"
    textTransform: "uppercase"
    usage: "Category chips, award badges, micro-buttons, action pills"

  title-large:
    fontFamily: "Sora, sans-serif"
    fontSize: 20px
    fontWeight: 700
    lineHeight: 1.3
    letterSpacing: "-0.3px"
    usage: "Section Titles & Card Headers"

  body-regular:
    fontFamily: "Inter, sans-serif"
    fontSize: 14px
    fontWeight: 400
    lineHeight: 1.5
    usage: "General Body Text & Description Paragraphs"

  numeric-tabular:
    fontFamily: "Inter, monospace"
    fontSize: 15px
    fontWeight: 700
    fontFeatureSettings: "tnum"
    usage: "Prices (₹), Interest Rates (%), Loan Balances"
```

---

## 📱 4. Mobile Responsive Layout Architecture

Every layout and page in KaratCore ERP MUST adhere to responsive layout rules:

### Breakpoint Matrix
* **Mobile (`<600px`)**: Single-column vertical stacks, 100% width pill buttons, wrapped page headers (`KcPageHeader`), 2-line stacked search bars (`KcSearchBarFilter`), bottom navigation bar (`KcBottomNavigation`), and horizontal scrolling data tables.
* **Tablet (`600px - 1024px`)**: 2-column metric cards, collapsable navigation drawer.
* **Desktop (`>1024px`)**: Multi-column split grid layouts, persistent sidebar drawer (`KcSidebar`), and inline action button rows.

---

## 🧩 5. Atomic Component Standards (Incredibles.dev Style)

### 1. Action Pill Buttons
* **Primary Mono Pill Button (`KcPrimaryButton`)**: Solid dark charcoal/black fill (`#18181B`), pill-shaped radius (`9999px`), 44px height, uppercase monospaced bold text (`JetBrains Mono`, letter-spacing `0.8px`), subtle hover scale.
* **Secondary Outlined Pill (`KcOutlinedButton`)**: 1px hairline border (`#18181B`), transparent background, uppercase monospaced text, pill radius.

### 2. Micro-Badges & Metric Chips
* Uppercase monospaced font with optional hot pink accent dot (`•`).
* Hairline outline or soft tinted background (`gold-subdued` / `emerald-subdued`).

### 3. High-Contrast Split Cards
* Light Card (`#FFFFFF` with `#EAEAEC` border) or Dark Card (`#18181B` with white text).
* Large bold statement quotes with thin signature divider lines.

---

## 🚀 6. Operational & Code Hygiene Rules

1. **No Hardcoded Store Names**: Always read business profile dynamically from state.
2. **Zero Lint Warnings**: Every Flutter file MUST pass `flutter analyze` with 0 errors and 0 warnings.
3. **No Swallowed Exceptions**: Backend and frontend API calls must return clear user-friendly error feedback.
