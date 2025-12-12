/// Modèle de données pour un document
class DocumentModel {
  final int? id;
  final int userId;
  final String type; // 'kbis', 'insurance', 'diploma', 'identity'
  final String? documentUrl; // URL du document depuis l'API
  final String? path; // Chemin local (obsolète, utiliser documentUrl)
  final String status; // 'pending', 'verified', 'rejected'
  final String? rejectReason; // Raison du rejet si status = 'rejected'
  final DateTime? uploadedAt;
  final DateTime? verifiedAt;
  final DateTime createdAt;

  DocumentModel({
    this.id,
    required this.userId,
    required this.type,
    this.documentUrl,
    this.path,
    this.status = 'pending',
    this.rejectReason,
    this.uploadedAt,
    this.verifiedAt,
    required this.createdAt,
  });

  /// Convertit le modèle en Map pour SQLite ou API
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'documentType': type,
      'documentUrl': documentUrl,
      'path': path,
      'status': status,
      'rejectReason': rejectReason,
      'uploadedAt': uploadedAt?.toIso8601String(),
      'verifiedAt': verifiedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Crée un DocumentModel à partir d'un Map (API ou SQLite)
  factory DocumentModel.fromMap(Map<String, dynamic> map) {
    // Gérer les formats de date
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

    return DocumentModel(
      id: map['id'] as int?,
      userId: map['userId'] as int? ?? (map['userId'] as num?)?.toInt() ?? 0,
      type: (map['documentType'] as String?) ?? (map['type'] as String?) ?? 'identity',
      documentUrl: map['documentUrl'] as String?,
      path: map['path'] as String?,
      status: (map['status'] as String?) ?? 'pending',
      rejectReason: map['rejectReason'] as String?,
      uploadedAt: parseDate(map['uploadedAt']),
      verifiedAt: parseDate(map['verifiedAt']),
      createdAt: parseDate(map['createdAt']) ?? DateTime.now(),
    );
  }

  /// Crée une copie du modèle avec des champs modifiés
  DocumentModel copyWith({
    int? id,
    int? userId,
    String? type,
    String? documentUrl,
    String? path,
    String? status,
    String? rejectReason,
    DateTime? uploadedAt,
    DateTime? verifiedAt,
    DateTime? createdAt,
  }) {
    return DocumentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      documentUrl: documentUrl ?? this.documentUrl,
      path: path ?? this.path,
      status: status ?? this.status,
      rejectReason: rejectReason ?? this.rejectReason,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
  
  /// Vérifie si le document est vérifié
  bool get isVerified => status == 'verified';
  
  /// Vérifie si le document est rejeté
  bool get isRejected => status == 'rejected';
  
  /// Vérifie si le document est en attente
  bool get isPending => status == 'pending';
}

