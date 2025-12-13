import '../constants/payment_constants.dart';

class PaymentHelper {
  /// Calcule le montant total d'une réservation
  static double calculateReservationAmount({
    required DateTime dateDebut,
    DateTime? dateFin,
    required double tarifHoraire,
    int heuresParJour = 8,
  }) {
    // Si réservation multi-jours
    if (dateFin != null) {
      final nombreJours = dateFin.difference(dateDebut).inDays + 1;
      return nombreJours * heuresParJour * tarifHoraire;
    }
   
    // Sinon, une journée
    return heuresParJour * tarifHoraire;
  }

  /// Formate un montant en devise EUR
  static String formatAmount(double amount) {
    return '${amount.toStringAsFixed(2)} ${PaymentConstants.currencySymbol}';
  }
}

