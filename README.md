# Result4D

A functional Result type for Dart, inspired by the Kotlin [result4k](https://github.com/fork-handles/forkhandles/tree/trunk/result4k) library.

## Overview

`Result<T, E>` represents the result of a computation that can either succeed with a value of type `T` or fail with an error of type `E`. This pattern helps you write more robust code by making error handling explicit and composable.

## Key Features

- **Type-safe error handling**: No more forgotten null checks or uncaught exceptions
- **Composable operations**: Chain operations with `map`, `flatMap`, `fold`, and more
- **Exhaustive pattern matching**: Leverages Dart's sealed classes for complete case coverage
- **Rich API**: Includes utilities for validation, nullable handling, and collection processing
- **Zero dependencies**: Lightweight and focused

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  result4d: ^0.0.0
```

Then run:

```bash
dart pub get
```

## Basic Usage

### Creating Results

```dart
import 'package:result4d/result4d.dart';

// Create success and failure results
final success = Success<int, String>(42);
final failure = Failure<int, String>('Something went wrong');

// Or use extension methods
final success2 = 42.asSuccess();
final failure2 = 'Error message'.asFailure();

// Wrap potentially throwing operations
final result = resultFrom(() => int.parse('42'));
```

### Pattern Matching

```dart
final result = getResult();
final message = switch (result) {
  Success(value: final value) => 'Got value: $value',
  Failure(reason: final error) => 'Error: $error',
};
```

### Core Operations

```dart
// Transform success values
final doubled = result.map((x) => x * 2);

// Chain operations that might fail
final processed = result.flatMap((x) => processValue(x));

// Handle both success and failure cases
final output = result.fold(
  (value) => 'Success: $value',
  (error) => 'Error: $error',
);

// Transform error types
final converted = result.mapFailure((err) => 'Converted: $err');
```

### Safe Value Extraction

```dart
// Get value or null
final value = result.valueOrNull(); // int?

// Get value or throw
final value = result.orThrow();

// Get value or provide default
final value = result.recover((error) => defaultValue);

// Unwrap with custom error handling
final value = result.orThrowWith((err) => CustomException(err));
```

### Validation

```dart
// Conditional validation
final validated = result
  .retainIf((x) => x > 0, () => 'Must be positive')
  .rejectIf((x) => x > 100, () => 'Must be <= 100');

// Null handling
final nonNull = nullableValue.asResultOr(() => 'Value was null');
final filtered = Success<int?>(42).filterNotNull(() => 'Was null');
```

### Collection Operations

```dart
final results = [Success<int, String>(1), Success(2), Success(3)];

// Extract all values (fails if any failure)
final allValues = results.allValues(); // Result<List<int>, String>

// Extract only successful values
final someValues = results.anyValues(); // List<int>

// Separate successes and failures
final partitioned = results.partition();
print(partitioned.successes); // [1, 2, 3]
print(partitioned.failures);  // []

// Process with early termination on failure
final processed = [1, 2, 3].mapAllValues((x) => 
  x.isEven ? Failure('Even numbers not allowed') : Success(x * 2)
);
```

### Combining Results

```dart
// Zip multiple results together
final combined = zip2(
  getUserId(),
  getUserName(), 
  (id, name) => User(id, name)
);

// For operations that return Results
final chained = flatZip2(
  getUser(),
  getPermissions(),
  (user, perms) => validateAccess(user, perms)
);
```

## Advanced Usage

### Custom Error Types

```dart
sealed class AppError {}
class NetworkError extends AppError { final String message; NetworkError(this.message); }
class ValidationError extends AppError { final String field; ValidationError(this.field); }

Result<User, AppError> fetchUser(String id) {
  if (id.isEmpty) return Failure(ValidationError('id'));
  
  return resultFrom(() => networkCall(id))
    .mapFailure((e) => NetworkError(e.toString()));
}
```

### Async Results

```dart
Future<Result<String, String>> fetchData() async {
  try {
    final response = await http.get(uri);
    return Success(response.body);
  } catch (e) {
    return Failure('Network error: $e');
  }
}

// Chain async operations
Future<Result<ProcessedData, String>> processData() =>
  fetchData().then((result) => 
    result.flatMap((data) => processRawData(data))
  );
```

### Railway-Oriented Programming

```dart
Result<User, String> createUser(String name, String email) => Success(name)
  .retainIf((n) => n.isNotEmpty, () => 'Name cannot be empty')
  .flatMap((n) => validateEmail(email).map((_) => n))
  .flatMap((n) => checkUserExists(n, email))
  .map((n) => User(n, email));
```

## API Reference

### Core Types

- `Result<T, E>` - Sealed base class
- `Success<T, E>` - Successful result containing value of type T
- `Failure<T, E>` - Failed result containing error of type E

### Core Methods

- `map<U>(U Function(T) f)` - Transform success values
- `flatMap<U>(Result<U, E> Function(T) f)` - Chain Result-returning operations
- `mapFailure<F>(F Function(E) f)` - Transform error values
- `fold<U>(U Function(T) f, U Function(E) g)` - Handle both cases
- `peek(void Function(T) f)` - Side effects on success
- `peekFailure(void Function(E) f)` - Side effects on failure

### Utilities

- `valueOrNull()` - Safe value extraction
- `orThrow()` - Unwrap or throw
- `recover<S>(S Function(E) errorToValue)` - Provide fallback value
- `retainIf/rejectIf` - Conditional validation

See the [API documentation](https://pub.dev/documentation/result4d) for complete details.

## Examples

Check out the [example](example/main.dart) for a comprehensive demonstration of the library's features.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.


## License

This project is licensed under the Apache2 License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Inspired by [result4k](https://github.com/fork-handles/forkhandles/tree/trunk/result4k) for Kotlin
- Rust's `Result<T, E>` type
- The functional programming community
