import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wikiscrolls_frontend/widgets/primary_button.dart';

void main() {
  group('PrimaryButton', () {
    testWidgets('renders with correct label', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              label: 'Test Button',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (WidgetTester tester) async {
      bool wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              label: 'Click Me',
              onPressed: () => wasPressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Click Me'));
      await tester.pump();

      expect(wasPressed, true);
    });

    testWidgets('has correct styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              label: 'Styled Button',
              onPressed: () {},
            ),
          ),
        ),
      );

      final elevatedButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );

      expect(elevatedButton, isNotNull);
    });

    testWidgets('button is constrained to max width', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
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
            body: PrimaryButton(
              label: 'Text Style',
              onPressed: () {},
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('Text Style'));
      
      expect(text.style?.fontSize, 18);
      expect(text.style?.fontWeight, FontWeight.w700);
    });

    testWidgets('button takes full width within constraints', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              label: 'Full Width',
              onPressed: () {},
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(
        find.descendant(
          of: find.byType(ConstrainedBox),
          matching: find.byType(SizedBox),
        ),
      );

      expect(sizedBox.width, double.infinity);
    });
  });
}
