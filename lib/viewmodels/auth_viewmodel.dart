import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user_model.dart';
import '../services/database_service.dart';
import '../services/backend_api_service.dart';

/// ViewModel pour la gestion de l'authentification
class AuthViewModel extends ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;
  
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

  /// Connexion d'un utilisateur
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Essayer d'abord via l'API backend (base de données unique)
      final loginResult = await BackendApiService.login(email, password);
      
      if (loginResult != null && loginResult['user'] != null) {
        // Connexion réussie via l'API
        final userData = loginResult['user'];
        _currentUser = UserModel.fromMap(userData);
        // Le token est déjà défini dans BackendApiService.login()
        _isLoading = false;
        notifyListeners();
        return true;
      }

      // Fallback : essayer la base locale (pour compatibilité)
      final user = await _db.getUserByEmail(email);
      
      if (user == null) {
        _errorMessage = 'Email ou mot de passe incorrect';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Vérification simple du mot de passe (en production, utiliser bcrypt)
      if (user.password != password) {
        _errorMessage = 'Email ou mot de passe incorrect';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de la connexion';
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
      // Vérifier si l'email existe déjà
      final existingUser = await _db.getUserByEmail(email);
      if (existingUser != null) {
        _errorMessage = 'Cet email est déjà utilisé';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Créer le nouvel utilisateur directement dans le backend (base unique)
      final user = UserModel(
        name: name,
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
        _errorMessage = 'Erreur lors de la création du compte';
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
  void logout() {
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Efface le message d'erreur
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Synchronise un utilisateur avec le backend
  Future<void> _syncUserToBackend(UserModel user) async {
    try {
      print('🔄 Synchronisation utilisateur: ${user.email} (${user.userType})');
      
      final response = await http.post(
        Uri.parse('http://localhost:3001/api/users/sync'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': user.name,
          'email': user.email,
          'password': user.password,
          'phone': user.phone,
          'categorie': user.categorie,
          'ville': user.ville,
          'tarif': user.tarif,
          'experience': user.experience,
          'photo': user.photo,
          'userType': user.userType,
        }),
      ).timeout(const Duration(seconds: 10));

      print('📡 Réponse synchronisation: Status ${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = json.decode(response.body);
        print('✅ Utilisateur synchronisé avec le backend: ${responseBody}');
      } else {
        print('❌ Erreur synchronisation: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      // Erreur silencieuse - ne pas bloquer l'inscription
      print('❌ Erreur connexion backend: $e');
    }
  }
}
