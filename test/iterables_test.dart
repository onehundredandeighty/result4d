import 'package:test/test.dart';
import 'package:result4d/result4d.dart';

void main() {
  group('Iterable extensions', () {
    test('allValues with all successes', () {
      final results = [1.asSuccess(), 2.asSuccess(), 3.asSuccess()];
      final allValues = results.allValues();
      expect(allValues.valueOrNull(), equals([1, 2, 3]));
    });

    test('allValues with one failure', () {
      final List<Result<dynamic, dynamic>> results = [
        1.asSuccess(),
        'error'.asFailure(),
        3.asSuccess(),
      ];
      final allValues = results.allValues();
      expect(allValues.failureOrNull(), equals('error'));
    });

    test('anyValues with mixed results', () {
      final List<Result<dynamic, dynamic>> results = [
        1.asSuccess(),
        'error'.asFailure(),
        3.asSuccess(),
        'another'.asFailure(),
      ];
      final values = results.anyValues();
      expect(values, equals([1, 3]));
    });

    test('anyValues with no successes', () {
      final results = ['error1'.asFailure(), 'error2'.asFailure()];
      final values = results.anyValues();
      expect(values, isEmpty);
    });

    test('partition with mixed results', () {
      final List<Result<dynamic, dynamic>> results = [
        1.asSuccess(),
        'error1'.asFailure(),
        2.asSuccess(),
        'error2'.asFailure(),
      ];
      final partitioned = results.partition();
      expect(partitioned.successes, equals([1, 2]));
      expect(partitioned.failures, equals(['error1', 'error2']));
    });

    test('partition with all successes', () {
      final List<Result<int, String>> results = [
        1.asSuccess(),
        2.asSuccess(),
        3.asSuccess(),
      ];
      final partitioned = results.partition();
      expect(partitioned.successes, equals([1, 2, 3]));
      expect(partitioned.failures, isEmpty);
    });

    test('partition with all failures', () {
      final results = ['error1'.asFailure(), 'error2'.asFailure()];
      final partitioned = results.partition();
      expect(partitioned.successes, isEmpty);
      expect(partitioned.failures, equals(['error1', 'error2']));
    });

    test('foldResult with successful operations', () {
      final numbers = [1, 2, 3, 4];
      final result = numbers.foldResult<int, String>(
        Success<int, String>(0),
        (acc, element) => Success<int, String>(acc + element),
      );
      expect(result.valueOrNull(), equals(10));
    });

    test('foldResult with failure', () {
      final numbers = [1, 2, 3, 4];
      final Result<int, String> result = numbers.foldResult<int, String>(
        Success<int, String>(0),
        (acc, element) =>
            element == 3
                ? Failure<int, String>('error at 3')
                : Success<int, String>(acc + element),
      );
      expect(result.failureOrNull(), equals('error at 3'));
    });

    test('mapAllValues with all successes', () {
      final numbers = [1, 2, 3];
      final result = numbers.mapAllValues((x) => (x * 2).asSuccess());
      expect(result.valueOrNull(), equals([2, 4, 6]));
    });

    test('mapAllValues with one failure', () {
      final numbers = [1, 2, 3];
      final result = numbers.mapAllValues(
        (x) => x == 2 ? 'error'.asFailure() : (x * 2).asSuccess(),
      );
      expect(result.failureOrNull(), equals('error'));
    });

    test('mapAllValues with empty list', () {
      final numbers = <int>[];
      final result = numbers.mapAllValues((x) => (x * 2).asSuccess());
      expect(result.valueOrNull(), equals(<int>[]));
    });
  });
}
