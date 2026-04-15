# easy_flutter

A lightweight, zero-third-party-dependency architecture package for Flutter providing MVVM state management primitives, a sealed `Result` type, and clean architecture contracts.

## Core Concepts

### State Management

All state classes extend `DataState<T>` (which extends `ChangeNotifier`), providing a unified listener/notification API.

```dart
// Simple mutable state
final counter = MutableState<int>(initialValue: 0);
counter.value = 1; // notifies listeners
counter.addListener(() => print(counter.value));

// Collection states with granular operations
final list = MutableListState<String>(initialValue: ['a']);
list.add('b');         // notifies
list.removeAt(0);      // notifies
list.batchUpdate((l) { // single notification
  l.add('c');
  l.add('d');
});
```

### CommandState

Encapsulates an async operation with loading, success, and error tracking:

```dart
final cmd = CommandState<User>(
  action: () => userRepository.fetchCurrent(),
);

await cmd.execute(
  onLoading: (loading) => print('Loading: $loading'),
  onSuccess: (user) => print('Got: ${user.name}'),
  onError: (e) => print('Failed: $e'),
);

print(cmd.isLoading);  // false
print(cmd.isSuccess);  // true
print(cmd.value);      // User(...)
```

### PagingCommandState

Handles paginated list loading with automatic page tracking:

```dart
final paging = PagingCommandState<Product>(
  pageLoader: (params) => api.getProducts(page: params.page, size: params.size),
  config: const PagingConfig(pageSize: 20),
);

await paging.execute();        // loads first page
await paging.executeNext();    // loads next page, appends to list
await paging.refresh();        // resets and reloads from page 1

print(paging.value);           // all loaded items
print(paging.endOfList);       // true when no more pages
print(paging.canLoadNextPage); // false if loading or at end
```

### StreamState

Wraps a `Stream<T>` as a `DataState` with error tracking:

```dart
final state = StreamState<int>(
  stream: myStream,
  initialValue: 0,
);
// state.value updates automatically
// state.hasError / state.lastError for error handling
```

### ViewModel

Base class that owns states and manages their lifecycle:

```dart
class HomeViewModel extends ViewModel {
  late final counter = createMutableState(initialValue: 0);
  late final users = createCommandState<List<User>>(
    action: () => userRepository.getAll(),
  );

  void increment() => counter.value++;
}

// In a StatefulWidget using BaseState:
class _HomeScreenState extends BaseState<HomeScreen> {
  late final vm = factoryViewModel(() => HomeViewModel());

  @override
  Widget build(BuildContext context) {
    return StateBuilder(
      state: vm.counter,
      builder: (context, count, _) => Text('$count'),
    );
  }
}
```

### Shared ViewModels

Share a ViewModel across routes with automatic cleanup:

```dart
// In MaterialApp / GoRouter, attach the observer:
navigatorObservers: [ViewModelRouteObserver()]

// Create or retrieve a shared ViewModel:
final vm = context.createSharedViewModel(() => CartViewModel());

// Access it from any descendant:
final vm = context.getSharedViewModel<CartViewModel>();
```

### UI Builders

```dart
// Single state
StateBuilder(
  state: vm.counter,
  builder: (context, value, child) => Text('$value'),
);

// Multiple states
MultiStateBuilder(
  states: [vm.counter, vm.name],
  builder: (context, values, child) => Text('${values[0]} ${values[1]}'),
);

// Command with loading/error handling
CommandBuilder(
  state: vm.users,
  onLoading: (context) => CircularProgressIndicator(),
  onError: (context, error) => Text('Error: $error'),
  builder: (context, users, child) => ListView(...),
);
```

### Result Type

Sealed class for explicit error handling:

```dart
final result = await useCase.call(params);

switch (result) {
  case Ok(value: final user):
    print(user.name);
  case Error(error: final e):
    print(e);
}

// Or use the when helper:
result.when(
  onSuccess: (user) => print(user.name),
  onError: (e, stackTrace) => print(e),
);
```

### UseCase

Domain-layer contracts:

```dart
class GetUserUseCase extends UseCase<int, User> {
  final UserRepository _repo;
  GetUserUseCase(this._repo);

  @override
  Future<Result<User>> call(int id) => _repo.getUser(id);
}

class GetSettingsUseCase extends NoParamUseCase<Settings> {
  @override
  Future<Result<Settings>> call() => settingsRepo.get();
}
```

## API Reference

| Class                              | Description                                      |
|------------------------------------|--------------------------------------------------|
| `DataState<T>`                     | Base observable state extending `ChangeNotifier` |
| `MutableState<T>`                  | Read/write state with change detection           |
| `MutableListState<T>`              | Observable list with add/remove/batch ops        |
| `MutableMapState<K,V>`             | Observable map with put/remove/batch ops         |
| `MutableSetState<T>`               | Observable set with full Set API                 |
| `CommandState<T>`                  | Async command with loading/success/error         |
| `PagingCommandState<T>`            | Paginated list loading                           |
| `StreamState<T>`                   | Stream-backed state with error tracking          |
| `StateBuilder<V>`                  | Widget builder for a single `DataState`          |
| `MultiStateBuilder`                | Widget builder for multiple states               |
| `CommandBuilder<T>`                | Convenience builder for `CommandState`           |
| `ViewModel`                        | Base class with state lifecycle management       |
| `SharedViewModelStore`             | Singleton store for route-scoped ViewModels      |
| `ViewModelRouteObserver`           | Navigator observer for auto-cleanup              |
| `SharedViewModelScope<T>`          | InheritedWidget scope for child-tree VMs         |
| `BaseState<T>`                     | `State` mixin for ViewModel lifecycle in widgets |
| `Result<T>` / `Ok<T>` / `Error<T>` | Sealed result type                               |
| `UseCase<I,O>`                     | Use case contract with input                     |
| `NoParamUseCase<O>`                | Use case contract without input                  |
| `BaseException`                    | Structured exception base class                  |
| `Initializer`                      | DI initialization step contract                  |

## License

MIT — see [LICENSE](../../LICENSE).
