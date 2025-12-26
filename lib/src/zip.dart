import '../result4d.dart';

/// Zip function for combining one [Result] with a transform function.
Result<U, E> zip<T1, U, E>(Result<T1, E> r1, U Function(T1) transform) {
  return r1.map(transform);
}

/// Zip function for combining two [Result] instances.
Result<U, E> zip2<T1, T2, U, E>(
  Result<T1, E> r1,
  Result<T2, E> r2,
  U Function(T1, T2) transform,
) {
  return r1.flatMap((v1) => r2.map((v2) => transform(v1, v2)));
}

/// Zip function for combining three [Result] instances.
Result<U, E> zip3<T1, T2, T3, U, E>(
  Result<T1, E> r1,
  Result<T2, E> r2,
  Result<T3, E> r3,
  U Function(T1, T2, T3) transform,
) {
  return r1.flatMap(
    (v1) => r2.flatMap((v2) => r3.map((v3) => transform(v1, v2, v3))),
  );
}

/// Zip function for combining four [Result] instances.
Result<U, E> zip4<T1, T2, T3, T4, U, E>(
  Result<T1, E> r1,
  Result<T2, E> r2,
  Result<T3, E> r3,
  Result<T4, E> r4,
  U Function(T1, T2, T3, T4) transform,
) {
  return r1.flatMap(
    (v1) => r2.flatMap(
      (v2) => r3.flatMap((v3) => r4.map((v4) => transform(v1, v2, v3, v4))),
    ),
  );
}

/// Zip function for combining five [Result] instances.
Result<U, E> zip5<T1, T2, T3, T4, T5, U, E>(
  Result<T1, E> r1,
  Result<T2, E> r2,
  Result<T3, E> r3,
  Result<T4, E> r4,
  Result<T5, E> r5,
  U Function(T1, T2, T3, T4, T5) transform,
) {
  return r1.flatMap(
    (v1) => r2.flatMap(
      (v2) => r3.flatMap(
        (v3) =>
            r4.flatMap((v4) => r5.map((v5) => transform(v1, v2, v3, v4, v5))),
      ),
    ),
  );
}

/// Zip function for combining six [Result] instances.
Result<U, E> zip6<T1, T2, T3, T4, T5, T6, U, E>(
  Result<T1, E> r1,
  Result<T2, E> r2,
  Result<T3, E> r3,
  Result<T4, E> r4,
  Result<T5, E> r5,
  Result<T6, E> r6,
  U Function(T1, T2, T3, T4, T5, T6) transform,
) {
  return r1.flatMap(
    (v1) => r2.flatMap(
      (v2) => r3.flatMap(
        (v3) => r4.flatMap(
          (v4) => r5.flatMap(
            (v5) => r6.map((v6) => transform(v1, v2, v3, v4, v5, v6)),
          ),
        ),
      ),
    ),
  );
}
