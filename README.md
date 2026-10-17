# ShopSphere

A production-quality Flutter e-commerce catalogue application consuming the [DummyJSON](https://dummyjson.com) REST API, built for the **Prosessed Flutter Developer Intern Technical Assignment**.

---

## 1. Project Overview

**ShopSphere** is a lightweight, responsive e-commerce application designed with clean architecture, strict separation of concerns, and an intentional visual identity. It provides product discovery, category filtering, search, detailed product specifications, local cart persistence, simulated checkout, and session profile management.

* **Repository**: [Subhadeep-Dhar/flutter_internship](https://github.com/Subhadeep-Dhar/flutter_internship)
* **SDK Environment**: Flutter **3.44.1** (channel `stable`) • Dart SDK **3.12.1**
* **Target Platforms**: Android (minSdk 26+), iOS, Web, Desktop

---

## 2. Architecture & Design Principles

The application strictly follows **Feature-First Clean Architecture**:

```text
lib/
├── core/
│   ├── di/               # Riverpod infrastructure providers
│   ├── error/            # Pure Dart Failures, Exceptions, and ErrorHandler
│   ├── network/          # Dio client, sanitized logger, auth interceptor, endpoints
│   ├── theme/            # Centralized Material 3 ThemeData and design tokens
│   ├── utils/            # Responsive breakpoints, debouncer, formatting
│   └── widgets/          # Shared reusable UI: AppErrorView, AppEmptyView, AppLoadingIndicator
├── features/
│   ├── auth/             # Authentication & session verification
│   │   ├── data/         # Models, data sources, repository implementations
│   │   ├── domain/       # Pure Dart entities, repository contracts, use cases
│   │   └── presentation/ # Riverpod controllers, pages, widgets
│   ├── products/         # Catalog browsing, search, category filtering, product details
│   ├── cart/             # Local cart management, price calculations, checkout
│   └── profile/          # User profile view and session termination
├── routing/              # GoRouter route declarations and provider
├── app.dart              # ShopSphereApp root consumer widget
└── main.dart             # Application bootstrap & asynchronous dependency overrides
```

### Key Architectural Constraints
1. **Pure Dart Domain**: Domain entities, repository interfaces, and use cases do not import Flutter, Dio, or infrastructure libraries.
2. **Dependency Inversion**: Presentation widgets interact only with use cases or state notifiers; data layers implement domain interfaces.
3. **Single State & DI Framework**: Riverpod is used exclusively for both state management and dependency injection, eliminating the need for `get_it` or secondary service locators.

---

## 3. State Management & Justification

**Chosen Solution**: `flutter_riverpod` (v3.4.3)

* **Why Riverpod**:
  1. **Compile-time Safety**: Eliminates runtime `ProviderNotFoundException` issues by relying on top-level provider declarations.
  2. **Unified State & DI**: Acts as both a reactive state manager and a declarative dependency injection container, removing the architectural overhead of combining BLoC with `get_it`.
  3. **Testability**: Riverpod enables straightforward overrides in unit and widget tests using `ProviderContainer` and `ProviderScope(overrides: [...])` without complex mocking harnesses.
* **Trade-offs**:
  * Riverpod requires wrapping widgets in `ConsumerWidget` or reading via `WidgetRef`, introducing a slight learning curve compared to standard inherited widgets. Code generation can also add build latency, so plain provider declarations were selected for transparency and immediate testability.

---

## 4. Visual Identity & Design System

ShopSphere uses an earthy, premium design system configured with Material 3:
* **Backgrounds & Surfaces**: Warm Ivory (`#FAF7F2` background, `#FFFFFF` surfaces, `#F3EFEA` cards)
* **Primary Brand**: Forest Green (`#1E4633`) with subtle tonal containers
* **Secondary Accents**: Muted Sage (`#586B5D`)
* **Typography**: Near-Black (`#1A1D1A`) with distinct weights across Display, Headline, Title, and Body
* **Promotional Highlights**: Restrained Sale Orange (`#D45B28`)
* **Accessibility**: Minimum **48dp** interactive tap targets enforced across all button and input themes.
* **Responsive Breakpoints**:
  * **Compact** (`< 600 dp`): 2-column product grid, bottom navigation bar
  * **Medium** (`600–1024 dp`): 3–4 column product grid, navigation rail
  * **Expanded** (`> 1024 dp`): Master-detail split view

---

## 5. Network & Security Engineering

* **Base URL**: `https://dummyjson.com`
* **Timeouts**: 15 seconds connect, receive, and send timeouts.
* **Sanitized Debug Logging**: `SanitizedLoggerInterceptor` automatically strips passwords, access tokens, refresh tokens, and authorization headers from debug console output to prevent credential leakage.
* **Auth Extension Point**: `AuthInterceptor` injects `Bearer` tokens via an `AuthTokenProvider` contract, establishing a clean path for session injection and future token refresh.
* **Error Mapping**: `ErrorHandler` systematically translates low-level `DioException`, `SocketException`, and HTTP 4xx/5xx status codes into strongly typed domain `Failure` abstractions.

---

## 6. Getting Started

### Prerequisites
* Flutter SDK: `3.44.1` (channel `stable`)
* Dart SDK: `3.12.1`
* Android Studio / VS Code with Flutter extension
* Java 21 / OpenJDK (specified in Flutter toolchain)

### Setup & Run Commands

```bash
# 1. Clone repository
git clone https://github.com/Subhadeep-Dhar/flutter_internship.git
cd flutter_internship

# 2. Install dependencies
flutter pub get

# 3. Format code
dart format .

# 4. Analyze code (zero issues enforced)
flutter analyze

# 5. Execute test suite
flutter test

# 6. Launch application
flutter run
```

---

## 7. Test Suite Status

Foundational unit and widget tests covering error mapping, network logging, auth interceptors, endpoints, breakpoints, and debouncing:

```bash
flutter test
```
* Status: **30 / 30 tests passing**

---

## 8. Verified Test Credentials (DummyJSON)

* **Username**: `emilys`
* **Password**: `emilyspass`
