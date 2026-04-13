import 'package:flutter_test/flutter_test.dart';
import 'package:easy_flutter/easy_flutter.dart';

class AddUseCase extends UseCase<int, int> {
  final int addend;
  AddUseCase(this.addend);

  @override
  Future<Result<int>> call(int params) async {
    return Result.ok(params + addend);
  }
}

class FailingUseCase extends UseCase<void, String> {
  @override
  Future<Result<String>> call(void params) async {
    return Result.error(Exception('deliberate failure'));
  }
}

class GetTimestampUseCase extends NoParamUseCase<int> {
  @override
  Future<Result<int>> call() async {
    return const Result.ok(1234567890);
  }
}

void main() {
  group('UseCase tests', () {
    test('UseCase returns Ok result', () async {
      final useCase = AddUseCase(10);
      final result = await useCase(5);
      result.when(
        onSuccess: (value) => expect(value, 15),
        onError: (_, __) => fail('Should not error'),
      );
    });

    test('UseCase returns Error result', () async {
      final useCase = FailingUseCase();
      final result = await useCase(null);
      result.when(
        onSuccess: (_) => fail('Should not succeed'),
        onError: (e, _) => expect(e.toString(), contains('deliberate failure')),
      );
    });

    test('NoParamUseCase works', () async {
      final useCase = GetTimestampUseCase();
      final result = await useCase();
      result.when(
        onSuccess: (value) => expect(value, 1234567890),
        onError: (_, __) => fail('Should not error'),
      );
    });
  });
}
