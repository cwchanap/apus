# Dependency Injection System

## Overview
This dependency injection system provides a clean, testable way to manage dependencies throughout the apus app.

## Components

### 1. DIContainer
- **Purpose**: Core dependency injection container
- **Features**: 
  - Singleton and factory registration
  - Type-safe dependency resolution
  - Clear error messages for missing dependencies

### 2. Property Wrappers
- **@Injected**: For required dependencies (force unwraps)
- **@OptionalInjected**: For optional dependencies

### 3. ServiceLocator
- **Purpose**: Simplified access to common dependencies
- **Usage**: Alternative to property wrappers for easier access

### 4. AppDependencies
- **Purpose**: Centralized configuration of all app dependencies
- **Features**: 
  - Production dependency setup
  - Testing dependency configuration
  - Mock implementations for testing

## Usage Examples

### Basic Dependency Injection
```swift
class MyViewModel: ObservableObject {
    @Injected private var cameraManager: CameraManagerProtocol
    @OptionalInjected private var optionalService: SomeServiceProtocol?
}
```

### Service Locator Pattern
```swift
class MyClass {
    private let cameraManager = ServiceLocator.shared.cameraManager
}
```

### Testing Setup
```swift
func testSetup() {
    AppDependencies.shared.configureForTesting()
    // Now all dependencies are mocked
}
```

## Benefits

1. **Testability**: Easy to inject mock dependencies for testing
2. **Flexibility**: Change implementations without modifying client code
3. **Maintainability**: Centralized dependency configuration
4. **Type Safety**: Compile-time type checking for dependencies
5. **Performance**: Lazy loading and singleton support

## Best Practices

1. Always use protocols for dependency types
2. Register dependencies in AppDependencies
3. Use @Injected for required dependencies
4. Use @OptionalInjected for optional dependencies
5. Create mock implementations for testing
6. Keep the container configuration centralized