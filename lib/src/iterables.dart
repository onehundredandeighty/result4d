import '../result4d.dart';

/// Collection operations for [Iterable] of [Result] instances.
extension ResultIterableExtensions<T, E> on Iterable<Result<T, E>> {
  /// Extract all successful values, returning [Failure] if any element is a failure.
  Result<List<T>, E> allValues() => mapAllValues((result) => result);

  /// Extract only the successful values, ignoring failures.
  List<T> anyValues() {
    final values = <T>[];
    for (final result in this) {
      if (result is Success<T, E>) {
        values.add(result.value);
      }
    }
    return values;
  }

  /// Partition the results into separate lists of successful values and failure reasons.
  ({List<T> successes, List<E> failures}) partition() {
    final successes = <T>[];
    final failures = <E>[];

    for (final result in this) {
      switch (result) {
        case Success(value: final value):
          successes.add(value);
        case Failure(reason: final reason):
          failures.add(reason);
      }
    }

    return (successes: successes, failures: failures);
  }
}

/// Extension methods for [Iterable] to work with [Result].
extension IterableResultExtensions<T> on Iterable<T> {
  /// Fold over the iterable with a [Result]-returning operation.
  Result<U, E> foldResult<U, E>(
    Result<U, E> initial,
    Result<U, E> Function(U acc, T element) operation,
  ) {
    var accumulator = initial;
    for (final element in this) {
      accumulator = accumulator.flatMap((acc) => operation(acc, element));
      if (accumulator is Failure<U, E>) {
        return accumulator;
      }
    }
    return accumulator;
  }

  /// Map each element through a [Result]-returning function, collecting all successful values.
  /// Returns [Failure] on the first failure encountered.
  Result<List<U>, E> mapAllValues<U, E>(Result<U, E> Function(T) f) {
    final results = <U>[];
    for (final element in this) {
      final Result<U, E> result = f(element);
      switch (result) {
        case Success(value: final value):
          results.add(value);
        case Failure(:final reason):
          return Failure(reason);
      }
    }
    return Success<List<U>, E>(results);
  }
}
