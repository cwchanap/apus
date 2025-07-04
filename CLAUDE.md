# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a SwiftUI iOS application named "apus" that demonstrates basic SwiftData functionality with a simple item management interface. The app uses a master-detail navigation pattern with the ability to add and delete timestamped items.

## Architecture

- **App Entry Point**: `apusApp.swift` - Contains the main app structure with SwiftData ModelContainer setup
- **Main View**: `ContentView.swift` - Navigation split view with list of items and add/delete functionality  
- **Data Model**: `Item.swift` - SwiftData model representing timestamped items
- **Testing**: Uses Swift Testing framework (not XCTest)

## Key Technologies

- SwiftUI for UI framework
- SwiftData for persistent data storage
- Swift Testing framework for unit tests

## Development Commands

### Building and Running
- Open `apus.xcodeproj` in Xcode to build and run the application
- Use Xcode's built-in simulator or connected device for testing

### Testing
- Run tests through Xcode Test Navigator (⌘+6) or Product → Test (⌘+U)
- Unit tests are in `apusTests/apusTests.swift` using Swift Testing framework
- UI tests are in `apusUITests/` directory

## Project Structure

- `apus/` - Main application source code
- `apusTests/` - Unit test target using Swift Testing
- `apusUITests/` - UI test target
- `apus.xcodeproj/` - Xcode project configuration

## SwiftData Model Setup

The app uses an in-memory-false ModelContainer configured in the main app file with the Item schema. The model context is injected into the environment and accessed via `@Environment(\.modelContext)` in views.