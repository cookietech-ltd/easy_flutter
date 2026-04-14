# Easy Flutter Boilerplate

A production-ready Flutter boilerplate implementing **MVVM with Clean Architecture**, powered by a zero-dependency state management core (`easy_flutter` package). Built following the [official Flutter architecture guidelines](https://docs.flutter.dev/app-architecture).

## Architecture

```
┌─────────────────────────────────────────────────┐
│                   UI Layer                       │
│  Screens → StateBuilder / CommandBuilder         │
│  ViewModel ← DataState / CommandState            │
├─────────────────────────────────────────────────┤
│                 Domain Layer                      │
│  UseCase → Result<T> → Repository (interface)    │
├─────────────────────────────────────────────────┤
│                  Data Layer                       │
│  RepositoryImpl → DataSource → API / DB          │
└─────────────────────────────────────────────────┘
```

- **State management** — `DataState` (extends `ChangeNotifier`), `MutableState`, `CommandState`, `StreamState`, collection states, and `PagingCommandState` — all in the `easy_flutter` package with no third-party dependencies.
- **ViewModel** — plain Dart class that owns and disposes states. Supports scoped sharing across routes via `SharedViewModelStore` + `ViewModelRouteObserver`.
- **Dependency injection** — `get_it` with a layered initializer chain (`Core → Network → DataSource → Repository → UseCase`).
- **Routing** — `go_router` with a typed `ScreenBuilder` for transitions.
- **Localization** — Flutter's built-in `gen_l10n` with ARB files.

## Folder Structure

```
easy_flutter/
├── lib/
│   ├── main.dart                          # Entry point
│   ├── l10n/                              # Localization (ARB + generated)
│   └── app/
│       ├── app.dart                       # MaterialApp.router setup
│       ├── core/
│       │   ├── base/                      # ScreenState, ScreenBuilder
│       │   ├── constants/                 # App-wide constants
│       │   ├── exceptions/                # Domain exception types
│       │   ├── model/                     # AppSettings (env config)
│       │   └── services/                  # AppService (bootstrap)
│       ├── data/
│       │   ├── datasource/                # Remote/local data sources
│       │   ├── model/                     # Data transfer objects
│       │   └── repository_impl/           # Repository implementations
│       ├── domain/
│       │   ├── entities/                  # Business entities
│       │   ├── repository/                # Repository contracts
│       │   └── use_case/                  # Use case implementations
│       ├── di/
│       │   ├── service_locator.dart       # GetIt instance + helpers
│       │   └── initializer/               # Layered DI initializers
│       ├── presentation/
│       │   ├── modules/                   # Feature screens
│       │   ├── shared/                    # Reusable widgets
│       │   └── styles/                    # Theme, colors, text styles
│       ├── routes/                        # GoRouter config + route names
│       └── utils/                         # Extensions
│
├── packages/
│   └── easy_flutter/                      # Core architecture package
│       ├── lib/src/
│       │   ├── state.dart                 # DataState, MutableState, CommandState, etc.
│       │   ├── view_model.dart            # ViewModel, SharedViewModelStore
│       │   ├── state_builder.dart         # StateBuilder, MultiStateBuilder, CommandBuilder
│       │   ├── result.dart                # Sealed Result<T> type
│       │   ├── use_case.dart              # UseCase / NoParamUseCase
│       │   ├── base_state.dart            # BaseState for widget lifecycle
│       │   ├── base_exception.dart        # Structured exception base
│       │   └── initializer.dart           # Initializer contract
│       └── test/                          # Package unit & widget tests
│
├── test/                                  # App-level tests
├── android/ ios/ web/                     # Platform projects
└── pubspec.yaml
```

## Prerequisites

- Flutter SDK `>=3.2.6` (see `pubspec.yaml` for exact constraints)
- Dart SDK `>=3.2.6 <4.0.0`

## Getting Started

```bash
# Clone the repository
git clone https://github.com/<your-org>/easy_flutter.git
cd easy_flutter

# Install dependencies (including the local easy_flutter package)
flutter pub get

# Run the app
flutter run

# Run package tests
cd packages/easy_flutter
flutter test
```

## DI Initializers

Dependency registration follows a strict layer order. Each initializer implements the `Initializer` contract from the `easy_flutter` package:

```
CoreInitializer → NetworkInitializer → DataSourceInitializer → RepositoryInitializer → UseCaseInitializer
```

Add your registrations inside each initializer's `init()` method. The chain is orchestrated by `DiInitializer` and called from `AppService.start()`.

## The `easy_flutter` Package

The core package (`packages/easy_flutter/`) provides framework-agnostic architecture primitives:

| Component | Purpose |
|---|---|
| `DataState<T>` | Base observable state (extends `ChangeNotifier`) |
| `MutableState<T>` | Simple read/write state |
| `MutableListState<T>` | Observable list with granular mutations |
| `MutableMapState<K,V>` | Observable map |
| `MutableSetState<T>` | Observable set |
| `CommandState<T>` | Async operation with loading/success/error |
| `PagingCommandState<T>` | Paginated list loading |
| `StreamState<T>` | Stream-backed reactive state |
| `StateBuilder` | Widget that rebuilds on state change |
| `MultiStateBuilder` | Listens to multiple states |
| `CommandBuilder` | Handles loading/error/success UI |
| `ViewModel` | Base class with state lifecycle management |
| `SharedViewModelStore` | Route-scoped ViewModel sharing |
| `Result<T>` | Sealed success/error type |
| `UseCase<I,O>` | Domain layer use case contract |
| `BaseException` | Structured error base class |
| `Initializer` | DI step contract |

See [`packages/easy_flutter/README.md`](packages/easy_flutter/README.md) for detailed API documentation.

## Inspired By

- [Flutter Architecture: Concepts](https://docs.flutter.dev/app-architecture/concepts)
- [Flutter Architecture: Guide](https://docs.flutter.dev/app-architecture/guide)
- [Flutter Architecture: Recommendations](https://docs.flutter.dev/app-architecture/recommendations)
- [Flutter Architecture: Design Patterns](https://docs.flutter.dev/app-architecture/design-patterns)

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
