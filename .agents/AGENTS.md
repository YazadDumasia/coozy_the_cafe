# Project Rules for Coozy The Cafe

## 1. Modular Clean Architecture
- Place feature code inside `lib/packages/<feature_name>/` adhering to `data/`, `domain/`, and `presentation/` separation.
- `domain/` must remain pure Dart without UI dependencies. Handle async return values with `Either<Failure, T>`.
- `presentation/`: Organize pages into dedicated screen folders under `presentation/pages/<screen_name>/` containing `<screen_name>.dart`, `<screen_name>_actions.dart`, and a nested `widget/` folder for screen-specific sub-widgets. Shared feature widgets go in dedicated folders under `presentation/widgets/<widget_name>/`.
- **Common Widgets**: Screen-specific widgets live in `presentation/pages/<screen_name>/widget/`. Feature-wide common widgets live in `presentation/widgets/<widget_name>/`. App-wide common widgets shared across features live in `lib/packages/shared/widgets/<widget_name>/`.
- Register all new dependencies in `<feature_name>_injection.dart` and call registration in `lib/injection.dart`.

## 2. Code Generation & Database
- Database models and DAOs live under `lib/packages/database/`.
- When updating Drift tables or mock annotations, run code generation using `dart run build_runner build`.

## 3. State Management & Navigation
- **Avoid `setState`**: Do NOT use `setState` for state management in UI widgets. Use `flutter_bloc` (`Bloc` or `Cubit`) with `Equatable` for feature state, or `ValueNotifier` / `ValueListenableBuilder` for lightweight UI-only state.
- **BLoC & Cubit Structure**: Every BLoC or Cubit must not import its event or state files via `import`. Instead, use `part '<name>_event.dart';` and/or `part '<name>_state.dart';` in the main file and `part of '<name>_bloc.dart';` (or `_cubit.dart`) in the event/state files. Use `sealed class` instead of `abstract class` for main/base event and state classes.
- App routes are managed using `go_router` in `package:coozy_the_cafe/packages/core/coozy_core.dart`.

## 4. Localization (i18n)
- String translations are maintained in JSON files under `assets/locale/` (e.g. `locale_en.json`).
- Keys inside `locale_en.json` must be grouped into top-level feature section JSON objects (`table_page`, `customer_page`, `reservation_page`, `order_page`, `menu_item_page`, `recipes`, `staff_management_page`, `settings_page`, `login_page`, `resgister_page`, `inventory_page`, `purchase_page`, `common`, `utils`, etc.) and sorted alphabetically within each object.
- Parameter placeholders in translation strings must use `${paramName}` syntax (e.g. `${count}`, `${name}`).
- Locale state is controlled via `LocaleCubit` in `package:coozy_the_cafe/packages/shared/coozy_shared.dart`.
- Look up strings using `context.tr(shared.LocaleKeys.<key>, track: shared.TrackConstants.<track>) ?? 'Fallback'`, where `track:` matches the section object in `locale_en.json`.

## 5. Performance & Large Dataset Optimization
- **Database & Query Efficiency**: Design Drift DAOs with proper indexing, pagination (`LIMIT` / `OFFSET`), and targeted stream queries to efficiently handle large datasets.
- **UI Performance**: Use lazy list builders (`ListView.builder`, `GridView.builder`) with explicit performance flags (`addAutomaticKeepAlives: false`, `addRepaintBoundaries: true`), pagination, and avoid heavy $O(N^2)$ in-memory operations on the main thread.
- **Async Execution**: Offload heavy computational operations to background isolates (`compute`) to prevent UI jank.
- **Date & Time Utilities**: For any date and time parsing, formatting, or manipulation, always use `DateUtil` from core (`package:coozy_the_cafe/packages/core/coozy_core.dart`).
- **Common Shared Screens (Loading, Error & No Internet)**: Always use shared `LoadingPage` (`shared.LoadingPage()`), `ErrorPage` (`shared.ErrorPage(...)`), and `NoInternetPage` (`shared.NoInternetPage(...)`) from `package:coozy_the_cafe/packages/shared/coozy_shared.dart` for UI loading, error handling, and connectivity loss states.





## 6. Testing & Verification
- **Unit Tests Only for Business Logic (No Widget / Full-Fledged Testing)**: Do NOT implement any kind of widget testing or full-fledged integration testing. Only unit test cases for business logic (Domain Use Cases, Repositories, BLoCs/Cubits) are permitted.
- **Ask User question After Code/UI Implementation**: Do NOT implement unit tests automatically while writing features or building UI. At the end of completing the code or UI implementation, ask the user question: *"Do you want to implement unit test cases for the business logic?"* to allow implementation. Based on the user's interaction/response, only implement unit tests if the user confirms and permits it. If the user does not confirm or does not want them, do NOT implement test cases.
- **Write Unit Tests (Only Upon Confirmation)**: If and only if the user explicitly confirms or requests unit tests, write and run unit tests under `test/` for business logic (new use cases, repositories, and BLoCs) using `flutter test`.
- **Large Dataset Testing**: Test business logic against large mock datasets, empty states, and edge cases to ensure scalability and memory stability when unit tests are implemented.

## 7. Theme & UI Design Principles (Light & Dark Mode)
- **Dual-Theme Consideration**: Before implementing any UI design or widget, explicitly consider how it renders in **both Light Theme and Dark Theme**.
- **Use Theme Context**: Avoid hardcoding fixed color values (e.g. `Colors.white`, `Colors.black`, `Colors.grey[200]`). Use theme token properties from `Theme.of(context).colorScheme` or `Theme.of(context).textTheme` so UI components seamlessly adapt to theme changes.
- **AppThemeExtension**: Leverage `Theme.of(context).extension<shared.AppThemeExtension>()` for custom theme parameters.

## 8. Form & Input Management (Controllers, FocusNodes & Disposal)
- **Controllers & FocusNodes**: For every form, `TextFormField`, or input control, explicitly create its own `TextEditingController` and `FocusNode`.
- **Proper Initialization**: Explicitly initialize all `TextEditingController`s, `FocusNode`s, initial field values, and focus/change listeners inside `initState()` (or class declaration) to prevent `LateInitializationError` or null dereference.
- **Form Key & Validation**: Use a `GlobalKey<FormState>` for form validation and state management.
- **Proper Resource Disposal**: Always dispose all `TextEditingController`s and `FocusNode`s inside `dispose()` to prevent memory leaks.
- **Keyboard Navigation & Accessibility**: Wire focus nodes to enable seamless tab navigation, focus traversal, and action handling.



