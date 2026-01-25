import 'package:easy_flutter_boilerplate/app/core/state_management/state/state.dart';
import 'package:easy_flutter_boilerplate/app/utils/log.dart';
import 'package:flutter/widgets.dart';

// ✅ Base ViewModel class
abstract class ViewModel {
  ViewModel() {
    onInit();
  }

  final List<DataState<dynamic>> _ownedStates = [];

  T track<T extends DataState<dynamic>>(T state) {
    _ownedStates.add(state);
    return state;
  }

  MutableState<T> createMutableState<T>({
    required T initialValue,
  }) {
    final state = MutableState(
      initialValue: initialValue,
    );
    return track(state); // Register for disposal
  }

  MutableListState<T> createMutableListState<T>({
    required List<T> initialValue,
  }) {
    final state = MutableListState(
      initialValue: initialValue,
    );
    return track(state); // Register for disposal
  }

  MutableMapState<K, V> createMutableMapState<K, V>({
    required Map<K, V> initialValue,
  }) {
    final state = MutableMapState(
      initialValue: initialValue,
    );
    return track(state); // Register for disposal
  }

  MutableSetState<T> createMutableSetState<T>({
    required Set<T> initialValue,
  }) {
    final state = MutableSetState(
      initialValue: initialValue,
    );
    return track(state);
  }

  CommandState<T> createCommandState<T>({
    T? initialValue,
    AsyncCallback<T>? action,
  }) {
    final state = CommandState(
      initialValue: initialValue,
      action: action,
    );
    return track(state); // Register for disposal
  }

  PagingCommandState<T> createPagingCommandState<T>({
    required PageLoader<T> pageLoader,
    PagingConfig config = const PagingConfig(),
  }) {
    final state = PagingCommandState(
      pageLoader: pageLoader,
      config: config,
    );
    return track(state); // Register for disposal
  }

  bool _isShared = false;

  void markAsShared() => _isShared = true;

  bool get isShared => _isShared;

  @mustCallSuper
  void dispose() {
    for (final state in _ownedStates) {
      state.dispose();
    }
    _ownedStates.clear();
    Log.print('$runtimeType Disposed');
  }

  @mustCallSuper
  void onInit() {
    Log.print('$runtimeType Initialized');
  }
}

// ✅ Shared ViewModel Store with Route Cleanup
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
  final Map<String, Set<Type>> _routeToTypesMap = {};
  final Map<Type, ViewModel> _overrides = {};

  T put<T extends ViewModel>({
    required T viewModel,
    required String routeName,
  }) {
    viewModel.markAsShared(); // tag it as shared
    _store[T] = _ScopedViewModel(viewModel, routeName);
    _routeToTypesMap.putIfAbsent(routeName, () => {}).add(T);
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

  void disposeByRoute(String routeName) {
    final types = _routeToTypesMap[routeName];
    if (types != null) {
      for (final type in types) {
        _store[type]?.vm.dispose();
        _store.remove(type);
      }
      _routeToTypesMap.remove(routeName);
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
  final String routeName;

  _ScopedViewModel(this.vm, this.routeName);
}

// ✅ Route Observer for flow-wide ViewModel cleanup
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
    if (name != null) {
      debugPrint('Popping Route: $name');
      SharedViewModelStore().disposeByRoute(name);
    }
  }
}

// ✅ Child-scoped Shared ViewModel (InheritedWidget)
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

// ✅ Public API to create or get shared ViewModel (flowWide by default)
extension ViewModelCreationExtension on BuildContext {
  T createSharedViewModel<T extends ViewModel>(T Function() create) {
    if (SharedViewModelStore().contains<T>()) {
      return SharedViewModelStore().get<T>()!;
    }

    final routeName = ModalRoute.of(this)?.settings.name ?? 'unknown';
    if (!SharedViewModelStore._routeObserverAttached) {
      throw FlutterError(
        'SharedViewModelStore: ViewModelRouteObserver must be attached to navigatorObservers in MaterialApp or GoRouter to support auto-cleanup.',
      );
    }
    return SharedViewModelStore()
        .put(viewModel: create(), routeName: routeName);
  }
}

extension ViewModelAccessExtension on BuildContext {
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
