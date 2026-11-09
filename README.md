# Coozy the Cafe

![Flutter](https://img.shields.io/badge/Flutter-3.47.5-02569B?logo=flutter)
![License](https://img.shields.io/badge/License-MIT-green.svg)
![Demo](https://img.shields.io/badge/Demo-Live-8A2BE2)
![AI Assisted Development](https://img.shields.io/badge/AI--Assisted-Development-blueviolet?logo=google)

A modern Flutter cafe management application built to deliver a smooth experience for customers and staff alike — now with **AI-assisted development** powered by [Google Antigravity](https://antigravity.google).

## Live Demo

Explore the app online here:

https://yazaddumasia.github.io/coozy_the_cafe/

---

## Overview

Coozy the Cafe is a feature-rich cafe management and customer experience app designed for browsing menus, placing orders, managing inventory, and supporting staff workflows — all built on a clean, modular Flutter architecture.

---

## Highlights

### 🍽️ Dining, Orders & Kitchen Operations
- **Waiter Order Placement & POS**: Fast, touch-friendly order-taking workflow with menu searching, category/subcategory filtering, item variations, custom notes, and table binding.
- **Table Management & Dining Layout**: Real-time table status tracking (available, occupied, reserved), interactive table layout grid, and individual **table QR code generation & scanning**.
- **Kitchen Display System (KDS)**: Dedicated live kitchen order queue for kitchen staff to track ticket statuses (pending, preparing, ready, completed) in real time.
- **Table Reservation System**: Complete reservation lifecycle tracking with guest details, party size, date/time slots, and table assignment.

### 💰 Billing, Checkout & Customer Loyalty
- **Flexible Checkout & Multi-Payment**: Supports cash, card, UPI/digital payments, split bills, and instant receipt generation.
- **Customer Loyalty Program**: Configurable loyalty tiers (Bronze, Silver, Gold, Platinum), automatic points accrual on orders, and seamless point redemption as bill discounts.
- **Invoicing & Digital Receipts**: Full invoice history with printable PDF receipts, customizable business headers, tax breakdowns, and on-screen PDF preview.
- **Promotions & Combos Engine**: Bundle discounts, combo meal deals, and promotional campaign management with customizable validity rules.

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

## Screenshots

Coming soon.

---

## Tech Stack

| Category | Libraries / Tools |
|---|---|
| UI Framework | Flutter, Dart (WASM & Cross-Platform) |
| State Management | flutter_bloc, Equatable, ValueNotifier |
| Navigation | go_router |
| Database & ORM | Drift, SQLite, drift_flutter |
| Dependency Injection | get_it |
| Functional Error Handling | dartz |
| Localization | flutter_localization, intl |
| Charts & Sliders | syncfusion_flutter_charts, syncfusion_flutter_sliders |
| Animations & UI Effects | animations, animated_text_kit, lottie, flutter_floating_particles, flutter_neumorphism_ui |
| Hardware, Printing & Scanning | printing, esc_pos_utils_plus, print_bluetooth_thermal, flutter_thermal_printer, mobile_scanner, camera |
| Barcodes & QR | syncfusion_flutter_barcodes, barcode, secure_qr_generator |
| PDF & Spreadsheet Export | syncfusion_flutter_pdf, syncfusion_flutter_pdfviewer, syncfusion_flutter_xlsio, printing |
| Notifications & Sync | flutter_local_notifications, flutter_timezone, timezone, local P2P WebSocket & UDP sync |
| Geolocation | geolocator, geocoding |
| Networking & Connectivity | http, internet_connection_checker_plus |
| Security & Storage | flutter_secure_storage, encrypt, crypto, shared_preferences |
| AI Dev & MCP Tooling | Antigravity IDE, marionette_flutter, marionette_mcp, marionette_logging |

---

## AI-Powered Development

Coozy the Cafe uses **[Google Antigravity IDE](https://antigravity.google)** as its AI coding assistant. The project ships with workspace-level **agent customizations** inside `.agents/` that teach the AI the project's architecture, coding standards, and developer workflows — ensuring every code change adheres to conventions without manual prompting.

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

The [`.agents/AGENTS.md`](.agents/AGENTS.md) file defines **strict rules** that the AI must follow across every interaction. They act as a living, enforced style guide at the AI layer:

| Rule Area | What It Enforces |
|---|---|
| **Modular Clean Architecture** | Features live in `lib/packages/<feature>/` with `data/`, `domain/`, `presentation/` separation |
| **Domain Purity** | `domain/` must be pure Dart — no Flutter/UI imports; uses `Either<Failure, T>` for error handling |
| **State Management** | No `setState`. Use `flutter_bloc` (Bloc/Cubit) with Equatable; `ValueNotifier` for lightweight UI state |
| **BLoC Structure** | `part` files for events/states, `sealed class` for base classes, strict file separation |
| **Navigation** | All routes via `go_router` defined in `coozy_core.dart` |
| **Localization** | JSON locale files in `assets/locale/`; keys grouped by feature section, sorted alphabetically |
| **Performance** | Paginated Drift queries, lazy list builders, `compute` isolates for heavy operations |
| **Date & Time** | Always use `DateUtil` from `coozy_core` — never raw `DateTime` formatting |
| **Shared Screens** | Use `shared.LoadingPage()`, `shared.ErrorPage(...)`, `shared.NoInternetPage(...)` consistently |
| **Form Management** | Explicit `TextEditingController` + `FocusNode` per field; always disposed in `dispose()` |
| **Theme** | No hardcoded colors — use `Theme.of(context).colorScheme`, `textTheme`, and `AppThemeExtension` |
| **Testing** | Unit tests only for business logic — no widget tests; only added when user explicitly confirms |
| **Code Generation** | Run `dart run build_runner build` after modifying Drift tables or mock annotations |

---

### Agent Skill — `SKILL.md`

The [`.agents/skills/coozy-the-cafe/SKILL.md`](.agents/skills/coozy-the-cafe/SKILL.md) gives the AI a rich, structured understanding of the project internals:

- **Full module map** of all 26 feature packages under `lib/packages/`
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

## Getting Started

### Prerequisites

- Flutter SDK installed and configured
- Android Studio or VS Code
- A device/emulator or browser for testing
- *(Optional)* [Antigravity IDE](https://antigravity.google) for AI-assisted development

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/yazaddumasia/coozy_the_cafe.git
   ```

2. Navigate to the project directory:

   ```bash
   cd coozy_the_cafe
   ```

3. Install dependencies:

   ```bash
   flutter pub get
   ```

4. Run code generation (required after first clone or Drift schema changes):

   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

5. Run the app:

   ```bash
   flutter run
   ```

## Development Environment

- Flutter Version: 3.47.5 (stable channel)
- Android Studio: Rabbit 1 | 2026.2.1
- AI Assistant: Google Antigravity IDE

## Project Architecture

The project follows a **Modular Clean Architecture** pattern. Each business domain is a self-contained feature package under `lib/packages/`, with strict `data/`, `domain/`, and `presentation/` layer separation.

```
lib/
├── main.dart                    # App entry point & theme/router initialization
├── injection.dart               # Central DI coordinator
└── packages/
    ├── core/                    # Shared utilities, failure types, DateUtil, DI instance (sl)
    ├── database/                # Drift ORM tables, DAOs, web sync scripts, backup/restore
    ├── shared/                  # Common UI widgets, design system, themes, AppThemeExtension
    ├── auth/                    # Authentication & login/signup workflows
    ├── business_profile/        # Cafe branding, contact info, tax & currency profile
    ├── checkout/                # Order checkout, billing processing & loyalty discounts
    ├── customer/                # Customer directory, history & loyalty tracking
    ├── expenditure/             # Expense tracking & financial logs
    ├── home_page/               # Dashboard, quick actions & home navigation
    ├── inventory/               # Inventory, ingredient tracking & stock units
    ├── inventory_intelligence/  # Low stock alerts, reorder thresholds & automated suggestions
    ├── invoice_management/      # Invoices, billing receipts & PDF previews
    ├── kitchen_management/      # Kitchen display system (KDS) & order queue
    ├── menu_category/           # Menu categories
    ├── menu_subcategory/        # Menu subcategories
    ├── menu_item/               # Menu item catalog & variations
    ├── order_management/        # Order lifecycle & history
    ├── promotions_engine/       # Combo deals, bundle discounts & promotion rules
    ├── purchase/                # Purchase orders & supplier logs
    ├── recipes/                 # Recipe management & ingredient composition
    ├── reports/                 # Sales trends, analytics & stock adjustment reports
    ├── reservation/             # Table reservation management
    ├── settings/                # App settings, P2P sync, loyalty configs & thermal printers
    ├── staff_management/        # Staff roles & scheduling
    ├── table_management/        # Dining table layout, QR generation & status tracking
    └── waiter_order_placement/  # POS / Waiter order-taking flow
```

Business logic is structured around state-driven BLoC flows. All dependency registration happens in `lib/injection.dart` via per-feature `register<Feature>Dependencies(sl)` functions.

## Contributing

Contributions are welcome. If you would like to improve the project, open a pull request or share feedback.

If you are contributing using Antigravity IDE, the agent automatically follows the project's [`.agents/AGENTS.md`](.agents/AGENTS.md) rules and skill guide — no additional setup needed.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.