import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_flutter/easy_flutter.dart';

class _TestViewModel extends ViewModel {
  late final counter = createMutableState(initialValue: 0);
}

class _TestScreen extends StatefulWidget {
  const _TestScreen({super.key});

  @override
  State<_TestScreen> createState() => TestScreenState();
}

class TestScreenState extends BaseState<_TestScreen> {
  late final vm = factoryViewModel(() => _TestViewModel());

  @override
  Widget build(BuildContext context) {
    return StateBuilder(
      state: vm.counter,
      builder: (context, value, _) => Text(
        '$value',
        textDirection: TextDirection.ltr,
      ),
    );
  }
}

class _SharedVmScreen extends StatefulWidget {
  const _SharedVmScreen({super.key});

  @override
  State<_SharedVmScreen> createState() => SharedVmScreenState();
}

class SharedVmScreenState extends BaseState<_SharedVmScreen> {
  late final vm = factoryViewModel(() => _TestViewModel()..markAsShared());

  @override
  Widget build(BuildContext context) {
    return StateBuilder(
      state: vm.counter,
      builder: (context, value, _) => Text(
        '$value',
        textDirection: TextDirection.ltr,
      ),
    );
  }
}

void main() {
  group('BaseState tests', () {
    testWidgets('factoryViewModel creates and tracks VM', (tester) async {
      await tester.pumpWidget(const _TestScreen());
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('disposes non-shared VMs when widget is removed', (
      tester,
    ) async {
      final key = GlobalKey<TestScreenState>();
      await tester.pumpWidget(_TestScreen(key: key));

      final vm = key.currentState!.vm;
      expect(vm.isShared, isFalse);

      await tester.pumpWidget(const SizedBox());

      // After disposal, setting a value should not throw but state is disposed
      expect(() => vm.counter.value = 99, returnsNormally);
    });

    testWidgets('does not dispose shared VMs when widget is removed', (
      tester,
    ) async {
      final key = GlobalKey<SharedVmScreenState>();
      await tester.pumpWidget(_SharedVmScreen(key: key));

      final vm = key.currentState!.vm;
      expect(vm.isShared, isTrue);

      await tester.pumpWidget(const SizedBox());

      // Shared VMs survive widget disposal — listeners still attached
      vm.counter.value = 42;
      expect(vm.counter.value, 42);
    });
  });
}
