import 'dart:async';
import 'package:flutter/foundation.dart' hide AsyncCallback;
import 'package:flutter/cupertino.dart';
import 'result.dart';
import 'package:collection/collection.dart';

/// A base class that extends [ChangeNotifier] to provide state management.
///
/// [T] represents the type of the state value.
abstract class DataState<T> extends ChangeNotifier {
  /// Holds the current state value.
  late T _value;

  /// Callback function triggered when the state changes.
  final VoidCallback? _onValueChanged;

  bool _isDisposed = false;

  /// Constructor for initializing [BaseState].
  DataState({required T initialValue, VoidCallback? onValueChanged})
    : _onValueChanged = onValueChanged,
      _value = initialValue;

  /// Returns the current value.
  T get value => _value;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  /// Notifies listeners about changes in state.
  void _notifyListeners() {
    if (_isDisposed) return;
    _onValueChanged?.call();
    notifyListeners();
  }

  @override
  String toString() => _value.toString();
}

/// A mutable state class that allows modifying the state value.
///
/// [T] represents the type of the state value.
class MutableState<T> extends DataState<T> {
  /// Constructor for initializing [MutableState].
  MutableState({required super.initialValue, super.onValueChanged});

  /// Updates the state value and notifies listeners.
  set value(T newValue) {
    if (_value != newValue) {
      _value = newValue;
      _notifyListeners();
    }
  }

  /// Updates the state value and notifies listeners.
  void forceUpdate(T newValue) {
    _value = newValue;
    _notifyListeners();
  }

  DataState<T> asImmutable() {
    return this;
  }
}

typedef AsyncCallback<T> = Future<T> Function();

typedef VoidAsyncCallback = Future<void> Function();

typedef ErrorCallback = void Function(Exception e);

typedef LoadingCallback = void Function(bool isLoading);

/// A state class that manages an asynchronous command execution.
///
/// [T] represents the type of the result value.
class CommandState<T> extends DataState<T?> {
  /// The asynchronous function that executes the command.
  final AsyncCallback<T>? _executeAction;

  /// Indicates whether the command is currently executing.
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  /// Holds the result of the command execution.
  Result<T>? _result;

  /// Returns an error if the result contains an error.
  Error<T>? get error => _result is Error<T> ? _result as Error<T> : null;

  /// Returns true if the result contains a successful value.
  bool get isSuccess => _result is Ok<T>;

  /// Returns the computed value if the execution was successful.
  @override
  T? get value => _result is Ok<T> ? (_result as Ok<T>).value : null;

  /// Constructor for initializing [CommandState].
  CommandState({
    super.initialValue,
    required AsyncCallback<T>? action,
    super.onValueChanged,
  }) : _executeAction = action;

  /// Executes the action only if it hasn't been executed before.
  Future<Result<T>?> executeOnce({
    ErrorCallback? onError,
    LoadingCallback? onLoading,
    void Function(T value)? onSuccess,
  }) async {
    return _result ??
        await execute(
          onError: onError,
          onLoading: onLoading,
          onSuccess: onSuccess,
        );
  }

  /// Executes the command asynchronously, updating the state accordingly.
  Future<Result<T>?> executeExact({
    required AsyncCallback<T>? action,
    ErrorCallback? onError,
    LoadingCallback? onLoading,
    void Function(T value)? onSuccess,
  }) async {
    if (_isLoading) return null;
    if (action == null) return null;

    _isLoading = true;
    onLoading?.call(_isLoading);
    _result = null;
    _notifyListeners();

    try {
      final value = await action.call();
      _result = Result.ok(value);
      onSuccess?.call(value);
    } on Exception catch (e, stackTrace) {
      debugPrint('ERROR: CommandState execution failed $e');
      _result = Result.error(e, stackTrace);
      onError?.call(e);
    } finally {
      _isLoading = false;
      onLoading?.call(_isLoading);
      _notifyListeners();
    }

    return _result;
  }

  /// Executes the command asynchronously, updating the state accordingly.
  Future<Result<T>?> execute({
    ErrorCallback? onError,
    LoadingCallback? onLoading,
    void Function(T value)? onSuccess,
  }) async {
    return executeExact(
      action: _executeAction,
      onError: onError,
      onLoading: onLoading,
      onSuccess: onSuccess,
    );
  }

  DataState<T?> asImmutable() => this;

  @override
  String toString() => 'Result: $_result \nValue: ${super.toString()}';
}

/// A mutable list state that notifies listeners when the list changes.
class MutableListState<T> extends DataState<List<T>> {
  final _equality = IterableEquality<T>();

  MutableListState({List<T> initialValue = const [], super.onValueChanged})
    : super(initialValue: List<T>.from(initialValue));

  /// Provides read-only access to the current list
  @override
  List<T> get value => List.unmodifiable(_value);

  /// Replaces the entire list and notifies listeners if changed
  set value(List<T> newValue) {
    if (!_equality.equals(_value, newValue)) {
      _value = List<T>.from(newValue);
      _notifyListeners();
    }
  }

  /// Adds an item to the list
  void add(T item) {
    _value.add(item);
    _notifyListeners();
  }

  /// Adds multiple items to the list
  void addAll(Iterable<T> items) {
    _value.addAll(items);
    _notifyListeners();
  }

  /// Removes an item if present
  bool remove(T item) {
    final result = _value.remove(item);
    if (result) _notifyListeners();
    return result;
  }

  /// Removes an item by index
  T removeAt(int index) {
    _validateIndex(index);
    final removed = _value.removeAt(index);
    _notifyListeners();
    return removed;
  }

  /// Replaces an item at a specific index
  void replaceAt(int index, T item) {
    _validateIndex(index);
    _value[index] = item;
    _notifyListeners();
  }

  /// Updates an item at a specific index using a mutation callback
  void updateAt(int index, void Function(T) update) {
    _validateIndex(index);
    update(_value[index]);
    _notifyListeners();
  }

  /// Clears the entire list
  void clear() {
    if (_value.isNotEmpty) {
      _value.clear();
      _notifyListeners();
    }
  }

  /// Runs a batch of mutations and notifies once
  void batchUpdate(void Function(List<T>) updateFn) {
    updateFn(_value);
    _notifyListeners();
  }

  void _validateIndex(int index) {
    if (index < 0 || index >= _value.length) {
      throw RangeError(
        'Index ($index) out of bounds for list of length ${_value.length}',
      );
    }
  }

  DataState<List<T>> asImmutable() => this;

  @override
  String toString() => _value.toString();
}

/// A mutable map state that notifies listeners when the map changes.
class MutableMapState<K, V> extends DataState<Map<K, V>> {
  final _equality = MapEquality<K, V>();

  MutableMapState({Map<K, V> initialValue = const {}, super.onValueChanged})
    : super(initialValue: Map<K, V>.from(initialValue));

  /// Provides read-only access to the current map.
  @override
  Map<K, V> get value => Map.unmodifiable(_value);

  /// Replaces the entire map and notifies listeners if changed.
  set value(Map<K, V> newValue) {
    if (!_equality.equals(_value, newValue)) {
      _value = Map<K, V>.from(newValue);
      _notifyListeners();
    }
  }

  /// Adds or updates a key-value pair.
  void put(K key, V value) {
    if (_value[key] != value) {
      _value[key] = value;
      _notifyListeners();
    }
  }

  /// Adds multiple key-value pairs.
  void putAll(Map<K, V> entries) {
    _value.addAll(entries);
    _notifyListeners();
  }

  /// Removes a key-value pair by key.
  V? remove(K key) {
    final removed = _value.remove(key);
    _notifyListeners();
    return removed;
  }

  /// Checks if the map contains a specific key.
  bool containsKey(K key) => _value.containsKey(key);

  /// Clears the entire map.
  void clear() {
    if (_value.isNotEmpty) {
      _value.clear();
      _notifyListeners();
    }
  }

  /// Updates a value at a key using a mutation callback if key exists.
  void update(K key, void Function(V value) updateFn) {
    if (_value.containsKey(key)) {
      final value = _value[key];
      if (value != null) {
        updateFn(value);
        _notifyListeners();
      }
    }
  }

  /// Runs a batch of mutations and notifies once.
  void batchUpdate(void Function(Map<K, V>) updateFn) {
    updateFn(_value);
    _notifyListeners();
  }

  DataState<Map<K, V>> asImmutable() => this;

  @override
  String toString() => _value.toString();
}

/// A mutable set state that notifies listeners when the set changes.
class MutableSetState<T> extends DataState<Set<T>> {
  final _equality = SetEquality<T>();

  MutableSetState({Set<T>? initialValue, super.onValueChanged})
    : super(initialValue: Set<T>.from(initialValue ?? {}));

  /// Provides read-only access to the current set.
  @override
  Set<T> get value => Set.unmodifiable(_value);

  /// Replaces the entire set and notifies listeners if changed.
  set value(Set<T> newValue) {
    if (!_equality.equals(_value, newValue)) {
      _value = Set<T>.from(newValue);
      _notifyListeners();
    }
  }

  /// Adds an item to the set. Returns true if the value was added.
  bool add(T item) {
    final result = _value.add(item);
    if (result) {
      _notifyListeners();
    }
    return result;
  }

  /// Adds multiple items to the set.
  void addAll(Iterable<T> items) {
    if (items.isEmpty) return;
    _value.addAll(items);
    _notifyListeners();
  }

  /// Removes an item from the set. Returns true if the value was removed.
  bool remove(T item) {
    final result = _value.remove(item);
    if (result) {
      _notifyListeners();
    }
    return result;
  }

  /// Removes multiple items from the set.
  void removeAll(Iterable<T> items) {
    if (items.isEmpty) return;
    _value.removeAll(items);
    _notifyListeners();
  }

  /// Checks if the set contains a specific item.
  bool contains(T item) => _value.contains(item);

  /// Clears the entire set.
  void clear() {
    if (_value.isNotEmpty) {
      _value.clear();
      _notifyListeners();
    }
  }

  /// Runs a batch of mutations and notifies once.
  void batchUpdate(void Function(Set<T>) updateFn) {
    updateFn(_value);
    _notifyListeners();
  }

  /// Returns the object in the set if it exists, otherwise null.
  T? lookup(Object? object) => _value.lookup(object);

  /// Whether this set contains all the elements of [other].
  bool containsAll(Iterable<Object?> other) => _value.containsAll(other);

  /// Removes all elements of this set that satisfy [test].
  void removeWhere(bool Function(T element) test) {
    final sizeBefore = _value.length;
    _value.removeWhere(test);
    if (_value.length != sizeBefore) {
      _notifyListeners();
    }
  }

  /// Removes all elements of this set that fail to satisfy [test].
  void retainWhere(bool Function(T element) test) {
    final sizeBefore = _value.length;
    _value.retainWhere(test);
    if (_value.length != sizeBefore) {
      _notifyListeners();
    }
  }

  /// Removes all elements of this set that are not elements in [elements].
  void retainAll(Iterable<Object?> elements) {
    final sizeBefore = _value.length;
    _value.retainAll(elements);
    if (_value.length != sizeBefore) {
      _notifyListeners();
    }
  }

  /// Creates a new set which is the intersection between this set and [other].
  Set<T> intersection(Set<Object?> other) => _value.intersection(other);

  /// Creates a new set which contains all the elements of this set and [other].
  Set<T> union(Set<T> other) => _value.union(other);

  /// Creates a new set with the elements of this that are not in [other].
  Set<T> difference(Set<Object?> other) => _value.difference(other);

  /// Creates a [Set] with the same elements and behavior as this set.
  Set<T> toSet() => Set<T>.from(_value);

  DataState<Set<T>> asImmutable() => this;

  @override
  String toString() => _value.toString();
}

/// Parameters for pagination requests
class PagingParams {
  final int page;
  final int size;

  const PagingParams({required this.page, required this.size});

  @override
  String toString() => 'PagingParams(page: $page, size: $size)';
}

/// Callback that loads a page of data
typedef PageLoader<T> = Future<List<T>> Function(PagingParams params);

/// Configuration for pagination behavior
class PagingConfig {
  final int pageSize;
  final int initialPage;
  final double loadMoreThreshold;
  final int debounceMilliseconds;

  const PagingConfig({
    this.pageSize = 20,
    this.initialPage = 1,
    this.loadMoreThreshold = 0.75,
    this.debounceMilliseconds = 500,
  });
}

/// A specialized CommandState for handling paginated data
class PagingCommandState<T> extends DataState<List<T>> {
  final PageLoader<T> _pageLoader;
  final PagingConfig _config;

  // Pagination state
  int _currentPage;
  bool _isLoading = false;
  bool _endOfList = false;
  bool _isInitialLoad = true;
  Exception? _lastError;

  // Getters for pagination state
  bool get isLoading => _isLoading;

  bool get endOfList => _endOfList;

  bool get isInitialLoad => _isInitialLoad;

  bool get canLoadNextPage => !_isLoading && !_endOfList;

  int get currentPage => _currentPage;

  Exception? get lastError => _lastError;

  PagingCommandState({
    required PageLoader<T> pageLoader,
    PagingConfig config = const PagingConfig(),
    super.onValueChanged,
  }) : _pageLoader = pageLoader,
       _config = config,
       _currentPage = config.initialPage,
       super(initialValue: <T>[]);

  /// Execute initial load (only if not already loaded)
  Future<Result<List<T>>?> execute({
    ErrorCallback? onError,
    LoadingCallback? onLoading,
    void Function(List<T> items)? onSuccess,
  }) async {
    if (!_isInitialLoad) {
      // Already loaded, return existing data
      onSuccess?.call(_value);
      return Result.ok(_value);
    }

    _isLoading = true;
    _lastError = null;
    onLoading?.call(_isLoading);
    _notifyListeners();

    try {
      final params = PagingParams(
        page: _config.initialPage,
        size: _config.pageSize,
      );
      final newItems = await _pageLoader(params);

      if (newItems.isEmpty) {
        _endOfList = true;
        debugPrint('PagingCommandState: No initial data found');
      } else {
        _value = newItems;
        _currentPage = _config.initialPage + 1;
        debugPrint('PagingCommandState: Initial load: ${newItems.length} items');
      }

      _isInitialLoad = false;
      final result = Result.ok(newItems);
      onSuccess?.call(newItems);
      return result;
    } on Exception catch (e, stackTrace) {
      debugPrint('ERROR: PagingCommandState execute failed: $e');
      _lastError = e;
      onError?.call(e);
      return Result.error(e, stackTrace);
    } finally {
      _isLoading = false;
      onLoading?.call(_isLoading);
      _notifyListeners();
    }
  }

  /// Load the next page of data
  Future<Result<List<T>>?> executeNext({
    ErrorCallback? onError,
    LoadingCallback? onLoading,
    void Function(List<T> newItems)? onSuccess,
  }) async {
    if (!canLoadNextPage) return null;

    _isLoading = true;
    _lastError = null;
    onLoading?.call(_isLoading);
    _notifyListeners();

    try {
      final params = PagingParams(page: _currentPage, size: _config.pageSize);
      final newItems = await _pageLoader(params);

      if (newItems.isEmpty) {
        // No more data available - mark end of list
        _endOfList = true;
        debugPrint(
          'PagingCommandState: End of list reached at page $_currentPage',
        );
      } else {
        // Append new items to existing list
        final updatedList = List<T>.from(_value)..addAll(newItems);
        _value = updatedList;
        _currentPage++;
        onSuccess?.call(newItems);
        debugPrint(
          'PagingCommandState: Loaded ${newItems.length} items, total: ${_value.length}',
        );
      }

      final result = Result.ok(newItems);
      return result;
    } on Exception catch (e, stackTrace) {
      debugPrint('ERROR: PagingCommandState executeNext failed: $e');
      _lastError = e;
      onError?.call(e);
      return Result.error(e, stackTrace);
    } finally {
      _isLoading = false;
      onLoading?.call(_isLoading);
      _notifyListeners();
    }
  }

  /// Refresh by clearing all data and loading the first page
  Future<Result<List<T>>?> refresh({
    ErrorCallback? onError,
    LoadingCallback? onLoading,
    void Function(List<T> items)? onSuccess,
  }) async {
    _isLoading = true;
    _lastError = null;
    onLoading?.call(_isLoading);
    _notifyListeners();

    try {
      // Reset to initial state
      _currentPage = _config.initialPage;
      _endOfList = false;
      _isInitialLoad = true;
      _value = <T>[];

      final params = PagingParams(
        page: _config.initialPage,
        size: _config.pageSize,
      );
      final newItems = await _pageLoader(params);

      if (newItems.isEmpty) {
        _endOfList = true;
        debugPrint('PagingCommandState: No data found on refresh');
      } else {
        _value = newItems;
        _currentPage = _config.initialPage + 1;
        debugPrint(
          'PagingCommandState: Refresh loaded: ${newItems.length} items',
        );
      }

      _isInitialLoad = false;
      final result = Result.ok(newItems);
      onSuccess?.call(newItems);
      return result;
    } on Exception catch (e, stackTrace) {
      debugPrint('ERROR: PagingCommandState refresh failed: $e');
      _lastError = e;
      onError?.call(e);
      return Result.error(e, stackTrace);
    } finally {
      _isLoading = false;
      onLoading?.call(_isLoading);
      _notifyListeners();
    }
  }

  /// Check if should load more based on scroll position
  bool shouldLoadMore(double scrollPosition, double maxScrollExtent) {
    if (!canLoadNextPage) return false;

    // Prevent triggering if maxScrollExtent is too small (less than one screen)
    if (maxScrollExtent < 100) return false;

    final threshold = _config.loadMoreThreshold * maxScrollExtent;
    return scrollPosition >= threshold;
  }

  /// Reset to initial state
  void reset() {
    _currentPage = _config.initialPage;
    _isLoading = false;
    _endOfList = false;
    _isInitialLoad = true;
    _lastError = null;
    _value = <T>[];
    _notifyListeners();
  }

  DataState<List<T>> asImmutable() => this;

  @override
  String toString() =>
      'PagingCommandState(items: ${_value.length}, page: $_currentPage, loading: $_isLoading, endOfList: $_endOfList)';
}

/// A state that automatically listens to and extracts data from a [Stream].
class StreamState<T> extends DataState<T> {
  StreamSubscription<T>? _subscription;

  StreamState({
    required Stream<T> stream,
    required super.initialValue,
    super.onValueChanged,
  }) {
    _subscription = stream.listen(
      (data) {
        _value = data;
        _notifyListeners();
      },
      onError: (e) {
        debugPrint('ERROR: StreamState error: $e');
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  DataState<T> asImmutable() => this;
}

