import '../models/settings_model.dart';

/// Logger pour l'application avec support du mode debug
class AppLogger {
  static SettingsModel? _settings;

  static void init(SettingsModel? settings) {
    _settings = settings;
  }

  static void log(String message, {String? tag}) {
    if (_settings?.debugMode ?? false) {
      final timestamp = DateTime.now().toIso8601String();
      print('[$timestamp] ${tag ?? 'APP'}: $message');
    }
  }

  static void error(String message, {dynamic error, StackTrace? stackTrace}) {
    if (_settings?.debugMode ?? false) {
      final timestamp = DateTime.now().toIso8601String();
      print('[$timestamp] ERROR: $message');
      if (error != null) print('Error: $error');
      if (stackTrace != null) print('StackTrace: $stackTrace');
    }
  }

  static void network(String url, {dynamic request, dynamic response}) {
    if (_settings?.debugMode ?? false) {
      print('=== NETWORK REQUEST ===');
      print('URL: $url');
      if (request != null) print('Request: $request');
      if (response != null) print('Response: $response');
      print('=======================');
    }
  }
}

