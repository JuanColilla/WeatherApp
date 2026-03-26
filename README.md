# WeatherApp

![Swift 6](https://img.shields.io/badge/Swift-6-F05138?logo=swift&logoColor=white)
![iOS 26+](https://img.shields.io/badge/iOS-26+-000000?logo=apple&logoColor=white)
![TCA](https://img.shields.io/badge/Architecture-TCA-7B61FF)
![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-007AFF?logo=swift&logoColor=white)
![Apple Intelligence](https://img.shields.io/badge/AI-Apple%20Intelligence-FF6B9D)
![Liquid Glass](https://img.shields.io/badge/Design-Liquid%20Glass-B0C4DE)
![SwiftData](https://img.shields.io/badge/Persistence-SwiftData-34C759)
![Tests](https://img.shields.io/badge/Tests-50%20total-brightgreen)

A weather app that displays current conditions for random locations around the world. Built as a code challenge, prioritizing production-grade architecture, testability, and visual polish.

---

## Requirements Compliance

Each requirement mapped to its implementation:

| # | Requirement | Status | Verification |
|---|---|---|---|
| 1 | **Display weather for a random location** (lat/lon) | Done | `LocationGenerator.swift:14-16` — generates valid lat `[-90, 90]` and lon `[-180, 180]` via `Double.random`. `WeatherClient.swift:12` — fetches from `api.openweathermap.org/data/2.5/weather` by geographic coordinates. |
| 2 | **Display latitude/longitude or city name** | Done | `LocationBadgeView.swift:13-17` — renders both the city name (from API response) and formatted lat/lon coordinates simultaneously. |
| 3 | **Way to refresh with a new random location** | Done | `WeatherView.swift:25-26` — SwiftUI `.refreshable` triggers pull-to-refresh. `WeatherListFeature.swift` intercepts to generate a new coordinate and fetch fresh data. Also available via the "Add Random Location" button. |
| 4 | **Using Swift 6** | Done | `SWIFT_VERSION = 6.0` set explicitly on all 3 targets (app + 2 test targets) in `project.pbxproj`. Combined with `SWIFT_APPROACHABLE_CONCURRENCY = YES` and `SWIFT_DEFAULT_ACTOR_ISOLATION = nonisolated` for Swift 6.2 concurrency model. |
| 5 | **Strict concurrency checking enabled** | Done | Swift 6 language mode makes concurrency violations compile-time errors (not warnings). All types conform to `Sendable`, test closures use `LockIsolated` for thread-safe mutation capture. Zero concurrency errors at build time. |
| 6 | **Code on this git repository** | Done | All source code, tests, design files, specs, and plans are committed and pushed. |
| 7 | **README describing the solution** | Done | This file. |
| 8 | **Document AI usage** | Done | See [AI-Assisted Development](#ai-assisted-development) section — covers Claude Code, skills, Pencil MCP, and the full workflow. |
| 9 | **Document trade-offs** | Done | See [Decisions and Trade-offs](#decisions-and-trade-offs) section — covers iOS 26+ targeting, TCA choice, SwiftData vs UserDefaults, cache strategy, and testing framework split. |

---

## Solution Overview

WeatherApp generates random geographic coordinates and fetches real-time weather data from the [OpenWeatherMap API](https://openweathermap.org/current#geo). Users can swipe horizontally between multiple locations, pull to refresh for a new random location, and manage their saved locations from a modal sheet.

### Why TCA?

The project uses [The Composable Architecture (TCA)](https://github.com/pointfreeco/swift-composable-architecture) — a state management framework by Point-Free — as its core architecture. While arguably more complex than vanilla SwiftUI for a single-screen app, TCA was chosen deliberately:

- **Testability**: Every state mutation and side effect is deterministic and testable via `TestStore`. The 24 unit tests cover all reducer logic with dependency replacement via `withDependencies` — no third-party mocking frameworks needed.
- **Scalability**: The parent-child composition (`WeatherListFeature` → `WeatherFeature`) demonstrates how features compose cleanly. Adding a new feature (e.g., Apple Intelligence quotes) required no changes to existing reducers — it slotted into the existing state/action/effect structure naturally.
- **Dependency Injection**: All external dependencies (`WeatherClient`, `PersistenceClient`, `CacheClient`, `IntelligenceClient`, `LocationGenerator`) are injected via `@Dependency`, making them trivially replaceable in tests.
- **Strict Concurrency**: TCA's `Sendable` enforcement and effect system align perfectly with Swift 6 strict concurrency checking.

### Key Features

| Feature | Implementation |
|---|---|
| **Random locations** | `LocationGenerator` produces valid lat/lon pairs; new location on each refresh |
| **Pull to refresh** | SwiftUI `.refreshable` + TCA parent-child action interception pattern |
| **Multi-location paging** | `TabView(.page)` with `WeatherListFeature` managing an `IdentifiedArray` |
| **Location management** | Modal sheet (`@Presents`) with swipe-to-delete and tap-to-navigate |
| **Persistence** | SwiftData with `@Attribute(.unique)` for upsert semantics |
| **In-memory cache** | `LockIsolated` dictionary to avoid redundant API calls |
| **Apple Intelligence** | On-device sarcastic weather quotes via FoundationModels (`#if canImport`) |
| **Liquid Glass** | iOS 26 `.glassEffect()` on all cards, badges, and interactive surfaces |
| **Animated gradients** | Weather-condition-driven mesh gradients with eased speed during AI generation |

---

## Project Structure

```
juan-colilla/
├── CLAUDE.md                          # AI assistant configuration
├── WeatherApp.pen                   # Design file (Pencil MCP)
├── DOCS/
│   ├── DESIGN.md                      # Design System specification
│   └── superpowers/
│       ├── specs/
│       │   └── 2026-03-20-weather-app-design.md    # Feature spec
│       └── plans/
│           ├── 2026-03-20-weather-app-implementation.md  # Implementation plan
│           └── 2026-03-21-apple-intelligence-feature.md    # AI feature plan
│
└── WeatherApp/
    ├── WeatherApp.xcodeproj
    ├── WeatherApp/                   # Main app target (30 Swift files)
    │   ├── WeatherAppApp.swift       # Entry point, root Store
    │   ├── Features/
    │   │   ├── WeatherList/            # Root feature — location collection + paging
    │   │   ├── Weather/                # Child feature — per-location weather lifecycle
    │   │   └── ManageLocations/        # Modal — edit/delete/select locations
    │   ├── Clients/                    # TCA @Dependency implementations
    │   │   ├── WeatherClient.swift     # OpenWeatherMap API
    │   │   ├── LocationGenerator.swift # Random coordinate generation
    │   │   ├── CacheClient.swift       # In-memory weather cache
    │   │   ├── PersistenceClient.swift # SwiftData persistence
    │   │   └── IntelligenceClient.swift # Apple Intelligence (FoundationModels)
    │   ├── Models/                     # Domain models (Coordinate, WeatherData, etc.)
    │   ├── Persistence/                # SwiftData model (PersistedLocation)
    │   ├── DesignSystem/               # Tokens, gradients, reusable components
    │   │   ├── Tokens.swift            # DSColor, DSSpacing, DSRadius constants
    │   │   ├── AnimatedGradientView.swift
    │   │   ├── WeatherGradient.swift
    │   │   ├── ShimmerModifier.swift
    │   │   └── Components/             # LocationBadge, MetricCard, AIQuoteCard, etc.
    │   ├── Configuration/              # API keys (gitignored)
    │   └── Extensions/                 # Color+Hex
    │
    ├── WeatherAppTests/              # Unit tests (24 tests, 5 files)
    │   ├── WeatherFeatureTests.swift
    │   ├── WeatherFeatureAITests.swift
    │   ├── WeatherListFeatureTests.swift
    │   ├── ManageLocationsFeatureTests.swift
    │   └── TestFixtures.swift
    │
    └── WeatherAppSnapshotTests/      # Snapshot tests (26 tests, 3 files)
        └── Snapshots/
            ├── ComponentSnapshotTests.swift
            ├── AIQuoteCardSnapshotTests.swift
            ├── ScreenSnapshotTests.swift
            └── __Snapshots__/          # 26 reference images (light + dark)
```

---

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                  WeatherListFeature                 │
│  (root reducer — manages IdentifiedArray, paging,   │
│   persistence, location generation, modal)          │
├──────────────┬──────────────┬───────────────────────┤
│ WeatherFeature│ WeatherFeature│  ManageLocationsFeature│
│  (child 0)    │  (child 1)    │   (@Presents modal)   │
│  - fetch      │  - fetch      │   - select location   │
│  - cache      │  - cache      │   - delete location   │
│  - AI quote   │  - AI quote   │   - add random        │
└──────────────┴──────────────┴───────────────────────┘
         │              │                │
    ┌────┴────┐    ┌────┴────┐     ┌────┴────┐
    │ Weather │    │  Cache  │     │Persistence│
    │ Client  │    │ Client  │     │  Client   │
    └─────────┘    └─────────┘     └──────────┘
         │                              │
   OpenWeatherMap                  SwiftData
       API                      (PersistedLocation)
```

### Parent-Child Action Interception

A key architectural pattern used throughout: the parent reducer (`WeatherListFeature`) intercepts actions from child features before they reach the child. This is used for:

- **Pull to refresh**: Child sends `.pullToRefresh` (returns `.none`), parent intercepts to generate a new coordinate and sends `.refreshLocation(coord)` back to the child.
- **Modal add location**: Parent intercepts `manageLocations(.presented(.addRandomLocation))` to add the location to the main collection and dismiss the modal.
- **Location selection**: Parent intercepts `manageLocations(.presented(.selectLocation))` to update `selectedIndex`.

---

## Testing Strategy

### Three Xcode Targets

| Target | Framework | Tests | Purpose |
|---|---|---|---|
| `WeatherApp` | — | — | Main app |
| `WeatherAppTests` | Swift Testing | 24 | TCA reducer logic (exhaustive + non-exhaustive) |
| `WeatherAppSnapshotTests` | XCTest + swift-snapshot-testing | 26 | Visual regression for components and screens |

### Unit Tests (24)

All TCA features are tested with `TestStore`, covering:

- `WeatherFeature`: fetch, retry, cache hit/miss, error handling, pull-to-refresh, AI quote generation
- `WeatherListFeature`: onAppear (empty/persisted), add/remove location, page selection, pull-to-refresh interception, modal interactions
- `ManageLocationsFeature`: done, delete, select location

Tests use both exhaustive mode (`.on` — every state change asserted) and non-exhaustive mode (`.off` — focus on specific interactions while allowing child effects to fire).

### Snapshot Tests (26)

All components and screens are snapshot-tested in both **light and dark mode** using [swift-snapshot-testing](https://github.com/pointfreeco/swift-snapshot-testing):

- `ComponentSnapshotTests`: LocationBadge, TemperatureDisplay, WeatherConditionBadge, WeatherMetricCard, LocationListItem, RefreshButton
- `AIQuoteCardSnapshotTests`: Generated, Generating (skeleton), Unavailable states
- `ScreenSnapshotTests`: Full weather screen (loaded, loading, error states)

> Snapshot tests run with parallel execution disabled to prevent multiple simulator instances from causing inconsistencies.

---

## Design System

The visual identity follows a **dark-first, translucent aesthetic** inspired by iOS 26 Liquid Glass. Every interactive surface uses `.glassEffect()` over dynamic weather-condition-driven gradient backgrounds.

### Design Workflow

The Design System was created using **[Pencil](https://pencil.dev)** — a design tool accessible via MCP (Model Context Protocol). The design file (`WeatherApp.pen`) is tracked in the repository and serves as the visual source of truth.

| Artifact | Purpose |
|---|---|
| `WeatherApp.pen` | Visual design file with all screens, components, and tokens |
| `DOCS/DESIGN.md` | Design System specification — tokens, rules, component inventory |

The `DESIGN.md` file documents all color tokens, typography scales, spacing values, corner radii, component structures, and Liquid Glass rules. It ensures the coded implementation matches the design by providing a shared contract between the design file and the Swift code.

### Key Design Tokens

- **Colors**: `bg-primary`, `glass-surface`, `text-primary/secondary/tertiary`, `accent-blue/teal/orange/pink`, `weather-sunny/cloudy/rainy/snowy`
- **Spacing**: 4px base grid (`xs: 4`, `sm: 8`, `md: 16`, `lg: 24`, `xl: 32`)
- **Radii**: `sm: 12`, `md: 20`, `lg: 24`, `pill: 100`
- **Glass**: `.glassEffect(.regular)` for all surfaces — never manually recreated with opacity fills

---

## Decisions and Trade-offs

| Decision | Rationale |
|---|---|
| **iOS 26+ only** | Required for Liquid Glass (`.glassEffect()`) and FoundationModels. A production app would support iOS 17+ with fallbacks, but for a challenge this lets us showcase the latest APIs. |
| **TCA over vanilla SwiftUI** | Over-engineered for the scope, but demonstrates scalable architecture, clean testing, and dependency management at a level suitable for a team of several engineers. |
| **SwiftData over UserDefaults** | Locations have structured data (ID, coordinate, order). SwiftData provides `@Attribute(.unique)` upsert semantics that simplify refresh persistence. |
| **In-memory cache** | Simple `LockIsolated<[String: CachedEntry]>` avoids unnecessary API calls. No disk persistence — cache is ephemeral by design. |
| **Apple Intelligence with `#if canImport`** | Gracefully degrades on devices/simulators without FoundationModels. The AI feature is additive and never blocks the core weather experience. |
| **Snapshot tests on XCTest** | swift-snapshot-testing has better XCTest integration than Swift Testing at the time of writing. Unit tests use Swift Testing for modern `@Test`/`@Suite` syntax. |

### Challenges Encountered

- **SwiftUI nested Button hit areas**: Wrapping a `Button` inside another `Button` causes the outer one to capture all taps. Solved by using sibling `Button(.plain)` elements at the same `HStack` level for independent tap targets (location row vs. delete button).
- **TCA `.refreshable` completion**: `.refreshable { await store.send(.action).finish() }` requires the effect chain to terminate. The parent-child interception pattern ensures `.finish()` waits transitively for all child effects.
- **`LockIsolated` return types**: `Dictionary.removeValue(forKey:)` returns `Value?`, which conflicts with `Void` closures in `@DependencyClient`. Must explicitly discard with `_ =`.
- **Snapshot test parallelism**: Xcode's default parallel test execution spawns multiple simulators, causing inconsistent snapshot rendering. Fixed by disabling `parallelizable` in the scheme.

---

## AI-Assisted Development

This project was built entirely using **[Claude Code](https://docs.anthropic.com/en/docs/claude-code)** — Anthropic's CLI agent for software engineering. Claude Code was used as a pair-programming partner throughout the entire development lifecycle: architecture design, implementation, testing, debugging, and documentation.

### Configuration Files

| File | Purpose |
|---|---|
| `CLAUDE.md` | Project-level AI assistant configuration — defines architecture context (TCA), stack constraints (iOS 26+, Swift 6), build commands, project structure, design system rules, and learned corrections |
| `DOCS/superpowers/specs/2026-03-20-weather-app-design.md` | Complete feature specification — architecture, data flow, components, navigation, and API contracts. Generated collaboratively during the brainstorming phase |
| `DOCS/superpowers/plans/2026-03-20-weather-app-implementation.md` | Step-by-step implementation plan with file map and task breakdown for the core app |
| `DOCS/superpowers/plans/2026-03-21-apple-intelligence-feature.md` | Dedicated implementation plan for the Apple Intelligence integration |
| `DOCS/DESIGN.md` | Design System documentation — ensures AI-generated UI code respects established tokens and component patterns |

### Specialized Skills

Claude Code was configured with custom skills (plugins) that provided domain-specific expertise:

| Skill | Source | Purpose |
|---|---|---|
| `tca-architecture` | Custom | TCA patterns — `@ObservableState`, `Scope`, `@Presents`, `StackState`, `@Dependency`, effects |
| `tca-testing` | Custom | `TestStore` exhaustive/non-exhaustive modes, `withDependencies`, `@Shared` state testing |
| `swift-snapshot-testing` | Custom | `assertSnapshot` strategies, recording modes, CI consistency, Swift Testing integration |
| `swift-concurrency` | [Antoine van der Lee (SwiftLee)](https://www.avanderlee.com/) | Async/await patterns, `@MainActor`, `Sendable`, actor isolation for Swift 6 |
| `brainstorming` | [Superpowers](https://github.com/anthropics/claude-code-superpowers) | Structured design exploration — questions, approach proposals, spec generation |
| `writing-plans` | [Superpowers](https://github.com/anthropics/claude-code-superpowers) | Implementation plans with file maps and bite-sized tasks |
| `subagent-driven-development` | [Superpowers](https://github.com/anthropics/claude-code-superpowers) | Task dispatch via isolated subagents for focused implementation |

### Design with Pencil MCP

The UI design was created using **[Pencil](https://pencil.dev)** — a design tool accessible via MCP (Model Context Protocol) that integrates directly into the Claude Code workflow. This allowed designing screens, extracting tokens, and implementing UI in a single feedback loop.

The design file (`WeatherApp.pen`) and the Design System documentation (`DOCS/DESIGN.md`) are both tracked in the repository, ensuring design decisions are versioned alongside code.

### Workflow Summary

```
Decision-making → Planning → Specs → Implementation → Test generation → Adjustments → Testing → Closure
                      ↑                                                                   │
                      └───────────────────── Corrections ─────────────────────────────────┘
```

The actual workflow was **implementation-first**: features were built, then tests were written as a dedicated phase to validate behavior retroactively. This is reflected in the git history — unit tests (PR #9) and snapshot tests (PR #10) were added after all features were implemented (PRs #1–#8). Specs and plans are committed to the repo, providing full traceability from requirements to implementation.

---

## Build & Run

### Requirements

- Xcode 26 beta (for Liquid Glass / `.glassEffect()`)
- iOS 26+ simulator or device
- OpenWeatherMap API key (free tier)

### Setup

1. Clone the repository
2. Open `WeatherApp/WeatherApp.xcodeproj`
3. Copy the example secrets file and add your API key:
   ```bash
   cp WeatherApp/WeatherApp/Configuration/Secrets.example \
      WeatherApp/WeatherApp/Configuration/Secrets.swift
   ```
   Then edit `Secrets.swift` and replace `YOUR_API_KEY_HERE` with your [OpenWeatherMap API key](https://openweathermap.org/appid) (free tier works).
4. Build and run on an iOS 26 simulator

### Running Tests

From Xcode:
- **Unit tests**: `Cmd+U` with the `WeatherApp` scheme selected
- **Snapshot tests**: Run the `WeatherAppSnapshotTests` scheme

> Note: Snapshot tests require iPhone 13 Pro simulator for consistent reference images.

---

## License

This project was created as a code challenge submission and is not licensed for redistribution.
