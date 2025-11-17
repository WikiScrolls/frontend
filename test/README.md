# Unit Testing Documentation

This directory contains comprehensive unit tests for the WikiScrolls Flutter frontend application.

## Test Organization

The test suite is organized into the following directories:

```
test/
├── models/          # Tests for data models (Article, User, Pagination)
├── api/             # Tests for API services and HTTP client
├── state/           # Tests for state management (AuthState)
├── widgets/         # Tests for UI widgets (Buttons, etc.)
└── helpers/         # Test utilities, mocks, and factories
```

## Running Tests

### Run all tests
```bash
flutter test
```

### Run tests with coverage
```bash
flutter test --coverage
```

### Run specific test file
```bash
flutter test test/models/article_test.dart
```

### Run tests in a directory
```bash
flutter test test/api/
```

### Run tests in watch mode
```bash
flutter test --watch
```

## Test Categories

### Model Tests (`test/models/`)
Tests for data serialization, deserialization, and validation:
- `article_test.dart` - ArticleModel JSON parsing and conversion
- `user_test.dart` - UserModel JSON parsing and conversion
- `pagination_test.dart` - PaginationInfo JSON parsing and conversion

**Coverage:**
- JSON serialization (toJson)
- JSON deserialization (fromJson)
- Handling missing/null fields
- Default value behavior
- Round-trip serialization

### API Tests (`test/api/`)
Tests for API services and HTTP communication:
- `api_client_test.dart` - HTTP client, token management, error handling
- `auth_service_test.dart` - Login, signup, profile, logout
- `profile_service_test.dart` - Profile CRUD operations
- `feed_service_test.dart` - Feed management operations
- `interaction_service_test.dart` - Like, bookmark, view tracking

**Coverage:**
- Successful API responses
- Error handling and exceptions
- Token persistence
- Request/response validation
- Mock HTTP responses

### State Management Tests (`test/state/`)
Tests for application state management:
- `auth_state_test.dart` - Authentication state, token storage, user session

**Coverage:**
- State initialization
- State updates and notifications
- Listener notifications
- Token persistence
- Session management

### Widget Tests (`test/widgets/`)
Tests for UI components:
- `primary_button_test.dart` - PrimaryButton rendering and interaction
- `gradient_button_test.dart` - GradientButton rendering and interaction

**Coverage:**
- Widget rendering
- User interactions (tap, press)
- Styling verification
- Layout constraints
- Enabled/disabled states

## Test Helpers

### Mock Data Factory (`test/helpers/mock_data_factory.dart`)
Provides factory methods for creating test data:
```dart
// Create a single article
final article = MockDataFactory.createArticle(title: 'Test');

// Create multiple articles
final articles = MockDataFactory.createArticles(10);

// Create a user
final user = MockDataFactory.createUser(email: 'test@example.com');

// Create API responses
final response = MockDataFactory.createSuccessResponse(data: {'id': '123'});
final error = MockDataFactory.createErrorResponse(message: 'Not found');
```

### Widget Test Helpers (`test/helpers/widget_test_helpers.dart`)
Provides helper functions for widget testing:
```dart
// Wrap widget with MaterialApp
testableWidget(MyWidget());

// Wrap with theme
testableThemedWidget(MyWidget(), theme: ThemeData.dark());

// Wrap with Provider
testableWidgetWithProvider(MyWidget(), myProvider);

// Wrap with AuthState
testableWidgetWithAuth(MyWidget(), authState);
```

## Mocking Strategy

The test suite uses `mockito` for creating mocks. Key mock classes:
- `MockApiClient` - Mocks HTTP client for API tests
- `MockHttpClient` - Mocks low-level HTTP client
- `MockSharedPreferences` - Mocks persistent storage

### Generating Mocks

To generate mock classes (if needed in future):
```bash
flutter pub run build_runner build
```

## Best Practices

1. **Arrange-Act-Assert Pattern**: Structure tests clearly
   ```dart
   test('description', () {
     // Arrange - set up test data
     final data = createTestData();
     
     // Act - perform the action
     final result = functionUnderTest(data);
     
     // Assert - verify the result
     expect(result, expectedValue);
   });
   ```

2. **Use Descriptive Test Names**: Tests should clearly describe what they verify
   ```dart
   test('fromJson creates ArticleModel with all fields', () { ... });
   test('login with invalid credentials throws exception', () { ... });
   ```

3. **Mock External Dependencies**: Isolate units under test
   ```dart
   final mockClient = MockApiClient();
   when(mockClient.get('/api/endpoint'))
       .thenAnswer((_) async => http.Response('{}', 200));
   ```

4. **Test Edge Cases**: Include tests for:
   - Null/empty values
   - Error conditions
   - Boundary conditions
   - Invalid input

5. **Keep Tests Isolated**: Each test should be independent
   - Use `setUp()` to initialize fresh state
   - Don't rely on test execution order
   - Clean up after tests if needed

## Current Test Coverage

The test suite provides comprehensive coverage for:
- ✅ All data models (Article, User, Pagination)
- ✅ API client and token management
- ✅ All API services (Auth, Profile, Feed, Interaction)
- ✅ Authentication state management
- ✅ Core UI widgets (Buttons)

## Future Test Additions

Consider adding tests for:
- Screen/page widgets
- Navigation flows
- Form validation
- Integration tests
- Performance tests
- Accessibility tests

## Continuous Integration

These tests are designed to run in CI/CD pipelines:
```yaml
# Example GitHub Actions workflow
- name: Run tests
  run: flutter test --coverage
  
- name: Upload coverage
  uses: codecov/codecov-action@v3
  with:
    files: ./coverage/lcov.info
```

## Troubleshooting

### Tests fail with "Null check operator used on a null value"
- Ensure `TestWidgetsFlutterBinding.ensureInitialized()` is called in setUp
- Check that SharedPreferences has mock values initialized

### Mock methods not being called
- Verify the method signature matches exactly
- Use `any` for flexible parameter matching
- Check that you're testing the right instance

### Widget tests fail to find widgets
- Use `await tester.pump()` after state changes
- Use `await tester.pumpAndSettle()` for animations
- Verify the widget is actually in the tree with `find.byType()`

## Resources

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Mockito Package](https://pub.dev/packages/mockito)
- [Widget Testing Guide](https://docs.flutter.dev/cookbook/testing/widget/introduction)
