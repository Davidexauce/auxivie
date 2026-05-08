import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/settings_model.dart';
import '../services/backend_api_service.dart';

/// ViewModel pour gérer les paramètres de l'application
class SettingsViewModel extends ChangeNotifier {
  SettingsModel? _settings;
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _refreshTimer;

  SettingsModel? get settings => _settings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoaded => _settings != null;

  /// Charge les paramètres depuis l'API
  Future<void> loadSettings({bool forceRefresh = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final settings = await BackendApiService.getSettings(forceRefresh: forceRefresh);
      
      if (settings != null) {
        _settings = settings;
        _errorMessage = null;
      } else {
        // Utiliser les valeurs par défaut si l'API échoue
        _settings = SettingsModel.defaults();
        _errorMessage = 'Impossible de charger les paramètres, utilisation des valeurs par défaut';
      }
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des paramètres: $e';
      _settings = SettingsModel.defaults();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Initialise les paramètres et démarre le rafraîchissement automatique
  Future<void> initialize({bool fastStartup = false}) async {
    if (fastStartup) {
      // Démarrage ultra-rapide: valeurs par défaut immédiates, puis synchro réseau en arrière-plan.
      if (_settings == null) {
        _settings = SettingsModel.defaults();
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      }
      unawaited(loadSettings(forceRefresh: true));
    } else {
      await loadSettings();
    }

    _startAutoRefresh();
  }

  /// Démarre le rafraîchissement automatique (toutes les heures)
  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(hours: 1), (_) {
      loadSettings(forceRefresh: true);
    });
  }

  /// Arrête le rafraîchissement automatique
  void stopAutoRefresh() {
    _refreshTimer?.cancel();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}

