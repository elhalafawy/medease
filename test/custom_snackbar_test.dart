import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medease/core/widgets/custom_snackbar.dart';

void main() {
  group('CustomSnackBar Tests', () {
    testWidgets('CustomSnackBar shows message correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) {
              return Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      CustomSnackBar.show(
                        context: context,
                        message: 'Test Message',
                        isError: false,
                      );
                    },
                    child: const Text('Show SnackBar'),
                  ),
                ),
              );
            },
          ),
        ),
      );

      // Tap the button to show the snackbar
      await tester.tap(find.text('Show SnackBar'));
      await tester.pumpAndSettle();

      // Verify that the SnackBar appears with correct message
      expect(find.text('Test Message'), findsOneWidget);
    });

    testWidgets('CustomSnackBar shows error message', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) {
              return Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      CustomSnackBar.show(
                        context: context,
                        message: 'Error Message',
                        isError: true,
                      );
                    },
                    child: const Text('Show Error SnackBar'),
                  ),
                ),
              );
            },
          ),
        ),
      );

      // Tap the button to show the error snackbar
      await tester.tap(find.text('Show Error SnackBar'));
      await tester.pumpAndSettle();

      // Verify that the error SnackBar appears with correct message
      expect(find.text('Error Message'), findsOneWidget);
    });

    testWidgets('CustomSnackBar can be dismissed by tap', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) {
              return Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      CustomSnackBar.show(
                        context: context,
                        message: 'Tap to Dismiss',
                        isError: false,
                      );
                    },
                    child: const Text('Show SnackBar'),
                  ),
                ),
              );
            },
          ),
        ),
      );

      // Show the snackbar
      await tester.tap(find.text('Show SnackBar'));
      await tester.pumpAndSettle();

      // Verify snackbar is shown
      expect(find.text('Tap to Dismiss'), findsOneWidget);

      // Tap the snackbar to dismiss it
      await tester.tap(find.text('Tap to Dismiss'));
      await tester.pumpAndSettle();

      // Verify that the SnackBar is dismissed
      expect(find.text('Tap to Dismiss'), findsNothing);
    });
  });
}