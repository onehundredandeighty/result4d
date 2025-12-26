import 'package:test/test.dart';
import 'package:result4d/result4d.dart';

void main() {
  group('Result basic functionality', () {
    test('Success should store value', () {
      final result = Success(42);
      expect(result.value, equals(42));
      expect(result.toString(), equals('Success(42)'));
    });

    test('Failure should store reason', () {
      final result = Failure('error');
      expect(result.reason, equals('error'));
      expect(result.toString(), equals('Failure(error)'));
    });

    test('Success equality', () {
      expect(Success(42), equals(Success(42)));
      expect(Success(42), isNot(equals(Success(43))));
    });

    test('Failure equality', () {
      expect(Failure('error'), equals(Failure('error')));
      expect(Failure('error'), isNot(equals(Failure('other'))));
    });
  });

  group('Extension methods', () {
    test('asSuccess should create Success', () {
      final result = 42.asSuccess();
      expect(result, isA<Success>());
      expect(result.value, equals(42));
    });

    test('asFailure should create Failure', () {
      final result = 'error'.asFailure();
      expect(result, isA<Failure>());
      expect(result.reason, equals('error'));
    });
  });

  group('Core operations', () {
    test('map on Success', () {
      final result = Success(5).map((x) => x * 2);
      expect(result, isA<Success>());
      expect(result.valueOrNull(), equals(10));
    });

    test('map on Failure', () {
      final result = Failure('error').map((x) => x * 2);
      expect(result, isA<Failure>());
      expect(result.failureOrNull(), equals('error'));
    });

    test('flatMap on Success', () {
      final result = Success(5).flatMap((x) => Success(x * 2));
      expect(result.valueOrNull(), equals(10));
    });

    test('flatMap on Failure', () {
      final result = Failure('error').flatMap((x) => Success(x * 2));
      expect(result.failureOrNull(), equals('error'));
    });

    test('flatMap Success to Failure', () {
      final result = Success(5).flatMap((x) => Failure('new error'));
      expect(result.failureOrNull(), equals('new error'));
    });

    test('fold on Success', () {
      final result = Success(5).fold((x) => 'Value: $x', (e) => 'Error: $e');
      expect(result, equals('Value: 5'));
    });

    test('fold on Failure', () {
      final result = Failure(
        'error',
      ).fold((x) => 'Value: $x', (e) => 'Error: $e');
      expect(result, equals('Error: error'));
    });

    test('bimap on Success', () {
      final result = Success(5).bimap((x) => x * 2, (e) => 'Error: $e');
      expect(result.valueOrNull(), equals(10));
    });

    test('bimap on Failure', () {
      final result = Failure('error').bimap((x) => x * 2, (e) => 'Error: $e');
      expect(result.failureOrNull(), equals('Error: error'));
    });
  });

  group('Peek operations', () {
    test('peek on Success', () {
      var sideEffect = 0;
      final result = Success(5).peek((x) => sideEffect = x);
      expect(result.valueOrNull(), equals(5));
      expect(sideEffect, equals(5));
    });

    test('peek on Failure', () {
      var sideEffect = 0;
      final result = Failure('error').peek((x) => sideEffect = x);
      expect(result.failureOrNull(), equals('error'));
      expect(sideEffect, equals(0));
    });

    test('peekFailure on Success', () {
      var sideEffect = '';
      final result = Success(5).peekFailure((e) => sideEffect = e);
      expect(result.valueOrNull(), equals(5));
      expect(sideEffect, equals(''));
    });

    test('peekFailure on Failure', () {
      var sideEffect = '';
      final result = Failure('error').peekFailure((e) => sideEffect = e);
      expect(result.failureOrNull(), equals('error'));
      expect(sideEffect, equals('error'));
    });
  });

  group('Error handling', () {
    test('resultFrom with successful operation', () {
      final result = resultFrom(() => 42);
      expect(result.valueOrNull(), equals(42));
    });

    test('resultFrom with exception', () {
      final result = resultFrom(() => throw Exception('test error'));
      expect(result.failureOrNull(), isA<Exception>());
    });

    test('orThrow on Success', () {
      expect(() => Success(42).orThrow(), returnsNormally);
      expect(Success(42).orThrow(), equals(42));
    });

    test('orThrow on Failure', () {
      expect(() => Failure('error').orThrow(), throwsA('error'));
    });

    test('orThrowWith on Success', () {
      expect(Success(42).orThrowWith((e) => Exception(e)), equals(42));
    });

    test('orThrowWith on Failure', () {
      expect(
        () => Failure('error').orThrowWith((e) => Exception(e)),
        throwsA(isA<Exception>()),
      );
    });

    test('recover on Success', () {
      final result = Success(42).recover((e) => 0);
      expect(result, equals(42));
    });

    test('recover on Failure', () {
      final result = Failure('error').recover((e) => 0);
      expect(result, equals(0));
    });
  });

  group('Nullable integration', () {
    test('valueOrNull on Success', () {
      expect(Success(42).valueOrNull(), equals(42));
    });

    test('valueOrNull on Failure', () {
      expect(Failure('error').valueOrNull(), isNull);
    });

    test('failureOrNull on Success', () {
      expect(Success(42).failureOrNull(), isNull);
    });

    test('failureOrNull on Failure', () {
      expect(Failure('error').failureOrNull(), equals('error'));
    });

    test('asResultOr with non-null value', () {
      final result = 42.asResultOr(() => 'error');
      expect(result.valueOrNull(), equals(42));
    });

    test('asResultOr with null value', () {
      final int? nullValue = null;
      final result = nullValue.asResultOr(() => 'error');
      expect(result.failureOrNull(), equals('error'));
    });

    test('filterNotNull with non-null Success', () {
      final result = Success(42).filterNotNull(() => 'error');
      expect(result.valueOrNull(), equals(42));
    });

    test('filterNotNull with null Success', () {
      final result = Success(null).filterNotNull(() => 'error');
      expect(result.failureOrNull(), equals('error'));
    });
  });

  group('Validation utilities', () {
    test('retainIf with passing test', () {
      final result = Success(5).retainIf((x) => x > 3, () => 'too small');
      expect(result.valueOrNull(), equals(5));
    });

    test('retainIf with failing test', () {
      final result = Success(2).retainIf((x) => x > 3, () => 'too small');
      expect(result.failureOrNull(), equals('too small'));
    });

    test('rejectIf with failing test', () {
      final result = Success(2).rejectIf((x) => x > 3, () => 'too big');
      expect(result.valueOrNull(), equals(2));
    });

    test('rejectIf with passing test', () {
      final result = Success(5).rejectIf((x) => x > 3, () => 'too big');
      expect(result.failureOrNull(), equals('too big'));
    });

    test('retainIfCondition with true condition', () {
      final result = Success(
        5,
      ).retainIfCondition(true, () => 'condition failed');
      expect(result.valueOrNull(), equals(5));
    });

    test('retainIfCondition with false condition', () {
      final result = Success(
        5,
      ).retainIfCondition(false, () => 'condition failed');
      expect(result.failureOrNull(), equals('condition failed'));
    });
  });
}
