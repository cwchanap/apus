# Repository Guidelines

## Project Structure & Module Organization
- `apus/`: SwiftUI app code, organized by layer:
  - `App/` (entry point, `AppDependencies.swift`)
  - `Core/` (`Models/`, `Protocols/`, `DependencyInjection/`, `Extensions/`)
  - `Features/` (`Camera/`, `ObjectDetection/`, `Navigation/`, etc.)
  - `Services/` (`HapticService.swift`, `PermissionService.swift`, ...)
  - `Resources/` (`Assets.xcassets`, `Info.plist`, `MLModels/`)
- Tests: `apusTests/` (unit) and `apusUITests/` (UI).
- iOS dependencies via CocoaPods (`Podfile`, `Pods/`, `apus.xcworkspace`).

## Build, Test, and Development Commands
- Install pods: `pod install`
- Open in Xcode: `open apus.xcworkspace`
- Build/Run (GUI): Xcode `Cmd+B` / `Cmd+R` with the "apus" scheme.
- CLI build (may need sandbox flag): `./build.sh` or
  `xcodebuild -workspace apus.xcworkspace -scheme apus -destination 'platform=iOS Simulator,name=iPhone 16' build ENABLE_USER_SCRIPT_SANDBOXING=NO`
- Run tests: Xcode `Cmd+U` or
  `xcodebuild -workspace apus.xcworkspace -scheme apus -destination 'platform=iOS Simulator,name=iPhone 16' test`

## Coding Style & Naming Conventions
- Language: Swift 5 + SwiftUI. Indentation: 4 spaces, no tabs.
- Names: Types `UpperCamelCase`; properties/functions `lowerCamelCase`; enum cases `lowerCamelCase`.
- Files: One primary type per file, file name matches type (e.g., `DetectionResultsManager.swift`).
- Linting: SwiftLint is used (default rules). Keep functions small and prefer protocols for seams.

## Testing Guidelines
- Framework: XCTest. Place tests mirroring sources (e.g., `apusTests/Services/HapticServiceTests.swift`).
- Names: `test_doesThing_whenCondition()`; arrange-act-assert inside each test.
- Coverage: Add tests for new code paths and edge cases (async, permission denials, empty results).

## Commit & Pull Request Guidelines
- Commits: Imperative and scoped (e.g., "Fix ResultsDashboardView hang", "Add OCR unit tests").
- PRs: Include a clear description, linked issues, and screenshots/videos for UI changes.
- Note any new permissions or assets (e.g., Info.plist keys, files under `Resources/MLModels/`).

## Security & Configuration Tips
- Permissions: Update Info.plist (e.g., `NSCameraUsageDescription`) and route prompts via `PermissionService`.
- Entitlements: Modify files under `apus/Resources/*.entitlements` when needed.
- Assets: Commit large ML models to `Resources/MLModels/`; avoid committing secrets.

## Adding New Features
- Create `Features/<FeatureName>/` with SwiftUI views and view models.
- Define interfaces in `Core/Protocols` and concrete services in `Services/`.
- Register dependencies in `App/AppDependencies.swift`.

