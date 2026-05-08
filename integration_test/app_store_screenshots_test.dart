import 'dart:io';

import 'package:auxivie/models/user_model.dart';
import 'package:auxivie/services/backend_api_service.dart';
import 'package:auxivie/services/consent_service.dart';
import 'package:auxivie/theme/app_theme.dart';
import 'package:auxivie/viewmodels/auth_viewmodel.dart';
import 'package:auxivie/viewmodels/message_viewmodel.dart';
import 'package:auxivie/viewmodels/profile_viewmodel.dart';
import 'package:auxivie/viewmodels/reservation_viewmodel.dart';
import 'package:auxivie/viewmodels/settings_viewmodel.dart';
import 'package:auxivie/views/auth/choice_screen.dart';
import 'package:auxivie/views/auth/login_screen.dart';
import 'package:auxivie/views/home_screen.dart';
import 'package:auxivie/views/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

/// Captures d’écran pour l’App Store (simulateur iOS).
///
/// Usage :
///   flutter test integration_test/app_store_screenshots_test.dart -d "iPhone 16 Plus"
///   flutter test integration_test/app_store_screenshots_test.dart -d "iPad Pro 13-inch (M4)"
///
/// Les fichiers PNG sont écrits dans le répertoire courant du test (voir logs)
/// ou récupérables via la sortie `integration_test` de Flutter.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> settleUi(WidgetTester tester, {Duration totalWait = const Duration(seconds: 3)}) async {
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(totalWait);
  }

  Future<void> snap(String name) async {
    await binding.takeScreenshot(name);
  }

  UserModel demoFamille() => UserModel(
        id: 90001,
        name: 'Sophie Martin',
        email: 'famille.demo@aidalia.app',
        password: '',
        categorie: 'Famille',
        userType: 'famille',
        ville: 'Paris',
        besoin: 'Accompagnement quotidien',
      );

  UserModel demoPro() => UserModel(
        id: 90002,
        name: 'Jean Dupont',
        email: 'pro.demo@aidalia.app',
        password: '',
        categorie: 'Auxiliaire de vie',
        userType: 'professionnel',
        ville: 'Paris',
        tarif: 28,
        experience: 8,
      );

  Future<void> pumpWithProviders(
    WidgetTester tester, {
    required AuthViewModel auth,
    required Widget home,
  }) async {
    final settings = SettingsViewModel();
    await settings.initialize(fastStartup: true);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: settings),
          ChangeNotifierProvider.value(value: auth),
          ChangeNotifierProvider(create: (_) => ProfileViewModel()),
          ChangeNotifierProvider(create: (_) => MessageViewModel()),
          ChangeNotifierProvider(create: (_) => ReservationViewModel()),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          debugShowCheckedModeBanner: false,
          home: home,
        ),
      ),
    );
  }

  group('App Store screenshots', () {
    setUpAll(() async {
      await initializeDateFormatting('fr_FR', null);
      await BackendApiService.init();
      await ConsentService.setConsent(analytics: false, marketing: false);
    });

    testWidgets('parcours famille + pro', (tester) async {
      final authSplash = AuthViewModel();
      await pumpWithProviders(tester, auth: authSplash, home: const SplashScreen(disableAutoNavigation: true));
      await settleUi(tester);
      await snap('01_splash');

      // 02 — Choix compte
      final authChoice = AuthViewModel();
      await pumpWithProviders(tester, auth: authChoice, home: const ChoiceScreen());
      await settleUi(tester);
      await snap('02_choice');

      // 03 — Connexion (famille)
      final authLogin = AuthViewModel();
      await pumpWithProviders(
        tester,
        auth: authLogin,
        home: const LoginScreen(userType: 'famille'),
      );
      await settleUi(tester);
      await snap('03_login_famille');

      // 04–08 — Onglets accueil (famille)
      final authF = AuthViewModel()..setScreenshotDemoUser(demoFamille());
      for (var tab = 0; tab < 5; tab++) {
        await pumpWithProviders(
          tester,
          auth: authF,
          home: HomeScreen(initialTabIndex: tab),
        );
        await settleUi(tester, totalWait: const Duration(seconds: 4));
        await snap('${(4 + tab).toString().padLeft(2, '0')}_home_famille_tab$tab');
      }

      // 09–13 — Espace professionnel (même barre d’onglets)
      final authP = AuthViewModel()..setScreenshotDemoUser(demoPro());
      for (var tab = 0; tab < 5; tab++) {
        await pumpWithProviders(
          tester,
          auth: authP,
          home: HomeScreen(initialTabIndex: tab),
        );
        await settleUi(tester, totalWait: const Duration(seconds: 4));
        await snap('${(9 + tab).toString().padLeft(2, '0')}_home_pro_tab$tab');
      }
    }, skip: !Platform.isIOS);
  });
}
