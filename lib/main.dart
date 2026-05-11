import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'dart:async';
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
import 'widgets/aidalya_logo.dart';
import 'views/splash_screen.dart';
import 'views/maintenance/maintenance_screen.dart';
import 'widgets/consent/consent_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Token / prefs API avant le premier frame (rapide, pas de réseau).
  try {
    await BackendApiService.init();
  } catch (_) {}

  // Barres système transparentes (statut + navigation)
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light, // Android
    systemNavigationBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark, // iOS: light content
  ));

  runApp(const AidalyaApp());
}

class AidalyaApp extends StatefulWidget {
  /// Active un démarrage allégé pour les tests widgets (pas de tâches arrière-plan).
  final bool disableBackgroundStartupTasks;

  /// Désactive la navigation automatique du splash (utile en test pour éviter des timers).
  final bool disableSplashAutoNavigation;

  const AidalyaApp({
    super.key,
    this.disableBackgroundStartupTasks = false,
    this.disableSplashAutoNavigation = false,
  });

  @override
  State<AidalyaApp> createState() => _AidalyaAppState();
}

class _AidalyaAppState extends State<AidalyaApp> {
  final SettingsViewModel _settingsViewModel = SettingsViewModel();
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    if (widget.disableBackgroundStartupTasks) {
      AppLogger.init(null);
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
      return;
    }

    // Lancer les initialisations non critiques en arrière-plan pour accélérer le 1er rendu.
    unawaited(_initializeNonBlockingStartupTasks());

    // Initialiser rapidement les paramètres (mode fast startup) afin d'afficher l'app plus vite.
    await _settingsViewModel.initialize(fastStartup: true);
    
    // Initialiser le logger avec les paramètres
    AppLogger.init(_settingsViewModel.settings);
    
    // Stripe : ne pas bloquer le premier rendu sur applySettings (SDK natif / réseau peut être très lent).
    _scheduleStripeInit();
    
    if (mounted) {
      setState(() {
        _isInitializing = false;
      });
    }
  }

  Future<void> _initializeNonBlockingStartupTasks() async {
    try {
      await initializeDateFormatting('fr_FR', null);
      AppLogger.log('Formatage de dates initialisé avec succès');
    } catch (e) {
      AppLogger.error('Erreur lors de l\'initialisation du formatage de dates', error: e);
    }
  }

  /// Applique les réglages Stripe en arrière-plan avec borne de temps pour ne pas figer l’UI au démarrage.
  void _scheduleStripeInit() {
    unawaited(_initializeStripeInBackground());
  }

  Future<void> _initializeStripeInBackground() async {
    try {
      final settings = _settingsViewModel.settings;
      String stripeKey;
      String mode;

      if (settings != null && settings.stripePublicKey.isNotEmpty) {
        stripeKey = settings.stripePublicKey;
        mode = settings.stripeMode;
      } else {
        stripeKey = PaymentConstants.stripePublishableKey;
        mode = 'production';
        AppLogger.log('Stripe: Utilisation de la clé par défaut (fallback)');
      }

      if (stripeKey.isEmpty) {
        AppLogger.error('Stripe non initialisé: aucune clé publishable disponible');
        return;
      }

      Stripe.publishableKey = stripeKey;
      await Stripe.instance
          .applySettings()
          .timeout(const Duration(seconds: 8));
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
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Container(
            decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AidalyaLogoCompact(size: 120),
                  const SizedBox(height: 28),
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Préparation de l’application…',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
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
              title: 'Aidalya',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: ThemeMode.system,
              home: const MaintenanceScreen(),
            );
          }

          return MaterialApp(
            title: 'Aidalya',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            builder: (context, child) {
              return child!;
            },
            home: ConsentGate(
              child: SplashScreen(
                disableAutoNavigation: widget.disableSplashAutoNavigation,
              ),
            ),
          );
        },
      ),
    );
  }
}


