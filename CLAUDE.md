# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a SwiftUI iOS camera application named "apus" that provides full camera functionality with navigation between camera and settings views. The app features comprehensive camera controls, photo capture, gallery access, and uses SwiftData for data persistence.

## Architecture

- **App Entry Point**: `apusApp.swift` - Contains the main app structure with SwiftData ModelContainer setup
- **Root Navigation**: `ContentView.swift` - Navigation view with hamburger menu switching between Home and Settings
- **Camera Implementation**: `CameraView.swift` - Full-featured camera with AVFoundation integration, capture, gallery access, and camera switching
- **Settings View**: `SettingsView.swift` - Placeholder for app settings and preferences
- **Data Model**: `Item.swift` - SwiftData model for timestamped items
- **Permissions**: `Info.plist` - Contains camera and photo library usage descriptions

## Key Technologies

- SwiftUI for declarative UI framework
- SwiftData for persistent data storage
- AVFoundation for camera capture and media handling
- Photos framework for photo library access
- Swift Testing framework for unit tests
- XCTest for UI testing

## Development Commands

### Building and Running
- **IMPORTANT**: Open `apus.xcworkspace` (not `apus.xcodeproj`) in Xcode due to CocoaPods integration
- Use Xcode GUI for building - command line builds may fail due to CocoaPods sandbox permissions
- Physical device required for camera functionality and object detection testing
- Simulator has limitations: no camera access, no GPU acceleration for TensorFlow Lite
- Requires iOS 18.5+ deployment target

### Dependencies Setup
- Install CocoaPods dependencies: `pod install` (if Podfile.lock changes)
- Dependencies managed via CocoaPods include TensorFlow Lite Swift with GPU support

### Testing
- Run tests through Xcode Test Navigator (⌘+6) or Product → Test (⌘+U)
- Unit tests are in `apusTests/apusTests.swift` using Swift Testing framework
- UI tests are in `apusUITests/` directory using XCTest framework

## Camera Architecture

The camera implementation uses a centralized `CameraManager` class that handles:
- AVCaptureSession management and configuration
- Front/back camera switching with animation
- Photo capture with completion handlers
- Permission handling for camera and photo library access
- Error handling and user feedback

Camera permissions are configured in `Info.plist` with descriptive usage descriptions for camera access, photo library read/write access.

## Navigation Flow

The app uses state-based navigation with `NavigationPage` enum:
- **Home**: Displays the camera interface (`CameraView`)
- **Settings**: Placeholder for future settings functionality
- **Menu**: Hamburger menu in toolbar for navigation between sections

## SwiftData Integration

The app uses a persistent ModelContainer configured in the main app file with the Item schema. The model context is injected into the environment and accessed via `@Environment(\.modelContext)` in views. Currently minimal but extensible for photo metadata storage.

## TensorFlow Lite Object Detection

The app includes real-time object detection using TensorFlow Lite with EfficientDet-Lite0 model:

### Object Detection Components
- **ObjectDetectionManager**: Manages TensorFlow Lite inference with EfficientDet-Lite0 model
- **Detection Processing**: Real-time video frame processing with throttling (100ms intervals)
- **Performance Optimization**: GPU acceleration support via MetalDelegate
- **Object Classification**: COCO dataset labels (80 classes including person, car, bicycle, etc.)

### Detection Features
- **Real-time Processing**: Processes camera feed at 10fps for optimal performance
- **Bounding Box Overlay**: Visual detection results with confidence scores
- **Model Specifications**: EfficientDet-Lite0 (4.5MB), 320x320 input resolution
- **Threading**: Background processing to maintain UI responsiveness

### Detection Files
- `ObjectDetectionManager.swift` - TensorFlow Lite inference manager
- `efficientdet_lite0.tflite` - Pre-trained object detection model
- `coco_labels.txt` - Class labels for detected objects

### Dependencies
- **TensorFlow Lite Swift**: Added via CocoaPods (`pod 'TensorFlowLiteSwift'`)
- **AVFoundation**: Video processing and camera integration
- **CoreVideo**: Pixel buffer handling and image preprocessing

## Project Structure Notes

### Key Configuration Files
- `Podfile` and `Podfile.lock` - CocoaPods dependency management
- `apus.xcworkspace` - Main workspace file (use this, not .xcodeproj)
- `Info.plist` - Camera and photo library permissions configuration
- `apus.entitlements` - CloudKit and app sandbox permissions

### Object Detection Assets
- `efficientdet_lite0.tflite` - 4.5MB pre-trained model (320x320 input resolution)
- `coco_labels.txt` - 80 COCO dataset object class labels

### Development Constraints
- Command-line builds may fail due to CocoaPods sandbox restrictions
- GPU acceleration (MetalDelegate) automatically disabled on simulator
- Real-time object detection requires physical device for performance testing
- Camera permissions must be granted for full functionality