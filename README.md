# ShopSphere

A production-quality Flutter e-commerce application consuming the [DummyJSON](https://dummyjson.com) REST API, engineered for the **Prosessed Flutter Developer Intern Technical Assignment**.

---

## 1. Title, Overview & Links

**ShopSphere** is a lightweight, responsive e-commerce mobile application built with strict **Clean Architecture**, **Riverpod 3** state management, and an earthy, premium Material 3 design system. It delivers end-to-end user journeys including secure token-based authentication, paginated catalogue browsing with search and category filters, rich product detail previews with customer reviews, real-time reactive cart capacity and stock constraints, offline cart persistence, and simulated checkout.

* **Repository**: [https://github.com/Subhadeep-Dhar/prosessed-flutter-assignment](https://github.com/Subhadeep-Dhar/prosessed-flutter-assignment)
* **SDK Environment**: Flutter **3.44.1** (channel `stable`) • Dart SDK **3.12.1**
* **Target Platforms**: Android (minSdk 26+), iOS, Web, Desktop
* **Release APK**: [GitHub Releases](https://github.com/Subhadeep-Dhar/prosessed-flutter-assignment/releases) *(Generate locally via `flutter build apk --release`)*
* **Video Walkthrough**: *(Demo recording covering Auth, Catalogue, Details, Cart, Checkout, and Offline Error Scenarios)*

---

## 2. Screenshots & Screen Recordings

### Mobile Phone Layouts (< 600 dp)
| Splash & Authentication | Product Catalogue & Search | Product Details & Reviews | Cart & Simulated Checkout |
| :---: | :---: | :---: | :---: |
| ![Splash / Login](docs/screenshots/phone_auth.png) | ![Product Catalogue](docs/screenshots/phone_catalogue.png) | ![Product Details](docs/screenshots/phone_details.png) | ![Cart & Checkout](docs/screenshots/phone_cart.png) |

### Tablet & Landscape Layouts (>= 600 dp)
| Medium Screen (600–1024 dp) — NavigationRail & Grid | Expanded (> 1024 dp) — Master-Detail Split Layout |
| :---: | :---: |
| ![Tablet Medium](docs/screenshots/tablet_medium.png) | ![Tablet Master-Detail](docs/screenshots/tablet_expanded.png) |

---

## 3. Feature Checklist (Must-Have & Bonus) + Incomplete Items

### Must-Have Requirements Checklist
| Area | Requirement | Status | Evidence / Notes |
| :--- | :--- | :---: | :--- |
| **Auth** | Splash session restoration or rejection | PASS | `SplashPage`, `RestoreSessionUseCase`, `AuthNotifier` |
| **Auth** | Form validation (empty check, min lengths) | PASS | `LoginPage`, `ValidationFailure`, unit/widget tests |
| **Auth** | Password visibility toggle & loading indicator | PASS | `LoginPage`, `AppLoadingIndicator` |
| **Auth** | Secure token storage (Keychain / EncryptedSharedPreferences) | PASS | `AuthLocalDataSource` via `flutter_secure_storage` |
| **Auth** | `/auth/login`, `/auth/me`, `/auth/refresh` API integration | PASS | `AuthRemoteDataSource`, `AuthInterceptor` |
| **Auth** | User profile view (avatar, name, email, phone) | PASS | `ProfilePage` with pull-to-refresh session check |
| **Auth** | Logout clearing tokens & state | PASS | `LogoutUseCase`, `AuthNotifier.logout()` |
| **Auth** | HTTP 401 & 403 session expiration handling | PASS | `AuthInterceptor`, `AuthSessionExpired` state |
| **Catalogue** | Product cards (thumbnail, title, price, discount, rating) | PASS | `ProductCard`, WCAG-compliant semantics & badges |
| **Catalogue** | Pagination (`limit=20`, `skip=N`, loading indicator, no duplicates) | PASS | `ProductListNotifier.loadMore()`, pagination lock |
| **Catalogue** | Pull-to-refresh | PASS | `RefreshIndicator` in `HomePage` |
| **Catalogue** | API category filtering with "All" option | PASS | `CategoryChipsBar`, `GetProductsByCategoryUseCase` |
| **Catalogue** | Search endpoint with ~400ms debounce & stale-guard | PASS | `Debouncer(400ms)`, `_activeRequestId` sequence guard |
| **Catalogue** | 4 sort options (price asc/desc, rating, title/none) | PASS | `ProductSortBottomSheet`, `ProductSortOption` |
| **Catalogue** | Shimmer/skeleton loading UI on initial load | PASS | `ProductGridSkeleton` with staggered pulses |
| **Catalogue** | Distinct empty search state vs network error state | PASS | `AppEmptyView` vs `AppErrorView` with Retry |
| **Details** | Image carousel with indicator & thumbnail strip | PASS | `ProductImageGallery` with `PageView` |
| **Details** | Full metadata, stock, description & customer reviews | PASS | `ProductInfoSection`, `ProductSpecificationsCard`, `ProductReviewsList` |
| **Details** | Add-to-cart with quantity stepper & out-of-stock guard | PASS | `AddToCartSection`, real-time inventory clamping |
| **Details** | Recoverable "Product not found" state (e.g. `/product/9999`) | PASS | `ProductDetailStatus.notFound`, `AppEmptyView` with "Back to Catalogue" |
| **Details** | Reactive cart badge updates | PASS | `CartBadgeIconButton` driven by `cartItemCountProvider` |
| **Cart** | Add, remove, and quantity update operations | PASS | `AddToCartUseCase`, `UpdateCartItemQuantityUseCase`, `RemoveFromCartUseCase` |
| **Cart** | Subtotal, discount savings, and grand total calculations | PASS | `Cart` domain entity pure getters |
| **Cart** | Offline local persistence surviving restarts | PASS | `CartLocalDataSource` via `SharedPreferences` |
| **Cart** | Real-time badge counter synchronization | PASS | `cartItemCountProvider` across all screens |
| **Checkout**| Remote checkout via `POST /carts/add` | PASS | `CheckoutUseCase`, `CartRemoteDataSource` |
| **Checkout**| Cart cleared only on confirmed remote success | PASS | `CartRepositoryImpl.checkout()`, local cart preserved on error |
| **Checkout**| Honest simulation labeling ("Place Order (Simulated)") | PASS | `CartPage`, `CheckoutSuccessDialog` |
| **Network** | Centralized Dio client with timeouts and sanitized logging | PASS | `DioClientProvider`, `SanitizedLoggerInterceptor` |
| **Network** | Typed Domain Failures & Error Mapping | PASS | `Failure` hierarchy, `ErrorHandler.handle()` |
| **Layout**  | Compact (< 600 dp): 2-column grid, bottom `NavigationBar` | PASS | `HomePage`, `Breakpoints.fromWidth()` |
| **Layout**  | Medium (600–1024 dp): 3–4 column grid, `NavigationRail` | PASS | `HomePage`, adaptive `NavigationRail` |
| **Layout**  | Expanded (> 1024 dp): Master-detail split layout | PASS | `HomePage` with embedded `ProductDetailPage(isEmbedded: true)` |
| **A11y**    | 48dp min tap targets, 1.3x text scaling, contrast | PASS | `AppSpacing.minTapTarget`, verified 0 RenderFlex overflows |

### Bonus Features Status
* **[Bonus] Tablet / Desktop Adaptive Master-Detail**: Implemented via `HomePage` split pane (`flex: 5` master catalogue, `flex: 6` embedded detail view) for screens `> 1024 dp`.
* **[Bonus] Shimmer Loading UI**: Implemented via `ProductGridSkeleton` with animated gradient pulse.
* **[Bonus] Reactive Stock & Capacity Constraints**: Enforced 99-unit cart capacity limit with real-time UI disabling and explanatory inline banners.
* **[Bonus] Hero Animations**: Intentionally omitted to protect master-detail layout stability (co-presence of master catalogue cards and detail pane creates duplicate Hero tag collisions).

### Honest List of Incomplete / Demo Limitations
1. **Mock Remote Backend**: DummyJSON is a static mock API; orders submitted via `POST /carts/add` return a simulated response without server-side persistence.
2. **Simulated Payment**: No real credit card or banking flow is present; checkout is clearly marked as simulated.

---

## 4. Tech Stack & Key Packages

| Package | Version | Justification |
| :--- | :---: | :--- |
| **`flutter_riverpod`** | `^3.4.3` | Unified, compile-time safe state management and dependency injection without secondary service locators (`get_it`). |
| **`dio`** | `^5.9.2` | Powerful HTTP client providing connection/receive timeouts, interceptors for single-flight token refresh, and sanitized debug logging. |
| **`go_router`** | `^17.1.0` | Declarative, URL-driven routing engine supporting reactive authentication redirects and deep linking. |
| **`flutter_secure_storage`** | `^10.0.0` | Hardware-backed, encrypted key-value storage (Android KeyStore / iOS Keychain) for sensitive access/refresh tokens. |
| **`shared_preferences`** | `^2.5.4` | Lightweight, reliable asynchronous persistence for active cart state and offline recovery. |
| **`cached_network_image`** | `^3.4.1` | Asynchronous image loading with in-memory/disk caching, progress indicators, and fallback error widgets. |
| **`mocktail`** | `^1.0.4` | Pure Dart, null-safe mocking library for repository, data source, and use-case unit/widget tests. |

---

## 5. Architecture Diagram, Folder Structure & Data Flow

### Architecture Layers Diagram
```text
┌────────────────────────────────────────────────────────┐
│                   PRESENTATION LAYER                   │
│   Widgets • Pages • Riverpod Controllers • AppRouter  │
└───────────────────────────┬────────────────────────────┘
                            │ depends on (invokes)
┌───────────────────────────▼────────────────────────────┐
│                      DOMAIN LAYER                      │
│   Entities • Value Objects • Repository Interfaces     │
│       Use Cases (Interactors) • Result<T> Monad        │
│                (Pure Dart - Zero Flutter)              │
└───────────────────────────▲────────────────────────────┘
                            │ implements
┌───────────────────────────┴────────────────────────────┐
│                       DATA LAYER                       │
│    Data Sources (Remote/Local) • Data Models (DTOs)    │
│       Repository Implementations • Error Mappers       │
└────────────────────────────────────────────────────────┘
```

### Folder Structure
```text
lib/
├── core/
│   ├── di/               # Riverpod infrastructure providers
│   ├── error/            # Failures, Exceptions, ErrorHandler, Result monad
│   ├── network/          # Dio client, AuthInterceptor, sanitized logger
│   ├── theme/            # Material 3 colors, typography, spacing tokens
│   ├── utils/            # Breakpoints, Debouncer, currency formatters
│   └── widgets/          # Shared AppErrorView, AppEmptyView, AppLoadingIndicator
├── features/
│   ├── auth/             # Authentication & session verification
│   │   ├── data/         # AuthRemoteDataSource, AuthLocalDataSource, AuthRepositoryImpl
│   │   ├── domain/       # User, AuthTokens, AuthRepository, LoginUseCase, etc.
│   │   └── presentation/ # AuthNotifier, LoginPage, SplashPage
│   ├── products/         # Catalogue browsing, search, details
│   │   ├── data/         # ProductRemoteDataSource, ProductRepositoryImpl, Models
│   │   ├── domain/       # Product, Category, ProductRepository, UseCases
│   │   └── presentation/ # ProductListNotifier, ProductDetailNotifier, HomePage, ProductDetailPage
│   ├── cart/             # Cart persistence, capacity rules, checkout
│   │   ├── data/         # CartLocalDataSource, CartRemoteDataSource, CartRepositoryImpl
│   │   ├── domain/       # Cart, CartItem, CheckoutResult, CartRepository, UseCases
│   │   └── presentation/ # CartNotifier, CartPage, AddToCartSection, CartBadgeIconButton
│   └── profile/          # Profile view, pull-to-refresh session verification, logout
├── routing/              # GoRouter route declarations and auth redirect listenable
├── app.dart              # ShopSphereApp root consumer widget
└── main.dart             # Application bootstrap & asynchronous dependency overrides
```

### UI → API → UI Data Flow
```text
[User Action: Tap "Add to Cart"]
       │
       ▼
[Presentation: AddToCartSection / CartNotifier.addItem()]
       │
       ▼
[Domain: AddToCartUseCase] ──(Validates stock & cart capacity: 99 max)──► [Validation Failure?] ──► [Inline Warning]
       │
       ▼ (if valid)
[Data: CartRepositoryImpl]
       ├──► [CartLocalDataSource] ──(Persist to SharedPreferences)
       └──► Returns Result.success(cart)
       │
       ▼
[Presentation: CartNotifier updates CartState(cart: newCart)]
       ├──► UI re-renders updated quantity & price totals
       └──► cartItemCountProvider automatically invalidates ──► CartBadgeIconButton updates badge count!
```

---

## 6. State Management Strategy & Justification

ShopSphere utilizes **Riverpod 3** (`flutter_riverpod`) exclusively across the entire code base:

* **Why Riverpod**:
  1. **Compile-time Safety**: Eliminates runtime `ProviderNotFoundException` issues by relying on top-level provider declarations.
  2. **Unified State & DI**: Acts as both a reactive state manager and a declarative dependency injection container, removing the architectural overhead of combining BLoC with `get_it`.
  3. **Testability**: Riverpod enables straightforward overrides in unit and widget tests using `ProviderContainer` and `ProviderScope(overrides: [...])` without complex mocking harnesses.
* **Trade-offs**:
  * Riverpod requires wrapping widgets in `ConsumerWidget` or reading via `WidgetRef`, introducing a slight learning curve compared to standard inherited widgets. Code generation was avoided in favour of explicit class notifiers for complete transparency and rapid test execution.

---

## 7. Error Mapping & Recovery

`ErrorHandler` systematically translates all transport, protocol, and format exceptions into strongly typed domain failures:

| Failure Type | Source / Status | User-Facing Message | Recovery Mechanism |
| :--- | :--- | :--- | :--- |
| **`NetworkFailure`** | `SocketException` / Connection Error | *"No internet connection. Please check your network and retry."* | Inline `Retry` button, persistent top-level error banner for refresh/pagination |
| **`TimeoutFailure`** | Connection / Receive Timeout | *"The server took too long to respond. Please try again."* | `Retry` action re-triggers original request |
| **`UnauthorizedFailure`** | HTTP 401 / 403 / Refresh failure | *"Session expired or invalid credentials. Please sign in again."* | Single-flight refresh attempt; if failed, clears session & redirects to `/login` |
| **`NotFoundFailure`** | HTTP 404 (e.g. `/products/9999`) | *"The requested item was not found."* | Dedicated `Product Not Found` screen with *"Back to Catalogue"* navigation |
| **`ServerFailure`** | HTTP 500..599 | *"Server error (5xx). Please try again shortly."* | Non-destructive error state with `Retry` button |
| **`SerializationFailure`** | FormatException / schema mismatch | *"Failed to parse response from server."* | Safe fallback defaults prevent app crashing |
| **`ValidationFailure`** | Domain constraint violation | Contextual validation message (e.g. *"Cart is full."*) | UI disables submit action and displays inline banner |

---

## 8. Getting Started & APK Build

### Prerequisites
* Flutter SDK: `3.44.1` (channel `stable`)
* Dart SDK: `3.12.1`
* Android Studio / VS Code with Flutter extension
* Java 21 / OpenJDK

### Commands
```bash
# 1. Clone repository
git clone https://github.com/Subhadeep-Dhar/flutter_internship.git
cd flutter_internship

# 2. Install dependencies
flutter pub get

# 3. Format code (must exit 0)
dart format --set-exit-if-changed lib test

# 4. Analyze code (zero issues enforced)
flutter analyze

# 5. Run test suite
flutter test

# 6. Run test suite with coverage
flutter test --coverage

# 7. Run locally on connected device
flutter run

# 8. Build release APK
flutter build apk --release
```

---

## 9. Testing, Test Count & Coverage Summary

* **Test Command**: `flutter test`
* **Test Count**: **257 passing tests** (0 failures, 0 skipped, 0 errors).
* **Code Coverage**: **76.76% line coverage** (2,930 lines hit of 3,817 total instrumented lines in `coverage/lcov.info`).

### Test Suite Breakdown
| Feature Area | Test File | Test Count | Scope |
| :--- | :--- | :---: | :--- |
| **Core, Network & Theme** | `error_handler_test.dart`, `api_endpoints_test.dart`, `auth_interceptor_test.dart`, `auth_interceptor_advanced_test.dart`, `sanitized_logger_test.dart`, `app_theme_test.dart`, `breakpoints_test.dart`, `debouncer_test.dart` | 42 | Dio exceptions, HTTP status codes, socket/timeout mapping, JWT interceptor, theme tokens, responsive breakpoints, debounce timer |
| **Authentication & Profile** | `user_model_test.dart`, `auth_tokens_model_test.dart`, `auth_local_data_source_test.dart`, `auth_remote_data_source_test.dart`, `auth_repository_impl_test.dart`, `auth_usecases_test.dart`, `auth_notifier_test.dart`, `login_page_test.dart`, `profile_page_test.dart`, `logout_confirmation_dialog_test.dart` | 74 | JSON parsing, secure token persistence, single-flight refresh, form validation, profile mapping, logout confirmation dialog, widget states |
| **Products & Catalogue** | `product_model_test.dart`, `product_detail_model_test.dart`, `category_model_test.dart`, `product_page_response_model_test.dart`, `product_remote_data_source_test.dart`, `product_repository_impl_test.dart`, `product_usecases_test.dart`, `product_card_test.dart`, `product_list_notifier_test.dart`, `product_detail_notifier_test.dart`, `product_catalogue_widget_test.dart`, `product_detail_page_test.dart` | 132 | Filtering, search debouncing, pagination lock, 404 recovery, adaptive layouts, stock limits, cart capacity clamp, 1.3x text scaling, BoxFit.contain thumbnails |
| **Cart & Persistent Shell** | `cart_item_test.dart`, `cart_model_test.dart`, `cart_local_data_source_test.dart`, `cart_remote_data_source_test.dart`, `cart_repository_impl_test.dart`, `cart_usecases_test.dart`, `cart_notifier_test.dart`, `cart_page_test.dart`, `app_scaffold_shell_test.dart` | 67 | 99-item capacity, stock clamping, offline persistence, simulated checkout, widget steppers, persistent NavigationBar/NavigationRail shell |
| **App Smoke** | `widget_test.dart` | 1 | App launch and splash mount verification |
| **Total** | **All 39 suites** | **257** | **100% passing across unit, domain, repository, and widget tests** |

---

## 10. Verified Test Credentials (DummyJSON)

The application consumes DummyJSON's official mock authentication endpoints:
* **Username**: `emilys`
* **Password**: `emilyspass`

*(Note: Credentials are for manual test evaluation and are never hard-coded into production code).*

---

## 11. Assumptions, Trade-offs & Future Improvements

### Assumptions
1. **Mock Backend Behaviour**: DummyJSON does not maintain a mutable server database across client sessions. Order submission via `POST /carts/add` is acknowledged with a simulated order reference.
2. **Cart Capacity Limit**: Standardized to **99 total units** across the cart, aligning mobile UX constraints with practical inventory ceilings.

### Trade-offs
1. **Single State & DI Framework**: Avoided combining `get_it` or `Provider` with Riverpod. Riverpod handles both dependency injection and state management uniformly.
2. **Hero Animation Omission**: Omitted Hero transitions between catalogue cards and detail pages to prevent duplicate tag crashes during tablet landscape master-detail co-presence.

### Future Roadmap
1. **Real Payment Gateway**: Stripe / Razorpay SDK integration for real payment authorization.
2. **Biometric Authentication**: Local biometric authentication (Fingerprint / Face ID) via `local_auth`.
3. **Structured Local Database**: Upgrade cart and offline catalogue cache to a typed local database like Drift or Isar.

---

## 12. Author & Submission Details

* **Author**: Subhadeep Dhar
* **Email**: subhadeepdhar.dev@gmail.com
* **Repository**: [https://github.com/Subhadeep-Dhar/flutter_internship](https://github.com/Subhadeep-Dhar/flutter_internship)
* **Date**: 18 October 2026
* **Assignment Deadline**: 21 October 2026, 11:59 PM IST
* **Final Verdict**: **READY FOR SUBMISSION PREPARATION**
