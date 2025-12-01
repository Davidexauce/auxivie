/// Modèle pour les notes utilisateur
class RatingModel {
  final int? id;
  final int userId;
  final double averageRating;
  final int totalRatings;
  final String? updatedAt;

  RatingModel({
    this.id,
    required this.userId,
    required this.averageRating,
    required this.totalRatings,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'averageRating': averageRating,
      'totalRatings': totalRatings,
      'updatedAt': updatedAt,
    };
  }

  factory RatingModel.fromMap(Map<String, dynamic> map) {
    return RatingModel(
      id: map['id'] as int?,
      userId: map['userId'] as int,
      averageRating: (map['averageRating'] as num).toDouble(),
      totalRatings: map['totalRatings'] as int,
      updatedAt: map['updatedAt'] as String?,
    );
  }
}

