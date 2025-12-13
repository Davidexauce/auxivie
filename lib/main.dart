import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'services/backend_api_service.dart';
import 'constants/payment_constants.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/profile_viewmodel.dart';
import 'viewmodels/message_viewmodel.dart';
import 'viewmodels/reservation_viewmodel.dart';
import 'viewmodels/settings_viewmodel.dart';
import 'utils/app_logger.dart';
import 'theme/app_theme.dart';
import 'views/splash_screen.dart';
import 'views/maintenance/maintenance_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Supprimer les assertions en mode debug pour éviter les erreurs KeyUpEvent dans le simulateur
  // (Ces erreurs sont des warnings connus du simulateur iOS et n'affectent pas le fonctionnement)
  
  // Initialisation des données de locale pour le formatage des dates en français
  try {
    await initializeDateFormatting('fr_FR', null);
    print('✅ Formatage de dates initialisé avec succès');
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

class AuxivieApp extends StatefulWidget {
  const AuxivieApp({super.key});

  @override
  State<AuxivieApp> createState() => _AuxivieAppState();
}

class _AuxivieAppState extends State<AuxivieApp> {
  final SettingsViewModel _settingsViewModel = SettingsViewModel();
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Initialiser les paramètres (charge + démarre le rafraîchissement automatique)
    await _settingsViewModel.initialize();
    
    // Initialiser le logger avec les paramètres
    AppLogger.init(_settingsViewModel.settings);
    
    // Initialiser Stripe avec les clés des paramètres
    await _initializeStripe();
    
    if (mounted) {
      setState(() {
        _isInitializing = false;
      });
    }
  }

  Future<void> _initializeStripe() async {
    try {
      final settings = _settingsViewModel.settings;
      String stripeKey;
      String mode;
      
      // Utiliser la clé des paramètres si disponible, sinon fallback sur PaymentConstants
      if (settings != null && settings.stripePublicKey.isNotEmpty) {
        stripeKey = settings.stripePublicKey;
        mode = settings.stripeMode;
      } else {
        // Fallback sur la clé par défaut
        stripeKey = PaymentConstants.stripePublishableKey;
        mode = 'production'; // Clé par défaut est en production
        AppLogger.log('Stripe: Utilisation de la clé par défaut (fallback)');
      }
      
      Stripe.publishableKey = stripeKey;
      await Stripe.instance.applySettings();
      AppLogger.log('Stripe initialisé avec succès (mode $mode)');
    } catch (e) {
      AppLogger.error('Erreur lors de l\'initialisation de Stripe', error: e);
    }
  }

  @override
  void dispose() {
    _settingsViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Chargement des paramètres...',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _settingsViewModel),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => MessageViewModel()),
        ChangeNotifierProvider(create: (_) => ReservationViewModel()),
      ],
      child: Consumer<SettingsViewModel>(
        builder: (context, settingsViewModel, _) {
          // Vérifier le mode maintenance
          if (settingsViewModel.settings?.maintenanceMode == true) {
            return MaterialApp(
              title: 'Auxivie',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: ThemeMode.system,
              home: const MaintenanceScreen(),
            );
          }

          return MaterialApp(
            title: 'Auxivie',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            builder: (context, child) {
              return child!;
            },
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}


