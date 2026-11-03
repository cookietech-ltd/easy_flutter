import 'dart:async';
import 'dart:collection'
    show UnmodifiableListView, UnmodifiableMapView, UnmodifiableSetView;

import 'package:flutter/foundation.dart' hide AsyncCallback;

import 'result.dart';

/// Logs a caught error in debug builds only.
void _logError(String source, Object error) {
  assert(() {
    debugPrint('ERROR: $source failed: $error');
    return true;
  }());
}

/// A base class that extends [ChangeNotifier] to provide state management.
///
/// [T] represents the type of the state value.
abstract class DataState<T> extends ChangeNotifier {
  /// Holds the current state value.
  late T _value;

  /// Callback function triggered when the state changes.
  final VoidCallback? _onValueChanged;

  bool _isDisposed = false;

  /// Constructor for initializing [DataState].
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

  /// Returns this state typed as read-only [DataState], for exposing from a
  /// ViewModel without letting the UI change it.
  DataState<T> asImmutable() => this;
}

/// Async function that returns a value of type [T].
typedef AsyncCallback<T> = Future<T> Function();


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

  /// Returns the computed value if execution was successful,
  /// or falls back to the initial value when no execution has occurred.
  @override
  T? get value => _result is Ok<T> ? (_result as Ok<T>).value : _value;

  /// Constructor for initializing [CommandState].
  CommandState({
    super.initialValue,
    required AsyncCallback<T>? action,
    super.onValueChanged,
  }) : _executeAction = action;

  /// Runs the stored action only if it has not run before.
  ///
  /// Returns the cached [Result] on later calls.
  Future<Result<T>?> executeOnce() async => _result ?? await execute();

  /// Runs the stored action passed to the constructor.
  ///
  /// Returns null without running when there is no stored action or a run
  /// is already in progress.
  Future<Result<T>?> execute() async {
    final action = _executeAction;
    if (action == null) return null;
    return executeWith(action);
  }

  /// Runs a one-off [action] instead of the stored one. Loading, error and
  /// value are tracked in this state exactly like [execute].
  ///
  /// Returns null without running when a run is already in progress.
  Future<Result<T>?> executeWith(AsyncCallback<T> action) async {
    if (_isLoading) return null;

    _isLoading = true;
    _result = null;
    _notifyListeners();

    try {
      _result = Result.ok(await action());
    } on Exception catch (e, stackTrace) {
      _logError('CommandState', e);
      _result = Result.error(e, stackTrace);
    } finally {
      _isLoading = false;
      _notifyListeners();
    }

    return _result;
  }

  /// Returns this state typed as read-only [DataState], for exposing from a
  /// ViewModel without letting the UI run it.
  DataState<T?> asImmutable() => this;

  @override
  String toString() => 'Result: $_result \nValue: ${super.toString()}';
}

/// A mutable list state that notifies listeners when the list changes.
class MutableListState<T> extends DataState<List<T>> {
  MutableListState({List<T> initialValue = const [], super.onValueChanged})
    : super(initialValue: List<T>.from(initialValue));

  /// Provides read-only access to the current list
  @override
  List<T> get value => UnmodifiableListView(_value);

  /// Replaces the entire list and notifies listeners if changed
  set value(List<T> newValue) {
    if (!listEquals(_value, newValue)) {
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

  /// Returns this state typed as read-only [DataState], for exposing from a
  /// ViewModel without letting the UI change it.
  DataState<List<T>> asImmutable() => this;

  @override
  String toString() => _value.toString();
}

/// A mutable map state that notifies listeners when the map changes.
class MutableMapState<K, V> extends DataState<Map<K, V>> {
  MutableMapState({Map<K, V> initialValue = const {}, super.onValueChanged})
    : super(initialValue: Map<K, V>.from(initialValue));

  /// Provides read-only access to the current map.
  @override
  Map<K, V> get value => UnmodifiableMapView(_value);

  /// Replaces the entire map and notifies listeners if changed.
  set value(Map<K, V> newValue) {
    if (!mapEquals(_value, newValue)) {
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
    if (!_value.containsKey(key)) return null;
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

  /// Returns this state typed as read-only [DataState], for exposing from a
  /// ViewModel without letting the UI change it.
  DataState<Map<K, V>> asImmutable() => this;

  @override
  String toString() => _value.toString();
}

/// A mutable set state that notifies listeners when the set changes.
class MutableSetState<T> extends DataState<Set<T>> {
  MutableSetState({Set<T>? initialValue, super.onValueChanged})
    : super(initialValue: Set<T>.from(initialValue ?? {}));

  /// Provides read-only access to the current set.
  @override
  Set<T> get value => UnmodifiableSetView(_value);

  /// Replaces the entire set and notifies listeners if changed.
  set value(Set<T> newValue) {
    if (!setEquals(_value, newValue)) {
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

  /// Returns this state typed as read-only [DataState], for exposing from a
  /// ViewModel without letting the UI change it.
  DataState<Set<T>> asImmutable() => this;

  @override
  String toString() => _value.toString();
}

/// Parameters passed to a [PageLoader] for each page request.
class PagingParams {
  /// The 1-based page number to load.
  final int page;

  /// The number of items per page.
  final int size;

  const PagingParams({required this.page, required this.size});

  @override
  String toString() => 'PagingParams(page: $page, size: $size)';
}

/// Callback that loads a page of items given [PagingParams].
typedef PageLoader<T> = Future<List<T>> Function(PagingParams params);

/// Configuration for pagination behavior.
class PagingConfig {
  /// Number of items to request per page.
  final int pageSize;

  /// The first page number (typically 0 or 1).
  final int initialPage;

  /// Fraction of scroll extent at which to trigger the next page load.
  final double loadMoreThreshold;

  const PagingConfig({
    this.pageSize = 20,
    this.initialPage = 1,
    this.loadMoreThreshold = 0.75,
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

  /// Bumped by [refresh] and [reset] so results of older loads are dropped.
  int _generation = 0;

  /// Whether a page is currently loading.
  bool get isLoading => _isLoading;

  /// Whether the last load returned no items, so there are no more pages.
  bool get endOfList => _endOfList;

  /// Whether the first page has not loaded yet.
  bool get isInitialLoad => _isInitialLoad;

  /// Whether [executeNext] would load a page right now.
  bool get canLoadNextPage => !_isLoading && !_endOfList;

  /// The page number the next [executeNext] call will request.
  int get currentPage => _currentPage;

  /// The error from the last failed load, cleared when a new load starts.
  Exception? get lastError => _lastError;

  PagingCommandState({
    required PageLoader<T> pageLoader,
    PagingConfig config = const PagingConfig(),
    super.onValueChanged,
  }) : _pageLoader = pageLoader,
       _config = config,
       _currentPage = config.initialPage,
       super(initialValue: <T>[]);

  /// Loads the first page. Returns the loaded items as an [Ok] without
  /// loading again once the first page is in.
  Future<Result<List<T>>?> execute() async {
    if (!_isInitialLoad) return Result.ok(_value);
    if (_isLoading) return null;
    return _load(_config.initialPage, append: false);
  }

  /// Loads the next page and appends it. Returns null when a load is in
  /// progress or the end of the list was reached.
  Future<Result<List<T>>?> executeNext() async {
    if (!canLoadNextPage) return null;
    return _load(_currentPage, append: true);
  }

  /// Clears all items and loads the first page again. A load still in
  /// flight is discarded.
  Future<Result<List<T>>?> refresh() {
    _clear();
    return _load(_config.initialPage, append: false);
  }

  /// Returns null when [refresh] or [reset] ran while this load was in flight.
  Future<Result<List<T>>?> _load(int page, {required bool append}) async {
    final generation = _generation;
    _isLoading = true;
    _lastError = null;
    _notifyListeners();

    try {
      final items = await _pageLoader(
        PagingParams(page: page, size: _config.pageSize),
      );
      if (generation != _generation) return null;

      if (items.isEmpty) {
        _endOfList = true;
      } else {
        _value = append ? [..._value, ...items] : items;
        _currentPage = page + 1;
      }
      _isInitialLoad = false;
      return Result.ok(items);
    } on Exception catch (e, stackTrace) {
      if (generation != _generation) return null;
      _logError('PagingCommandState', e);
      _lastError = e;
      return Result.error(e, stackTrace);
    } finally {
      if (generation == _generation) {
        _isLoading = false;
        _notifyListeners();
      }
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

  /// Clears all items and goes back to the first page without loading.
  /// A load still in flight is discarded.
  void reset() {
    _clear();
    _notifyListeners();
  }

  void _clear() {
    _generation++;
    _currentPage = _config.initialPage;
    _isLoading = false;
    _endOfList = false;
    _isInitialLoad = true;
    _lastError = null;
    _value = <T>[];
  }

  /// Returns this state typed as read-only [DataState], for exposing from a
  /// ViewModel without letting the UI change it.
  DataState<List<T>> asImmutable() => this;

  @override
  String toString() =>
      'PagingCommandState(items: ${_value.length}, page: $_currentPage, loading: $_isLoading, endOfList: $_endOfList)';
}

/// A state that automatically listens to and extracts data from a [Stream].
///
/// Stream errors are captured and accessible via [lastError] and [hasError].
class StreamState<T> extends DataState<T> {
  StreamSubscription<T>? _subscription;
  Exception? _lastError;

  /// The last error received from the stream, if any.
  Exception? get lastError => _lastError;

  /// Whether the stream has encountered an error.
  bool get hasError => _lastError != null;

  StreamState({
    required Stream<T> stream,
    required super.initialValue,
    super.onValueChanged,
  }) {
    _subscription = stream.listen(
      (data) {
        _lastError = null;
        _value = data;
        _notifyListeners();
      },
      onError: (Object e) {
        _lastError = e is Exception ? e : Exception(e.toString());
        _logError('StreamState', e);
        _notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  /// Returns this state typed as read-only [DataState], for exposing from a
  /// ViewModel without letting the UI change it.
  DataState<T> asImmutable() => this;
}

