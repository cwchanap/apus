# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

APUS is an iOS 18.5+ machine learning application featuring real-time computer vision capabilities: object detection (Vision/Core ML YOLO), OCR, image classification, contour detection, and barcode scanning. Built with SwiftUI and protocol-driven architecture using custom dependency injection.

## Build Commands

- **Xcode GUI** (recommended): Open `apus.xcodeproj` in Xcode
- **Command line**: `./build.sh` - Builds for iPhone 16 simulator with sandbox disabled
- **Requirements**: iOS 18.5+, physical device recommended for camera/ML testing

## Test Commands

```bash
# Run all tests
xcodebuild -project apus.xcodeproj -scheme apus test

# Run specific test class
xcodebuild -project apus.xcodeproj -scheme apus test -only-testing:apusTests/CameraViewModelTests

# Run single test method
xcodebuild -project apus.xcodeproj -scheme apus test -only-testing:apusTests/CameraViewModelTests/testCapturePhoto_UpdatesCapturedImage

# Xcode GUI: Product → Test (⌘+U) or Test Navigator (⌘+6)
```

### Running Tests (preferred: XcodeBuildMCP, fallback: xcodebuild)

**Always disable parallel testing** — this machine does not have enough resources for concurrent simulator clones, and parallel `xcodebuild test` leaves orphaned clones in `~/Library/Developer/XCTestDevices` that accumulate to tens of GB.

**Preferred — via XcodeBuildMCP** (configured in Devin CLI):
1. Call `session_show_defaults` first to verify the active project/scheme/simulator.
2. If defaults are unset, call `session_set_defaults` with `projectPath`, `scheme`, and `simulatorName`.
3. Run `test_sim` with `extraArgs: ["-parallel-testing-enabled", "NO"]` to disable cloning.

**Fallback — direct xcodebuild** (when XcodeBuildMCP is unavailable):
```bash
xcodebuild test \
  -project apus.xcodeproj \
  -scheme apus \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -parallel-testing-enabled NO
```

## Lint Commands

```bash
swiftlint                                                      # Run linter
swiftlint --autocorrect                                        # Auto-fix violations
swiftlint lint --path apus/Features/Camera/Views/CameraView.swift  # Lint specific file
```

## Architecture

### Dependency Injection System

The codebase uses a custom DI container (`DIContainer.swift`) with property wrapper injection:

- **Property Wrappers**: `@Injected<T>` for required dependencies, `@OptionalInjected<T>` for optional
- **Registration**: `AppDependencies.swift` configures all dependencies at startup
- **Singleton Pattern**: Most services registered as singletons, some use factories
- **Lazy Initialization**: Dependencies configured on first access via `ensureDependenciesConfigured()`
- **Testing Support**: `configureForTesting()` registers mock implementations

**Usage Example**:
```swift
class CameraViewModel {
    @Injected var cameraManager: CameraManagerProtocol
    @Injected var objectDetection: ObjectDetectionProtocol
}
```

**Important**: Dependencies must be configured via `AppDependencies.shared` before using `@Injected`. The container uses type-based string keys (`String(describing: type)`) for registration.

### Protocol-First Design

All major components are abstracted behind protocols (suffix: `Protocol`):

**Detection Protocols**:
- `ObjectDetectionProtocol` - Real-time frame processing (camera feed)
- `UnifiedObjectDetectionProtocol` - High-level API supporting multiple frameworks (Vision/Core ML)
- `VisionObjectDetectionProtocol` - Detailed Vision framework interface
- `VisionTextRecognitionProtocol` - OCR with character-level recognition
- `ImageClassificationProtocol` - Image classification
- `ContourDetectionProtocol` - Shape/contour detection
- `BarcodeDetectionProtocol` - Barcode/QR code scanning
- `CameraManagerProtocol` - Camera session control

**Service Protocols**:
- `PermissionServiceProtocol` - iOS permissions (camera/photos)
- `PhotoLibraryServiceProtocol` - Photo library access
- `ErrorServiceProtocol` - Centralized error handling
- `HapticServiceProtocol` - Haptic feedback

### Feature-Based Organization

```
Features/
├── Camera/              # Live camera feed with real-time detection
├── ObjectDetection/     # Multiple detection framework implementations
├── ImageClassification/ # Image classification
├── ContourDetection/    # Shape detection
├── Preview/             # Detection result preview
├── Results/             # Results display and management
├── Settings/            # App configuration
└── Navigation/          # App navigation (ContentView)
```

Each feature contains: `Managers/`, `ViewModels/`, `Views/`, `Models/` (as needed).

### Detection Framework Abstraction

The app supports multiple ML frameworks through `ObjectDetectionFactory`:

```swift
// Auto-selects based on device capability
let manager = ObjectDetectionFactory.createObjectDetectionManager()

// Explicit framework selection
let manager = ObjectDetectionFactory.createObjectDetectionManager(framework: .coreML)
```

**Frameworks**:
- **Vision**: Native iOS, always available
- **Core ML**: YOLO v12s (when bundled model present in `Resources/Models/yolov12s.mlpackage`)

Framework selection stored in `AppSettings.shared.objectDetectionFramework`.

### Results Management

`DetectionResultsManager` (split across 8 extension files) handles persistence:

**Extensions**:
- `DetectionResultsManager+OCR.swift`
- `DetectionResultsManager+ObjectDetection.swift`
- `DetectionResultsManager+Classification.swift`
- `DetectionResultsManager+Contour.swift`
- `DetectionResultsManager+Barcode.swift`
- `DetectionResultsManager+AsyncLoading.swift`
- `DetectionResultsManager+Helpers.swift`

**Stored Result Types**: `StoredOCRResult`, `StoredObjectDetectionResult`, etc.
- Image data (JPEG compressed)
- Thumbnail caching (max 160px)
- Metadata (timestamp, confidence stats)
- Per-category storage limits (configurable in `AppSettings`)

### Error Handling

Use `ErrorService` for centralized error presentation:

```swift
@Injected var errorService: ErrorServiceProtocol

// Present error with optional recovery
errorService.presentError(error, context: "capturing photo")
```

**Error Types** (`AppError` enum):
- Localized messages
- Recovery suggestions
- Permission-aware (shows settings button when appropriate)

### Settings Management

Global singleton: `AppSettings.shared`

**Key Settings**:
- `isRealTimeObjectDetectionEnabled: Bool`
- `isRealTimeBarcodeDetectionEnabled: Bool`
- `objectDetectionFramework: ObjectDetectionFramework` (.vision or .coreML)
- `objectDetectionModel: ObjectDetectionModel` (.yoloV12s)
- Storage limits per detection category (1-100 results)

Settings automatically persist to `UserDefaults` via `didSet` observers.

### Threading Model

- **@MainActor**: All ViewModels and UI updates
- **Background Processing**: Heavy ML operations on `.utility` QoS
- **Preloading**: Models preload asynchronously in `AppDependencies.configureDependencies()`

Example:
```swift
DispatchQueue.global(qos: .utility).async {
    objectDetectionManager.preload()
}
```

## Code Style Guidelines

- **Imports**: Group by framework (stdlib → system → third-party → local); sort alphabetically
- **Formatting**: Follow `.swiftlint.yml` (line length 180/220, function body 120/170)
- **Types**: PascalCase for classes/structs/enums; camelCase for properties/methods
- **Naming**: Descriptive, avoid abbreviations; protocols end with "Protocol"
- **Error Handling**: Use `ErrorService` for user-facing errors; throw/return Results where appropriate
- **Architecture**: Protocol-first with dependency injection (`@Injected`); background threading for heavy ops

## Testing

- **Framework**: XCTest with async/await
- **Test Container**: `TestDIContainer` for isolation
- **Mocks**: Comprehensive mock implementations in `AppDependencies.configureForTesting()`
  - `MockCameraManager`, `MockObjectDetectionManager`, `MockPermissionService`, etc.
- **Helpers**: `TestRunner.swift`, `TestDIContainer.swift`

**Pattern**:
```swift
@MainActor
class CameraViewModelTests: XCTestCase {
    var viewModel: CameraViewModel!

    override func setUp() {
        super.setUp()
        AppDependencies.shared.configureForTesting()
        viewModel = CameraViewModel()
    }
}
```

## ML Model Integration

- **Model**: YOLOv12s Core ML model in `Resources/Models/yolov12s.mlpackage/`
- **Format**: `.mlpackage` (Apple's recommended format)
- **Preloading**: Background preload via `UnifiedObjectDetectionProtocol.preload()`
- **Python Tools**: `src/apus_ml_tools/` for model conversion (torch → ONNX → Core ML)
  - Requires Python 3.12+, managed via `pyproject.toml`

## Key Files

- `apus/App/AppDependencies.swift` - Centralized DI configuration
- `apus/Core/DependencyInjection/DIContainer.swift` - DI container implementation
- `apus/Core/Models/AppSettings.swift` - Global settings singleton
- `apus/Core/Protocols/` - Protocol definitions (8 files)
- `apus/Services/DetectionResultsManager/` - Result persistence (8 extension files)
- `apus/Features/Camera/Managers/CameraManager.swift` - Camera session management
- `apus/Features/ObjectDetection/Managers/` - Detection framework implementations

## Common Patterns

### Adding a New Feature

1. Create feature directory under `Features/`
2. Define protocol in `Core/Protocols/` if new capability
3. Implement manager conforming to protocol
4. Register in `AppDependencies.configureDependencies()`
5. Create ViewModel with `@Injected` dependencies
6. Build SwiftUI views
7. Add mock implementation for testing

### Switching Detection Frameworks

User controls via Settings UI. Code reads `AppSettings.shared.objectDetectionFramework`:
```swift
let framework = AppSettings.shared.objectDetectionFramework
let manager = ObjectDetectionFactory.createObjectDetectionManager(framework: framework)
```

### Adding Storage for New Detection Type

1. Add case to `DetectionCategory` enum in `AppSettings.swift`
2. Add stored result type in `DetectionResults.swift`
3. Create extension file: `DetectionResultsManager+NewType.swift`
4. Add storage limit property to `AppSettings`
5. Update `getStorageLimit()` and `setStorageLimit()` switch statements
