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
    // Fonction helper pour parser les nombres qui peuvent être String, int, double ou num
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      if (value is num) return value.toDouble();
      return null;
    }

    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      if (value is num) return value.toInt();
      return null;
    }

    return RatingModel(
      id: parseInt(map['id']),
      userId: parseInt(map['userId']) ?? 0,
      averageRating: parseDouble(map['averageRating']) ?? 0.0,
      totalRatings: parseInt(map['totalRatings']) ?? 0,
      updatedAt: map['updatedAt'] as String?,
    );
  }
}

