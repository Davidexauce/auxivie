import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/backend_api_service.dart';
import '../utils/user_display_name.dart';

/// ViewModel pour la gestion de l'authentification
class AuthViewModel extends ChangeNotifier {
  
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  /// Utilisateur actuellement connecté
  UserModel? get currentUser => _currentUser;

  /// Indique si un utilisateur est connecté
  bool get isAuthenticated => _currentUser != null;

  /// Indique si une opération est en cours
  bool get isLoading => _isLoading;

  /// Message d'erreur éventuel
  String? get errorMessage => _errorMessage;

  /// Initialise le ViewModel et restaure l'utilisateur connecté
  Future<void> init() async {
    final userData = await BackendApiService.getCurrentUser();
    if (userData != null) {
      _currentUser = UserModel.fromMap(userData);
      notifyListeners();
    }
  }

  /// Connexion d'un utilisateur
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Connexion via l'API backend
      final loginResult = await BackendApiService.login(email, password);
      
      if (loginResult != null && loginResult['user'] != null) {
        // Connexion réussie via l'API
        final userData = loginResult['user'] as Map<String, dynamic>;
        _currentUser = UserModel.fromMap(userData);
        // Le token est déjà sauvegardé dans BackendApiService.login()
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _errorMessage = 'Email ou mot de passe incorrect';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Inscription d'un nouvel utilisateur
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    required String categorie,
    String? ville,
    double? tarif,
    int? experience,
    required String userType,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Créer le nouvel utilisateur directement dans le backend (base unique)
      // Le backend gérera la vérification d'email existant
      final user = UserModel(
        name: sanitizeUserDisplayName(name.trim(), experience: experience),
        email: email,
        password: password, // En production, hasher avec bcrypt
        phone: phone,
        categorie: categorie,
        ville: ville,
        tarif: tarif,
        experience: experience,
        userType: userType,
      );

      // Créer directement dans le backend
      final result = await BackendApiService.createUser(user);
      if (result == null) {
        _errorMessage = 'Impossible de se connecter au serveur. Vérifiez votre connexion internet ou que l\'API est disponible.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Récupérer l'ID de l'utilisateur créé depuis la réponse
      final userId = result['id'] as int?;
      if (userId == null) {
        _errorMessage = 'Erreur lors de la création du compte';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Si un token n'a pas été retourné par syncUser, se connecter automatiquement
      final token = await BackendApiService.getToken();
      if (token == null || token.isEmpty) {
        // Se connecter automatiquement après l'inscription pour obtenir un token
        final loginResult = await BackendApiService.login(email, password);
        if (loginResult == null || loginResult['token'] == null) {
          _errorMessage = 'Compte créé mais impossible de se connecter automatiquement. Veuillez vous connecter manuellement.';
          _isLoading = false;
          notifyListeners();
          return false;
        }
        // Le token est déjà sauvegardé par login()
      }

      // Récupérer l'utilisateur créé depuis le backend avec l'ID (route publique)
      final createdUser = await BackendApiService.getUserById(userId);
      if (createdUser == null) {
        _errorMessage = 'Erreur lors de la récupération du compte';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _currentUser = createdUser;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de l\'inscription';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Déconnexion de l'utilisateur
  Future<void> logout() async {
    await BackendApiService.logout();
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Efface le message d'erreur
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Réservé aux captures App Store / tests d’intégration (utilisateur fictif, sans API).
  void setScreenshotDemoUser(UserModel user) {
    _currentUser = user;
    _errorMessage = null;
    notifyListeners();
  }
}
