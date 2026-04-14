import 'dart:async';
import 'package:flutter/widgets.dart';

import 'state.dart';

/// Base class for ViewModels in the MVVM architecture.
///
/// Subclasses create states via factory methods ([createMutableState],
/// [createCommandState], etc.) which are automatically tracked and disposed
/// when [dispose] is called. Override [onInit] for post-construction setup.
abstract class ViewModel {
  ViewModel() {
    onInit();
  }

  final List<DataState<dynamic>> _ownedStates = [];

  /// Registers [state] for automatic disposal when this ViewModel is disposed.
  T track<T extends DataState<dynamic>>(T state) {
    _ownedStates.add(state);
    return state;
  }

  /// Creates a [MutableState] tracked by this ViewModel.
  MutableState<T> createMutableState<T>({
    required T initialValue,
    VoidCallback? onValueChanged,
  }) {
    final state = MutableState(
      initialValue: initialValue,
      onValueChanged: onValueChanged,
    );
    return track(state);
  }

  /// Creates a [MutableListState] tracked by this ViewModel.
  MutableListState<T> createMutableListState<T>({
    required List<T> initialValue,
    VoidCallback? onValueChanged,
  }) {
    final state = MutableListState(
      initialValue: initialValue,
      onValueChanged: onValueChanged,
    );
    return track(state);
  }

  /// Creates a [MutableMapState] tracked by this ViewModel.
  MutableMapState<K, V> createMutableMapState<K, V>({
    required Map<K, V> initialValue,
    VoidCallback? onValueChanged,
  }) {
    final state = MutableMapState(
      initialValue: initialValue,
      onValueChanged: onValueChanged,
    );
    return track(state);
  }

  /// Creates a [MutableSetState] tracked by this ViewModel.
  MutableSetState<T> createMutableSetState<T>({
    required Set<T> initialValue,
    VoidCallback? onValueChanged,
  }) {
    final state = MutableSetState(
      initialValue: initialValue,
      onValueChanged: onValueChanged,
    );
    return track(state);
  }

  /// Creates a [CommandState] tracked by this ViewModel.
  CommandState<T> createCommandState<T>({
    T? initialValue,
    AsyncCallback<T>? action,
    VoidCallback? onValueChanged,
  }) {
    final state = CommandState(
      initialValue: initialValue,
      action: action,
      onValueChanged: onValueChanged,
    );
    return track(state);
  }

  /// Creates a [StreamState] tracked by this ViewModel.
  StreamState<T> createStreamState<T>({
    required Stream<T> stream,
    required T initialValue,
    VoidCallback? onValueChanged,
  }) {
    final state = StreamState<T>(
      stream: stream,
      initialValue: initialValue,
      onValueChanged: onValueChanged,
    );
    return track(state);
  }

  /// Creates a [PagingCommandState] tracked by this ViewModel.
  PagingCommandState<T> createPagingCommandState<T>({
    required PageLoader<T> pageLoader,
    PagingConfig config = const PagingConfig(),
    VoidCallback? onValueChanged,
  }) {
    final state = PagingCommandState(
      pageLoader: pageLoader,
      config: config,
      onValueChanged: onValueChanged,
    );
    return track(state);
  }

  bool _isShared = false;

  /// Marks this ViewModel as shared, preventing automatic disposal by [BaseState].
  void markAsShared() => _isShared = true;

  /// Whether this ViewModel is shared across routes via [SharedViewModelStore].
  bool get isShared => _isShared;

  /// Disposes all tracked states and releases resources.
  @mustCallSuper
  void dispose() {
    for (final state in _ownedStates) {
      state.dispose();
    }
    _ownedStates.clear();
    debugPrint('$runtimeType Disposed');
  }

  /// Called once during construction. Override to perform setup logic.
  @mustCallSuper
  void onInit() {
    debugPrint('$runtimeType Initialized');
  }
}

/// Singleton store for sharing ViewModels across routes.
///
/// ViewModels are scoped to a route ID and automatically disposed when
/// that route is popped, provided [ViewModelRouteObserver] is attached
/// to the navigator.
class SharedViewModelStore {
  static bool _routeObserverAttached = false;

  static void markRouteObserverAttached() {
    _routeObserverAttached = true;
  }

  static final SharedViewModelStore _instance =
      SharedViewModelStore._internal();

  factory SharedViewModelStore() => _instance;

  SharedViewModelStore._internal();

  final Map<Type, _ScopedViewModel> _store = {};
  final Map<int, Set<Type>> _routeToTypesMap = {};
  final Map<Type, ViewModel> _overrides = {};

  T put<T extends ViewModel>({
    required T viewModel,
    required int routeId,
  }) {
    viewModel.markAsShared(); // tag it as shared
    _store[T] = _ScopedViewModel(viewModel, routeId);
    _routeToTypesMap.putIfAbsent(routeId, () => {}).add(T);
    return viewModel;
  }

  T? get<T extends ViewModel>() {
    final override = _overrides[T];
    if (override is T) return override;

    final stored = _store[T]?.vm;
    if (stored is T) return stored;

    return null;
  }

  bool contains<T extends ViewModel>() => _store.containsKey(T);

  void override<T extends ViewModel>(T instance) {
    _overrides[T] = instance;
  }

  void clearOverride<T extends ViewModel>() => _overrides.remove(T);

  void disposeByRouteId(int routeId) {
    final types = _routeToTypesMap[routeId];
    if (types != null) {
      for (final type in types) {
        _store[type]?.vm.dispose();
        _store.remove(type);
      }
      _routeToTypesMap.remove(routeId);
    }
  }

  void clearAll() {
    for (var e in _store.values) {
      e.vm.dispose();
    }
    _store.clear();
    _routeToTypesMap.clear();
    _overrides.clear();
  }
}

class _ScopedViewModel {
  final ViewModel vm;
  final int routeId;

  _ScopedViewModel(this.vm, this.routeId);
}

/// Navigator observer that disposes route-scoped shared ViewModels on pop.
///
/// Attach to `navigatorObservers` in your `MaterialApp` or `GoRouter`.
class ViewModelRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  bool _marked = false;

  void _ensureMarked() {
    if (!_marked) {
      SharedViewModelStore.markRouteObserverAttached();
      _marked = true;
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _ensureMarked();
    super.didPush(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _ensureMarked();
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _ensureMarked();
    final name = route.settings.name;
    final id = route.hashCode;
    debugPrint('Popping Route ID: $id (name: $name)');
    SharedViewModelStore().disposeByRouteId(id);
  }
}

/// Provides a ViewModel to the widget subtree via [InheritedWidget].
///
/// The ViewModel is created once and disposed when the scope is removed
/// from the tree. Access it with [SharedViewModelScope.of] or [maybeOf].
class SharedViewModelScope<T extends ViewModel> extends StatefulWidget {
  final Widget child;
  final T Function() create;

  const SharedViewModelScope({
    super.key,
    required this.create,
    required this.child,
  });

  @override
  State<SharedViewModelScope<T>> createState() =>
      _SharedViewModelScopeState<T>();

  static T? maybeOf<T extends ViewModel>(BuildContext context) {
    final inherited =
        context.dependOnInheritedWidgetOfExactType<_ViewModelInherited<T>>();
    return inherited?.viewModel;
  }

  static T of<T extends ViewModel>(BuildContext context) {
    final inherited =
        context.dependOnInheritedWidgetOfExactType<_ViewModelInherited<T>>();
    assert(inherited != null, 'No SharedViewModelScope<$T> found in context');
    return inherited!.viewModel;
  }
}

class _SharedViewModelScopeState<T extends ViewModel>
    extends State<SharedViewModelScope<T>> {
  late final T _viewModel = widget.create()..markAsShared();

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ViewModelInherited<T>(viewModel: _viewModel, child: widget.child);
  }
}

class _ViewModelInherited<T> extends InheritedWidget {
  final T viewModel;

  const _ViewModelInherited({required super.child, required this.viewModel});

  @override
  bool updateShouldNotify(covariant _ViewModelInherited<T> oldWidget) => false;
}

/// Extension for creating route-scoped shared ViewModels.
extension ViewModelCreationExtension on BuildContext {
  /// Creates a shared ViewModel of type [T] bound to the current route,
  /// or returns the existing instance if one is already registered.
  ///
  /// Requires [ViewModelRouteObserver] to be attached for auto-cleanup.
  T createSharedViewModel<T extends ViewModel>(T Function() create) {
    if (SharedViewModelStore().contains<T>()) {
      return SharedViewModelStore().get<T>()!;
    }

    final routeId = ModalRoute.of(this)?.hashCode ?? 0;
    if (!SharedViewModelStore._routeObserverAttached) {
      throw FlutterError(
        'SharedViewModelStore: ViewModelRouteObserver must be attached to navigatorObservers in MaterialApp or GoRouter to support auto-cleanup.',
      );
    }
    return SharedViewModelStore()
        .put(viewModel: create(), routeId: routeId);
  }
}

/// Extension for accessing shared ViewModels from the widget tree.
extension ViewModelAccessExtension on BuildContext {
  /// Retrieves a shared ViewModel of type [T] from child scope
  /// ([SharedViewModelScope]) or global scope ([SharedViewModelStore]).
  ///
  /// Throws [FlutterError] if no ViewModel of type [T] is found.
  T getSharedViewModel<T extends ViewModel>() {
    assert(
      T != dynamic,
      'You must explicitly specify the ViewModel type: context.viewModel<MyViewModel>()',
    );

    final childScoped = SharedViewModelScope.maybeOf<T>(this);
    if (childScoped != null) return childScoped;

    final globalScoped = SharedViewModelStore().get<T>();
    if (globalScoped != null) return globalScoped;

    throw FlutterError(
      'Shared ViewModel<$T> not found in child or global scope. Did you forget to create it?',
    );
  }
}
