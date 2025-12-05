import 'package:flutter/foundation.dart';
import '../models/reservation_model.dart';
import '../services/backend_api_service.dart';

/// ViewModel pour la gestion des réservations
class ReservationViewModel extends ChangeNotifier {
  
  List<ReservationModel> _reservations = [];
  bool _isLoading = false;
  String? _errorMessage;

  /// Liste des réservations
  List<ReservationModel> get reservations => _reservations;

  /// Indique si une opération est en cours
  bool get isLoading => _isLoading;

  /// Message d'erreur éventuel
  String? get errorMessage => _errorMessage;

  /// Charge toutes les réservations d'un utilisateur
  Future<void> loadUserReservations(int userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Charger depuis le backend (base de données unique)
      _reservations = await BackendApiService.getUserReservations(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des réservations';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Charge les réservations d'un professionnel
  Future<void> loadProfessionalReservations(int professionnelId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Charger depuis le backend (base de données unique)
      _reservations = await BackendApiService.getProfessionalReservations(professionnelId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des réservations';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Crée une nouvelle réservation (peut être sur plusieurs jours)
  Future<bool> createReservation({
    required int userId,
    required int professionnelId,
    required DateTime date,
    DateTime? dateFin,
    required String heure,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Vérifier si la date n'est pas dans le passé
      final now = DateTime.now();
      final reservationDate = DateTime(date.year, date.month, date.day);
      final today = DateTime(now.year, now.month, now.day);
      
      if (reservationDate.isBefore(today)) {
        _errorMessage = 'Impossible de réserver une date passée';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Si dateFin est fournie, créer une réservation pour chaque jour
      if (dateFin != null) {
        final dateFinNormalized = DateTime(dateFin.year, dateFin.month, dateFin.day);
        final dateDebutNormalized = DateTime(date.year, date.month, date.day);
        
        if (dateFinNormalized.isBefore(dateDebutNormalized)) {
          _errorMessage = 'La date de fin doit être après la date de début';
          _isLoading = false;
          notifyListeners();
          return false;
        }

        // Créer une réservation pour chaque jour
        bool allSuccess = true;
        DateTime currentDate = dateDebutNormalized;
        
        while (!currentDate.isAfter(dateFinNormalized)) {
          final reservation = ReservationModel(
            userId: userId,
            professionnelId: professionnelId,
            date: currentDate,
            dateFin: dateFinNormalized,
            heure: heure,
            status: 'pending',
          );

          final success = await BackendApiService.createReservation(reservation);
          if (!success) {
            allSuccess = false;
            break;
          }
          
          currentDate = currentDate.add(const Duration(days: 1));
        }

        if (!allSuccess) {
          _errorMessage = 'Erreur lors de la création de certaines réservations';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      } else {
        // Réservation sur un seul jour
        final reservation = ReservationModel(
          userId: userId,
          professionnelId: professionnelId,
          date: date,
          heure: heure,
          status: 'pending',
        );

        final success = await BackendApiService.createReservation(reservation);
        if (!success) {
          _errorMessage = 'Erreur lors de la création de la réservation';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }
      
      // Recharger les réservations depuis le backend
      await loadUserReservations(userId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de la création de la réservation';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Met à jour une réservation
  Future<bool> updateReservation(ReservationModel reservation) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Mettre à jour directement dans le backend
      final success = await BackendApiService.updateReservation(reservation);
      if (!success) {
        _errorMessage = 'Erreur lors de la mise à jour de la réservation';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      // Recharger les réservations depuis le backend
      await loadUserReservations(reservation.userId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de la mise à jour de la réservation';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Confirme une réservation
  Future<bool> confirmReservation(ReservationModel reservation) async {
    final updatedReservation = reservation.copyWith(status: 'confirmed');
    return await updateReservation(updatedReservation);
  }

  /// Annule une réservation
  Future<bool> cancelReservation(ReservationModel reservation) async {
    final updatedReservation = reservation.copyWith(status: 'cancelled');
    return await updateReservation(updatedReservation);
  }

  /// Supprime une réservation
  Future<bool> deleteReservation(int reservationId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Supprimer directement dans le backend
      // TODO: Implémenter la suppression via API si nécessaire
      // Pour l'instant, retirer de la liste locale
      _reservations.removeWhere((r) => r.id == reservationId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de la suppression de la réservation';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Efface le message d'erreur
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

