/// Modèle pour les paramètres système de la plateforme
class SettingsModel {
  // Général
  final double platformFee; // Commission en %
  final int cancellationDelay; // Heures avant réservation pour annulation gratuite
  final String contactEmail;
  final String supportPhone;
  final int minReservationHours;
  final int maxReservationHours;
  
  // Paiements Stripe
  final String stripePublicKey;
  final String stripeMode; // 'test' ou 'production'
  
  // Notifications
  final bool autoApproveDocuments;
  final bool sendEmailNotifications;
  final bool sendSMSNotifications;
  
  // Sécurité
  final int maxLoginAttempts;
  final int lockoutDuration; // Minutes
  final int sessionTimeout; // Heures
  final bool require2FA;
  
  // Système
  final bool maintenanceMode;
  final bool debugMode;

  SettingsModel({
    required this.platformFee,
    required this.cancellationDelay,
    required this.contactEmail,
    required this.supportPhone,
    required this.minReservationHours,
    required this.maxReservationHours,
    required this.stripePublicKey,
    required this.stripeMode,
    required this.autoApproveDocuments,
    required this.sendEmailNotifications,
    required this.sendSMSNotifications,
    required this.maxLoginAttempts,
    required this.lockoutDuration,
    required this.sessionTimeout,
    required this.require2FA,
    required this.maintenanceMode,
    required this.debugMode,
  });

  /// Crée un SettingsModel à partir d'un Map (API)
  factory SettingsModel.fromMap(Map<String, dynamic> map) {
    return SettingsModel(
      platformFee: (map['platformFee'] as num?)?.toDouble() ?? 15.0,
      cancellationDelay: (map['cancellationDelay'] as num?)?.toInt() ?? 24,
      contactEmail: map['contactEmail'] as String? ?? 'contact@auxivie.org',
      supportPhone: map['supportPhone'] as String? ?? '+33 6 52 24 85 94',
      minReservationHours: (map['minReservationHours'] as num?)?.toInt() ?? 2,
      maxReservationHours: (map['maxReservationHours'] as num?)?.toInt() ?? 24,
      stripePublicKey: map['stripePublicKey'] as String? ?? '',
      stripeMode: map['stripeMode'] as String? ?? 'test',
      autoApproveDocuments: map['autoApproveDocuments'] as bool? ?? false,
      sendEmailNotifications: map['sendEmailNotifications'] as bool? ?? true,
      sendSMSNotifications: map['sendSMSNotifications'] as bool? ?? false,
      maxLoginAttempts: (map['maxLoginAttempts'] as num?)?.toInt() ?? 5,
      lockoutDuration: (map['lockoutDuration'] as num?)?.toInt() ?? 30,
      sessionTimeout: (map['sessionTimeout'] as num?)?.toInt() ?? 24,
      require2FA: map['require2FA'] as bool? ?? false,
      maintenanceMode: map['maintenanceMode'] as bool? ?? false,
      debugMode: map['debugMode'] as bool? ?? false,
    );
  }

  /// Crée un SettingsModel avec les valeurs par défaut
  factory SettingsModel.defaults() {
    return SettingsModel(
      platformFee: 15.0,
      cancellationDelay: 24,
      contactEmail: 'contact@auxivie.org',
      supportPhone: '+33 6 52 24 85 94',
      minReservationHours: 2,
      maxReservationHours: 24,
      stripePublicKey: '',
      stripeMode: 'test',
      autoApproveDocuments: false,
      sendEmailNotifications: true,
      sendSMSNotifications: false,
      maxLoginAttempts: 5,
      lockoutDuration: 30,
      sessionTimeout: 24,
      require2FA: false,
      maintenanceMode: false,
      debugMode: false,
    );
  }

  /// Calcule le montant total avec les frais de plateforme
  double calculateTotal(double basePrice) {
    return basePrice * (1 + platformFee / 100);
  }

  /// Calcule le montant des frais de plateforme
  double calculateFeeAmount(double basePrice) {
    return basePrice * (platformFee / 100);
  }

  /// Vérifie si une durée de réservation est valide
  bool isValidReservationDuration(int hours) {
    return hours >= minReservationHours && hours <= maxReservationHours;
  }

  /// Retourne un message d'erreur si la durée n'est pas valide
  String? validateReservationDuration(int hours) {
    if (hours < minReservationHours) {
      return 'Durée minimale: ${minReservationHours}h';
    }
    if (hours > maxReservationHours) {
      return 'Durée maximale: ${maxReservationHours}h';
    }
    return null;
  }

  /// Vérifie si une annulation est gratuite selon le délai
  bool canCancelFree(DateTime reservationStart) {
    final now = DateTime.now();
    final hoursUntilStart = reservationStart.difference(now).inHours;
    return hoursUntilStart >= cancellationDelay;
  }

  /// Retourne le texte de la politique d'annulation
  String getCancellationPolicyText() {
    return 'Annulation gratuite jusqu\'à ${cancellationDelay}h avant le début';
  }
}

