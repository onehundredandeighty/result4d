import '../result4d.dart';

/// FlatZip function for combining one [Result] with a Result-returning transform function.
Result<U, E> flatZip<T1, U, E>(
  Result<T1, E> r1,
  Result<U, E> Function(T1) transform,
) {
  return r1.flatMap(transform);
}

/// FlatZip function for combining two [Result] instances with a Result-returning transform.
Result<U, E> flatZip2<T1, T2, U, E>(
  Result<T1, E> r1,
  Result<T2, E> r2,
  Result<U, E> Function(T1, T2) transform,
) {
  return r1.flatMap((v1) => r2.flatMap((v2) => transform(v1, v2)));
}

/// FlatZip function for combining three [Result] instances with a Result-returning transform.
Result<U, E> flatZip3<T1, T2, T3, U, E>(
  Result<T1, E> r1,
  Result<T2, E> r2,
  Result<T3, E> r3,
  Result<U, E> Function(T1, T2, T3) transform,
) {
  return r1.flatMap(
    (v1) => r2.flatMap((v2) => r3.flatMap((v3) => transform(v1, v2, v3))),
  );
}

/// FlatZip function for combining four [Result] instances with a Result-returning transform.
Result<U, E> flatZip4<T1, T2, T3, T4, U, E>(
  Result<T1, E> r1,
  Result<T2, E> r2,
  Result<T3, E> r3,
  Result<T4, E> r4,
  Result<U, E> Function(T1, T2, T3, T4) transform,
) {
  return r1.flatMap(
    (v1) => r2.flatMap(
      (v2) => r3.flatMap((v3) => r4.flatMap((v4) => transform(v1, v2, v3, v4))),
    ),
  );
}

/// FlatZip function for combining five [Result] instances with a Result-returning transform.
Result<U, E> flatZip5<T1, T2, T3, T4, T5, U, E>(
  Result<T1, E> r1,
  Result<T2, E> r2,
  Result<T3, E> r3,
  Result<T4, E> r4,
  Result<T5, E> r5,
  Result<U, E> Function(T1, T2, T3, T4, T5) transform,
) {
  return r1.flatMap(
    (v1) => r2.flatMap(
      (v2) => r3.flatMap(
        (v3) => r4.flatMap(
          (v4) => r5.flatMap((v5) => transform(v1, v2, v3, v4, v5)),
        ),
      ),
    ),
  );
}

/// FlatZip function for combining six [Result] instances with a Result-returning transform.
Result<U, E> flatZip6<T1, T2, T3, T4, T5, T6, U, E>(
  Result<T1, E> r1,
  Result<T2, E> r2,
  Result<T3, E> r3,
  Result<T4, E> r4,
  Result<T5, E> r5,
  Result<T6, E> r6,
  Result<U, E> Function(T1, T2, T3, T4, T5, T6) transform,
) {
  return r1.flatMap(
    (v1) => r2.flatMap(
      (v2) => r3.flatMap(
        (v3) => r4.flatMap(
          (v4) => r5.flatMap(
            (v5) => r6.flatMap((v6) => transform(v1, v2, v3, v4, v5, v6)),
          ),
        ),
      ),
    ),
  );
}
