import 'package:test/test.dart';
import 'package:result4d/result4d.dart';

void main() {
  group('Zip operations', () {
    test('zip with Success', () {
      final Result<int, Never> result = zip(Success(5), (x) => x * 2);
      expect(result.valueOrNull(), equals(10));
    });

    test('zip with Failure', () {
      final Result<int, String> result = zip(Failure('error'), (x) => x * 2);
      expect(result.failureOrNull(), equals('error'));
    });

    test('zip2 with two Successes', () {
      final Result<int, Never> result = zip2(
        Success(3),
        Success(4),
        (a, b) => a + b,
      );
      expect(result.valueOrNull(), equals(7));
    });

    test('zip2 with first Failure', () {
      final Result<int, String> result = zip2(
        Failure<int, String>('error1'),
        Success(4),
        (a, b) => a + b,
      );
      expect(result.failureOrNull(), equals('error1'));
    });

    test('zip2 with second Failure', () {
      final result = zip2(Success(3), Failure('error2'), (a, b) => a + b);
      expect(result.failureOrNull(), equals('error2'));
    });

    test('zip2 with both Failures returns first', () {
      final result = zip2(
        Failure('error1'),
        Failure('error2'),
        (a, b) => a + b,
      );
      expect(result.failureOrNull(), equals('error1'));
    });

    test('zip3 with all Successes', () {
      final result = zip3(
        Success(1),
        Success(2),
        Success(3),
        (a, b, c) => a + b + c,
      );
      expect(result.valueOrNull(), equals(6));
    });

    test('zip3 with middle Failure', () {
      final Result<int, String> result = zip3(
        Success(1),
        Failure<int, String>('error'),
        Success(3),
        (a, b, c) => a + b + c,
      );
      expect(result.failureOrNull(), equals('error'));
    });

    test('zip4 with all Successes', () {
      final result = zip4(
        Success(1),
        Success(2),
        Success(3),
        Success(4),
        (a, b, c, d) => a + b + c + d,
      );
      expect(result.valueOrNull(), equals(10));
    });

    test('zip4 with last Failure', () {
      final result = zip4(
        Success(1),
        Success(2),
        Success(3),
        Failure('error'),
        (a, b, c, d) => a + b + c + d,
      );
      expect(result.failureOrNull(), equals('error'));
    });

    test('zip5 with all Successes', () {
      final result = zip5(
        Success(1),
        Success(2),
        Success(3),
        Success(4),
        Success(5),
        (a, b, c, d, e) => a + b + c + d + e,
      );
      expect(result.valueOrNull(), equals(15));
    });

    test('zip5 with first Failure', () {
      final Result<int, String> result = zip5(
        Failure<int, String>('error'),
        Success(2),
        Success(3),
        Success(4),
        Success(5),
        (a, b, c, d, e) => a + b + c + d + e,
      );
      expect(result.failureOrNull(), equals('error'));
    });

    test('zip6 with all Successes', () {
      final result = zip6(
        Success(1),
        Success(2),
        Success(3),
        Success(4),
        Success(5),
        Success(6),
        (a, b, c, d, e, f) => a + b + c + d + e + f,
      );
      expect(result.valueOrNull(), equals(21));
    });

    test('zip6 with multiple Failures returns first encountered', () {
      final Result<int, String> result = zip6(
        Success(1),
        Failure<int, String>('error1'),
        Success(3),
        Failure<int, String>('error2'),
        Success(5),
        Success(6),
        (a, b, c, d, e, f) => a + b + c + d + e + f,
      );
      expect(result.failureOrNull(), equals('error1'));
    });

    test('zip functions compose properly', () {
      final step1 = zip2(Success(2), Success(3), (a, b) => a * b);
      final step2 = zip2(step1, Success(4), (product, c) => product + c);
      expect(step2.valueOrNull(), equals(10));
    });
  });
}
