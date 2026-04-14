import 'package:flutter_test/flutter_test.dart';
import 'package:easy_flutter/easy_flutter.dart';

class _TestInitializer implements Initializer {
  bool didInit = false;

  @override
  Future<void> init() async {
    didInit = true;
  }
}

class _ThrowingInitializer implements Initializer {
  @override
  Future<void> init() async {
    throw Exception('init failed');
  }
}

void main() {
  group('Initializer tests', () {
    test('implementation can be called and completes', () async {
      final init = _TestInitializer();
      expect(init.didInit, isFalse);
      await init.init();
      expect(init.didInit, isTrue);
    });

    test('init errors propagate', () async {
      final init = _ThrowingInitializer();
      expect(() => init.init(), throwsException);
    });
  });
}
