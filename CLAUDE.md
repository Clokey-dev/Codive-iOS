# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Git Commit Rules

When asked to commit, follow this procedure:

1. Check recent commit history to match the existing message format (e.g., `[#issue-number] description`)
2. Present the commit message(s) and included files to the user for review
3. Only create the commit after user approval

Commit message format:
- Write header only, or header + body. Nothing else.
- NEVER append `Co-Authored-By`, signatures, or any extra metadata

## Build & Project Setup

**Build system:** Tuist v4.65.4

### Common Commands

```bash
# Generate Xcode project from Tuist configuration
tuist generate

# Build the app (development)
xcodebuild -workspace Codive.xcworkspace -scheme Codive -configuration Debug

# Run tests
xcodebuild -workspace Codive.xcworkspace -scheme CodiveTests -configuration Debug test

# Lint code (runs automatically on build)
swiftlint

# Development environment setup (Fastlane)
fastlane setup_development

# App Store environment setup
fastlane setup_appstore
```

## Architecture Overview

This project follows **MVVM (Model-View-ViewModel)** pattern with **Clean Architecture** principles. The codebase is organized into feature-based modules with clear separation of concerns across three layers.

### Layer Structure

**Domain Layer** (Pure business logic, no external dependencies)
- **Entities:** Core data models
- **UseCases:** Business logic operations
- **Repository Interfaces:** Protocols that Data layer implements

**Data Layer** (Data access and networking)
- **Repositories (Implementation):** Implement Domain layer repository protocols
- **DataSources:** Remote (API via CodiveAPI) and Local (UserDefaults, CoreData) data sources
- **DTOs:** API response models that map to Domain entities

**Presentation Layer** (UI and state management)
- **Views (SwiftUI):** UI components and screens
- **ViewModels:** State management using `@Published` properties, orchestrate UseCases

### Project Structure

```
Codive/
├── Application/          # App entry point and global configuration
├── Core/                # Shared utilities and resources
├── Features/            # Feature modules (Auth, Home, Feed, Profile, etc.)
│   └── [Feature]/
│       ├── Domain/      # Business logic
│       ├── Data/        # Data access
│       └── Presentation/ # UI
├── Shared/              # Common components (DesignSystem, Extensions, Data utilities)
├── DIContainer/         # Dependency injection containers
└── Router/             # Navigation and routing
```

## Dependency Injection

The project uses a **DIContainer pattern** with centralized dependency management:

- **AppDIContainer** (`Codive/DIContainer/AppDIContainer.swift`): Root container that creates and manages all feature containers
- **FeatureDIContainers** (e.g., `AuthDIContainer.swift`): Individual containers for each feature that assemble their UseCases, Repositories, and ViewModels

Key pattern: Feature containers are initialized lazily by `AppDIContainer` and passed to Features. When implementing new features, create a corresponding `[Feature]DIContainer.swift` file following existing examples.

## Reactive Programming

- **Primary:** Swift Concurrency (async/await) for networking and asynchronous operations
- **Secondary:** Combine framework for View bindings and state management
- ViewModels use `@Published` properties for SwiftUI state binding
- API calls use async/await (see HomeDatasource.swift for examples)

## Key Dependencies

- **CodiveAPI:** Swift OpenAPI generated client for backend communication
- **Moya:** Networking layer foundation (used by CodiveAPI)
- **Kingfisher:** Image caching and loading
- **KakaoSDK:** Kakao authentication integration

## Code Style & Quality

**SwiftLint configuration** (`/.swiftlint.yml`):
- Lint is run as a pre-build script automatically
- Key rules:
  - No force casting (`as!`) or force try (`try!`)
  - Use `.isEmpty` instead of `.count == 0`
  - Trailing closures required for SwiftUI style
  - Type body length: warning at 300 lines, error at 400 lines
  - File length: warning at 400 lines, error at 600 lines
  - Cyclomatic complexity: warning at 15, error at 25
  - Type nesting max 2 levels, function nesting max 3 levels

Run `swiftlint` manually to check code before committing.

## Testing

- **Framework:** XCTest
- **Location:** `CodiveTests/Features/`
- **Run tests:** `xcodebuild -workspace Codive.xcworkspace -scheme CodiveTests test`
- Tests should follow the same feature structure as main app (Domain, Data, Presentation)

## Build Configuration

- **Deployment Target:** iOS 16.0+
- **Swift Version:** 6.0+
- **Configurations:** Debug (with Dev app variant) and Release
- **Development Team:** BBVZV8T99P
- **Code Signing:** Manual (uses match)

Debug build:
- App name: "Codive (Dev)"
- Bundle ID: `com.codive.app`
- Provisioning: `match Development com.codive.app`

Release build:
- App name: "Codive"
- Provisioning: `match AppStore com.codive.app`

## Environment & Secrets

- **Base URL:** Set via `BASE_URL` in xcconfig files (`Codive/Resources/Secrets/Debug.xcconfig` and `Release.xcconfig`)
- **Kakao SDK:** `KAKAO_APP_KEY` and `KAKAO_AUTH_URL` configured in Info.plist
- **Custom URL schemes:** `kakao[APP_KEY]` and `codive://`

## Networking

API communication uses `CodiveAPI` package (Swift OpenAPI generated):
- Remote data sources (e.g., `HomeDatasource.swift`) call API services
- Responses are converted from DTOs to Domain entities
- Use async/await for API calls
- Error handling should follow repository pattern (catch in repositories, surface as Result or throw)

## Navigation

- **Router Pattern:** `AppRouter` and feature-specific `NavigationRouter`s manage navigation stack
- **ViewFactory:** Creates Views with injected dependencies
- Views request navigation through Router without creating child ViewModels directly
- Routes are typically handled in ViewModel, which calls Router methods

## Git Workflow

Current branch: `feat/#57`
Main branch for PRs: `develop`

Follow feature branch naming: `feat/#[issue-number]`

## Common Development Tasks

**Adding a new feature:**
1. Create feature directory in `Codive/Features/[FeatureName]/` with Domain/Data/Presentation subdirectories
2. Implement Domain layer (Entities, UseCases, Repository Interfaces)
3. Implement Data layer (Repositories, DataSources, DTOs)
4. Implement Presentation layer (ViewModels, Views)
5. Create `[FeatureName]DIContainer.swift` in `Codive/DIContainer/`
6. Register the container in `AppDIContainer`
7. Add routing in `AppRouter` if needed

**Modifying API interaction:**
- Update DTOs in appropriate Data layer (in feature)
- Ensure domain entity mapping in repository implementation
- Add corresponding API call method in repository if needed

**Adding shared UI components:**
- Place in `Codive/Shared/DesignSystem/` following existing structure (Buttons, Sheets, Navigation, Alerts, UIHelpers, etc.)
- Use custom style modifiers (e.g., `.customCornerRadius()`, `.customShadow()`)
- Design system colors are in `Codive/Resources/Colors.xcassets`

**Updating build configuration:**
- Modify `Project.swift` for Tuist configuration
- Rebuild with `tuist generate` after changes
- Info.plist entries defined in Project.swift `infoPlist` section
