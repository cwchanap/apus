# GEMINI.md

This file provides guidance to Gemini when working with code in this repository.

## Project Overview

This is a SwiftUI iOS application named "apus" that serves as a basic template for a camera-centric app with settings. The app utilizes SwiftData for data persistence, although the current data model is simple. It also includes an object detection feature using TensorFlow Lite.

## Architecture

- **App Entry Point**: `apusApp.swift` - Configures and provides the SwiftData `ModelContainer`.
- **Main View**: `ContentView.swift` - Acts as the root view, managing navigation between the `HomeView` and `SettingsView` using a toolbar menu.
- **Home View**: `HomeView.swift` - Currently displays the `CameraView`.
- **Camera View**: `CameraView.swift` - Handles camera input and display, and integrates with the `ObjectDetectionManager`.
- **Settings View**: `SettingsView.swift` - A placeholder for application settings.
- **Data Model**: `Item.swift` - A simple SwiftData model with a single `timestamp` attribute.
- **Object Detection Manager**: `ObjectDetectionManager.swift` - Manages the TensorFlow Lite model and performs object detection on camera frames.

## Key Technologies

- SwiftUI for the user interface.
- SwiftData for data persistence.
- TensorFlow Lite for object detection.
- Cocoapods for dependency management.

## Development Commands

### Building and Running
- Open `apus.xcworkspace` in Xcode.
- Build and run the application using the Xcode toolbar, selecting an appropriate simulator or a connected device.

### Testing
- The project is set up for both unit tests and UI tests.
- Unit tests are located in `apusTests/apusTests.swift`.
- UI tests are in `apusUITests/`.
- Currently, no specific tests have been implemented.

## Project Structure

- `apus/`: Contains the main application source code.
- `apus/models`: Contains the TensorFlow Lite model and labels.
- `apusTests/`: The target for unit tests.
- `apusUITests/`: The target for UI tests.
- `apus.xcodeproj/`: Xcode project file and configuration.
- `Podfile`: Manages the Cocoapods dependencies.

## Object Detection Setup

The object detection feature is implemented in `ObjectDetectionManager.swift`. It uses the `efficientdet_lite0` model from TensorFlow Lite and the `coco_labels` file for class names. The manager is initialized in `CameraView.swift` and receives camera frames for processing. The detected objects are then displayed as an overlay on the camera preview.