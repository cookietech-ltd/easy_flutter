import 'package:flutter_test/flutter_test.dart';
import 'package:easy_flutter/easy_flutter.dart';

void main() {
  group('BaseException tests', () {
    test('creates with title and message', () {
      const e = BaseException(title: 'Not Found', message: 'User does not exist');
      expect(e.title, 'Not Found');
      expect(e.message, 'User does not exist');
      expect(e.toString(), contains('Not Found'));
      expect(e.toString(), contains('User does not exist'));
    });

    test('creates with null fields', () {
      const e = BaseException();
      expect(e.title, isNull);
      expect(e.message, isNull);
    });

    test('implements Exception', () {
      const e = BaseException(message: 'test');
      expect(e, isA<Exception>());
    });

    test('can be caught as Exception', () {
      Object? caught;
      try {
        throw const BaseException(title: 'Oops', message: 'Something broke');
      } on Exception catch (e) {
        caught = e;
      }
      expect(caught, isA<BaseException>());
      expect((caught! as BaseException).title, 'Oops');
    });
  });
}
