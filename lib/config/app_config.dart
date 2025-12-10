import 'dart:io';

/// Configuration de l'application par environnement
class AppConfig {
  // Environnement actuel
  static const Environment _currentEnvironment = Environment.production;
  
  // URLs de l'API selon l'environnement
  static String get apiBaseUrl {
    switch (_currentEnvironment) {
      case Environment.development:
        // Détection automatique de la plateforme
        if (Platform.isAndroid) {
          // Android Emulator utilise 10.0.2.2 pour accéder à localhost de la machine hôte
          return 'http://10.0.2.2:3001';
        } else if (Platform.isIOS) {
          // iOS Simulator peut utiliser localhost directement
          return 'http://localhost:3001';
        } else {
          // Pour les autres plateformes (web, desktop), utiliser localhost
          return 'http://localhost:3001';
        }
      
      case Environment.staging:
        return 'https://api-staging.auxivie.org';
      
      case Environment.production:
        return 'https://api.auxivie.org';
    }
  }
  
  // Timeout pour les requêtes API
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // Debug mode
  static bool get isDebugMode => _currentEnvironment != Environment.production;
  
  // Logging
  static bool get enableLogging => _currentEnvironment != Environment.production;
}

enum Environment {
  development,
  staging,
  production,
}

