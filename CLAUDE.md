# WeatherApp CLAUDE.md

## Project Context
- Type: personal
- Architecture: tca

## STACK
- iOS 26+ (Liquid Glass / .glassEffect())
- Swift 6 (strict concurrency: Complete)
- SwiftUI
- The Composable Architecture (TCA) v1.x
- swift-snapshot-testing v1.x (test targets only)
- SwiftData (location persistence)
- OpenWeatherMap API
- Foundation Models (Apple Intelligence, deferred)

## COMMANDS
```bash
# Build
xcodebuild -project WeatherApp/WeatherApp.xcodeproj -scheme WeatherApp -sdk iphonesimulator build

# Test (unit + snapshots)
xcodebuild -project WeatherApp/WeatherApp.xcodeproj -scheme WeatherApp -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16 Pro' test
```

## ARCHITECTURE
Two-level TCA composition:
- `WeatherListFeature` (root) → manages collection of locations, paging, persistence
- `WeatherFeature` (child) → per-location weather data lifecycle
- `ManageLocationsFeature` (presented modal via @Presents) → edit/delete locations

Dependencies: `WeatherClient`, `LocationGenerator`, `CacheClient`, `PersistenceClient`, `IntelligenceClient` (deferred)

See `DOCS/DESIGN.md` for the full Design System specification.
See `DOCS/superpowers/specs/2026-03-20-weather-app-design.md` for the complete spec.
See `DOCS/superpowers/plans/2026-03-20-weather-app-implementation.md` for the implementation plan.

## PROJECT STRUCTURE
```
WeatherApp/WeatherApp/           # Main app target
├── App/                             # Entry point
├── Features/{Weather,WeatherList,ManageLocations}/  # TCA features
├── Clients/                         # @Dependency implementations
├── Models/                          # Domain models
├── Persistence/                     # SwiftData models
├── DesignSystem/{Components}/       # Tokens + reusable views
├── Configuration/                   # Secrets (gitignored)
└── Extensions/                      # Swift extensions
WeatherApp/WeatherAppTests/      # Unit tests
WeatherApp/WeatherAppSnapshotTests/  # Snapshot tests
```

## GIT WORKFLOW
- Each task creates a branch from the previous completed branch
- PRs from task branch → parent branch, numbered sequentially
- Branch naming: `task/N-description`

## DESIGN SYSTEM
- Source of truth: `WeatherApp.pen` (Pencil MCP)
- Documentation: `DOCS/DESIGN.md`
- **Rule**: Any visual change must update BOTH the .pen file AND DOCS/DESIGN.md
- **Rule**: Always read DOCS/DESIGN.md before any UI work
- **Rule**: Use design tokens from the DS, never hardcode colors/spacing/radius

## LEARNED CORRECTIONS
- `fontFamily` variables don't resolve in Pencil MCP — use font name strings directly (2026-03-20)
