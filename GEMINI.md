# GEMINI.md

This file provides guidance to Gemini when working with code in this repository.

## Project Overview

This is a SwiftUI iOS application named "apus" that serves as a basic template for a camera-centric app with settings. The app utilizes SwiftData for data persistence, although the current data model is simple.

## Architecture

- **App Entry Point**: `apusApp.swift` - Configures and provides the SwiftData `ModelContainer`.
- **Main View**: `ContentView.swift` - Acts as the root view, managing navigation between the `HomeView` and `SettingsView` using a toolbar menu.
- **Home View**: `HomeView.swift` - Currently displays the `CameraView`.
- **Camera View**: `CameraView.swift` - (Not provided, but referenced) Presumably handles camera input and display.
- **Settings View**: `SettingsView.swift` - (Not provided, but referenced) A placeholder for application settings.
- **Data Model**: `Item.swift` - A simple SwiftData model with a single `timestamp` attribute.

## Key Technologies

- SwiftUI for the user interface.
- SwiftData for data persistence.

## Development Commands

### Building and Running
- Open `apus.xcodeproj` in Xcode.
- Build and run the application using the Xcode toolbar, selecting an appropriate simulator or a connected device.

### Testing
- The project is set up for both unit tests and UI tests.
- Unit tests are located in `apusTests/apusTests.swift`.
- UI tests are in `apusUITests/`.
- Currently, no specific tests have been implemented.

## Project Structure

- `apus/`: Contains the main application source code.
- `apusTests/`: The target for unit tests.
- `apusUITests/`: The target for UI tests.
- `apus.xcodeproj/`: Xcode project file and configuration.

## SwiftData Model Setup

The SwiftData `ModelContainer` is configured in `apusApp.swift`. It uses a `Schema` that includes the `Item` model and is configured for on-disk persistence (`isStoredInMemoryOnly: false`). The container is then injected into the SwiftUI environment for access in different views.
