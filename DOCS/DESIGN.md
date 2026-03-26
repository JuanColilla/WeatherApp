# WeatherApp Design System

## Source of Truth

The canonical Design System lives in `WeatherApp.pen` (Pencil MCP).
This document describes the tokens, rules, and components defined there.

> **Mandatory rule**: Any change to colors, typography, spacing, components, or visual patterns
> MUST be reflected in both `WeatherApp.pen` AND this document. When working with Pencil MCP,
> update this file immediately after modifying the .pen file. When modifying code that affects
> the design, update the .pen file to match.

---

## Visual Identity

### Philosophy

WeatherApp uses a **dark-first, translucent** aesthetic inspired by iOS 26 Liquid Glass.
The UI is a single screen where content floats on dynamic gradient backgrounds that change
with weather conditions. Glass panels let the background color breathe through them, creating
depth and atmosphere.

### Key Principles

1. **Glass over gradient** — Every surface uses translucent fills (`#FFFFFF1A`–`#FFFFFF33`) over dynamic backgrounds. Never use opaque card backgrounds.
2. **Minimal chrome** — No heavy borders. Use 1px `glass-border` strokes only. No drop shadows on cards.
3. **Typography hierarchy through weight** — Use size AND weight contrast. Display: 800 extrabold. Body: 400–600.
4. **Color from weather** — The background gradient is the primary source of color. UI elements stay neutral (white/translucent) to let the weather gradient shine.
5. **Pill shapes for badges, generous radii for cards** — Badges and buttons use `radius-pill` (100). Cards use `radius-lg` (24).

---

## Liquid Glass Rules

In code (SwiftUI / iOS 26), Liquid Glass maps to `.glassEffect()`. In the design file,
we simulate it with the following pattern:

| Property | Design Token | Code Equivalent |
|---|---|---|
| Surface fill | `glass-surface` (#FFFFFF1A, 10% white) | `.glassEffect()` |
| Stronger surface | `glass-surface-strong` (#FFFFFF33, 20% white) | `.glassEffect(.regular)` with tint |
| Border | `glass-border` (#FFFFFF26, 15% white) | Automatic in `.glassEffect()` |
| Background blur | N/A (simulated with gradient) | `.glassEffect()` includes blur |

### When to use Glass

- **Always**: Cards, badges, buttons, bottom bars — any interactive or grouping surface.
- **Never**: Text directly, icons, dividers, the background itself.
- **Stronger variant**: Only for primary CTAs (RefreshButton) and interactive elements on hover/press.

### Glass + Background Contract

Glass looks best when the background has color/contrast. Every screen MUST have a gradient background
derived from the current weather condition. The gradient tokens are:

| Condition | Token | Hex | Gradient Direction |
|---|---|---|---|
| Sunny / Clear | `weather-sunny` | #F59E0B | Warm amber → deep orange (top→bottom) |
| Cloudy | `weather-cloudy` | #94A3B8 | Cool gray → slate (top→bottom) |
| Rainy | `weather-rainy` | #5B9CF6 | Deep blue → indigo (top→bottom) |
| Snowy | `weather-snowy` | #CBD5E1 | Light silver → cool blue (top→bottom) |

The gradient is a computed property in the View layer (not in the Reducer).
Blend the weather token with `bg-primary` for the gradient stops.

---

## Color Tokens

### Backgrounds

| Token | Value | Usage |
|---|---|---|
| `bg-primary` | #1A1B2E | App base background (deep navy) |
| `bg-secondary` | #252842 | Elevated surfaces, gradient stop |

### Glass Surfaces

| Token | Value | Usage |
|---|---|---|
| `glass-surface` | #FFFFFF1A | Default card/panel fill (10% white) |
| `glass-surface-strong` | #FFFFFF33 | CTA buttons, active states (20% white) |
| `glass-border` | #FFFFFF26 | 1px inside stroke on all glass elements (15% white) |

### Text

| Token | Value | Usage |
|---|---|---|
| `text-primary` | #FFFFFF | Headlines, values, primary content |
| `text-secondary` | #FFFFFFB3 | Descriptions, units, supporting text (70%) |
| `text-tertiary` | #FFFFFF66 | Labels, placeholders, disabled text (40%) |

### Accents

| Token | Value | Usage |
|---|---|---|
| `accent-blue` | #5B9CF6 | Metric icons (humidity, pressure), links |
| `accent-teal` | #14B8A6 | Positive states, wind metrics |
| `accent-orange` | #F59E0B | Temperature highlights, sunny states |
| `accent-pink` | #F472B6 | Location badge, AI sparkles, special states |

### Weather Conditions

| Token | Value | Usage |
|---|---|---|
| `weather-sunny` | #F59E0B | Clear sky gradient source |
| `weather-cloudy` | #94A3B8 | Overcast gradient source |
| `weather-rainy` | #5B9CF6 | Rain gradient source |
| `weather-snowy` | #CBD5E1 | Snow gradient source |

---

## Typography

### Font Families

| Role | Font | Pencil Variable |
|---|---|---|
| Display / Headlines | Plus Jakarta Sans | `font-display` |
| Body / UI | Inter | `font-body` |

> Note: `fontFamily` variables don't resolve in Pencil MCP — use font names directly in .pen operations.
> In Swift code, use SF Pro (system font) as the primary font, with weight mapping preserved.

### Type Scale

| Size | Weight | Font | Usage |
|---|---|---|---|
| 96px | 800 | Display | Temperature hero value |
| 34px | 800 | Display | Section titles (design system only) |
| 32px | 600 | Display | Temperature unit (°C) |
| 28px | 700 | Display | Metric card values |
| 20px | 700 | Display | Section headers |
| 16px | 600 | Body | Status bar time, list item titles |
| 15px | 400 | Body | Body text, AI quote text |
| 14px | 600/500 | Body | Card labels, badge text, city name |
| 13px | 500 | Body | Metric labels |
| 12px | 600/500 | Body | AI badge label, tag text, coordinates |
| 11px | 400 | Body | Coordinates, tertiary text |

### Line Heights

| Context | Value |
|---|---|
| Large metrics (temperature) | 0.9 (compact) |
| Card content | 1.4 |
| AI quote text | 1.5 |
| Default | Inherit from font |

---

## Spacing

Base unit: 4px grid.

### Spacing Tokens

| Token | Value | Usage |
|---|---|---|
| `spacing-xs` | 4px | Micro gaps (icon-to-label in tabs) |
| `spacing-sm` | 8px | Small gaps (skeleton lines, tight stacks) |
| `spacing-md` | 16px | Standard gaps (between cards, form fields) |
| `spacing-lg` | 24px | Section gaps, card padding |
| `spacing-xl` | 32px | Major section separation |

### Component Padding

| Component | Padding |
|---|---|
| WeatherMetricCard | 16px uniform |
| GlassCard | 20px uniform |
| LocationBadge | 10px vertical, 16px horizontal |
| WeatherConditionBadge | 8px vertical, 16px horizontal |
| RefreshButton | 14px vertical, 24px horizontal |
| AIQuoteCard | 20px uniform |
| Screen content wrapper | 0px top, 24px sides, 24px bottom |

---

## Corner Radius

| Token | Value | Usage |
|---|---|---|
| `radius-sm` | 12px | Small elements, color swatches, skeleton lines (6px) |
| `radius-md` | 20px | Medium cards (WeatherMetricCard) |
| `radius-lg` | 24px | Large cards (GlassCard, AIQuoteCard) |
| `radius-pill` | 100px | Badges, buttons (LocationBadge, RefreshButton, ConditionBadge) |

---

## Components

All components are defined as reusable nodes in `WeatherApp.pen`.

### Inventory

| Component | Pen ID | Type | Description |
|---|---|---|---|
| WeatherMetricCard | `rRXwQ` | Data display | Icon + label + value for humidity, wind, pressure, feels like |
| LocationBadge | `gCvbQ` | Info badge | Pin icon + city name + lat/lon coordinates |
| WeatherConditionBadge | `9R7BG` | Info badge | Weather icon + condition description |
| TemperatureDisplay | `LcVaK` | Hero display | Large temperature value + unit |
| RefreshButton | `Q6GN2` | Action | Glass button with refresh icon + "New Location" |
| StatusBar | `xQdct` | Chrome | iOS status bar (time + signal/wifi/battery) |
| GlassCard | `h397r` | Container | Generic glass panel with content slot |
| AIQuoteCard/Generated | `s0CQD` | Content | Apple Intelligence quote with header + text + refresh |
| AIQuoteCard/Generating | `qf8g3` | Loading | Skeleton shimmer state with "Thinking..." |
| LocationListItem | `xXg6E` | List item | Location row with weather icon, city, temp summary + delete button |

### Component Structure Patterns

**Data display** (WeatherMetricCard):
```
Frame (glass-surface, radius-md)
├── icon_font (accent color, 20x20)
├── text/label (text-tertiary, 13px, 500)
└── text/value (text-primary, 28px, 700)
```

**Info badge** (LocationBadge, ConditionBadge):
```
Frame (glass-surface, radius-pill, horizontal)
├── icon_font (accent color, 16-18px)
└── text or frame/content
```

**Action** (RefreshButton):
```
Frame (glass-surface-strong, radius-pill, horizontal)
├── icon_font (text-primary, 18x18)
└── text/label (text-primary, 15px, 600)
```

**AI Card states**:
```
Generated                          Generating
Frame (glass-surface, radius-lg)   Frame (glass-surface, radius-lg)
├── header (horizontal)            ├── header (horizontal)
│   ├── sparkles (accent-pink)     │   ├── sparkles (accent-pink)
│   └── "Apple Intelligence"       │   └── "Thinking..."
├── quoteText (italic, 15px)       └── skeletonLines (vertical)
└── footer                             ├── ████ full width (gradient)
    └── refresh-cw icon                ├── ████ full width (gradient)
                                       └── ████ 200px (gradient)
```

**List item** (LocationListItem):
```
Frame (glass-surface, radius-md, horizontal, space-between)
├── info (horizontal)
│   ├── weatherIcon (40x40, glass-surface-strong, radius-sm)
│   │   └── icon_font (weather icon, 20px)
│   └── texts (vertical, gap 2)
│       ├── cityName (text-primary, 15px, 600)
│       └── temperature (text-secondary, 13px, 400) — "24°C · Partly Cloudy"
└── deleteButton (32x32, #EF444533, radius-pill)
    └── minus icon (16px, #EF4445)
```

**Swipe-to-delete pattern**: The row shifts left revealing a red "Delete" action (80px, #EF4445) behind. The first location (main) hides the delete button via `enabled: false`.

### Skeleton/Loading Pattern

Skeleton lines use a gradient fill simulating shimmer:
- Gradient type: linear, rotation 90°
- Colors: `#FFFFFF12` → `#FFFFFF25` → `#FFFFFF12`
- Height: 12px, corner radius: 6px
- Last line is shorter (200px vs fill) to simulate natural text truncation

---

## Icons

All icons use the **Lucide** icon set via `icon_font` nodes.

| Context | Icon Name | Size | Color |
|---|---|---|---|
| Humidity | `droplets` | 20px | accent-blue |
| Wind | `wind` | 20px | accent-teal |
| Pressure | `gauge` | 20px | accent-blue |
| Feels Like | `thermometer` | 20px | accent-orange |
| Location | `map-pin` | 16px | accent-pink |
| Weather condition | `cloud`, `sun`, `cloud-rain`, `snowflake` | 18px | weather-* token |
| Refresh | `refresh-cw` | 18px (btn), 14px (quote) | text-primary / text-tertiary |
| AI | `sparkles` | 16px | accent-pink |
| Status bar | `signal`, `wifi`, `battery-full` | 16px | text-primary |
| Add location | `plus` | 16px | text-primary |
| Delete | `minus` | 16px | #EF4445 |
| Info hint | `info` | 14px | text-tertiary |

---

## Screens

| Screen | Pen ID | Description |
|---|---|---|
| Loaded State | `BBs6e` | Main weather view — Tokyo, 24°C, Partly Cloudy, AI quote generated |
| AI Generating State | `XbtTp` | Marrakech, 38°C, Clear Sky, AI quote skeleton shimmer |
| Manage Locations | `eQ88c` | Location list with delete buttons, hint text, add button |
| Delete Confirmation | `J553h` | Manage list with swipe-to-delete revealed on Marrakech row |

### Screen Structure

```
Screen (402x874, mesh_gradient, clip)
├── StatusBar (ref: xQdct)
└── Content (vertical, fill, padding [0,24,24,24], gap 24, center)
    ├── LocationBadge (ref: gCvbQ)
    ├── Hero (vertical, center, gap 12)
    │   ├── TemperatureDisplay (ref: LcVaK)
    │   └── WeatherConditionBadge (ref: 9R7BG)
    ├── MetricsGrid (vertical, gap 12)
    │   ├── Row1 (horizontal, gap 12)
    │   │   ├── WeatherMetricCard — Humidity
    │   │   └── WeatherMetricCard — Wind
    │   └── Row2 (horizontal, gap 12)
    │       ├── WeatherMetricCard — Pressure
    │       └── WeatherMetricCard — Feels Like
    ├── AIQuoteCard (Generated or Generating)
    └── BottomBar (horizontal, space-between)
        ├── PageDots (horizontal, gap 8)
        └── AddButton (glass-surface-strong, pill)
```

### Mesh Gradient Backgrounds

Each weather condition uses a 2x2 mesh gradient:

| Condition | Colors (TL, TR, BL, BR) |
|---|---|
| Cloudy / Default | `#1A1B4E`, `#2D1B6E`, `#1B3A5E`, `#0F2027` |
| Sunny / Clear | `#4A2810`, `#6B3A1F`, `#2D1B0E`, `#1A1B2E` |

In SwiftUI, implement as `MeshGradient(width:height:points:colors:)` with colors derived from `WeatherCondition`.

### Navigation Flow

```
Weather Screen (TabView, page style)
    ├── Swipe horizontal → Next/prev location card
    ├── "Add Location" → Generates random coords, adds card
    └── Long-press / List icon → Manage Locations (sheet)
        ├── Swipe left on row → Reveal "Delete"
        ├── Tap minus → Delete location
        ├── "Add Random Location" → Same as main screen add
        └── "Done" → Dismiss sheet
```

---

## Maintenance Rules

### When editing WeatherApp.pen (Pencil MCP)

1. **Before** making changes: Read this document to understand existing tokens and patterns.
2. **After** making changes: Update the relevant section of this document immediately.
3. **New components**: Add to the Components Inventory table with Pen ID, type, and description.
4. **New tokens**: Add to the appropriate token table and update `set_variables` in the .pen file.
5. **Renamed/deleted components**: Remove from inventory, note the change.

### When writing SwiftUI code

1. **Always** reference this document for token values, not hardcoded colors.
2. **Map tokens** to Swift: use `Color(hex:)` extension or asset catalog with matching names.
3. **Glass surfaces** in code use `.glassEffect()` — do not manually recreate translucent fills.
4. **Typography**: Map display font weights to SF Pro system font equivalents.
5. **Keep parity**: If a new view introduces a visual pattern not in this document, add it here first.

### Token → Swift Mapping

```swift
// Colors (define as extension on Color or in asset catalog)
static let bgPrimary = Color(hex: "#1A1B2E")
static let glassSurface = Color.white.opacity(0.1)    // In code, prefer .glassEffect()
static let glassSurfaceStrong = Color.white.opacity(0.2)
static let textPrimary = Color.white
static let textSecondary = Color.white.opacity(0.7)
static let textTertiary = Color.white.opacity(0.4)
static let accentBlue = Color(hex: "#5B9CF6")
static let accentTeal = Color(hex: "#14B8A6")
static let accentOrange = Color(hex: "#F59E0B")
static let accentPink = Color(hex: "#F472B6")
static let accentRed = Color(hex: "#EF4445")

// Spacing
enum Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
}

// Radius
enum Radius {
    static let sm: CGFloat = 12
    static let md: CGFloat = 20
    static let lg: CGFloat = 24
    static let pill: CGFloat = 100
}
```
