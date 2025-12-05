import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';
import '../services/backend_api_service.dart';

/// ViewModel pour la gestion des profils
class ProfileViewModel extends ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;
  
  List<UserModel> _professionals = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedCity;
  String? _selectedCategory;

  /// Liste des professionnels
  List<UserModel> get professionals => _professionals;

  /// Indique si une opération est en cours
  bool get isLoading => _isLoading;

  /// Message d'erreur éventuel
  String? get errorMessage => _errorMessage;

  /// Ville sélectionnée pour le filtre
  String? get selectedCity => _selectedCity;

  /// Catégorie sélectionnée pour le filtre
  String? get selectedCategory => _selectedCategory;

  /// Charge tous les professionnels
  Future<void> loadProfessionals() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Charger depuis le backend (base de données unique)
      _professionals = await BackendApiService.getProfessionals();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des professionnels';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Recherche des professionnels avec filtres
  Future<void> searchProfessionals({
    String? ville,
    String? categorie,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _selectedCity = ville;
    _selectedCategory = categorie;
    notifyListeners();

    try {
      // Charger tous les professionnels depuis le backend
      final allProfessionals = await BackendApiService.getProfessionals();
      
      // Appliquer les filtres localement
      _professionals = allProfessionals.where((p) {
        if (ville != null && p.ville != ville) return false;
        if (categorie != null && p.categorie != categorie) return false;
        return true;
      }).toList();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors de la recherche';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Récupère un professionnel par son ID
  Future<UserModel?> getProfessionalById(int id) async {
    try {
      return await _db.getUserById(id);
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement du professionnel';
      notifyListeners();
      return null;
    }
  }

  /// Met à jour le profil d'un utilisateur
  Future<bool> updateProfile(UserModel user) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _db.updateUser(user);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de la mise à jour du profil';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Récupère la liste des villes disponibles
  Future<List<String>> getAvailableCities() async {
    try {
      // Charger depuis le backend
      final professionals = await BackendApiService.getProfessionals();
      final cities = professionals
          .where((p) => p.ville != null && p.ville!.isNotEmpty)
          .map((p) => p.ville!)
          .toSet()
          .toList();
      cities.sort();
      return cities;
    } catch (e) {
      return [];
    }
  }

  /// Récupère la liste des catégories disponibles
  Future<List<String>> getAvailableCategories() async {
    try {
      // Charger depuis le backend
      final professionals = await BackendApiService.getProfessionals();
      final categories = professionals
          .map((p) => p.categorie)
          .toSet()
          .toList();
      categories.sort();
      return categories;
    } catch (e) {
      return [];
    }
  }

  /// Réinitialise les filtres
  void resetFilters() {
    _selectedCity = null;
    _selectedCategory = null;
    notifyListeners();
  }
}









