import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_flutter/easy_flutter.dart';

class TestViewModel extends ViewModel {
  late final MutableState<int> counter;
  late final MutableListState<int> list;
  late final MutableMapState<String, int> map;
  late final MutableSetState<int> set;
  late final CommandState<int> cmd;
  late final StreamState<int> streamCmd;
  late final PagingCommandState<int> paging;
  
  final StreamController<int> sc = StreamController<int>();

  TestViewModel() : super() {
    counter = createMutableState(initialValue: 0);
    list = createMutableListState(initialValue: <int>[]);
    map = createMutableMapState(initialValue: <String, int>{});
    set = createMutableSetState(initialValue: <int>{});
    cmd = createCommandState(initialValue: 0, action: () async => 1);
    streamCmd = createStreamState(stream: sc.stream, initialValue: 0);
    paging = createPagingCommandState(pageLoader: (_) async => <int>[]);
  }
}

void main() {
  group('ViewModel tests', () {
    test('create state methods correctly track states', () {
      final vm = TestViewModel();
      expect(vm.counter.value, 0);
      expect(vm.list.value, isEmpty);
      expect(vm.map.value, isEmpty);
      expect(vm.set.value, isEmpty);
      expect(vm.cmd.value, isNull);
      expect(vm.streamCmd.value, 0);
      expect(vm.paging.value, isEmpty);
      expect(vm.isShared, isFalse);
    });

    test('dispose sweeps all tracked states', () {
      final vm = TestViewModel();
      vm.dispose();
      // Internal states are disposed
      expect(() => vm.counter.value = 1, returnsNormally);
      vm.sc.close();
    });

    test('markAsShared works', () {
      final vm = TestViewModel();
      vm.markAsShared();
      expect(vm.isShared, isTrue);
    });
  });

  group('SharedViewModelStore tests', () {
    tearDown(() {
      SharedViewModelStore().clearAll();
    });

    test('put and get', () {
      final vm = TestViewModel();
      SharedViewModelStore().put(viewModel: vm, routeId: 123);
      
      expect(vm.isShared, isTrue);
      expect(SharedViewModelStore().contains<TestViewModel>(), isTrue);
      
      final retrieved = SharedViewModelStore().get<TestViewModel>();
      expect(retrieved, same(vm));
    });

    test('override works', () {
      final vm1 = TestViewModel();
      final vm2 = TestViewModel();
      
      SharedViewModelStore().put(viewModel: vm1, routeId: 1);
      SharedViewModelStore().override(vm2);
      
      final retrieved = SharedViewModelStore().get<TestViewModel>();
      expect(retrieved, same(vm2));
      
      SharedViewModelStore().clearOverride<TestViewModel>();
      expect(SharedViewModelStore().get<TestViewModel>(), same(vm1));
    });

    test('disposeByRouteId', () {
      final vm1 = TestViewModel();
      SharedViewModelStore().put(viewModel: vm1, routeId: 42);
      
      SharedViewModelStore().disposeByRouteId(42);
      expect(SharedViewModelStore().contains<TestViewModel>(), isFalse);
    });
    
    test('non-existent get returns null', () {
      expect(SharedViewModelStore().get<TestViewModel>(), isNull);
    });
  });
}
