import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';

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

      // Créer le nouvel utilisateur
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

      final userId = await _db.createUser(user);
      
      // Récupérer l'utilisateur créé avec son ID
      final createdUser = await _db.getUserById(userId);
      if (createdUser == null) {
        _errorMessage = 'Erreur lors de la création du compte';
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
}
