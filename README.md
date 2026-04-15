# Easy Flutter Boilerplate

A production-ready Flutter boilerplate implementing **MVVM with Clean Architecture**, powered by a lightweight, zero-dependency state management core (`easy_flutter` package). No Bloc, no Riverpod, no Provider -- just Flutter's own `ChangeNotifier` wrapped in a clean, opinionated API.

Built following the [official Flutter architecture guidelines](https://docs.flutter.dev/app-architecture).

## Motivation

MVVM with Clean Architecture is the [recommended approach](https://docs.flutter.dev/app-architecture/guide) by the Flutter team. Popular state management packages are great tools, but each introduces friction when you try to follow this pattern strictly:

| Package | Challenge with MVVM + Clean Architecture |
|---------|------------------------------------------|
| **Bloc** | Replaces the ViewModel concept with Event/State/Bloc triad -- adds ceremony for simple screens and makes holding multiple independent states awkward. |
| **Riverpod** | No native "ViewModel that lives and dies with a screen." Scoping to routes requires manual `autoDispose` config, and the mental model shifts away from UI-owns-ViewModel. |
| **Provider** | No built-in async command pattern -- you manually manage `isLoading`/`error`/`data` in every ChangeNotifier and end up building your own ViewModel base class. |

These are all excellent packages in their own right. Easy Flutter simply takes a different path -- instead of replacing MVVM, it **embraces it directly**:

- **ViewModel is a plain Dart class** that holds states and exposes methods. Not a Bloc, not a Notifier, not a Controller.
- **States are purpose-built** -- `MutableState`, `CommandState` (async with loading/error/success), `PagingCommandState`, `StreamState`. No event classes or state enums.
- **Lifecycle is automatic** -- `factoryViewModel(MyViewModel.new)` ties the ViewModel to the widget. Disposal happens on pop.
- **Shared ViewModels across routes** with automatic disposal via `ViewModelRouteObserver`.
- **Clean Architecture fits naturally** -- UseCase returns `Result<T>`, Repository implements a domain interface, each layer is independent and testable.
- **Zero third-party state management dependency** -- built entirely on Flutter's native `ChangeNotifier`.

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

**Data flows down, events flow up.** The UI never touches the data layer directly.

## Branching Strategy

This boilerplate is designed for a **fork-and-merge** workflow. After forking, merge feature branches to get pre-built setups:

| Branch | What You Get |
|--------|-------------|
| `main` | Core boilerplate (MVVM + Clean Architecture + state management) |
| `network-dio` | Dio HTTP client setup with interceptors, retry, and token refresh *(coming soon)* |
| `supabase` | Supabase auth + database + realtime integration *(coming soon)* |
| `firebase` | Firebase Auth + Firestore + FCM setup *(coming soon)* |
| `local-storage` | Hive / SharedPreferences with repository pattern *(coming soon)* |

```bash
# Fork the repo, then merge what you need:
git merge origin/network-dio
git merge origin/firebase
```

---

## Table of Contents

- [Motivation](#motivation)
- [Getting Started](#getting-started)
- [Folder Structure](#folder-structure)
- [Easy Flutter Package](#easy-flutter-package)
  - [States](#states)
  - [ViewModel](#viewmodel)
  - [UI Builders](#ui-builders)
  - [Result Type](#result-type)
  - [UseCase](#usecase)
- [Usage Guide](#usage-guide)
  - [Creating a Screen](#1-creating-a-screen)
  - [Creating a ViewModel](#2-creating-a-viewmodel)
  - [Using States in a ViewModel](#3-using-states-in-a-viewmodel)
  - [Building UI with StateBuilder](#4-building-ui-with-statebuilder)
  - [Handling Async Operations with CommandState](#5-handling-async-operations-with-commandstate)
  - [Listening to State Changes](#6-listening-to-state-changes)
  - [Paginated Lists](#7-paginated-lists)
  - [Stream-Backed State](#8-stream-backed-state)
  - [Shared ViewModels Across Screens](#9-shared-viewmodels-across-screens)
  - [Dependency Injection](#10-dependency-injection)
  - [Full Example: End-to-End Data Flow](#11-full-example-end-to-end-data-flow)
- [API Reference](#api-reference)
- [Inspired By](#inspired-by)
- [License](#license)

---

## Getting Started

```bash
# Clone the repository
git clone https://github.com/cookietech-ltd/easy_flutter.git
cd easy_flutter

# Install dependencies (including the local easy_flutter package)
flutter pub get

# Run the app
flutter run

# Run tests
flutter test                       # App tests
cd packages/easy_flutter && flutter test  # Package tests
```

### Prerequisites

- Flutter SDK `>=3.2.6`
- Dart SDK `>=3.2.6 <4.0.0`

---

## Folder Structure

```
easy_flutter/
├── lib/
│   ├── main.dart
│   └── app/
│       ├── app.dart                       # MaterialApp.router setup
│       ├── core/
│       │   ├── base/                      # ScreenBuilder (routing)
│       │   ├── constants/                 # App-wide constants
│       │   ├── exceptions/                # Domain exception types
│       │   ├── model/                     # AppSettings (env config)
│       │   └── services/                  # AppService (bootstrap)
│       ├── data/
│       │   ├── datasource/remote/         # Data source interfaces + implementations
│       │   ├── model/                     # Request/response DTOs
│       │   └── repository_impl/           # Repository implementations
│       ├── domain/
│       │   ├── entities/                  # Business entities
│       │   ├── repository/                # Repository contracts (interfaces)
│       │   └── use_case/                  # Use cases
│       ├── di/
│       │   ├── service_locator.dart       # GetIt instance + helpers
│       │   └── initializer/               # Layered DI initializers
│       ├── presentation/
│       │   ├── base/                      # ScreenState (error/loading helpers)
│       │   ├── modules/                   # Feature screens + view models
│       │   ├── shared/                    # Reusable widgets
│       │   └── styles/                    # Theme, colors, text styles
│       ├── routes/                        # GoRouter config + route definitions
│       └── utils/                         # Extensions
│
├── packages/
│   └── easy_flutter/                      # Core architecture package (zero dependencies)
│
├── test/                                  # App-level tests
└── pubspec.yaml
```

---

## Easy Flutter Package

The `easy_flutter` package (`packages/easy_flutter/`) provides all architecture primitives with **zero third-party dependencies** (only Flutter SDK).

### States

All state types extend `DataState<T>` which wraps Flutter's `ChangeNotifier`.

| State | Purpose |
|-------|---------|
| `MutableState<T>` | Simple read/write value (string, int, bool, object, etc.) |
| `MutableListState<T>` | Observable list with `add`, `remove`, `replaceAt`, `batchUpdate`, etc. |
| `MutableMapState<K,V>` | Observable map with `put`, `remove`, `update`, `batchUpdate` |
| `MutableSetState<T>` | Observable set with `add`, `remove`, `removeWhere`, `retainWhere` |
| `CommandState<T>` | Async operation with built-in `isLoading`, `error`, `isSuccess`, `value` |
| `PagingCommandState<T>` | Paginated list with `execute`, `executeNext`, `refresh`, `shouldLoadMore` |
| `StreamState<T>` | Automatically listens to a `Stream<T>` and updates value on each event |

### ViewModel

`ViewModel` is a plain Dart class (not a `ChangeNotifier`) that creates and **automatically tracks** states. When the ViewModel is disposed, all its tracked states are disposed too.

```dart
class MyViewModel extends ViewModel {
  late final counter = createMutableState<int>(initialValue: 0);
  late final items = createMutableListState<String>(initialValue: []);
  late final fetchData = createCommandState<User>(
    action: () => api.getUser(),
  );
}
```

### UI Builders

| Builder | Purpose |
|---------|---------|
| `StateBuilder<T>` | Rebuilds when a single `DataState<T>` changes |
| `MultiStateBuilder` | Rebuilds when any of multiple states change |
| `CommandBuilder<T>` | Handles `loading` / `error` / `success` states from a `CommandState<T>` |

### Result Type

A sealed class for explicit error handling -- no uncaught exceptions leaking through layers.

```dart
sealed class Result<T>
├── Ok<T>(T value)
└── Error<T>(Exception error, StackTrace? stackTrace)
```

### UseCase

Domain-layer contracts that encapsulate a single business operation:

```dart
abstract class UseCase<Input, Output> {
  Future<Result<Output>> call(Input params);
}

abstract class NoParamUseCase<Output> {
  Future<Result<Output>> call();
}
```

---

## Usage Guide

### 1. Creating a Screen

Every screen extends `ScreenState` (which extends `BaseState` from the package). This gives you automatic ViewModel lifecycle management plus built-in `showError`, `showLoading`, and `hideLoading` helpers.

```dart
class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends ScreenState<ProductScreen> {
  // Create and track the ViewModel -- disposed automatically when screen pops
  late final ProductViewModel vm = factoryViewModel(ProductViewModel.new);

  @override
  void initState() {
    super.initState();
    vm.loadProducts(onError: onError); // onError is from ScreenState
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CommandBuilder<List<Product>>(
        state: vm.products,
        onLoading: (_) => const Center(child: CircularProgressIndicator()),
        onError: (_, error) => Center(child: Text(error.toString())),
        builder: (context, products, _) {
          return ListView.builder(
            itemCount: products?.length ?? 0,
            itemBuilder: (_, i) => Text(products![i].name),
          );
        },
      ),
    );
  }
}
```

**Key points:**
- `factoryViewModel(YourViewModel.new)` creates, tracks, and auto-disposes the ViewModel.
- `ScreenState` provides `showError()`, `showLoading()`, `hideLoading()`, and `onError()` out of the box.
- No `dispose()` override needed -- `BaseState` handles it.

### 2. Creating a ViewModel

A ViewModel is where UI logic and state live. It never imports Flutter widgets.

```dart
class ProductViewModel extends ViewModel {
  late final GetProductsUseCase _useCase;
  late final CommandState<List<ProductEntity>> products;

  @override
  void onInit() {
    super.onInit();
    _useCase = inject<GetProductsUseCase>(); // get_it injection
    products = createCommandState<List<ProductEntity>>();
  }

  Future<void> loadProducts({ErrorCallback? onError}) async {
    await products.executeExact(
      action: () async {
        final result = await _useCase.call();
        return switch (result) {
          Ok(value: final v) => v,
          Error(error: final e) => throw e,
        };
      },
      onError: onError,
    );
  }
}
```

**Key points:**
- Override `onInit()` (always call `super.onInit()`) for setup logic that runs after construction.
- Use `createCommandState`, `createMutableState`, etc. -- they are auto-tracked for disposal.
- The ViewModel pattern-matches on `Result` to unwrap values or rethrow errors.

### 3. Using States in a ViewModel

#### MutableState -- simple values

```dart
late final counter = createMutableState<int>(initialValue: 0);
late final username = createMutableState<String>(initialValue: '');
late final isLoggedIn = createMutableState<bool>(initialValue: false);

void increment() => counter.value = counter.value + 1;
void setName(String name) => username.value = name;
```

#### MutableListState -- lists with granular mutations

```dart
late final todos = createMutableListState<Todo>(initialValue: []);

void addTodo(Todo todo) => todos.add(todo);
void removeTodo(int index) => todos.removeAt(index);
void updateTodo(int index, Todo updated) => todos.replaceAt(index, updated);
void clearAll() => todos.clear();

// Batch multiple mutations, notify once:
void reorder(int from, int to) {
  todos.batchUpdate((list) {
    final item = list.removeAt(from);
    list.insert(to, item);
  });
}
```

#### MutableMapState -- key-value pairs

```dart
late final settings = createMutableMapState<String, dynamic>(
  initialValue: {'theme': 'light', 'notifications': true},
);

void updateTheme(String theme) => settings.put('theme', theme);
bool hasKey(String key) => settings.containsKey(key);
```

#### MutableSetState -- unique collections

```dart
late final selectedIds = createMutableSetState<int>(initialValue: {});

void toggleSelection(int id) {
  if (selectedIds.contains(id)) {
    selectedIds.remove(id);
  } else {
    selectedIds.add(id);
  }
}
```

#### CommandState -- async operations

```dart
late final fetchUser = createCommandState<User>(
  action: () => apiService.getUser(),
);

// Execute the action:
await fetchUser.execute(
  onSuccess: (user) => print('Loaded: ${user.name}'),
  onError: (e) => print('Failed: $e'),
  onLoading: (loading) => print('Loading: $loading'),
);

// Check state:
fetchUser.isLoading;  // true while executing
fetchUser.isSuccess;  // true after successful execution
fetchUser.error;      // Error<T>? if failed
fetchUser.value;      // T? the result value

// Execute only once (cached):
await fetchUser.executeOnce();
```

### 4. Building UI with StateBuilder

`StateBuilder` rebuilds its `builder` whenever the state notifies.

```dart
// Single state
StateBuilder<int>(
  state: vm.counter,
  builder: (context, count, child) {
    return Text('Count: $count');
  },
)

// Multiple states -- rebuilds when ANY of them change
MultiStateBuilder(
  states: [vm.counter, vm.username],
  builder: (context, values, child) {
    final count = values[0] as int;
    final name = values[1] as String;
    return Text('$name tapped $count times');
  },
)
```

### 5. Handling Async Operations with CommandState

`CommandBuilder` is purpose-built for `CommandState` -- it handles loading, error, and success automatically.

```dart
CommandBuilder<User>(
  state: vm.fetchUser,
  onLoading: (_) => const CircularProgressIndicator(),
  onError: (_, error) => Text('Error: $error'),
  builder: (context, user, _) {
    if (user == null) return const Text('Press the button to load');
    return Text('Hello, ${user.name}');
  },
)
```

You can also use `StateBuilder` directly with `CommandState` for custom layouts:

```dart
StateBuilder<User?>(
  state: vm.fetchUser,
  builder: (context, user, _) {
    if (vm.fetchUser.isLoading) return const CircularProgressIndicator();
    if (vm.fetchUser.error != null) return Text('Error!');
    return Text(user?.name ?? 'No data');
  },
)
```

### 6. Listening to State Changes

Use the `listener` parameter to react to changes without rebuilding (e.g., navigation, showing snackbars):

```dart
StateBuilder<String>(
  state: vm.errorMessage,
  listener: (message) {
    if (message.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  },
  builder: (context, message, _) => const SizedBox.shrink(),
)
```

Or use `onValueChanged` at the ViewModel level:

```dart
late final counter = createMutableState<int>(
  initialValue: 0,
  onValueChanged: () => debugPrint('Counter changed: ${counter.value}'),
);
```

### 7. Paginated Lists

`PagingCommandState` handles page tracking, end-of-list detection, and incremental loading:

```dart
// In ViewModel:
late final products = createPagingCommandState<Product>(
  pageLoader: (params) => api.getProducts(page: params.page, size: params.size),
  config: const PagingConfig(pageSize: 20, initialPage: 1),
);

// Load first page:
await products.execute();

// Load next page:
await products.executeNext();

// Pull-to-refresh:
await products.refresh();

// Check state:
products.isLoading;
products.endOfList;
products.canLoadNextPage;
products.currentPage;
```

In the UI, trigger `executeNext` based on scroll position:

```dart
NotificationListener<ScrollNotification>(
  onNotification: (notification) {
    if (vm.products.shouldLoadMore(
      notification.metrics.pixels,
      notification.metrics.maxScrollExtent,
    )) {
      vm.products.executeNext();
    }
    return false;
  },
  child: ListView.builder(
    itemCount: vm.products.value.length,
    itemBuilder: (_, i) => ProductTile(vm.products.value[i]),
  ),
)
```

### 8. Stream-Backed State

`StreamState` automatically subscribes to a stream and updates on each event:

```dart
// In ViewModel:
late final connectionStatus = createStreamState<ConnectionStatus>(
  stream: connectivityService.statusStream,
  initialValue: ConnectionStatus.unknown,
);

// In UI:
StateBuilder<ConnectionStatus>(
  state: vm.connectionStatus,
  builder: (context, status, _) {
    return Icon(
      status == ConnectionStatus.online ? Icons.wifi : Icons.wifi_off,
    );
  },
)

// Check for stream errors:
if (vm.connectionStatus.hasError) {
  print(vm.connectionStatus.lastError);
}
```

### 9. Shared ViewModels Across Screens

Sometimes multiple screens need to share the same ViewModel instance (e.g., a cart, user session, or multi-step form). Easy Flutter provides two mechanisms:

#### Route-Scoped Sharing (auto-disposed on route pop)

Requires `ViewModelRouteObserver` in your router (already set up in this boilerplate):

```dart
// Screen A -- creates the shared ViewModel:
class _ScreenAState extends ScreenState<ScreenA> {
  late final cartVm = context.createSharedViewModel(CartViewModel.new);
  // ...
}

// Screen B -- accesses the same instance:
class _ScreenBState extends ScreenState<ScreenB> {
  late final cartVm = context.getSharedViewModel<CartViewModel>();
  // ...
}
```

When Screen A is popped from the navigator, the `CartViewModel` is automatically disposed.

#### Widget-Scoped Sharing (via InheritedWidget)

```dart
// Parent widget provides the ViewModel:
SharedViewModelScope<CartViewModel>(
  create: CartViewModel.new,
  child: const MyFeatureWidget(),
)

// Any descendant accesses it:
final cartVm = SharedViewModelScope.of<CartViewModel>(context);
```

### 10. Dependency Injection

Dependencies are registered in a strict layer order via initializers. Each implements the `Initializer` contract:

```
CoreInitializer → NetworkInitializer → DataSourceInitializer → RepositoryInitializer → UseCaseInitializer
```

```dart
// data_source_initializer.dart
class DataSourceInitializer implements Initializer {
  @override
  Future<void> init() async {
    getIt.registerLazySingleton<ProductDataSource>(
      () => ProductDataSourceImpl(),
    );
  }
}

// repository_initializer.dart
class RepositoryInitializer implements Initializer {
  @override
  Future<void> init() async {
    getIt.registerLazySingleton<ProductRepository>(
      () => ProductRepositoryImpl(getIt<ProductDataSource>()),
    );
  }
}

// use_case_initializer.dart
class UseCaseInitializer implements Initializer {
  @override
  Future<void> init() async {
    getIt.registerLazySingleton<GetProductsUseCase>(
      () => GetProductsUseCase(getIt<ProductRepository>()),
    );
  }
}
```

Inject anywhere using the `inject` extension:

```dart
final useCase = inject<GetProductsUseCase>();
```

### 11. Full Example: End-to-End Data Flow

Here is the complete data flow from this boilerplate -- Entity through Screen:

**Entity** (domain/entities/product_entity.dart):
```dart
class ProductEntity {
  final int id;
  final String name;
  final double price;

  const ProductEntity({required this.id, required this.name, required this.price});
}
```

**Data Model** (data/model/response/product_response.dart):
```dart
class ProductResponse {
  final int id;
  final String name;
  final double price;

  const ProductResponse({required this.id, required this.name, required this.price});

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      id: json['id'] as int,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
    );
  }

  ProductEntity toEntity() => ProductEntity(id: id, name: name, price: price);
}
```

**DataSource** (data/datasource/remote/product/product_data_source.dart):
```dart
abstract class ProductDataSource {
  Future<List<ProductResponse>> getProducts();
}
```

**Repository Contract** (domain/repository/product_repository.dart):
```dart
abstract class ProductRepository {
  Future<Result<List<ProductEntity>>> getProducts();
}
```

**Repository Implementation** (data/repository_impl/product_repository_impl.dart):
```dart
class ProductRepositoryImpl implements ProductRepository {
  final ProductDataSource _dataSource;

  ProductRepositoryImpl(this._dataSource);

  @override
  Future<Result<List<ProductEntity>>> getProducts() async {
    try {
      final responses = await _dataSource.getProducts();
      return Result.ok(responses.map((r) => r.toEntity()).toList());
    } on Exception catch (e, st) {
      return Result.error(e, st);
    }
  }
}
```

**UseCase** (domain/use_case/get_products_use_case.dart):
```dart
class GetProductsUseCase extends NoParamUseCase<List<ProductEntity>> {
  final ProductRepository _repository;

  const GetProductsUseCase(this._repository);

  @override
  Future<Result<List<ProductEntity>>> call() => _repository.getProducts();
}
```

**ViewModel** (presentation/modules/home/view_model/home_view_model.dart):
```dart
class HomeViewModel extends ViewModel {
  late final GetProductsUseCase _getProductsUseCase;
  late final CommandState<List<ProductEntity>> products;

  @override
  void onInit() {
    super.onInit();
    _getProductsUseCase = inject<GetProductsUseCase>();
    products = createCommandState<List<ProductEntity>>();
  }

  Future<void> loadProducts({ErrorCallback? onError}) async {
    await products.executeExact(
      action: () async {
        final result = await _getProductsUseCase.call();
        return switch (result) {
          Ok(value: final v) => v,
          Error(error: final e) => throw e,
        };
      },
      onError: onError,
    );
  }
}
```

**Screen** (presentation/modules/home/home_screen.dart):
```dart
class _HomeScreenState extends ScreenState<HomeScreen> {
  late final HomeViewModel vm = factoryViewModel(HomeViewModel.new);

  @override
  void initState() {
    super.initState();
    vm.loadProducts(onError: onError);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CommandBuilder<List<ProductEntity>>(
        state: vm.products,
        onLoading: (_) => const Center(child: CircularProgressIndicator()),
        onError: (_, error) => Center(child: Text(error.toString())),
        builder: (context, products, _) {
          if (products == null || products.isEmpty) {
            return const Center(child: Text('No products found.'));
          }
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (_, i) => ListTile(
              title: Text(products[i].name),
              subtitle: Text('\$${products[i].price.toStringAsFixed(2)}'),
            ),
          );
        },
      ),
    );
  }
}
```

---

## API Reference

| Component | Description |
|-----------|-------------|
| **States** | |
| `DataState<T>` | Base observable state (extends `ChangeNotifier`) |
| `MutableState<T>` | Simple read/write state with equality check |
| `MutableListState<T>` | Observable list with `add`, `remove`, `replaceAt`, `batchUpdate` |
| `MutableMapState<K,V>` | Observable map with `put`, `remove`, `update`, `batchUpdate` |
| `MutableSetState<T>` | Observable set with `add`, `remove`, `removeWhere`, `retainWhere` |
| `CommandState<T>` | Async operation -- `execute()`, `executeOnce()`, `executeExact()` |
| `PagingCommandState<T>` | Paginated loading -- `execute()`, `executeNext()`, `refresh()` |
| `StreamState<T>` | Stream-backed reactive state with `lastError`, `hasError` |
| **ViewModel** | |
| `ViewModel` | Base class with `createMutableState`, `createCommandState`, etc. |
| `SharedViewModelStore` | Singleton store for route-scoped ViewModel sharing |
| `ViewModelRouteObserver` | Navigator observer for auto-disposal on route pop |
| `SharedViewModelScope<T>` | InheritedWidget-based ViewModel provider |
| **UI Builders** | |
| `StateBuilder<T>` | Rebuilds on single state change, with optional `listener` |
| `MultiStateBuilder` | Rebuilds on any of multiple state changes |
| `CommandBuilder<T>` | Handles loading/error/success from `CommandState` |
| **Architecture** | |
| `Result<T>` | Sealed type -- `Ok<T>` or `Error<T>` |
| `UseCase<I,O>` | Domain use case with input parameter |
| `NoParamUseCase<O>` | Domain use case without input |
| `BaseException` | Structured exception with `title`, `message`, `code` |
| `Initializer` | Contract for DI initialization steps |
| `BaseState<T>` | Widget state base with `factoryViewModel` lifecycle management |

---

## Inspired By

- [Flutter Architecture: Concepts](https://docs.flutter.dev/app-architecture/concepts)
- [Flutter Architecture: Guide](https://docs.flutter.dev/app-architecture/guide)
- [Flutter Architecture: Recommendations](https://docs.flutter.dev/app-architecture/recommendations)
- [Flutter Architecture: Design Patterns](https://docs.flutter.dev/app-architecture/design-patterns)

## License

This project is licensed under the MIT License -- see the [LICENSE](LICENSE) file for details.
