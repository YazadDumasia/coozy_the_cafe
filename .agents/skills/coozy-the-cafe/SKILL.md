---
name: coozy-the-cafe
description: Guidelines, Clean Architecture standards, Drift database patterns, GetIt dependency injection, BLoC state management, and developer workflows for the Coozy The Cafe Flutter project.
---

# Coozy The Cafe - Agent Skill Guide

This skill provides architectural rules, coding standards, modular package patterns, and workflow guidelines for working on **Coozy The Cafe**, a modular Flutter cafe management application.

---

## 1. Project Architecture & Modular Layout

`coozy_the_cafe` follows a **Modular Clean Architecture** pattern. The root application logic is split into self-contained feature packages inside `lib/packages/`.

```
lib/
├── main.dart                  # Application entry point & theme/router initialization
├── injection.dart             # Central Dependency Injection coordinator
└── packages/                  # Feature & Core Modules
    ├── core/                  # Shared utilities, failure types, base classes, DI instance (sl)
    ├── database/              # Drift ORM tables, DAOs, helpers, & web sync scripts
    ├── shared/                # Common UI widgets, design system components, shared themes
    ├── auth/                  # Authentication module
    ├── checkout/              # Order checkout & billing processing
    ├── customer/              # Customer management module
    ├── expenditure/           # Expense tracking & financial logs
    ├── home_page/             # Dashboard and home navigation
    ├── inventory/             # Inventory and stock management
    ├── invoice_management/    # Invoices & billing receipts
    ├── kitchen_management/    # Kitchen display system (KDS) & order queue
    ├── menu_category/         # Menu category features
    ├── menu_subcategory/      # Menu subcategory features
    ├── menu_item/             # Menu item catalog
    ├── order_management/      # Order lifecycle & history
    ├── purchase/              # Purchase orders and supplier logs
    ├── recipes/               # Recipe management
    ├── reports/               # Sales trends, analytics & stock adjustment reports
    ├── reservation/           # Table reservation management
    ├── settings/              # Application settings & configurations
    ├── staff_management/      # Staff roles and scheduling
    ├── table_management/      # Dining table layout and status tracking
    └── waiter_order_placement/# POS / Waiter order taking flow
```

---

## 2. Feature Package Structure

Each feature package inside `lib/packages/<feature_name>/` must strictly separate concerns into three layers:

```
lib/packages/<feature_name>/
├── data/
│   ├── datasources/           # Local (Drift DAOs) & Remote data sources
│   ├── models/                # Data Transfer Objects (DTOs) with JSON/Drift mapping
│   └── repositories/          # Implementations of domain repository contracts
├── domain/
│   ├── entities/              # Pure Dart business objects
│   ├── repositories/          # Abstract repository interfaces
│   └── usecases/              # Single-responsibility business use cases
├── presentation/
│   ├── bloc/                  # Feature-wide BLoC / Cubit state management
│   ├── pages/                 # Screen folders (broken down per screen for easy navigation)
│   │   └── <screen_name>/     # Dedicated folder per screen
│   │       ├── <screen_name>.dart         # Main Screen UI widget
│   │       ├── <screen_name>_actions.dart # Screen actions / logic mixin
│   │       ├── cubit/                     # Page-specific Cubit (if needed)
│   │       └── widget/                    # Sub-widgets specific to this screen
│   ├── widgets/               # Feature-wide common widgets (broken down per widget)
│   │   └── <widget_name>/     # Dedicated folder per feature-wide common widget
│   │       ├── <widget_name>.dart         # Main widget implementation
│   │       └── widget/                    # Sub-components specific to this widget (if any)
│   └── navigation/            # Feature route definitions and arguments
├── <feature_name>.dart        # Barrel file exporting public surfaces
└── <feature_name>_injection.dart # Dependency injection registration function
```

### Layer & Widget Placement Rules:
- **Domain Layer**: Must be pure Dart code (no Flutter or UI dependencies). Uses `dartz` (`Either<Failure, T>`) for functional error handling.
- **Data Layer**: Implements domain contracts. Handles Drift database calls, JSON serialization, and data mapping to domain entities.
- **Presentation Layer**: Consumes Use Cases via BLoCs/Cubits. Renders Flutter UI and reacts to state changes.
  - **Screen-Specific Widgets**: Sub-widgets used ONLY by a single screen must be placed inside `presentation/pages/<screen_name>/widget/`.
  - **Feature-Common Widgets**: Widgets shared across multiple screens in the SAME feature must be placed inside `presentation/widgets/<widget_name>/`.
  - **App-Wide Common Widgets**: Widgets shared across MULTIPLE features across the entire app must be placed inside `lib/packages/shared/widgets/<widget_name>/`.




---

## 3. Dependency Injection (GetIt)

The project uses `get_it` for service location via the global instance `sl` defined in `package:coozy_the_cafe/packages/core/coozy_core.dart`.

### Modular Registration Pattern:
Each package defines a `register<Package>Dependencies(GetIt sl)` function in `<feature_name>_injection.dart`:

```dart
// Example: reservation_injection.dart
import 'package:get_it/get_it.dart';

void registerReservationDependencies(GetIt sl) {
  // BLoCs (Factory)
  sl.registerFactory(() => ReservationBloc(getReservations: sl(), createReservation: sl()));

  // Use Cases (Lazy Singleton)
  sl.registerLazySingleton(() => GetReservations(sl()));
  sl.registerLazySingleton(() => CreateReservation(sl()));

  // Repositories (Lazy Singleton)
  sl.registerLazySingleton<ReservationRepository>(
    () => ReservationRepositoryImpl(localDataSource: sl()),
  );

  // Data Sources / DAOs (Lazy Singleton)
  sl.registerLazySingleton(() => ReservationDao(sl()));
}
```

All package registrations are called inside `lib/injection.dart` during app initialization.

---

## 4. Database & Drift ORM Standards

- **Database Framework**: `drift` / `drift_flutter` with SQLite.
- **Location**: Database schemas and DAOs live under `lib/packages/database/`.
- **Code Generation**: Run `dart run build_runner build --delete-conflicting-outputs` whenever modifying Drift tables (`.drift` files or `@DataClassName` annotations).
- **Web Sync**: Web storage compatibility is managed via `scripts/sync_drift_web.dart`.

---

## 5. Coding & State Management Standards

1. **State Management (No `setState`)**:
   - **Do NOT use `setState`** for state management.
   - Use `flutter_bloc` (`Bloc` or `Cubit`) with `Equatable` for business logic & screen state management.
   - **BLoC & Cubit Structure**: Do NOT import event or state files into BLoC/Cubit. Use `part '<name>_event.dart';` / `part '<name>_state.dart';` in main file, `part of '<name>_bloc.dart';` in event/state files, and `sealed class` instead of `abstract class` for base event/state classes.
   - Use `ValueNotifier` / `ValueListenableBuilder` for transient, lightweight widget UI state.
2. **Error Handling**:
   - Repository methods return `Future<Either<Failure, T>>` or `Stream<Either<Failure, T>>`.
   - Use pre-defined `Failure` classes in `lib/packages/core/`.
3. **Immutability**:
   - Entities and States should be immutable with `copyWith` helpers.
4. **Navigation**:
   - Deep-linking and declarative routing handled via `go_router`.

5. **Localization (i18n)**:
   - Managed via `LocaleCubit` in `package:coozy_the_cafe/packages/shared/coozy_shared.dart`.
   - Translation strings are stored in `assets/locale/locale_<lang>.json` (e.g., `locale_en.json`). Keys are grouped into top-level feature section JSON objects (`table_page`, `customer_page`, `reservation_page`, `order_page`, `menu_item_page`, `recipes`, `staff_management_page`, `settings_page`, `login_page`, `resgister_page`, `inventory_page`, `purchase_page`, `common`, `utils`, etc.) and sorted alphabetically within each object.
   - Parameter placeholders in translation strings must use `${paramName}` syntax (e.g. `${count}`, `${name}`).
   - Use `context.tr(...)` with `shared.LocaleKeys` and matching `shared.TrackConstants`:
     ```dart
     context.tr(
       shared.LocaleKeys.loginViaFacebookTooltip,
       track: shared.TrackConstants.loginPageTrack,
     ) ?? 'Login Via Facebook'
     ```
6. **Performance & Large Dataset Optimization**:
   - **Pagination & Querying**: Implement pagination (`LIMIT`/`OFFSET`) in Drift DAOs for large tables (menu items, transactions, orders).
   - **Lazy Rendering**: Use `ListView.builder` / `GridView.builder` with `addAutomaticKeepAlives: false` and `addRepaintBoundaries: true` to prevent unnecessary repaints and reduce RAM usage.
   - **Isolate Offloading**: Offload heavy data processing, parsing, or filtering to background isolates (`compute`) to keep the main UI thread at 60/120 FPS.
   - **Date & Time Formatting**: For all date and time operations, use `DateUtil` from core (`package:coozy_the_cafe/packages/core/coozy_core.dart`).
   - **Common Shared Screens**: Use `shared.LoadingPage()`, `shared.ErrorPage(...)`, and `shared.NoInternetPage()` exported from `package:coozy_the_cafe/packages/shared/coozy_shared.dart` for consistent loading, error handling, and offline state rendering across the app.




7. **Testing & Quality Assurance**:
   - **Unit Tests Only for Business Logic (No Widget / Full-Fledged Testing)**: Do NOT implement any kind of widget testing or full-fledged integration testing. Only unit test cases for business logic (Domain Use Cases, Repositories, BLoCs/Cubits) are permitted.
   - **Ask User questions After Feature Implementation**: Do NOT write unit tests automatically while building features or UI. At the end of completing the code and UI implementation, ask the user question: *"Do you want to implement unit test cases for the business logic?"* to allow implementation. Based on the user's interaction/response, only proceed with implementing unit test cases if the user allows and confirms it. If declined or not requested, do NOT implement test cases.
   - When confirmed by the user, write unit tests for business logic (Domain Use Cases, Repositories, and BLoCs) using `package:flutter_test` / `package:test`.
   - Generate test mocks with `mockito` via `dart run build_runner build`.
   - Validate performance under stress testing with large mock dataset fixtures when unit tests are implemented.
8. **Theme & Dual-Mode UI Principles (Light & Dark Theme)**:
   - **Pre-Design Consideration**: Before implementing any layout or widget design, evaluate how colors, contrasts, borders, and shadows appear in **both Light Mode and Dark Mode**.
   - **Dynamic Theme References**: Never hardcode static color literals (`Colors.white`, `Colors.black`, `#FFFFFF`). Always reference `Theme.of(context).colorScheme` or `Theme.of(context).textTheme`.
   - **Theme Extensions**: Utilize `AppThemeExtension` via `Theme.of(context).extension<shared.AppThemeExtension>()` for custom radii, elevation, or brand colors.
9. **Form & Input Controller Lifecycle Management**:
   - **Explicit Controllers & FocusNodes**: For every form field (`TextFormField`, text input control), explicitly create its corresponding `TextEditingController` and `FocusNode`.
   - **Proper Initialization**: Explicitly initialize all `TextEditingController`s, `FocusNode`s, initial field values, and listeners in `initState()` (or upon declaration) to avoid `LateInitializationError` or null pointer crashes.
   - **Validation & FormKey**: Manage form state using a dedicated `GlobalKey<FormState>`.
   - **Mandatory Lifecycle Disposal**: Always call `.dispose()` on all `TextEditingController`s and `FocusNode`s in the widget's `dispose()` method to prevent memory leaks.
   - **Focus Navigation**: Properly configure focus nodes to support keyboard action traversal (e.g. Next, Done, Tab navigation).




---

## 6. Common Developer Workflows

### Running Static Analysis & Code Quality Checks
```bash
flutter analyze
```

### Running Build Runner for Code Generation (Drift, Mocks, etc.)
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Running Unit Tests (When Implemented)
```bash
flutter test
```


### Adding a New Feature Step-by-Step
1. Create directory `lib/packages/<new_feature>/` with `data/`, `domain/`, and `presentation/` subdirectories.
2. Define Entities and Repository interface in `domain/`.
3. Implement Repository & Data Source (Drift DAO/Table) in `data/`.
4. Create Use Cases in `domain/usecases/`.
5. Create BLoC/Cubit events, states, and logic in `presentation/bloc/`.
6. Implement Pages & Widgets in `presentation/pages/` and `presentation/widgets/`.
7. Create `<new_feature>_injection.dart` and invoke `register<NewFeature>Dependencies(sl)` in `lib/injection.dart`.
8. Create barrel file `<new_feature>.dart` exporting necessary public APIs.
9. At the end of completing the feature code and UI, ask the user: *"Do you want to implement unit test cases for the business logic?"*. Based on the user's response, only implement unit tests if the user allows and confirms it.
