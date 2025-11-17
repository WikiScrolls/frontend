import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wikiscrolls_frontend/widgets/gradient_button.dart';

void main() {
  group('GradientButton', () {
    testWidgets('renders with correct label', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientButton(
              label: 'Gradient Test',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Gradient Test'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (WidgetTester tester) async {
      bool wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientButton(
              label: 'Press Me',
              onPressed: () => wasPressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Press Me'));
      await tester.pump();

      expect(wasPressed, true);
    });

    testWidgets('can be disabled with null onPressed', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GradientButton(
              label: 'Disabled',
              onPressed: null,
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );

      expect(button.onPressed, isNull);
    });

    testWidgets('has gradient decoration', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientButton(
              label: 'Gradient',
              onPressed: () {},
            ),
          ),
        ),
      );

      final decoratedBox = tester.widget<DecoratedBox>(
        find.byType(DecoratedBox),
      );

      expect(decoratedBox.decoration, isA<BoxDecoration>());
      final boxDecoration = decoratedBox.decoration as BoxDecoration;
      expect(boxDecoration.gradient, isA<LinearGradient>());
    });

    testWidgets('button is constrained to max width', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientButton(
              label: 'Constrained',
              onPressed: () {},
            ),
          ),
        ),
      );

      final constrainedBoxes = tester.widgetList<ConstrainedBox>(
        find.byType(ConstrainedBox),
      );

      // Find the ConstrainedBox with maxWidth 350
      final targetBox = constrainedBoxes.firstWhere(
        (box) => box.constraints.maxWidth == 350,
      );

      expect(targetBox.constraints.maxWidth, 350);
    });

    testWidgets('has correct text style', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientButton(
              label: 'Styled Text',
              onPressed: () {},
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('Styled Text'));
      
      expect(text.style?.fontSize, 18);
      expect(text.style?.fontWeight, FontWeight.w700);
    });

    testWidgets('has correct button shape', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientButton(
              label: 'Rounded',
              onPressed: () {},
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );

      final shape = button.style?.shape?.resolve({});
      expect(shape, isA<RoundedRectangleBorder>());
    });

    testWidgets('button background is transparent', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientButton(
              label: 'Transparent',
              onPressed: () {},
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );

      final backgroundColor = button.style?.backgroundColor?.resolve({});
      expect(backgroundColor, Colors.transparent);
    });
  });
}
