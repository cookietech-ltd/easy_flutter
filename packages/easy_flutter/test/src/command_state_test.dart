import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_flutter/src/state.dart';
import 'package:easy_flutter/src/result.dart';

void main() {
  group('CommandState tests', () {
    test('execute sets loading and returns ok', () async {
      int count = 0;
      final completer = Completer<int>();
      final state = CommandState<int>(
        action: () async {
          return await completer.future;
        },
      );
      state.addListener(() => count++);
      
      expect(state.isLoading, isFalse);
      expect(state.value, isNull);

      final future = state.execute(
        onLoading: (isLoading) {},
        onSuccess: (value) {},
      );
      
      completer.complete(42);
      
      final result = await future;
      expect(result is Ok<int>, isTrue);
      expect(state.value, 42);
      expect(state.isLoading, isFalse);
      expect(state.isSuccess, isTrue);
      expect(state.asImmutable(), isA<DataState<int?>>());

      expect(count, greaterThan(1));
    });

    test('executeOnce does not run if already has result', () async {
      int executions = 0;
      final state = CommandState<int>(
        action: () async {
          executions++;
          return 1;
        },
      );
      
      await state.executeOnce();
      expect(executions, 1);
      
      await state.executeOnce();
      expect(executions, 1);
    });

    test('execute captures error state', () async {
      final state = CommandState<int>(
        action: () async {
          throw Exception('fail');
        },
      );

      final result = await state.execute(onError: (e) {});
      expect(result is Error<int>, isTrue);
      expect(state.error, isNotNull);
      expect(state.error!.error.toString().contains('fail'), isTrue);
      expect(state.isSuccess, isFalse);
    });
    
    test('executeExact prevents parallel executions', () async {
      final state = CommandState<int>(
        action: () async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          return 1;
        },
      );
      
      unawaited(state.executeExact(action: () async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return 1;
      }));
      final r2 = await state.executeExact(action: () async => 2);
      expect(r2, isNull);
    });

    test('execute returns null if action null', () async {
      final state = CommandState<int>(action: null);
      expect(await state.execute(), isNull);
    });

    test('initialValue is returned before any execution', () {
      final state = CommandState<int>(initialValue: 99, action: () async => 1);
      expect(state.value, 99);
    });

    test('initialValue is replaced after successful execution', () async {
      final state = CommandState<int>(initialValue: 99, action: () async => 42);
      await state.execute();
      expect(state.value, 42);
    });

    test('initialValue is preserved after failed execution', () async {
      final state = CommandState<int>(
        initialValue: 99,
        action: () async => throw Exception('fail'),
      );
      await state.execute(onError: (_) {});
      expect(state.value, 99);
    });
  });

  group('PagingCommandState tests', () {
    Future<List<int>> mockPageLoader(PagingParams params) async {
      if (params.page > 2) return [];
      return List.generate(params.size, (i) => (params.page - 1) * params.size + i);
    }

    test('paging execution flow', () async {
      final state = PagingCommandState<int>(
        pageLoader: mockPageLoader,
        config: const PagingConfig(pageSize: 5),
      );

      expect(state.isInitialLoad, isTrue);
      await state.execute(
        onLoading: (_) {},
        onSuccess: (_) {},
      );
      
      expect(state.value.length, 5);
      expect(state.currentPage, 2);
      expect(state.isInitialLoad, isFalse);
      expect(state.canLoadNextPage, isTrue);
      
      await state.execute();
      expect(state.value.length, 5); 

      await state.executeNext(onSuccess: (_) {});
      expect(state.value.length, 10);
      expect(state.currentPage, 3);
      expect(state.endOfList, isFalse);

      final r = await state.executeNext();
      expect(state.endOfList, isTrue);
      expect(state.canLoadNextPage, isFalse);
      expect(r?.when(onSuccess: (v) => v.length, onError: (_,__) => -1), 0);
      
      expect(await state.executeNext(), isNull);

      await state.refresh(onSuccess: (_) {});
      expect(state.value.length, 5);
      expect(state.currentPage, 2);
      expect(state.endOfList, isFalse);
      
      expect(state.shouldLoadMore(50, 100), isFalse); // maxScroll too small or threshold fail. 100 max scroll triggers fail check? wait code says if < 100 return false.
      expect(state.shouldLoadMore(150, 150), isTrue); 
      
      state.reset();
      expect(state.isInitialLoad, isTrue);
      expect(state.value.isEmpty, isTrue);
      expect(state.currentPage, 1);
    });

    test('paging handling errors on execute and executeNext', () async {
      int errorCount = 0;
      final state = PagingCommandState<int>(
        pageLoader: (p) async { throw Exception('fail'); },
      );

      final result1 = await state.execute(onError: (e) => errorCount++);
      expect(result1 is Error<List<int>>, isTrue);
      expect(state.lastError, isNotNull);
      expect(errorCount, 1);

      // executeNext also fails — canLoadNextPage is true (not loading, not endOfList)
      final result2 = await state.executeNext(onError: (e) => errorCount++);
      expect(result2 is Error<List<int>>, isTrue);
      expect(errorCount, 2);

      // After error, lastError is updated
      expect(state.lastError.toString(), contains('fail'));
    });

    test('PagingParams toString', () {
      const p = PagingParams(page: 1, size: 2);
      expect(p.toString(), 'PagingParams(page: 1, size: 2)');
    });
    
    test('PagingCommandState toString', () {
      final state = PagingCommandState<int>(pageLoader: (p) async => []);
      expect(state.toString(), 'PagingCommandState(items: 0, page: 1, loading: false, endOfList: false)');
      expect(state.asImmutable(), isA<DataState<List<int>>>());
    });
  });
}
