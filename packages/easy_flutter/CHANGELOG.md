## 2.0.0

### Breaking
- `CommandState.executeExact(action: ...)` is renamed to `executeWith(action)`.
- Removed the `onError`, `onLoading` and `onSuccess` params from `CommandState.execute`, `executeOnce`, `executeWith` and `PagingCommandState.execute`, `executeNext`, `refresh`. Read `isLoading` / `error` / `value` from the state, or check the returned `Result`.
- Removed the `ErrorCallback`, `LoadingCallback` and `VoidAsyncCallback` typedefs.
- Removed the `listeners` param from `MultiStateBuilder`.
- Requires Dart `^3.8.0`.

### Fixed
- `PagingCommandState.refresh()` and `reset()` now discard a page that was still loading, instead of appending it to the new list.
- `ViewModelRouteObserver` now disposes shared ViewModels when their route is removed or replaced, not only when it is popped.
- `createSharedViewModel` throws when called outside a route instead of registering a ViewModel that is never disposed.
- `BaseState.initState` calls `super.initState()` before `initializeListener()`.
- `MutableListState`, `MutableMapState` and `MutableSetState` return a read-only view from `value` instead of copying on every read.

### Changed
- No dependencies besides Flutter: dropped `package:collection`.
- Removed info logging. Caught errors are logged in debug builds only.

## 1.0.0

- Initial release.
