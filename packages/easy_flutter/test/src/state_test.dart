import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_flutter/src/state.dart';

void main() {
  group('MutableState tests', () {
    test('initialization sets initial value', () {
      final state = MutableState<int>(initialValue: 0);
      expect(state.value, 0);
      expect(state.toString(), '0');
    });

    test('value setter updates value and notifies listeners', () {
      bool notified = false;
      final state = MutableState<int>(initialValue: 0);
      state.addListener(() => notified = true);
      
      state.value = 1;
      expect(state.value, 1);
      expect(notified, isTrue);
    });

    test('value setter ignores same value', () {
      bool notified = false;
      final state = MutableState<int>(initialValue: 0);
      state.addListener(() => notified = true);
      
      state.value = 0;
      expect(state.value, 0);
      expect(notified, isFalse);
    });

    test('forceUpdate updates value and always notifies listeners', () {
      bool notified = false;
      final state = MutableState<int>(initialValue: 0);
      state.addListener(() => notified = true);
      
      state.forceUpdate(0);
      expect(state.value, 0);
      expect(notified, isTrue);
    });

    test('dispose prevents notifyListeners', () {
      final state = MutableState<int>(initialValue: 0);
      state.dispose();
      expect(() => state.value = 1, returnsNormally);
    });

    test('asImmutable returns DataState type', () {
      final state = MutableState<int>(initialValue: 0);
      expect(state.asImmutable(), isA<DataState<int>>());
    });
  });

  group('MutableListState tests', () {
    test('basic list operations notify correctly', () {
      int count = 0;
      final state = MutableListState<int>(initialValue: []);
      state.addListener(() => count++);

      state.add(1);
      expect(state.value, [1]);
      expect(count, 1);

      state.addAll([2, 3]);
      expect(state.value, [1, 2, 3]);
      expect(count, 2);

      expect(state.remove(2), isTrue);
      expect(state.value, [1, 3]);
      expect(count, 3);
      
      expect(state.remove(99), isFalse);
      expect(count, 3); // not removed

      expect(state.removeAt(0), 1);
      expect(state.value, [3]);
      expect(count, 4);

      state.replaceAt(0, 4);
      expect(state.value, [4]);
      expect(count, 5);

      state.clear();
      expect(state.value, isEmpty);
      expect(count, 6);
    });

    test('updateAt notifies correctly', () {
      bool notified = false;
      final state = MutableListState<int>(initialValue: [1, 2]);
      state.addListener(() => notified = true);

      // using wrapper to demonstrate mutation if it's object, for ints we just replace, wait... updateAt provides value but doesn't mutate primitive!
      // This test ensures it doesn't crash on primitive but we should test the callback is executed
      int updatedVal = 0;
      state.updateAt(0, (val) {
        updatedVal = val;
      });
      expect(updatedVal, 1);
      expect(notified, isTrue);
    });

    test('batchUpdate notifies once', () {
      int count = 0;
      final state = MutableListState<int>(initialValue: [1]);
      state.addListener(() => count++);

      state.batchUpdate((list) {
        list.add(2);
        list.add(3);
      });
      expect(state.value, [1, 2, 3]);
      expect(count, 1);
    });

    test('value setter checks equality', () {
      int count = 0;
      final state = MutableListState<int>(initialValue: [1]);
      state.addListener(() => count++);

      state.value = [1];
      expect(count, 0);

      state.value = [2];
      expect(count, 1);
      
      expect(state.asImmutable(), isA<DataState<List<int>>>());
      expect(state.toString(), '[2]');
    });

    test('validateIndex throws RangeError', () {
      final state = MutableListState<int>(initialValue: []);
      expect(() => state.removeAt(0), throwsRangeError);
      expect(() => state.replaceAt(0, 1), throwsRangeError);
      expect(() => state.updateAt(0, (val) {}), throwsRangeError);
    });
  });

  group('MutableMapState tests', () {
    test('basic map operations notify correctly', () {
      int count = 0;
      final state = MutableMapState<String, int>();
      state.addListener(() => count++);

      state.put('a', 1);
      expect(state.value, {'a': 1});
      expect(count, 1);

      state.put('a', 1);
      expect(count, 1); // no notify if same

      state.putAll({'b': 2, 'c': 3});
      expect(state.value, {'a': 1, 'b': 2, 'c': 3});
      expect(count, 2);

      expect(state.remove('b'), 2);
      expect(state.value, {'a': 1, 'c': 3});
      expect(count, 3);

      expect(state.containsKey('a'), isTrue);

      state.clear();
      expect(state.value, isEmpty);
      expect(count, 4);
    });

    test('remove does not notify when key is absent', () {
      int count = 0;
      final state = MutableMapState<String, int>(initialValue: {'a': 1});
      state.addListener(() => count++);

      final result = state.remove('z');
      expect(result, isNull);
      expect(count, 0);
    });

    test('update notifies correctly', () {
      bool notified = false;
      final state = MutableMapState<String, int>(initialValue: {'a': 1});
      state.addListener(() => notified = true);

      int updatedVal = 0;
      state.update('a', (val) {
        updatedVal = val;
      });
      expect(updatedVal, 1);
      expect(notified, isTrue);
    });

    test('batchUpdate notifies once', () {
      int count = 0;
      final state = MutableMapState<String, int>(initialValue: {'a': 1});
      state.addListener(() => count++);

      state.batchUpdate((map) {
        map['b'] = 2;
        map['c'] = 3;
      });
      expect(state.value, {'a': 1, 'b': 2, 'c': 3});
      expect(count, 1);
    });

    test('value setter checks equality', () {
      int count = 0;
      final state = MutableMapState<String, int>(initialValue: {'a': 1});
      state.addListener(() => count++);

      state.value = {'a': 1};
      expect(count, 0);

      state.value = {'a': 2};
      expect(count, 1);
      
      expect(state.asImmutable(), isA<DataState<Map<String, int>>>());
      expect(state.toString(), '{a: 2}');
    });
  });

  group('MutableSetState tests', () {
    test('basic set operations notify correctly', () {
      int count = 0;
      final state = MutableSetState<int>();
      state.addListener(() => count++);

      expect(state.add(1), isTrue);
      expect(state.value, {1});
      expect(count, 1);

      expect(state.add(1), isFalse);
      expect(count, 1); // no notify if same

      state.addAll([2, 3]);
      expect(state.value, {1, 2, 3});
      expect(count, 2);

      expect(state.remove(2), isTrue);
      expect(state.value, {1, 3});
      expect(count, 3);
      
      expect(state.remove(99), isFalse);
      expect(count, 3);

      state.removeAll([1, 99]);
      expect(state.value, {3});
      expect(count, 4);

      expect(state.contains(3), isTrue);

      state.clear();
      expect(state.value, isEmpty);
      expect(count, 5);
    });

    test('batchUpdate notifies once', () {
      int count = 0;
      final state = MutableSetState<int>(initialValue: {1});
      state.addListener(() => count++);

      state.batchUpdate((set) {
        set.add(2);
        set.add(3);
      });
      expect(state.value, {1, 2, 3});
      expect(count, 1);
    });

    test('extended Set methods', () {
      int count = 0;
      final state = MutableSetState<int>(initialValue: {1, 2, 3, 4});
      state.addListener(() => count++);

      expect(state.lookup(2), 2);
      expect(state.containsAll([1, 2]), isTrue);
      
      state.removeWhere((e) => e % 2 == 0);
      expect(state.value, {1, 3});
      expect(count, 1);

      state.retainWhere((e) => e == 3);
      expect(state.value, {3});
      expect(count, 2);

      state.addAll([4, 5]);
      count = 0;
      
      state.retainAll([3, 4]);
      expect(state.value, {3, 4});
      expect(count, 1);

      expect(state.intersection({4, 5}), {4});
      expect(state.union({5}), {3, 4, 5});
      expect(state.difference({3}), {4});
      expect(state.toSet(), {3, 4});
      
      expect(state.asImmutable(), isA<DataState<Set<int>>>());
      expect(state.toString(), '{3, 4}');
    });

    test('value setter checks equality', () {
      int count = 0;
      final state = MutableSetState<int>(initialValue: {1});
      state.addListener(() => count++);

      state.value = {1};
      expect(count, 0);

      state.value = {2};
      expect(count, 1);
    });
  });

  group('StreamState tests', () {
    test('listens to stream and updates value', () async {
      final controller = StreamController<int>();
      final state = StreamState<int>(
        stream: controller.stream,
        initialValue: 0,
      );

      expect(state.value, 0);
      expect(state.hasError, isFalse);
      expect(state.lastError, isNull);
      expect(state.asImmutable(), isA<DataState<int>>());

      controller.add(1);
      await Future<void>.delayed(Duration.zero);
      expect(state.value, 1);
      expect(state.hasError, isFalse);

      controller.addError(Exception('stream error'));
      await Future<void>.delayed(Duration.zero);
      expect(state.hasError, isTrue);
      expect(state.lastError.toString(), contains('stream error'));
      expect(state.value, 1, reason: 'Value should remain unchanged on error');

      controller.add(5);
      await Future<void>.delayed(Duration.zero);
      expect(state.value, 5);
      expect(state.hasError, isFalse);
      expect(state.lastError, isNull);

      state.dispose();
      controller.add(2);
      await Future<void>.delayed(Duration.zero);
      expect(state.value, 5);
      
      await controller.close();
    });

    test('notifies listeners on stream error', () async {
      final controller = StreamController<int>();
      int notifyCount = 0;
      final state = StreamState<int>(
        stream: controller.stream,
        initialValue: 0,
      );
      state.addListener(() => notifyCount++);

      controller.addError(Exception('fail'));
      await Future<void>.delayed(Duration.zero);

      expect(notifyCount, 1, reason: 'Listeners should be notified on error');
      expect(state.hasError, isTrue);

      state.dispose();
      await controller.close();
    });
  });
}
