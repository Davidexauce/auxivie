import 'package:flutter/foundation.dart';
import '../models/reservation_model.dart';
import '../services/database_service.dart';

/// ViewModel pour la gestion des réservations
class ReservationViewModel extends ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;
  
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
      _reservations = await _db.getUserReservations(userId);
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
      _reservations = await _db.getProfessionalReservations(professionnelId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des réservations';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Crée une nouvelle réservation
  Future<bool> createReservation({
    required int userId,
    required int professionnelId,
    required DateTime date,
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

      final reservation = ReservationModel(
        userId: userId,
        professionnelId: professionnelId,
        date: date,
        heure: heure,
        status: 'pending',
      );

      await _db.createReservation(reservation);
      
      // Recharger les réservations
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
      await _db.updateReservation(reservation);
      
      // Recharger les réservations
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
      await _db.deleteReservation(reservationId);
      
      // Retirer de la liste locale
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

