/// Modèle pour les avis
class ReviewModel {
  final int? id;
  final int? reservationId;
  final int userId;
  final int professionalId;
  final int rating;              // Note de 1 à 5
  final String? comment;
  final String? createdAt;
  final String? userName;
  final String? professionalName;
  final String? professionalEmail;

  ReviewModel({
    this.id,
    this.reservationId,
    required this.userId,
    required this.professionalId,
    required this.rating,
    this.comment,
    this.createdAt,
    this.userName,
    this.professionalName,
    this.professionalEmail,
  });

  /// Validation de la note
  bool get isValidRating => rating >= 1 && rating <= 5;

  /// Vérifier si l'avis a un commentaire
  bool get hasComment => comment != null && comment!.trim().isNotEmpty;

  /// Obtenir la date formatée
  DateTime? get createdAtDate {
    if (createdAt == null) return null;
    try {
      return DateTime.parse(createdAt!);
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reservationId': reservationId,
      'userId': userId,
      'professionalId': professionalId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt,
      'userName': userName,
      'professionalName': professionalName,
      'professionalEmail': professionalEmail,
    };
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
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

    final date = parseDate(map['createdAt']);
    
    return ReviewModel(
      id: map['id'] as int?,
      reservationId: map['reservationId'] as int?,
      userId: map['userId'] as int? ?? map['reviewerId'] as int? ?? 0,
      professionalId: map['professionalId'] as int? ?? map['reviewedUserId'] as int? ?? 0,
      rating: map['rating'] as int,
      comment: map['comment'] as String?,
      createdAt: date?.toIso8601String(),
      userName: map['userName'] as String?,
      professionalName: map['professionalName'] as String?,
      professionalEmail: map['professionalEmail'] as String?,
    );
  }

  /// Crée une copie du modèle avec des champs modifiés
  ReviewModel copyWith({
    int? id,
    int? reservationId,
    int? userId,
    int? professionalId,
    int? rating,
    String? comment,
    String? createdAt,
    String? userName,
    String? professionalName,
    String? professionalEmail,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      reservationId: reservationId ?? this.reservationId,
      userId: userId ?? this.userId,
      professionalId: professionalId ?? this.professionalId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      userName: userName ?? this.userName,
      professionalName: professionalName ?? this.professionalName,
      professionalEmail: professionalEmail ?? this.professionalEmail,
    );
  }
}

