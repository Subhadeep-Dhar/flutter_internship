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
* **Auth Extension Point**: `AuthInterceptor` injects `Bearer` tokens via an `AuthTokenProvider` contract, establishing a clean path for session injection and automatic token refresh.
* **Single-Flight Token Refresh**:
  * Concurrent 401 responses share a single synchronized in-flight refresh request (`_performSingleFlightRefresh`).
  * Avoids duplicate refresh calls when multiple requests fail with 401 simultaneously.
  * Retries the original request at most once (`x-shopsphere-retry` header guard).
  * Clears session and triggers `onAuthenticationExpired` on unrecoverable 401/403 refresh failure.
  * Excludes public authentication endpoints (`/auth/login`, `/auth/refresh`) to prevent recursion loops.
* **Error Mapping**: `ErrorHandler` systematically translates low-level `DioException`, `SocketException`, and HTTP 4xx/5xx status codes into strongly typed domain `Failure` abstractions.

---

## 6. Authentication Architecture (Phase 2)

ShopSphere implements an end-to-end, testable, and secure authentication flow:

### 1. Domain Layer (`lib/features/auth/domain/`)
* **Entities**:
  * `User`: Strongly typed, null-safe entity representing the authenticated customer profile (`id`, `username`, `email`, `firstName`, `lastName`, `gender`, `image`, `phone`).
  * `AuthTokens`: Immutable access and refresh token container.
* **Repository Interface**: `AuthRepository` pure Dart contract defining `login()`, `getCurrentUser()`, `restoreSession()`, `logout()`, `refreshTokens()`, and `hasStoredTokens()`.
* **Use Cases**: Single-responsibility domain operations:
  * `LoginUseCase`
  * `RestoreSessionUseCase`
  * `GetCurrentUserUseCase`
  * `LogoutUseCase`
* **Result Monad**: Sealed `Result<T>` (`Success<T>`, `Error<T>`) returning explicit typed failures rather than throwing or swallowing errors.

### 2. Data Layer (`lib/features/auth/data/`)
* **Data Sources**:
  * `AuthRemoteDataSource`: Consumes DummyJSON endpoints (`POST /auth/login`, `GET /auth/me`, `POST /auth/refresh`).
  * `AuthLocalDataSource`: Backed by `flutter_secure_storage` for hardware-backed token encryption. **Passwords are never persisted.**
* **Models**: `UserModel` and `AuthTokensModel` with defensive, null-safe JSON parsing handling optional API properties safely.
* **Repository Implementation**: `AuthRepositoryImpl` maps DummyJSON HTTP 400 responses to a clean, user-facing failure (`"Invalid username or password."`) and clears stored tokens when sessions expire.

### 3. State Management & Navigation
* **Riverpod 3 Controller**: `AuthNotifier` exposes explicit `AuthState` transitions:
  * `AuthInitial`: App initialization.
  * `AuthLoading`: Network operation in flight.
  * `AuthAuthenticated(user)`: Verified customer session.
  * `AuthUnauthenticated([message])`: Logged out or login failed with friendly inline error.
  * `AuthSessionExpired`: Session invalidated; prompts user to log in again.
  * `AuthSessionCheckFailed(message)`: Startup network failure; provides retry button without falsely invalidating stored tokens.
* **GoRouter Integration**: `_AuthRouterListenable` notifies `GoRouter` upon state changes. Top-level route redirects guard `/login`, `/splash`, `/home`, and `/profile` to ensure users cannot navigate to unauthorized screens.
* **Session Restoration**: On app launch, `SplashPage` verifies the active session against `GET /auth/me`. If connectivity fails, it presents an honest retry screen rather than blindly trusting token presence.

---

## 7. Product Catalogue Architecture (Phase 3)

ShopSphere implements a performant, responsive product catalogue with client-side debouncing, server-side and client-side sorting, category filtering, and safe infinite scroll pagination:

### 1. Domain Layer (`lib/features/products/domain/`)
* **Entities**:
  * `Product`: Strongly typed, null-safe domain entity (`id`, `title`, `description`, `category`, `price`, `discountPercentage`, `rating`, `stock`, `tags`, `brand`, `thumbnail`, `images`, `availabilityStatus`) with computed getters for `effectivePrice`, `stockStatusLabel`, `isInStock`, and `isLowStock`.
  * `Category`: Category entity (`slug`, `name`, `url`) with a static synthetic `Category.all` chip.
  * `PaginatedProducts`: Container holding a slice of products, `total`, `skip`, `limit`, and `hasMore` boundary helper.
  * `ProductSortOption`: Enum for sorting criteria: `none` (Featured), `priceAsc` (Price: Low to High), `priceDesc` (Price: High to Low), and `ratingDesc` (Highest Rated).
* **Repository Interface**: `ProductRepository` pure Dart contract.
* **Use Cases**:
  * `GetProductsUseCase`: Paginated list of products with optional sorting.
  * `GetCategoriesUseCase`: Available catalogue categories.
  * `SearchProductsUseCase`: Debounced query search with pagination and sorting.
  * `GetProductsByCategoryUseCase`: Filtered products by category slug with pagination and sorting.
  * `GetProductByIdUseCase`: Single product detail lookup.

### 2. Data Layer (`lib/features/products/data/`)
* **Remote Data Source**: `ProductRemoteDataSource` consuming:
  * `GET /products?limit=20&skip=0&sortBy={sortBy}&order={order}`
  * `GET /products/search?q={query}&limit=20&skip=0&sortBy={sortBy}&order={order}`
  * `GET /products/category/{category}?limit=20&skip=0&sortBy={sortBy}&order={order}`
  * `GET /products/categories` (parsing both object and raw string list payloads defensively)
  * `GET /products/{id}`
* **Models**: `ProductModel`, `CategoryModel`, and `ProductPageResponseModel` with defensive null-safety and fallback handling.
* **Repository Implementation**: `ProductRepositoryImpl` translating network/dio exceptions through `ErrorHandler` to typed `Failure` results.

### 3. State Management & Concurrency Protection
* **Riverpod 3 Controller**: `ProductListNotifier` manages `ProductListState`:
  * **Debounced Search**: Integrates `Debouncer(delay: 400ms)` so user typing never fires duplicate or excessive API requests.
  * **Stale-Query Protection**: Monotonic sequence token (`_activeRequestId`) invalidates responses from slower out-of-order search requests.
  * **Safe Infinite Pagination**: Concurrency lock prevents duplicate pagination requests while `isLoadingMore` is active or when reaching the end of the catalogue (`hasMore == false`).
  * **Non-Destructive Pagination Errors**: Network failures during pagination preserve all already loaded products and display a retryable footer banner rather than wiping the screen.
  * **Filter Reset**: Selecting a new category or submitting a new search resets pagination offset (`skip = 0`) cleanly.

### 4. Presentation & Responsive UI
* **Responsive Layout**: Computes grid columns dynamically using `Breakpoints.gridColumnCount(width)` (2 columns on mobile, 3–4 columns on tablets/landscape, 5 on wide screens).
* **Shimmer Skeleton**: `ProductGridSkeleton` displays an animated pulsing placeholder matching card geometry during initial data loads.
* **Product Card**:
  * Product thumbnail with `CachedNetworkImage` and placeholder/fallback widgets.
  * Bold orange discount percentage badge (e.g. `-20%`).
  * Stock status tag (In stock, Only N left, or Out of stock).
  * 2-line title with ellipsis, category badge, star rating, effective price, and struck-through original price.
* **Category Chips**: Horizontal scrollable list with an "All" chip and animated selection states.
* **Search & Sort Bar**: Search input with clear button, keyboard submission, and a sort bottom sheet (`ProductSortBottomSheet`).
* **Empty & Error States**: Contextual `AppEmptyView` with reset button and `AppErrorView` with retry action.
* **Accessibility**: Minimum **48dp** interactive touch targets enforced across all chips, buttons, and inputs.

---

## 8. Product Details Architecture (Phase 4)

ShopSphere implements a complete, responsive product details experience consuming DummyJSON's single product endpoint (`GET /products/{id}`) and displaying rich product metadata, an interactive image gallery, specifications, and customer reviews:

### 1. Domain Layer (`lib/features/products/domain/`)
* **Entities**:
  * `Product`: Extended to support full detail fields defensively: `sku`, `weight`, `dimensions` (`ProductDimensions`), `warrantyInformation`, `shippingInformation`, `returnPolicy`, `minimumOrderQuantity`, `meta` (`ProductMeta`), and `reviews` (`List<Review>`).
  * `Review`: Pure Dart entity encapsulating `rating`, `comment`, `reviewerName`, `reviewerEmail`, and `date` with defensive ISO 8601 date parsing (`parsedDate`) and formatted display strings (`formattedDate`).
  * `ProductDimensions`: Pure Dart entity for `width`, `height`, and `depth` with computed `formatted` string (e.g. `10.0 × 15.0 × 5.0 cm`).
  * `ProductMeta`: Pure Dart entity for barcode, QR code, and creation/update timestamps.
* **Use Cases**:
  * `GetProductByIdUseCase`: Retrieves single product details via `ProductRepository.getProductById(id)` with typed `Result<Product>` error handling.

### 2. Data Layer (`lib/features/products/data/`)
* **Models**:
  * `ProductModel`: Defensive parsing of optional fields; missing or malformed fields safely fallback without throwing runtime exceptions.
  * `ReviewModel`, `ProductDimensionsModel`, `ProductMetaModel`: Serialization and deserialization with null safety and trimming.
* **Remote Data Source**:
  * `ProductRemoteDataSource.getProductById(id)` consumes `GET /products/{id}` using the centralized Dio client.
* **Repository Implementation**:
  * `ProductRepositoryImpl.getProductById(id)` validates product ID (`id > 0`) and maps Dio/network exceptions through `ErrorHandler` to typed `Failure` results.

### 3. State Management & Lifecycle
* **Riverpod 3 Controller**:
  * `ProductDetailNotifier`: Managed via `NotifierProvider.autoDispose.family<ProductDetailNotifier, ProductDetailState, int>`.
  * **State**: `ProductDetailState` encapsulating explicit statuses: `initial`, `loading`, `loaded`, `error`, and `invalidId`.
  * **Stale Response Protection**: Request sequence counter (`_activeRequestId`) prevents out-of-order asynchronous responses from overwriting newer routes or state.
  * **Disposal & Lifecycle**: `ref.mounted` guards ensure that state updates never run against disposed providers.
  * **Retry Recovery**: `retry()` method allows instantaneous reload on network errors.

### 4. Responsive UI & Visual Presentation
* **Navigation & Routing**:
  * `GoRouter` route `/product/:id` protected by top-level authentication guard.
  * Product card tapping in `HomePage` pushes `/product/${product.id}`.
  * Standard Material 3 AppBar with accessible Back navigation action (`context.pop()` or fallback `/home`).
  * Invalid product IDs (non-numeric, `<= 0`) display a dedicated `AppEmptyView` with return-to-catalogue action.
* **Responsive Layout**:
  * **Compact / Mobile** (`< 600 dp`): Vertical flow with sticky AppBar, swipeable image gallery, summary details, specifications card, and reviews list.
  * **Medium / Tablet / Desktop** (`>= 600 dp`): Intelligent two-column layout with fixed-ratio image gallery on the left and scrollable product details, specifications, and reviews on the right.
* **Interactive Image Gallery (`ProductImageGallery`)**:
  * Swipeable `PageView` with smooth animated indicator dots.
  * Thumbnail carousel for rapid image switching.
  * High-resolution image caching with `CachedNetworkImage` and polished fallback on network/asset failure.
  * Accessible semantic labels indicating current image index (`image X of Y`).
* **Product Summary (`ProductInfoSection`)**:
  * Category badge, brand name, and full product title.
  * Star rating with total review count.
  * Accurate price formatting showing discounted price, struck-through original price, and bold discount pill (`-X%`).
  * Dynamic stock badge ("In Stock", "Only N left", "Out of Stock") using verified API values without fabrication.
* **Specifications Card (`ProductSpecificationsCard`)**:
  * Renders SKU, dimensions, weight, warranty, shipping terms, return policy, minimum order quantity, and barcode.
  * Defensive omission: empty or missing fields are completely omitted rather than displaying blank labels.
* **Customer Reviews (`ProductReviewsList`)**:
  * Renders authentic customer ratings, reviewer names, review dates, and comments.
  * Gracefully handles empty reviews with an informative notice.

---

## 9. Getting Started

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

## 10. Test Suite Status

Comprehensive unit and widget tests covering domain entities, data models, local/remote data sources, repository implementations, use cases, auth notifier, product list notifier, product detail notifier, image gallery, reviews, responsive detail layouts, search debouncing, concurrency protection, and widget interactions:

```bash
flutter test
```
* Status: **155 / 155 tests passing**
* Static Analysis: **0 issues found** across all files.

---

## 11. Verified Test Credentials (DummyJSON)

The following credentials are provided by DummyJSON for manual testing:
* **Username**: `emilys`
* **Password**: `emilyspass`

*(Note: These credentials are strictly for manual verification and are never hard-coded into application logic).*

