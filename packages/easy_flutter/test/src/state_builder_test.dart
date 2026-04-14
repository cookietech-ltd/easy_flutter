import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_flutter/easy_flutter.dart';

void main() {
  group('StateBuilder Widget Tests', () {
    testWidgets('StateBuilder rebuilds on state change', (WidgetTester tester) async {
      final state = MutableState<int>(initialValue: 0);

      await tester.pumpWidget(
        MaterialApp(
          home: StateBuilder<int>(
            state: state,
            listener: (val) {},
            builder: (context, value, child) {
              return Text('Value: $value', textDirection: TextDirection.ltr);
            },
          ),
        ),
      );

      expect(find.text('Value: 0'), findsOneWidget);

      state.value = 1;
      await tester.pump();

      expect(find.text('Value: 1'), findsOneWidget);
    });

    testWidgets('StateBuilder cleans up listener callback on dispose', (WidgetTester tester) async {
      final state = MutableState<int>(initialValue: 0);
      int listenerCallCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: StateBuilder<int>(
            state: state,
            listener: (val) => listenerCallCount++,
            builder: (context, value, child) => Text('$value'),
          ),
        ),
      );

      state.value = 1;
      await tester.pump();
      expect(listenerCallCount, 1);

      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.pump();

      listenerCallCount = 0;
      state.value = 2;
      expect(listenerCallCount, 0, reason: 'Listener should be removed on dispose');
    });

    testWidgets('MultiStateBuilder rebuilds on multiple state changes', (WidgetTester tester) async {
      final state1 = MutableState<int>(initialValue: 0);
      final state2 = MutableState<String>(initialValue: "A");

      await tester.pumpWidget(
        MaterialApp(
          home: MultiStateBuilder(
            states: [state1, state2],
            listeners: [(v) {}, (v) {}],
            builder: (context, values, child) {
              return Text('${values[0]} : ${values[1]}', textDirection: TextDirection.ltr);
            },
          ),
        ),
      );

      expect(find.text('0 : A'), findsOneWidget);

      state1.value = 1;
      await tester.pump();
      expect(find.text('1 : A'), findsOneWidget);

      state2.value = "B";
      await tester.pump();
      expect(find.text('1 : B'), findsOneWidget);
    });

    testWidgets('MultiStateBuilder cleans up listeners on dispose', (WidgetTester tester) async {
      final state1 = MutableState<int>(initialValue: 0);
      final state2 = MutableState<int>(initialValue: 0);
      int listener1Calls = 0;
      int listener2Calls = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: MultiStateBuilder(
            states: [state1, state2],
            listeners: [
              (v) => listener1Calls++,
              (v) => listener2Calls++,
            ],
            builder: (context, values, child) => Text('${values[0]},${values[1]}'),
          ),
        ),
      );

      state1.value = 1;
      state2.value = 1;
      await tester.pump();
      expect(listener1Calls, 1);
      expect(listener2Calls, 1);

      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.pump();

      listener1Calls = 0;
      listener2Calls = 0;
      state1.value = 2;
      state2.value = 2;
      expect(listener1Calls, 0, reason: 'Listener 1 should be removed on dispose');
      expect(listener2Calls, 0, reason: 'Listener 2 should be removed on dispose');
    });

    testWidgets('CommandBuilder displays outputs', (WidgetTester tester) async {
      final action = () async {
        await Future<void>.delayed(const Duration(milliseconds: 10));
        return 42;
      };
      final state = CommandState<int>(action: action);

      await tester.pumpWidget(
        MaterialApp(
          home: CommandBuilder<int>(
            state: state,
            onLoading: (context) => const Text('Loading...'),
            onError: (context, error) => Text('Error: $error'),
            builder: (context, value, child) {
              return Text('Result: $value');
            },
          ),
        ),
      );

      expect(find.text('Result: null'), findsOneWidget);

      state.execute();
      await tester.pump();
      expect(find.text('Loading...'), findsOneWidget);

      await tester.pumpAndSettle(const Duration(milliseconds: 20));
      expect(find.text('Result: 42'), findsOneWidget);
    });

    testWidgets('CommandBuilder displays error', (WidgetTester tester) async {
      final action = () async {
        await Future<void>.delayed(const Duration(milliseconds: 10));
        throw Exception('Custom Error');
      };
      final state = CommandState<int>(action: action);

      await tester.pumpWidget(
        MaterialApp(
          home: CommandBuilder<int>(
            state: state,
            onLoading: (context) => const Text('Loading...'),
            onError: (context, error) => Text('Err: $error'),
            builder: (context, value, child) => const Text('OK'),
          ),
        ),
      );

      state.execute();
      await tester.pumpAndSettle();
      expect(find.text('Err: Exception: Custom Error'), findsOneWidget);
    });

    testWidgets('SharedViewModelScope provides access', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SharedViewModelScope<_DummyViewModel>(
            create: () => _DummyViewModel(),
            child: Builder(
              builder: (ctx) {
                final vm = SharedViewModelScope.of<_DummyViewModel>(ctx);
                return Text('Shared: ${vm.isShared}');
              },
            ),
          ),
        ),
      );

      expect(find.text('Shared: true'), findsOneWidget);
    });
  });
}

class _DummyViewModel extends ViewModel {}
