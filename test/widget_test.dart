import 'package:easy_flutter_boilerplate/app/app.dart';
import 'package:easy_flutter_boilerplate/app/di/initializer/di_initializer.dart';
import 'package:easy_flutter_boilerplate/app/di/service_locator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() async {
    await getIt.reset();
    await DiInitializer().init();
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('App renders with router without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    expect(find.byType(App), findsOneWidget);
  });
}
