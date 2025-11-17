# Service Tests - Note

The service tests in the `test/api/` directory demonstrate the testing approach for API services, but they currently have compilation issues due to Mockito's strict typing requirements in newer versions of Dart.

## Current Status

✅ **Working Tests:**
- Model tests (Article, User, Pagination) - 100% passing
- State management tests (AuthState) - 100% passing  
- Widget tests (PrimaryButton, GradientButton) - 100% passing
- ApiClient basic tests - 100% passing

⚠️ **Service Tests (Demonstrative):**
The service test files show the correct testing approach but need updates for strict null safety:
- `auth_service_test.dart`
- `profile_service_test.dart`
- `feed_service_test.dart`
- `interaction_service_test.dart`

## How to Fix Service Tests

To make service tests fully functional, you have two options:

### Option 1: Use Manual Mocks (Recommended for now)
Create manual mock classes instead of using Mockito's code generation:

```dart
class MockApiClient extends Fake implements ApiClient {
  Map<String, dynamic>? mockResponse;
  int mockStatusCode = 200;

  @override
  Future<http.Response> post(String path, {Object? body, Map<String, dynamic>? query}) async {
    return http.Response(jsonEncode(mockResponse ?? {}), mockStatusCode);
  }

  @override
  dynamic decode(http.Response res) {
    return jsonDecode(res.body);
  }

  @override
  Future<void> saveToken(String token) async {}

  @override
  Future<void> clearToken() async {}
}
```

### Option 2: Generate Mocks with build_runner
Run the mock generator:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Then update the test imports to use the generated mocks.

## Testing Philosophy

The tests demonstrate:
1. **Unit Testing** - Testing each component in isolation
2. **Mocking Dependencies** - Using mocks to isolate units under test
3. **Arrange-Act-Assert** - Clear test structure
4. **Edge Case Coverage** - Testing both success and failure scenarios

## Running Working Tests Only

To run only the currently working tests:

```bash
# Run model tests
flutter test test/models/

# Run state tests
flutter test test/state/

# Run widget tests  
flutter test test/widgets/

# Run api_client test
flutter test test/api/api_client_test.dart
```

## Next Steps

1. Implement manual mocks for API services
2. Update service tests to use manual mocks
3. Add integration tests
4. Set up coverage reporting
