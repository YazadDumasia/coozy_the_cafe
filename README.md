# Coozy The Cafe ☕

<p align="center">
  <img src="assets/images/logo.png" alt="Coozy The Cafe Logo" width="140" onerror="this.style.display='none'"/>
</p>

<p align="center">
  <strong>An enterprise-grade, offline-first Cafe Management System & Point of Sale (POS) application built with Flutter, Clean Architecture, and AI-native engineering.</strong>
</p>

<p align="center">
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-3.47.5-02569B?logo=flutter&style=for-the-badge" alt="Flutter"></a>
  <a href="https://dart.dev"><img src="https://img.shields.io/badge/Dart-3.13.4-0175C2?logo=dart&style=for-the-badge" alt="Dart"></a>
  <a href="https://drift.simonbinder.eu/"><img src="https://img.shields.io/badge/Storage-Drift%20%7C%20SQLite%20%7C%20WASM-blue?style=for-the-badge" alt="Drift SQLite"></a>
  <a href="https://bloclibrary.dev"><img src="https://img.shields.io/badge/State-BLoC%20%26%20Cubit-blueviolet?style=for-the-badge" alt="BLoC"></a>
  <a href="https://github.com/yazaddumasia/coozy_the_cafe/blob/main/LICENSE"><img src="https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge" alt="License"></a>
  <a href="https://yazaddumasia.github.io/coozy_the_cafe/"><img src="https://img.shields.io/badge/Demo-Live%20Web-8A2BE2?style=for-the-badge&logo=googlechrome&logoColor=white" alt="Live Demo"></a>
</p>

<p align="center">
  <a href="#live-demo">Live Demo</a> •
  <a href="#highlights">Highlights</a> •
  <a href="#modular-package-structure">Modular Architecture</a> •
  <a href="#enterprise-architecture--technical-standards">Technical Standards</a> •
  <a href="#ai-assisted-software-engineering">AI-Native Engineering</a> •
  <a href="#getting-started">Getting Started</a>
</p>

---

## 🚀 Overview & Executive Summary

**Coozy The Cafe** is a feature-rich cafe management and customer experience app designed for browsing menus, placing orders, managing inventory, and supporting staff workflows — all built on a clean, modular Flutter architecture. Bridging front-of-house hospitality with back-of-house supply chain logistics, Coozy delivers an end-to-end POS, Kitchen Display System (KDS), inventory ledger, dynamic loyalty rewards program, and peer-to-peer (P2P) offline synchronization.

Engineered with **Strict Modular Clean Architecture**, **Drift (Type-Safe SQLite/WASM)**, and **BLoC State Management**, this codebase serves as a benchmark for enterprise Flutter architecture, zero-cloud-lock-in operations, and modern AI-augmented developer workflows.

---

## 🌐 Live Demo

Explore the app online here (compiled to WebAssembly / CanvasKit):

👉 **[Launch Coozy The Cafe Live Web Demo](https://yazaddumasia.github.io/coozy_the_cafe/)**

---

## 🌟 Highlights

### 🍽️ Dining, Orders & Kitchen Operations
- **Waiter Order Placement & POS**: Fast, touch-friendly order-taking workflow with menu searching, category/subcategory filtering, combo meal bundle pickers, item variations, custom notes, and table binding.
- **Table Management & Dining Layout**: Real-time table status tracking (available, occupied, reserved), interactive table layout grid, and individual **table QR code generation & scanning**.
- **Kitchen Display System (KDS)**: Dedicated live kitchen order queue for kitchen staff to track ticket statuses (*Pending*, *Preparing*, *Ready*, *Completed*) in real time.
- **Table Reservation System**: Complete reservation lifecycle tracking with guest details, party size, date/time slots, and table assignment.

### 💰 Billing, Checkout & Customer Loyalty
- **Flexible Checkout & Multi-Payment**: Supports cash, card, UPI/digital payments, split bills, and instant receipt generation.
- **Customer Loyalty Program**: Configurable loyalty tiers (Bronze, Silver, Gold, Platinum), automatic points accrual on orders, and seamless point redemption as bill discounts.
- **Invoicing & Digital Receipts**: Full invoice history with printable PDF receipts, customizable business headers, tax breakdowns, and on-screen PDF preview.
- **Combo & Bundle Deal Engine**: Interactive multi-step combo creator wizard (`combo_form_dialog`), bundle deal pricing rules, drag-and-drop/manual combo reordering (`combo_reorder_page`), and dynamic bundle item picker dialogs integrated into the POS ordering workflow.

### 📦 Inventory, Recipes & Supply Chain
- **Ingredient & Stock Tracking**: Granular inventory control with units of measurement, cost tracking, and stock usage logging.
- **Recipe Management**: Link menu items to raw ingredient recipes for automatic inventory depletion upon order fulfillment.
- **Inventory Intelligence & Auto-Reorder**: Smart stock monitoring with configurable low-stock thresholds, instant alert cards, and automated reorder quantity suggestions.
- **Supplier Purchases & Expense Tracking**: Supplier log management, incoming purchase receipts, and operational cafe expenditure logging.

### 👥 Staff, Business Profile & Multi-Device Sync
- **Staff & Shift Management**: Employee directory, attendance logs, leave request tracking, and staff performance reports.
- **Business Profile Customization**: Dedicated configuration for cafe branding, legal registration/tax IDs, contact information, social links, and base currency.
- **Local Wi-Fi P2P Multi-Device Sync**: Decentralized peer-to-peer sync between a primary POS Hub and client waitstaff terminals with outbox queue monitoring — works completely offline without cloud lock-in.
- **Hardware & Thermal Printing**: ESC/POS receipt and KOT printing support via Bluetooth, USB, and network thermal printers, plus barcode generation.

### 📊 Analytics, Reliability & Developer Experience
- **Interactive Reports & Insights**: Visual sales trends, top-selling items, payment mode distribution, and stock adjustment charts using Syncfusion, with **Excel (XLSX) and PDF export**.
- **Data Safety & Portability**: Built-in full database JSON export, automatic backup, and database restore utilities powered by Drift ORM & SQLite.
- **Adaptive UI & Theming**: Dynamic particle animations, soft neumorphic elements, responsive layouts (mobile, tablet, desktop, web/WASM), and dark/light theme switching.
- **Multi-Language Localization**: Multi-locale support (`assets/locale/` & `LocaleKeys`) with full UI translation.
- **AI-Assisted Development**: Built-in [Google Antigravity IDE](https://antigravity.google) customizations (`.agents/AGENTS.md` and `SKILL.md`) and MCP integration (`marionette_flutter`) for live UI inspection, hot reloads, and agentic pair programming.

---

## 📸 Screenshots

Coming soon.

---

## 📦 Modular Package Structure

The project strictly follows **Modular Clean Architecture**. Every business capability is an isolated package under `lib/packages/`, cleanly separated into infrastructure, operational domains, and platform services:

### 1. Root & Core Foundation
```
lib/
├── main.dart                    # App initialization, routing & theme binding
├── injection.dart               # Central Service Locator (GetIt) coordinator
└── packages/
    ├── core/                    # Shared utilities, failure types, DateUtil, DI (sl)
    ├── database/                # Drift ORM tables, DAOs, web sync, backup & restore
    └── shared/                  # Common design tokens, AppThemeExtension, shared widgets
```

### 2. Complete Inventory of Feature Packages (23 Feature Modules)

```
lib/packages/
│
├── 🍽️ Menu & Dining Operations
│   ├── waiter_order_placement/  # High-velocity POS & table-side ordering workflow
│   ├── table_management/        # Dining layout grid, table occupancy & QR generator
│   ├── kitchen_management/      # Kitchen Display System (KDS) & real-time queue
│   ├── reservation/             # Reservation lifecycle, party sizing & slots
│   ├── order_management/        # Order history, status lifecycle & tracking
│   ├── menu_category/           # Menu category taxonomy & display orders
│   ├── menu_subcategory/        # Subcategory organization & category relationships
│   └── menu_item/               # Menu catalog, variants, price tiers & modifiers
│
├── 💳 Billing, Invoicing & Loyalty
│   ├── checkout/                # Split-bill calculation, tips, taxes & payment tenders
│   ├── invoice_management/      # Fiscal invoice history, PDF preview & receipt printing
│   ├── customer/                # Customer directory, purchase histories & loyalty tiers
│   └── combo_engine/            # Multi-step combo creator, bundle pricing, reorder & item pickers
│
├── 📦 Inventory, Supply Chain & Finance
│   ├── inventory/               # Ingredient master data, UOM & stock tracking
│   ├── inventory_intelligence/  # Low stock alerts, min-max thresholds & reorders
│   ├── recipes/                 # Bill of Materials (BOM) & inventory depletion
│   ├── purchase/                # Vendor management, purchase orders & receiving logs
│   └── expenditure/             # Cafe operating expenses & cash outflow logging
│
├── 👥 Staff & Cafe Administration
│   ├── staff_management/        # Staff directory, attendance, leaves & role tracking
│   ├── business_profile/        # Cafe branding, legal tax IDs, contact & currency
│   ├── settings/                # App config, P2P hub setup & thermal printer settings
│   ├── auth/                    # Authentication, login & role permissions
│   └── home_page/               # Central dashboard, KPI cards & quick actions
│
└── 📊 Reporting & Platform Intelligence
    └── reports/                 # Syncfusion analytics, sales charts, Excel/PDF export
```

### 3. Anatomical Structure of Each Feature Package

Every single feature inside `lib/packages/<feature_name>/` adheres strictly to this 3-tier boundary:

```
lib/packages/<feature_name>/
├── data/
│   ├── datasources/             # Local Drift DAOs & remote data source implementations
│   ├── models/                  # Data Transfer Objects (DTOs) with JSON/Drift mapping
│   └── repositories/            # Concrete implementations of domain repository contracts
├── domain/
│   ├── entities/                # Pure Dart business objects (zero UI dependencies)
│   ├── repositories/            # Abstract repository interface contracts
│   └── usecases/                # Single-responsibility business use cases
├── presentation/
│   ├── bloc/                    # Feature BLoC / Cubits (part files + sealed states)
│   ├── pages/                   # Isolated screen folders
│   │   └── <screen_name>/
│   │       ├── <screen_name>.dart         # Screen UI composition
│   │       ├── <screen_name>_actions.dart # Screen action handler mixin
│   │       ├── cubit/                     # Page-specific Cubit (if needed)
│   │       └── widget/                    # Sub-widgets specific to this screen
│   ├── widgets/                 # Common widgets shared across this feature
│   │   └── <widget_name>/
│   │       ├── <widget_name>.dart
│   │       └── widget/          # Sub-components of this widget
│   └── navigation/              # Feature routes and argument schemas
├── <feature_name>.dart          # Feature barrel file exporting public surfaces
└── <feature_name>_injection.dart# Dependency injection registration (GetIt)
```

---

## 🛠️ Enterprise Architecture & Technical Standards

```
┌────────────────────────────────────────────────────────────────────────┐
│                        PRESENTATION LAYER                              │
│         Flutter Pages  │  BLoC / Cubit (Sealed)  │  ValueNotifier      │
└───────────────────────────────────▲────────────────────────────────────┘
                                    │ (Events / States)
┌───────────────────────────────────┴────────────────────────────────────┐
│                          DOMAIN LAYER (Pure Dart)                      │
│        Entities  │  Use Cases (FP Either<Failure, T>)  │  Contracts    │
└───────────────────────────────────▲────────────────────────────────────┘
                                    │ (Repository Pattern)
┌───────────────────────────────────┴────────────────────────────────────┐
│                           DATA LAYER                                   │
│    Drift ORM / SQLite  │  Data Sources  │  JSON Mappers  │  P2P Sync   │
└────────────────────────────────────────────────────────────────────────┘
```

- **Domain Layer Purity**: The `domain/` layer contains **zero Flutter or UI dependencies**. All asynchronous outcomes are typed with `Either<Failure, T>` using functional programming (`dartz`), preventing unhandled runtime exceptions.
- **State Management (Zero `setState` Rule)**:
  - Strict reliance on `flutter_bloc` (`Bloc` and `Cubit`) backed by `Equatable`.
  - Main events and states are defined with Dart 3 `sealed class` for compile-time exhaustive pattern matching.
  - Sub-events and states are split via `part` / `part of` directives — never imported directly.
  - BLoC `copyWith` supports explicit clearing flags (`bool clearFilter = false`) for nullable filters.
  - Lightweight UI state uses `ValueNotifier` / `ValueListenableBuilder`.
- **Type-Safe Persistence (Drift ORM & SQLite)**:
  - Fully reactive SQL queries and stream-based DAO subscriptions.
  - Multi-platform support: native SQLite on Mobile/Desktop, and OPFS / Web Workers on WebAssembly.
  - Synchronized web database assets via `dart run scripts/sync_drift_web_assets.dart`.
  - Built-in full database JSON backup, snapshot restore, and integrity checks.
- **Theme & Design System Tokens**:
  - Full Light and Dark mode compliance without hardcoded colors.
  - Powered by Material 3 `Theme.of(context).colorScheme`, `textTheme`, and custom `shared.AppThemeExtension`.
  - Modern color opacity using `.withValues(alpha: ...)` instead of deprecated methods.
  - Responsive layouts via `shared.ResponsiveLayout` for Mobile (`< 550px`), Tablet (`550px - 1200px`), and Desktop (`>= 1200px`).
  - Safe text constraints using `.inExpandedRow()`.
- **Form & Input Management**:
  - Independent `TextEditingController` and `FocusNode` per input field with guaranteed disposal in `dispose()`.
  - Validated via `GlobalKey<FormState>`.
- **Empty States & Screen Modularization**:
  - Mandatory dedicated standalone empty view files (`*_empty_view.dart`) in `widget/` folders.
  - Monolithic screen files are decomposed into clean sub-components (headers, filters, lists, tables).

---

## 🧰 Tech Stack Matrix

| Category | Libraries / Tools |
|---|---|
| **UI Framework** | Flutter 3.47.5, Dart 3.x (WASM & Cross-Platform) |
| **Architecture & DI** | Clean Architecture, `get_it`, `dartz` (Functional Error Handling) |
| **State Management** | `flutter_bloc`, `equatable`, `ValueNotifier` |
| **Navigation** | `go_router` (Declarative deep-linking in `coozy_core.dart`) |
| **Database & ORM** | `drift`, `sqlite3`, `drift_flutter`, SQLite3 WASM / OPFS |
| **Localization (i18n)** | `flutter_localization`, `intl` (JSON dictionaries in `assets/locale/`) |
| **Charts & Sliders** | `syncfusion_flutter_charts`, `syncfusion_flutter_sliders` |
| **Animations & Effects** | `animations`, `animated_text_kit`, `lottie`, `flutter_floating_particles`, `flutter_neumorphism_ui` |
| **Hardware, Printing & Scanning** | `printing`, `esc_pos_utils_plus`, `print_bluetooth_thermal`, `flutter_thermal_printer`, `mobile_scanner`, `camera` |
| **Barcodes & QR** | `syncfusion_flutter_barcodes`, `barcode`, `secure_qr_generator` |
| **PDF & Spreadsheet Export** | `syncfusion_flutter_pdf`, `syncfusion_flutter_pdfviewer`, `syncfusion_flutter_xlsio`, `printing` |
| **Notifications & Sync** | `flutter_local_notifications`, `flutter_timezone`, `timezone`, Local P2P WebSocket & UDP sync |
| **Geolocation** | `geolocator`, `geocoding` |
| **Networking & Connectivity** | `http`, `internet_connection_checker_plus` |
| **Security & Storage** | `flutter_secure_storage`, `encrypt`, `crypto`, `shared_preferences` |
| **AI Dev & MCP Tooling** | Google Antigravity IDE, `marionette_flutter`, `marionette_mcp`, `marionette_logging` |

---

## 🤖 AI-Powered Development

Coozy The Cafe uses **[Google Antigravity IDE](https://antigravity.google)** as its AI coding assistant. The project ships with workspace-level **agent customizations** inside `.agents/` that teach the AI the project's architecture, coding standards, and developer workflows — ensuring every code change adheres to conventions without manual prompting.

### How it Works

The `.agents/` directory at the project root contains:

```
.agents/
├── AGENTS.md               # Project rules enforced on every AI interaction
└── skills/
    └── coozy-the-cafe/
        └── SKILL.md        # Deep project-specific skill guide for the AI agent
```

The agent automatically discovers and follows these files during every session.

---

### Project Rules — `AGENTS.md`

The [`.agents/AGENTS.md`](.agents/AGENTS.md) file defines **strict rules** that the AI must follow across every interaction:

| Rule Area | What It Enforces |
|---|---|
| **Modular Clean Architecture** | Features live in `lib/packages/<feature>/` with `data/`, `domain/`, `presentation/` separation |
| **Domain Purity** | `domain/` must be pure Dart — no Flutter/UI imports; uses `Either<Failure, T>` for error handling |
| **State Management** | No `setState`. Use `flutter_bloc` (Bloc/Cubit) with Equatable; `ValueNotifier` for lightweight UI state |
| **BLoC Structure** | `part` files for events/states, `sealed class` for base classes, explicit clearing flags for nullable filters |
| **Navigation** | All routes via `go_router` defined in `coozy_core.dart` |
| **Localization & i18n** | JSON locale files in `assets/locale/` grouped by section; mandatory proactive UI string localization; `params:` interpolation (never `.replaceAll`) |
| **Performance** | Paginated Drift queries, lazy list builders, `compute` isolates for heavy operations |
| **Date & Time** | Always use `DateUtil` from `coozy_core` — never raw `DateTime` formatting |
| **Shared Screens** | Use `shared.LoadingPage()`, `shared.ErrorPage(...)`, `shared.NoInternetPage(...)` consistently |
| **Form Management** | Explicit `TextEditingController` + `FocusNode` per field; always disposed in `dispose()` |
| **Theme & Dual-Mode UI** | Dual-theme (Light & Dark) compliance; no hardcoded colors/fonts; modern `.withValues(alpha: ...)`; `.inExpandedRow()` for titles |
| **Responsive Layout** | `shared.ResponsiveLayout` across Mobile (`<550px`), Tablet (`550-1200px`), and Desktop/Web (`>=1200px`); adaptive dialog sizing |
| **Empty Views & Modularization** | Mandatory standalone empty views (`*_empty_view.dart`) in `widget/` folders; modular sub-widget breakdown |
| **Testing** | Unit tests only for business logic — no widget tests; only added after explicit user confirmation |
| **Code Generation** | Run `dart run build_runner build` after modifying Drift tables or mock annotations |

---

### Agent Skill — `SKILL.md`

The [`.agents/skills/coozy-the-cafe/SKILL.md`](.agents/skills/coozy-the-cafe/SKILL.md) gives the AI a rich, structured understanding of the project internals:

- **Full module map** of all packages under `lib/packages/` (core foundation + 23 modular feature packages)
- **Feature package scaffold** with exact directory and file naming conventions per layer
- **Dependency injection patterns** using `get_it` with `register<Feature>Dependencies(sl)`
- **Drift ORM standards** for table definitions, DAO patterns, and code generation
- **Localization lookup** patterns using `context.tr()`, `LocaleKeys`, and `TrackConstants`
- **Step-by-step guide** for adding a new feature from domain entity through to UI screen
- **Developer workflow commands** for analyze, build_runner, and tests

---

### MCP Integration (Marionette)

The project includes **MCP (Model Context Protocol)** support via `marionette_flutter`, `marionette_mcp`, and `marionette_logging`. This enables the Antigravity agent to:

- Take **live screenshots** of the running app
- **Tap, scroll, enter text**, and interact with UI elements during development
- Perform **hot reload / hot restart** without leaving the AI session
- Read **runtime error logs** directly from the running Flutter process
- Run **integration test flows** against the live app

This allows the agent to visually verify UI changes and debug layout or logic issues in real time.

---

### Extending Agent Rules or Skills

To update the AI agent's behavior for this project:

1. **Edit rules** — Modify [`.agents/AGENTS.md`](.agents/AGENTS.md) to add or update enforced coding conventions.
2. **Update the skill** — Modify [`.agents/skills/coozy-the-cafe/SKILL.md`](.agents/skills/coozy-the-cafe/SKILL.md) to document new modules, patterns, or developer workflows.
3. Changes are picked up automatically on the next Antigravity session — no restart needed.

---

## ⚡ Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`>= 3.24.0` / recommended `3.47.5`)
- Dart SDK (`>= 3.5.0`)
- Android Studio, VS Code, or Google Antigravity IDE
- Google Chrome (for web testing) or Android/iOS Emulator

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yazaddumasia/coozy_the_cafe.git
   ```

2. **Navigate to the project directory:**
   ```bash
   cd coozy_the_cafe
   ```

3. **Install dependencies:**
   ```bash
   flutter pub get
   ```

4. **Run code generation (required after clone or Drift schema changes):**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

5. **(Optional for Web) Synchronize Drift Web Worker assets:**
   ```bash
   dart run scripts/sync_drift_web_assets.dart
   ```

6. **Run the application:**
   ```bash
   # Run on connected desktop or mobile device
   flutter run

   # Or run with WebAssembly on Chrome
   flutter run -d chrome
   ```

---

## 🛠️ Development Environment

- **Flutter Version**: 3.47.5 (stable channel)
- **Android Studio**: Rabbit 1 | 2026.2.1
- **AI Assistant**: Google Antigravity IDE

---

## 🧪 Quality Assurance & Verification

To verify static analysis and ensure code formatting matches project standards:

```bash
# Run static analysis
dart analyze

# Run unit tests on business logic
flutter test
```

---

## 👥 Contributing

Contributions are welcome. If you would like to improve the project, open a pull request or share feedback.

If you are contributing using Antigravity IDE, the agent automatically follows the project's [`.agents/AGENTS.md`](.agents/AGENTS.md) rules and skill guide — no additional setup needed.

---

## 👤 Author & Maintainer

**Yazad Dumasia**  
- **GitHub**: [@yazaddumasia](https://github.com/yazaddumasia)  
- **Project Repository**: [coozy_the_cafe](https://github.com/yazaddumasia/coozy_the_cafe)  
- **Live Application**: [yazaddumasia.github.io/coozy_the_cafe](https://yazaddumasia.github.io/coozy_the_cafe/)

---

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
