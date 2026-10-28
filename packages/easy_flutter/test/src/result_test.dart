import 'package:flutter_test/flutter_test.dart';
import 'package:easy_flutter/src/result.dart';

void main() {
  group('Result tests', () {
    test('Result.ok returns correct value', () {
      const result = Result<String>.ok('success');
      expect(result is Ok, isTrue);
      if (result is Ok<String>) {
        expect(result.value, 'success');
        expect(result.toString(), 'Result<String>.ok(success)');
      }
    });

    test('Result.error returns Exception', () {
      final exception = Exception('error');
      final result = Result<String>.error(exception);
      expect(result is Error, isTrue);
      if (result is Error<String>) {
        expect(result.error, exception);
        expect(result.toString().contains('Exception: error'), isTrue);
      }
    });

    test('Result.when calls onSuccess when Ok', () {
      const result = Result<String>.ok('success');
      bool successCalled = false;
      bool errorCalled = false;

      final res = result.when(
        onSuccess: (value) {
          successCalled = true;
          expect(value, 'success');
          return 'done';
        },
        onError: (e, s) {
          errorCalled = true;
          return 'fail';
        },
      );
      expect(successCalled, isTrue);
      expect(errorCalled, isFalse);
      expect(res, 'done');
    });

    test('Result.when calls onError when Error', () {
      final exception = Exception('error');
      final result = Result<String>.error(exception);
      bool successCalled = false;
      bool errorCalled = false;

      final res = result.when(
        onSuccess: (value) {
          successCalled = true;
          return 'done';
        },
        onError: (e, s) {
          errorCalled = true;
          expect(e, exception);
          return 'fail';
        },
      );
      expect(successCalled, isFalse);
      expect(errorCalled, isTrue);
      expect(res, 'fail');
    });

    test('Result.map transforms Ok value', () {
      const result = Result<int>.ok(1);
      final mapped = result.map((value) => value.toString());
      expect(mapped is Ok<String>, isTrue);
      if (mapped is Ok<String>) {
        expect(mapped.value, '1');
      }
    });

    test('Result.map retains Error state', () {
      final exception = Exception('error');
      final result = Result<int>.error(exception);
      final mapped = result.map((value) => value.toString());
      expect(mapped is Error<String>, isTrue);
      if (mapped is Error<String>) {
        expect(mapped.error, exception);
      }
    });

    test('Result hashing and equality', () {
      const result1 = Result<String>.ok('a');
      const result2 = Result<String>.ok('a');
      const result3 = Result<String>.ok('b');

      final ex = Exception('e');
      final err1 = Result<String>.error(ex);
      final err2 = Result<String>.error(ex);
      
      expect(result1 == result2, isTrue);
      expect(result1.hashCode == result2.hashCode, isTrue);
      expect(result1 == result3, isFalse);
      
      expect(err1 == err2, isTrue);
      expect(err1.hashCode == err2.hashCode, isTrue);
    });
  });
}
