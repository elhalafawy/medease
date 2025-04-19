import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:medease/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MedEaseApp());

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
