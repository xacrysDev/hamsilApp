import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:hamsil_app/views/app.dart'; // <-- importa directamente App
import 'package:hamsil_app/views/aboutus.dart';
import 'package:hamsil_app/views/auth/login.dart';

void main() {
  testWidgets('HomePage shows LogIn widget', (WidgetTester tester) async {
    await tester.pumpWidget(const App());

    // Verifica que el título de la app esté presente
    expect(find.text('Hamsil App'), findsOneWidget); // o cAppTitle

    // Verifica que el LogIn widget esté presente
    expect(find.byType(LogIn), findsOneWidget);
  });

  testWidgets('AboutUs page opens when menu button is tapped', (WidgetTester tester) async {
    await tester.pumpWidget(const App());

    final menuButton = find.byIcon(Icons.menu);
    expect(menuButton, findsOneWidget);

    await tester.tap(menuButton);
    await tester.pumpAndSettle();

    expect(find.byType(AboutUs), findsOneWidget);
  });
}
