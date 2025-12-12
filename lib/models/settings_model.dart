/// Modèle pour les paramètres système de la plateforme
class SettingsModel {
  final double platformFee; // Commission en %
  final int cancellationDelay; // Heures avant réservation pour annulation gratuite
  final String contactEmail;
  final String supportPhone;
  final List<String> paymentMethods;
  final int minReservationHours;
  final int maxReservationHours;
  final bool autoApproveDocuments;
  final bool sendEmailNotifications;
  final bool sendSMSNotifications;
  final bool maintenanceMode;

  SettingsModel({
    required this.platformFee,
    required this.cancellationDelay,
    required this.contactEmail,
    required this.supportPhone,
    required this.paymentMethods,
    required this.minReservationHours,
    required this.maxReservationHours,
    required this.autoApproveDocuments,
    required this.sendEmailNotifications,
    required this.sendSMSNotifications,
    required this.maintenanceMode,
  });

  /// Crée un SettingsModel à partir d'un Map (API)
  factory SettingsModel.fromMap(Map<String, dynamic> map) {
    return SettingsModel(
      platformFee: (map['platformFee'] as num?)?.toDouble() ?? 15.0,
      cancellationDelay: (map['cancellationDelay'] as num?)?.toInt() ?? 24,
      contactEmail: map['contactEmail'] as String? ?? 'contact@auxivie.org',
      supportPhone: map['supportPhone'] as String? ?? '',
      paymentMethods: (map['paymentMethods'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          ['card', 'stripe'],
      minReservationHours: (map['minReservationHours'] as num?)?.toInt() ?? 2,
      maxReservationHours: (map['maxReservationHours'] as num?)?.toInt() ?? 24,
      autoApproveDocuments:
          map['autoApproveDocuments'] as bool? ?? false,
      sendEmailNotifications:
          map['sendEmailNotifications'] as bool? ?? true,
      sendSMSNotifications: map['sendSMSNotifications'] as bool? ?? false,
      maintenanceMode: map['maintenanceMode'] as bool? ?? false,
    );
  }
}

