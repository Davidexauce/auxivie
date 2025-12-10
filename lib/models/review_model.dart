/// Modèle pour les avis
class ReviewModel {
  final int? id;
  final int? reservationId;
  final int userId;
  final int professionalId;
  final int rating;
  final String? comment;
  final String? createdAt;
  final String? userName;
  final String? professionalName;

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
  });

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
    };
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: map['id'] as int?,
      reservationId: map['reservationId'] as int?,
      userId: map['userId'] as int,
      professionalId: map['professionalId'] as int,
      rating: map['rating'] as int,
      comment: map['comment'] as String?,
      createdAt: map['createdAt'] as String?,
      userName: map['userName'] as String?,
      professionalName: map['professionalName'] as String?,
    );
  }
}

