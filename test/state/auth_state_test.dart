import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wikiscrolls_frontend/state/auth_state.dart';
import 'package:wikiscrolls_frontend/api/models/user.dart';
import 'package:wikiscrolls_frontend/api/api_client.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthState', () {
    late AuthState authState;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      authState = AuthState();
    });

    test('initial state is not authenticated', () {
      expect(authState.isAuthenticated, false);
      expect(authState.user, isNull);
      expect(authState.token, isNull);
    });

    test('loadToken loads token from storage', () async {
      SharedPreferences.setMockInitialValues({'authToken': 'test-token-123'});
      
      final state = AuthState();
      await state.loadToken();
      
      expect(state.token, 'test-token-123');
      expect(state.isAuthenticated, true);
    });

    test('setSession updates user and token', () async {
      const user = UserModel(
        id: 'user1',
        username: 'testuser',
        email: 'test@example.com',
      );

      int notifyCount = 0;
      authState.addListener(() => notifyCount++);

      await authState.setSession(token: 'new-token', user: user);

      expect(authState.token, 'new-token');
      expect(authState.user, user);
      expect(authState.isAuthenticated, true);
      expect(notifyCount, 1);
    });

    test('setSession persists token to storage', () async {
      const user = UserModel(
        id: 'user2',
        username: 'persistuser',
        email: 'persist@example.com',
      );

      await authState.setSession(token: 'persist-token', user: user);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('authToken'), 'persist-token');
    });

    test('clear removes user and token', () async {
      const user = UserModel(
        id: 'user3',
        username: 'clearuser',
        email: 'clear@example.com',
      );

      await authState.setSession(token: 'clear-token', user: user);
      
      int notifyCount = 0;
      authState.addListener(() => notifyCount++);
      
      await authState.clear();

      expect(authState.token, isNull);
      expect(authState.user, isNull);
      expect(authState.isAuthenticated, false);
      expect(notifyCount, 1);
    });

    test('clear removes token from storage', () async {
      SharedPreferences.setMockInitialValues({'authToken': 'to-clear'});
      
      await authState.clear();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('authToken'), isNull);
    });

    test('notifies listeners when state changes', () async {
      int notifyCount = 0;
      authState.addListener(() => notifyCount++);

      const user = UserModel(
        id: 'user4',
        username: 'notifyuser',
        email: 'notify@example.com',
      );

      await authState.setSession(token: 'token1', user: user);
      expect(notifyCount, 1);

      await authState.clear();
      expect(notifyCount, 2);
    });

    test('isAuthenticated returns true when token exists', () async {
      const user = UserModel(
        id: 'user5',
        username: 'authuser',
        email: 'auth@example.com',
      );

      await authState.setSession(token: 'valid-token', user: user);
      
      expect(authState.isAuthenticated, true);
    });

    test('isAuthenticated returns false when token is empty string', () async {
      const user = UserModel(
        id: 'user6',
        username: 'emptyuser',
        email: 'empty@example.com',
      );

      await authState.setSession(token: '', user: user);
      
      expect(authState.isAuthenticated, false);
    });

    test('multiple listeners are all notified', () async {
      int listener1Count = 0;
      int listener2Count = 0;
      
      authState.addListener(() => listener1Count++);
      authState.addListener(() => listener2Count++);

      const user = UserModel(
        id: 'user7',
        username: 'multiuser',
        email: 'multi@example.com',
      );

      await authState.setSession(token: 'multi-token', user: user);

      expect(listener1Count, 1);
      expect(listener2Count, 1);
    });
  });
}
