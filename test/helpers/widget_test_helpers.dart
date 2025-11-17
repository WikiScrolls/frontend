import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wikiscrolls_frontend/state/auth_state.dart';

/// Helper function to wrap widgets with MaterialApp for testing
Widget testableWidget(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: child,
    ),
  );
}

/// Helper function to wrap widgets with MaterialApp and theme for testing
Widget testableThemedWidget(Widget child, {ThemeData? theme}) {
  return MaterialApp(
    theme: theme ?? ThemeData.dark(useMaterial3: true),
    home: Scaffold(
      body: child,
    ),
  );
}

/// Helper function to wrap widgets with Provider for state management testing
Widget testableWidgetWithProvider<T extends ChangeNotifier>(
  Widget child,
  T provider,
) {
  return ChangeNotifierProvider<T>.value(
    value: provider,
    child: MaterialApp(
      home: Scaffold(
        body: child,
      ),
    ),
  );
}

/// Helper function to wrap widgets with AuthState provider
Widget testableWidgetWithAuth(Widget child, AuthState authState) {
  return ChangeNotifierProvider<AuthState>.value(
    value: authState,
    child: MaterialApp(
      home: Scaffold(
        body: child,
      ),
    ),
  );
}

/// Helper to create a Builder widget for testing widgets that depend on context
Widget testableBuilderWidget(WidgetBuilder builder) {
  return MaterialApp(
    home: Scaffold(
      body: Builder(builder: builder),
    ),
  );
}
