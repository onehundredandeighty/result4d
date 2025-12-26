library result4d;

export 'src/flat_zip.dart';
export 'src/iterables.dart';
export 'src/zip.dart';

/// A result of a computation that can succeed or fail.
sealed class Result<T, E> {
  const Result();

  /// Map a function over the value of a successful [Result].
  Result<U, E> map<U>(U Function(T) f);

  /// Flat-map a function over the value of a successful [Result].
  Result<U, E> flatMap<U>(Result<U, E> Function(T) f);

  /// Map a function over the reason of an unsuccessful [Result].
  Result<T, F> mapFailure<F>(F Function(E) f);

  /// Flat-map a function over the reason of an unsuccessful [Result].
  Result<T, F> flatMapFailure<F>(Result<T, F> Function(E) f);

  /// Map a function, [f], over the value of a successful [Result]
  /// and a function, [g], over the reason of an unsuccessful [Result].
  Result<U, F> bimap<U, F>(U Function(T) f, F Function(E) g) =>
      map(f).mapFailure(g);

  /// Fold a function, [f], over the value of a successful [Result]
  /// and a function, [g], over the reason of an unsuccessful [Result]
  /// where both functions result in a value of the same type.
  U fold<U>(U Function(T) f, U Function(E) g) => bimap(f, g).get();

  /// Perform a side effect with the success value.
  Result<T, E> peek(void Function(T) f);

  /// Perform a side effect with the failure reason.
  Result<T, E> peekFailure(void Function(E) f);

  /// Returns the success value, or `null` if the [Result] is a failure.
  T? valueOrNull();

  /// Returns the failure reason, or `null` if the [Result] is a success.
  E? failureOrNull();
}

/// Represents a successful result with a value of type [T].
final class Success<T, E> extends Result<T, E> {
  final T value;

  const Success(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Success($value)';

  @override
  Result<U, E> map<U>(U Function(T) f) => Success<U, E>(f(value));

  @override
  Result<U, E> flatMap<U>(Result<U, E> Function(T) f) => f(value);

  @override
  Result<T, F> mapFailure<F>(F Function(E) f) => Success<T, F>(value);

  @override
  Result<T, F> flatMapFailure<F>(Result<T, F> Function(E) f) =>
      Success<T, F>(value);

  @override
  Result<T, E> peek(void Function(T) f) {
    f(value);
    return this;
  }

  @override
  Result<T, E> peekFailure(void Function(E) f) => this;

  @override
  T? valueOrNull() => value;

  @override
  E? failureOrNull() => null;

  /// Unwrap a successful result or throw an exception.
  T orThrow() => value;

  /// Unwrap a successful result or convert an error into an exception and throw it.
  T orThrowWith(Object Function(E) exceptionFactory) => value;

  /// Unwrap a [Result], by returning the success value or calling [block] on failure to abort.
  T onFailure(Never Function(Failure<T, E>) block) => value;

  /// Unwrap a [Result] by returning the success value or calling [errorToValue]
  /// to map the failure reason to a plain value.
  S recover<S>(S Function(E) errorToValue) => value as S;

  /// Retain the result if the test passes, otherwise return a failure.
  Result<T, E> retainIf(bool Function(T) test, E Function() otherwise) =>
      test(value) ? this : Failure<T, E>(otherwise());

  /// Reject the result if the test passes, otherwise retain it.
  Result<T, E> rejectIf(bool Function(T) test, E Function() error) =>
      retainIf((value) => !test(value), error);

  /// Retain the result if the condition is true, otherwise return a failure.
  Result<T, E> retainIfCondition(bool condition, E Function() otherwise) =>
      condition ? this : Failure<T, E>(otherwise());

  /// Reject the result if the condition is true, otherwise retain it.
  Result<T, E> rejectIfCondition(bool condition, E Function() error) =>
      retainIfCondition(!condition, error);
}

/// Represents a failed result with an error of type [E].
final class Failure<T, E> extends Result<T, E> {
  final E reason;

  const Failure(this.reason);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure &&
          runtimeType == other.runtimeType &&
          reason == other.reason;

  @override
  int get hashCode => reason.hashCode;

  @override
  String toString() => 'Failure($reason)';

  @override
  Result<U, E> map<U>(U Function(T) f) => Failure<U, E>(reason);

  @override
  Result<U, E> flatMap<U>(Result<U, E> Function(T) f) => Failure<U, E>(reason);

  @override
  Result<T, F> mapFailure<F>(F Function(E) f) => Failure<T, F>(f(reason));

  @override
  Result<T, F> flatMapFailure<F>(Result<T, F> Function(E) f) => f(reason);

  @override
  Result<T, E> peek(void Function(T) f) => this;

  @override
  Result<T, E> peekFailure(void Function(E) f) {
    f(reason);
    return this;
  }

  @override
  T? valueOrNull() => null;

  @override
  E? failureOrNull() => reason;

  /// Unwrap a successful result or throw an exception.
  T orThrow() => throw reason as Object;

  /// Unwrap a successful result or convert an error into an exception and throw it.
  T orThrowWith(Object Function(E) exceptionFactory) =>
      throw exceptionFactory(reason);

  /// Unwrap a [Result], by returning the success value or calling [block] on failure to abort.
  T onFailure(Never Function(Failure<T, E>) block) => block(this);

  /// Unwrap a [Result] by returning the success value or calling [errorToValue]
  /// to map the failure reason to a plain value.
  S recover<S>(S Function(E) errorToValue) => errorToValue(reason);

  /// Retain the result if the test passes, otherwise return a failure.
  Result<T, E> retainIf(bool Function(T) test, E Function() otherwise) => this;

  /// Reject the result if the test passes, otherwise retain it.
  Result<T, E> rejectIf(bool Function(T) test, E Function() error) => this;

  /// Retain the result if the condition is true, otherwise return a failure.
  Result<T, E> retainIfCondition(bool condition, E Function() otherwise) =>
      this;

  /// Reject the result if the condition is true, otherwise retain it.
  Result<T, E> rejectIfCondition(bool condition, E Function() error) => this;
}

/// Operations for [Result] instances where both success and failure have the same type.
extension ResultSameType<T> on Result<T, T> {
  /// Unwrap a [Result] in which both the success and failure values have the same type.
  T get() => switch (this) {
    Success(value: final value) => value,
    Failure(reason: final reason) => reason,
  };
}

/// Extension methods for converting values to [Result] instances.
extension ResultExtensions<T> on T {
  /// Convert this value to a successful [Result].
  Success<T, Never> asSuccess() => Success(this);
}

/// Extension methods for converting errors to [Result] instances.
extension FailureExtensions<E> on E {
  /// Convert this error to a failed [Result].
  Failure<Never, E> asFailure() => Failure(this);
}

/// A convenience constant for beginning a chain of operations.
final begin = {}.asSuccess();

/// Call a function and wrap the result in a [Result],
/// catching any [Exception] and returning it as [Failure] value.
Result<T, Exception> resultFrom<T>(T Function() block) {
  try {
    return Success<T, Exception>(block());
  } catch (e) {
    if (e is Exception) {
      return Failure<T, Exception>(e);
    } else {
      return Failure<T, Exception>(Exception(e.toString()));
    }
  }
}

/// Extension methods for nullable types to convert to [Result].
extension NullableExtensions<T extends Object> on T? {
  /// Convert a nullable value to a [Result], using [failureDescription] as the failure reason
  /// if the value is `null`.
  Result<T, E> asResultOr<E>(E Function() failureDescription) =>
      this != null ? Success<T, E>(this!) : Failure<T, E>(failureDescription());
}

/// Extension methods for [Result] with nullable success values.
extension ResultNullableExtensions<T extends Object, E> on Result<T?, E> {
  /// Convert a [Success] of a nullable value to a [Success] of a non-null value or a [Failure],
  /// using [failureDescription] as the failure reason, if the value is `null`.
  Result<T, E> filterNotNull(E Function() failureDescription) =>
      flatMap((value) => value.asResultOr(failureDescription));

  /// Convert a [Success] of a nullable value to a [Success] of a non-null value,
  /// or calling [block] to abort if the value is `null`.
  Result<T, E> onNull(Never Function() block) =>
      flatMap((value) => value != null ? Success<T, E>(value) : block());
}
