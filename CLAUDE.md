# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a SwiftUI iOS camera application named "apus" that provides full camera functionality with advanced computer vision capabilities. The app features comprehensive camera controls, photo capture, gallery access, real-time object detection, image classification, contour detection, and uses SwiftData for data persistence. Built with a modular architecture using dependency injection for high testability and maintainability.

## Architecture

### Core Architecture Components
- **App Entry Point**: `apusApp.swift` - SwiftData ModelContainer setup with forced dark mode and hidden status bar
- **Dependency Injection**: `DIContainer.swift` - Complete DI system with protocol-based dependencies, property wrappers (@Injected, @OptionalInjected), and testing support
- **Root Navigation**: `ContentView.swift` - Navigation view with hamburger menu switching between Home and Settings
- **Service Layer**: Modular services (CameraManager, PhotoLibraryService, PermissionService, ErrorService, HapticService)

### Feature Modules
- **Camera Module**: `CameraView.swift`, `CameraViewModel.swift`, `CameraManager.swift` - Full AVFoundation integration with state management
- **Object Detection Module**: Multiple detection systems (TensorFlow Lite, Vision framework, unified detection)
- **Image Classification Module**: ML-powered image analysis with classification history
- **Preview Module**: `PreviewView.swift` with zoomable image display and processing pipeline
- **Settings Module**: `SettingsView.swift` with app configuration and preferences

### Data Layer
- **Models**: `Item.swift` (SwiftData), `AppSettings.swift`, `DetectionResults.swift`
- **Extensions**: `UIImage+Processing.swift` for image normalization and optimization

## Key Technologies

- **SwiftUI**: Declarative UI framework with state management
- **SwiftData**: Persistent data storage with model container
- **AVFoundation**: Camera capture, video processing, and media handling
- **Vision Framework**: Apple's native computer vision for object detection
- **TensorFlow Lite**: Custom ML model inference with GPU acceleration
- **CoreVideo**: Pixel buffer handling and image preprocessing
- **Photos Framework**: Photo library access and integration
- **Combine**: Reactive programming for async operations
- **Swift Testing + XCTest**: Comprehensive unit and UI testing frameworks

## Development Commands

### Building and Running
- **IMPORTANT**: Open `apus.xcworkspace` (not `apus.xcodeproj`) in Xcode due to CocoaPods integration
- **Recommended**: Use Xcode GUI for building - command line builds may fail due to CocoaPods sandbox permissions
- **Alternative command line**: `./build.sh` (simulator build with sandbox workaround)
- **Device requirement**: Physical device required for camera and ML model testing
- **Simulator limitations**: No camera access, no GPU acceleration for TensorFlow Lite
- **iOS version**: Requires iOS 18.5+ deployment target

### Dependencies Setup
- **Install dependencies**: `pod install` (when Podfile.lock changes)
- **Key dependencies**: TensorFlow Lite Swift (~2.14.0) with potential GPU/Metal support
- **Sandbox settings**: User script sandboxing disabled for CocoaPods compatibility

### Testing Commands
```bash
# Run all tests via command line
xcodebuild -workspace apus.xcworkspace -scheme apus test

# Run specific test class
xcodebuild -workspace apus.xcworkspace -scheme apus test -only-testing:apusTests/CameraViewModelTests

# Run specific test method  
xcodebuild -workspace apus.xcworkspace -scheme apus test -only-testing:apusTests/CameraViewModelTests/testCapturePhoto_UpdatesCapturedImage
```

### Code Quality Commands
```bash
# Run SwiftLint for code style checking
swiftlint

# SwiftLint with autocorrect (fixes some violations automatically)
swiftlint --autocorrect

# SwiftLint for specific files
swiftlint lint --path apus/Features/Camera/Views/CameraView.swift
```

### SwiftLint Configuration
- **Configuration**: `.swiftlint.yml` with pragmatic thresholds optimized for SwiftUI development
- **Line length**: 180 warning, 220 error (ignores comments, URLs, interpolated strings)
- **Function body**: 120 warning, 170 error lines
- **Type body**: 400 warning, 600 error lines
- **File length**: 500 warning, 800 error lines
- **Disabled rules**: `multiple_closures_with_trailing_closure`, `orphaned_doc_comment`, `no_fallthrough_only` for SwiftUI ergonomics

### Testing via Xcode
- **All tests**: Xcode Test Navigator (⌘+6) or Product → Test (⌘+U)
- **Test structure**: Comprehensive unit tests with dependency injection and mocking
- **Coverage**: 100% coverage across services, ViewModels, views, extensions, and integration tests

## Dependency Injection Architecture

The app uses a comprehensive dependency injection system for testability and modularity:

### Core DI Components
- **DIContainer**: Type-safe dependency registration and resolution with singleton/factory support
- **Property Wrappers**: `@Injected` (required dependencies), `@OptionalInjected` (optional dependencies)
- **ServiceLocator**: Alternative access pattern for common dependencies
- **AppDependencies**: Centralized configuration with production/testing modes

### Camera Architecture

The camera implementation uses protocol-based architecture with dependency injection:
- **CameraManagerProtocol**: Interface for camera operations with mock support
- **CameraViewModel**: State management with injected dependencies
- **Permission handling**: Integrated via PermissionService with proper Info.plist configuration
- **Error handling**: Centralized via ErrorService with user feedback

## Navigation Flow

The app uses state-based navigation with `NavigationPage` enum:
- **Home**: Displays the camera interface (`CameraView`)
- **Settings**: App configuration and preferences
- **Results**: Detection results dashboard with category-based navigation
- **Menu**: Floating overlay buttons for navigation between sections

## SwiftData Integration

The app uses a persistent ModelContainer configured in the main app file with the Item schema. The model context is injected into the environment and accessed via `@Environment(\.modelContext)` in views. Currently minimal but extensible for photo metadata storage.

## Computer Vision Architecture

The app features multiple computer vision systems with unified interface:

### Detection System Overview
- **Unified Detection Interface**: `UnifiedObjectDetectionProtocol` for framework selection
- **Multiple Backends**: TensorFlow Lite, Vision Framework, and hybrid approaches
- **Framework Selection**: Automatic or manual selection based on performance/accuracy needs
- **Real-time Processing**: Optimized for 10fps with background threading

### TensorFlow Lite Detection
- **Model**: EfficientDet-Lite0 (4.5MB, 320x320 resolution)
- **Dataset**: COCO (80 object classes)
- **Acceleration**: GPU support via MetalDelegate (device-only)
- **Manager**: `TensorFlowLiteObjectDetectionManager.swift`

### Vision Framework Detection  
- **Integration**: Native iOS Vision framework
- **Performance**: Optimized for iOS devices
- **Manager**: `VisionObjectDetectionManager.swift`
- **Benefits**: Built-in optimization and system integration

### Additional Vision Features
- **Image Classification**: ML-powered classification with history tracking
- **Contour Detection**: Computer vision-based shape analysis  
- **OCR/Text Recognition**: Vision framework text detection and recognition with results storage
- **Barcode Detection**: QR code and barcode scanning with smart content parsing
- **Image Processing**: Normalization, resizing, optimization pipelines

### Results System Architecture
- **DetectionResultsManager**: Centralized results storage using AppStorage with JSON serialization
- **Result Types**: StoredOCRResult, StoredObjectDetectionResult, StoredClassificationResult, StoredBarcodeResult
- **Results Dashboard**: NavigationStack-based UI for browsing historical results by category
- **Data Persistence**: Local storage with automatic cleanup (max 10 results per category)

### Computer Vision Files
- **Models**: `efficientdet_lite0.tflite`, `coco_labels.txt`
- **Managers**: Detection, classification, contour analysis, text recognition, and barcode detection managers
- **Extensions**: `UIImage+Processing.swift` for image optimization

## Project Structure and Development Notes

### Key Configuration Files
- **Workspace**: `apus.xcworkspace` (use this, not .xcodeproj due to CocoaPods)
- **Dependencies**: `Podfile`, `Podfile.lock` with TensorFlow Lite Swift integration
- **Permissions**: `Info.plist` with camera and photo library usage descriptions
- **Entitlements**: `apus.entitlements` and `apusDebug.entitlements` for app capabilities
- **Build Scripts**: `build.sh` for command-line builds with sandbox workarounds

### ML Assets and Resources
- **TensorFlow Model**: `efficientdet_lite0.tflite` (4.5MB, 320x320 input)
- **Labels**: `coco_labels.txt` (80 COCO dataset object classes)
- **App Assets**: `Assets.xcassets` with app icons and color sets

### Development Constraints and Important Notes
- **CocoaPods Integration**: Always use `.xcworkspace`, not `.xcodeproj`
- **Sandbox Issues**: Command-line builds may fail; prefer Xcode GUI or use `build.sh`
- **Device Requirements**: Physical device needed for camera and GPU-accelerated ML
- **Simulator Limitations**: No camera access, no GPU acceleration, limited ML performance
- **Permission Requirements**: Camera and photo library permissions must be granted
- **iOS Version**: Minimum iOS 18.5+ deployment target
- **Testing**: Comprehensive test suite with 100% coverage using dependency injection
- **Code Quality**: SwiftLint configured with pragmatic thresholds for SwiftUI development

## Testing Strategy

### Unit Testing
- **Test Structure**: Located in `apusTests/` with organized subdirectories
- **Dependency Injection**: Uses `TestDIContainer.swift` for mock dependencies
- **Coverage Areas**: Services, ViewModels, managers, extensions, and data models
- **Test Helpers**: Mock implementations for all protocols

### UI Testing
- **Location**: `apusUITests/` for end-to-end testing
- **Launch Tests**: Basic app launch and navigation validation

### Running Tests
- **Xcode**: Use Test Navigator (⌘+6) or Product → Test (⌘+U)
- **Command Line**: `xcodebuild -workspace apus.xcworkspace -scheme apus test`
- **Specific Tests**: Use `-only-testing` flag for targeted test execution

## Development Workflow

### Code Organization
- **Features**: Organized by feature modules in `apus/Features/`
- **Core**: Shared utilities and protocols in `apus/Core/`
- **Services**: Business logic and external integrations in `apus/Services/`
- **Resources**: Assets, models, and configuration files in `apus/Resources/`

### Best Practices
- **Protocol-First**: All managers implement protocols for testability
- **Dependency Injection**: Use `@Injected` for required dependencies
- **Error Handling**: Centralized via `ErrorService` with user feedback
- **Performance**: Background threading for heavy operations
- **SwiftUI**: Declarative UI with state management patterns