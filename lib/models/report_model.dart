/// Modèle pour les signalements utilisateurs
class ReportModel {
  final int? id;
  final int reporterId;
  final int reportedUserId;
  final String reason;
  final String? description;
  final String status; // 'open', 'resolved', 'dismissed'
  final String? adminNotes;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  
  // Informations utilisateurs (pour affichage)
  final String? reporterName;
  final String? reporterEmail;
  final String? reportedName;
  final String? reportedEmail;

  ReportModel({
    this.id,
    required this.reporterId,
    required this.reportedUserId,
    required this.reason,
    this.description,
    this.status = 'open',
    this.adminNotes,
    required this.createdAt,
    this.resolvedAt,
    this.reporterName,
    this.reporterEmail,
    this.reportedName,
    this.reportedEmail,
  });

  /// Créer depuis JSON (API)
  factory ReportModel.fromMap(Map<String, dynamic> map) {
    DateTime? parseDate(dynamic dateValue) {
      if (dateValue == null) return null;
      if (dateValue is DateTime) return dateValue;
      if (dateValue is String) {
        try {
          return DateTime.parse(dateValue);
        } catch (e) {
          return null;
        }
      }
      return null;
    }

    // Le backend peut retourner soit 'reason'/'description' soit 'type'/'message'
    final reason = map['reason'] as String? ?? map['type'] as String? ?? 'other';
    final description = map['description'] as String? ?? map['message'] as String?;
    // Le backend peut retourner soit 'reportedUserId' soit 'userId'
    final reportedUserIdValue = map['reportedUserId'] ?? map['userId'];
    
    // Parser reporterId de manière sécurisée
    int? parseReporterId(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }
    
    return ReportModel(
      id: map['id'] as int?,
      reporterId: parseReporterId(map['reporterId']) ?? 0,
      reportedUserId: reportedUserIdValue != null
          ? (reportedUserIdValue is int
              ? reportedUserIdValue
              : (reportedUserIdValue is num
                  ? reportedUserIdValue.toInt()
                  : int.tryParse(reportedUserIdValue.toString()) ?? 0))
          : 0,
      reason: reason,
      description: description,
      status: (map['status'] as String?) ?? 'open',
      adminNotes: map['adminNotes'] as String?,
      createdAt: parseDate(map['createdAt']) ?? DateTime.now(),
      resolvedAt: parseDate(map['resolvedAt']),
      // Support des deux formats : reporterName/reportedName (ancien) ou userName/reportedUserName (nouveau)
      reporterName: map['reporterName'] as String? ?? map['userName'] as String?,
      reporterEmail: map['reporterEmail'] as String? ?? map['userEmail'] as String?,
      reportedName: map['reportedName'] as String? ?? map['reportedUserName'] as String?,
      reportedEmail: map['reportedEmail'] as String? ?? map['reportedUserEmail'] as String?,
    );
  }

  /// Convertir en JSON (pour envoi API)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'reporterId': reporterId,
      'reportedUserId': reportedUserId,
      'reason': reason,
      if (description != null) 'description': description,
      'status': status,
      if (adminNotes != null) 'adminNotes': adminNotes,
      'createdAt': createdAt.toIso8601String(),
      if (resolvedAt != null) 'resolvedAt': resolvedAt!.toIso8601String(),
    };
  }

  /// Obtenir l'icône selon la raison
  String get reasonIcon {
    switch (reason) {
      case 'spam':
        return '🚫';
      case 'harassment':
        return '😡';
      case 'fake_profile':
        return '🎭';
      case 'inappropriate_content':
        return '📵';
      default:
        return '❓';
    }
  }

  /// Obtenir le libellé de la raison
  String get reasonLabel {
    switch (reason) {
      case 'spam':
        return 'Spam ou publicité';
      case 'harassment':
        return 'Harcèlement ou insultes';
      case 'fake_profile':
        return 'Faux profil';
      case 'inappropriate_content':
        return 'Contenu inapproprié';
      case 'other':
        return 'Autre raison';
      default:
        return reason;
    }
  }

  /// Obtenir le badge de statut
  String get statusBadge {
    switch (status) {
      case 'open':
        return '🟡 En cours';
      case 'resolved':
        return '✅ Résolu';
      case 'dismissed':
        return '❌ Rejeté';
      default:
        return status;
    }
  }
}

