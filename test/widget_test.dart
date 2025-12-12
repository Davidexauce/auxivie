// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:auxivie/main.dart';
import 'package:auxivie/viewmodels/auth_viewmodel.dart';
import 'package:auxivie/viewmodels/profile_viewmodel.dart';
import 'package:auxivie/viewmodels/message_viewmodel.dart';
import 'package:auxivie/viewmodels/reservation_viewmodel.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthViewModel()),
          ChangeNotifierProvider(create: (_) => ProfileViewModel()),
          ChangeNotifierProvider(create: (_) => MessageViewModel()),
          ChangeNotifierProvider(create: (_) => ReservationViewModel()),
        ],
        child: const AuxivieApp(),
      ),
    );

    // Wait for the app to initialize
    await tester.pumpAndSettle();

    // Verify that the app loads (we should see the splash screen or choice screen)
    // Since the app requires async initialization, we just verify it doesn't crash
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
