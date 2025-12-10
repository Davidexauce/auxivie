import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'services/backend_api_service.dart';
import 'services/payment_service.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/profile_viewmodel.dart';
import 'viewmodels/message_viewmodel.dart';
import 'viewmodels/reservation_viewmodel.dart';
import 'theme/app_theme.dart';
import 'views/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialisation des données de locale pour le formatage des dates en français
  try {
    await initializeDateFormatting('fr_FR', null);
  } catch (e) {
    print('⚠️ Erreur lors de l\'initialisation du formatage de dates: $e');
  }
  
  // Initialisation du service API (récupération du token depuis SharedPreferences)
  // Utiliser un délai pour s'assurer que les canaux de communication sont prêts
  try {
    await Future.delayed(const Duration(milliseconds: 100));
    await BackendApiService.init();
  } catch (e) {
    print('⚠️ Erreur lors de l\'initialisation du service API: $e');
  }
  
  // Initialisation de Stripe
  try {
    await PaymentService.init();
  } catch (e) {
    print('⚠️ Erreur lors de l\'initialisation de Stripe: $e');
  }
  
  // Barres système transparentes (statut + navigation)
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light, // Android
    systemNavigationBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark, // iOS: light content
  ));
  
  runApp(const AuxivieApp());
}

class AuxivieApp extends StatelessWidget {
  const AuxivieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => MessageViewModel()),
        ChangeNotifierProvider(create: (_) => ReservationViewModel()),
      ],
      child: MaterialApp(
        title: 'Auxivie',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        builder: (context, child) {
          return child!;
        },
        home: const SplashScreen(),
      ),
    );
  }
}


