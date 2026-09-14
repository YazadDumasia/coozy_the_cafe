# Coozy the Cafe

![Flutter](https://img.shields.io/badge/Flutter-3.44.9-02569B?logo=flutter)
![License](https://img.shields.io/badge/License-MIT-green.svg)
![Demo](https://img.shields.io/badge/Demo-Live-8A2BE2)

A modern Flutter cafe application built to deliver a smooth experience for customers and staff alike.

## Live Demo

Explore the app online here:

https://yazaddumasia.github.io/coozy_the_cafe/

## Overview

Coozy the Cafe is a feature-rich cafe management and customer experience app designed for browsing menus, placing orders, managing inventory, and supporting staff workflows in a clean and scalable Flutter architecture.

## Highlights

- Beautiful, modern UI for cafe browsing and ordering
- Robust state management with Flutter BLoC
- Flexible routing with GoRouter
- Multi-language support through localization
- Lottie animations and rich media experiences
- Local persistence with Drift database
- Geolocation and map-ready integrations
- Suitable for both customer-facing and operational workflows

## Screenshots

Coming soon.

## Tech Stack

- Flutter
- Dart
- flutter_bloc
- go_router
- Drift
- shared_preferences
- lottie
- geolocator
- http

## Getting Started

### Prerequisites

- Flutter SDK installed and configured
- Android Studio or VS Code
- A device/emulator or browser support for testing

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

4. Run the app:

   ```bash
   flutter run
   ```

## Development Environment

- Flutter Version: 3.44.9 (stable channel)
- Android Studio: Quail 2 2026.1.2 Patch 1

## Project Architecture

The project follows a modular, feature-based Flutter architecture to keep the codebase maintainable and scalable as the application grows.

- `lib/main.dart` boots the application and initializes dependency injection
- `lib/injection.dart` registers services, repositories, and application dependencies
- Feature packages are separated under `lib/packages/` for domain-specific responsibilities
- Core utilities, shared components, and reusable services are kept centralized for consistency
- Business logic is structured around state-driven flows to support clean navigation and maintainable UI updates

This structure helps isolate functionality such as menu management, checkout, reservations, inventory, kitchen workflow, and staff operations without creating tight coupling between modules.

## Contributing

Contributions are welcome. If you would like to improve the project, open a pull request or share feedback.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.