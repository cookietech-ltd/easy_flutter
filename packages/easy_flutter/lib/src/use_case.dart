import 'result.dart';

/// Base class for use cases that require input parameters.
///
/// Encapsulates a single unit of business logic in the domain layer.
abstract class UseCase<Input, Output> {
  const UseCase();

  Future<Result<Output>> call(Input params);
}

/// Base class for use cases that do not require input parameters.
abstract class NoParamUseCase<Output> {
  const NoParamUseCase();

  Future<Result<Output>> call();
}
