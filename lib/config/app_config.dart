/// Configuration de l'application par environnement
class AppConfig {
  // Environnement actuel
  static const Environment _currentEnvironment = Environment.production;
  
  // URLs de l'API selon l'environnement
  static String get apiBaseUrl {
    switch (_currentEnvironment) {
      case Environment.development:
        // Pour iOS Simulator
        return 'http://localhost:3001';
        // Pour Android Emulator, décommentez la ligne suivante :
        // return 'http://10.0.2.2:3001';
      
      case Environment.staging:
        return 'https://api-staging.votre-domaine.com';
      
      case Environment.production:
        return 'https://api.votre-domaine.com';
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

