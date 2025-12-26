import 'package:result4d/result4d.dart';

/// Custom error types for our example
sealed class AppError {
  const AppError();
}

class ValidationError extends AppError {
  final String field;
  final String message;
  const ValidationError(this.field, this.message);

  @override
  String toString() => 'ValidationError($field): $message';
}

class NetworkError extends AppError {
  final String message;
  const NetworkError(this.message);

  @override
  String toString() => 'NetworkError: $message';
}

class BusinessLogicError extends AppError {
  final String message;
  const BusinessLogicError(this.message);

  @override
  String toString() => 'BusinessLogicError: $message';
}

/// User model
class User {
  final String id;
  final String name;
  final String email;
  final int age;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.age,
  });

  @override
  String toString() => 'User(id: $id, name: $name, email: $email, age: $age)';
}

/// Database simulation
class UserDatabase {
  static final _users = <String, User>{
    '1': User(id: '1', name: 'Alice', email: 'alice@example.com', age: 25),
    '2': User(id: '2', name: 'Bob', email: 'bob@example.com', age: 30),
  };

  static Result<User, AppError> findById(String id) {
    final user = _users[id];
    return user != null
        ? Success<User, AppError>(user)
        : Failure<User, AppError>(NetworkError('User not found: $id'));
  }

  static Result<User, AppError> save(User user) {
    // Simulate potential database failure
    if (user.name.contains('error')) {
      return Failure<User, AppError>(NetworkError('Database save failed'));
    }

    _users[user.id] = user;
    return Success<User, AppError>(user);
  }
}

/// Validation functions
Result<String, AppError> validateEmail(String email) {
  if (email.isEmpty) {
    return Failure(ValidationError('email', 'Email cannot be empty'));
  }
  if (!email.contains('@')) {
    return Failure(ValidationError('email', 'Email must contain @'));
  }
  return Success<String, AppError>(email);
}

Result<String, AppError> validateName(String name) {
  if (name.isEmpty) {
    return Failure(ValidationError('name', 'Name cannot be empty'));
  }
  if (name.length < 2) {
    return Failure(
      ValidationError('name', 'Name must be at least 2 characters'),
    );
  }
  return Success<String, AppError>(name);
}

Result<int, AppError> validateAge(int age) {
  if (age < 0) {
    return Failure(ValidationError('age', 'Age cannot be negative'));
  }
  if (age > 150) {
    return Failure(ValidationError('age', 'Age cannot be over 150'));
  }
  return Success<int, AppError>(age);
}

/// Business logic functions
Result<User, AppError> createUser({
  required String name,
  required String email,
  required int age,
}) {
  // Railway-oriented programming - chain validations
  return validateName(name)
      .flatMap((_) => validateEmail(email))
      .flatMap((_) => validateAge(age))
      .map(
        (_) => User(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name,
          email: email,
          age: age,
        ),
      )
      .flatMap((user) => UserDatabase.save(user));
}

Result<User, AppError> updateUserAge(String userId, int newAge) {
  return UserDatabase.findById(userId)
      .flatMap((user) => validateAge(newAge).map((_) => user))
      .map(
        (user) =>
            User(id: user.id, name: user.name, email: user.email, age: newAge),
      )
      .flatMap((user) => UserDatabase.save(user));
}

Result<String, AppError> getUserSummary(String userId) {
  return UserDatabase.findById(
    userId,
  ).map((user) => '${user.name} (${user.age} years old) - ${user.email}');
}

/// Collection processing example
Result<List<User>, AppError> processUserIds(List<String> userIds) {
  return userIds.mapAllValues((id) => UserDatabase.findById(id));
}

/// Advanced examples
void demonstrateBasicOperations() {
  print('=== Basic Operations ===');

  // Creating results
  final success = Success<int, String>(42);
  final failure = Failure<int, String>('Something went wrong');

  print('Success: $success');
  print('Failure: $failure');

  // Extension methods
  final quickSuccess = 100.asSuccess();
  final quickFailure = 'Quick error'.asFailure();

  print('Quick success: $quickSuccess');
  print('Quick failure: $quickFailure');

  // Pattern matching
  final message = switch (quickSuccess as Result<int, String>) {
    Success(value: final value) => 'Got value: $value',
    Failure(reason: final error) => 'Got error: $error',
  };
  print('Pattern match result: $message');
}

void demonstrateTransformations() {
  print('\n=== Transformations ===');

  final result = Success<int, String>(5);
  final failure = Failure<int, String>('Something went wrong');

  // Map
  final doubled = result.map((x) => x * 2);
  print('Doubled: ${doubled.valueOrNull()}');

  // FlatMap
  final processed = result.flatMap(
    (x) =>
        x > 0
            ? Success<String, String>('Positive: $x')
            : Failure('Not positive'),
  );
  print('Processed: ${processed.valueOrNull()}');

  // Fold
  final folded = result.fold(
    (value) => 'Success with $value',
    (error) => 'Error: $error',
  );
  print('Folded: $folded');

  // MapFailure
  final convertedError = failure.mapFailure((err) => 'Converted: $err');
  print('Converted error: ${convertedError.failureOrNull()}');
}

void demonstrateValidation() {
  print('\n=== Validation ===');

  final success = Success<int, String>(15);

  // Conditional validation using flatMap pattern
  final validated = success
      .flatMap(
        (x) =>
            x > 0
                ? Success<int, String>(x)
                : Failure<int, String>('Must be positive'),
      )
      .flatMap(
        (x) =>
            x <= 100
                ? Success<int, String>(x)
                : Failure<int, String>('Must be <= 100'),
      );

  print('Validated result: ${validated.valueOrNull()}');

  // Test with value that fails validation
  final tooLarge = Success<int, String>(150);
  final failed = tooLarge.flatMap(
    (x) =>
        x <= 100
            ? Success<int, String>(x)
            : Failure<int, String>('Must be <= 100'),
  );
  print('Failed validation: ${failed.failureOrNull()}');

  // Direct validation method calls on Success instances
  final directValidation = success.retainIf((x) => x > 10, () => 'Too small');
  print('Direct validation: ${directValidation.valueOrNull()}');

  // Null handling
  const int? nullValue = null;
  final nonNull = nullValue.asResultOr(() => 'Value was null');
  print('Null handling: ${nonNull.failureOrNull()}');

  // FilterNotNull
  final nullable = Success<int?, String>(42);
  final filtered = nullable.filterNotNull(() => 'Was null');
  print('Filtered: ${filtered.valueOrNull()}');
}

void demonstrateCollections() {
  print('\n=== Collection Operations ===');

  final results = [
    Success<int, String>(1),
    Success<int, String>(2),
    Success<int, String>(3),
  ];

  // AllValues (all must succeed)
  final allValues = results.allValues();
  print('All values: ${allValues.valueOrNull()}');

  // AnyValues (extract successes only)
  final mixedResults = [
    Success<int, String>(1),
    Failure<int, String>('error'),
    Success<int, String>(3),
  ];
  final someValues = mixedResults.anyValues();
  print('Some values: $someValues');

  // Partition
  final partitioned = mixedResults.partition();
  print('Successes: ${partitioned.successes}');
  print('Failures: ${partitioned.failures}');

  // MapAllValues - process with early termination on failure
  final processedSuccess = [
    1,
    3,
    5,
  ].mapAllValues((x) => Success<int, String>(x * 2));
  print('Processed successfully: ${processedSuccess.valueOrNull()}');

  final processedFailure = [1, 2, 3].mapAllValues(
    (x) =>
        x == 2
            ? Failure<int, String>('Even not allowed')
            : Success<int, String>(x * 2),
  );
  print('Processed with failure: ${processedFailure.failureOrNull()}');
}

void demonstrateZipping() {
  print('\n=== Zipping Results ===');

  final id = Success<String, String>('123');
  final name = Success<String, String>('Alice');
  final email = Success<String, String>('alice@example.com');

  // Zip two results
  final nameEmail = zip2(name, email, (n, e) => '$n <$e>');
  print('Name + Email: ${nameEmail.valueOrNull()}');

  // Zip three results
  final userInfo = zip3(id, name, email, (i, n, e) => 'User($i): $n <$e>');
  print('User info: ${userInfo.valueOrNull()}');

  // FlatZip (for Result-returning operations)
  final userResult = flatZip2(
    Success<String, AppError>('1'),
    Success<String, AppError>('Alice'),
    (userId, userName) => UserDatabase.findById(userId),
  );
  print('FlatZip result: ${userResult.valueOrNull()}');
}

void demonstrateErrorHandling() {
  print('\n=== Error Handling ===');

  final success = Success<int, String>(42);
  final failure = Failure<int, String>('Something broke');

  // Safe extraction
  print('Success value or null: ${success.valueOrNull()}');
  print('Failure value or null: ${failure.valueOrNull()}');

  // Recovery
  final recovered = failure.recover((error) => -1);
  print('Recovered: $recovered');

  // OrThrow (commented out to avoid exceptions)
  // final thrown = success.orThrow();

  // Custom exception handling would look like:
  // final value = failure.orThrowWith((err) => Exception('Custom: $err'));
  print('Would throw: Exception(Custom: Something broke)');
}

void demonstrateBusinessLogic() {
  print('\n=== Business Logic Examples ===');

  // Valid user creation
  final validUser = createUser(
    name: 'Charlie',
    email: 'charlie@example.com',
    age: 28,
  );
  print('Created user: ${validUser.valueOrNull()}');

  // Invalid user creation (validation failure)
  final invalidUser = createUser(
    name: '', // Invalid name
    email: 'charlie@example.com',
    age: 28,
  );
  print('Invalid user error: ${invalidUser.failureOrNull()}');

  // Update user age
  final updatedUser = updateUserAge('1', 26);
  print('Updated user: ${updatedUser.valueOrNull()}');

  // Get user summary
  final summary = getUserSummary('1');
  print('User summary: ${summary.valueOrNull()}');

  // Process multiple users
  final users = processUserIds(['1', '2', 'nonexistent']);
  print(
    'Processing result: ${users.failureOrNull()}',
  ); // Should fail on nonexistent user

  final validUsers = processUserIds(['1', '2']);
  print('Valid users count: ${validUsers.valueOrNull()?.length}');
}

void demonstrateResultFrom() {
  print('\n=== ResultFrom Examples ===');

  // Successful parsing
  final validParse = resultFrom(() => int.parse('42'));
  print('Parsed successfully: ${validParse.valueOrNull()}');

  // Failed parsing
  final invalidParse = resultFrom(() => int.parse('not-a-number'));
  print('Parse error: ${invalidParse.failureOrNull()}');

  // Chain with other operations - convert to proper type first
  final parsed = resultFrom(() => int.parse('100'))
      .mapFailure((e) => 'Parse error: $e')
      .flatMap(
        (x) =>
            x > 0
                ? Success<int, String>(x)
                : Failure<int, String>('Must be positive'),
      )
      .map((x) => x * 2);
  print('Chained parsing: ${parsed.valueOrNull()}');
}

void main() {
  print('🎯 Result4D Comprehensive Example\n');

  demonstrateBasicOperations();
  demonstrateTransformations();
  demonstrateValidation();
  demonstrateCollections();
  demonstrateZipping();
  demonstrateErrorHandling();
  demonstrateBusinessLogic();
  demonstrateResultFrom();

  print('\n✅ All examples completed!');
  print('\nKey takeaways:');
  print('• Results make error handling explicit and composable');
  print('• Pattern matching provides exhaustive case coverage');
  print('• Chain operations safely with map/flatMap');
  print('• Validate and transform data in a functional style');
  print('• Handle collections of Results elegantly');
  print('• Combine multiple Results with zip operations');
}
