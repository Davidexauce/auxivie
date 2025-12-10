/// Modèle pour les badges utilisateur
class BadgeModel {
  final int? id;
  final int userId;
  final String badgeType;
  final String badgeName;
  final String? badgeIcon;
  final String? description;
  final String? createdAt;

  BadgeModel({
    this.id,
    required this.userId,
    required this.badgeType,
    required this.badgeName,
    this.badgeIcon,
    this.description,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'badgeType': badgeType,
      'badgeName': badgeName,
      'badgeIcon': badgeIcon,
      'description': description,
      'createdAt': createdAt,
    };
  }

  factory BadgeModel.fromMap(Map<String, dynamic> map) {
    return BadgeModel(
      id: map['id'] as int?,
      userId: map['userId'] as int,
      badgeType: map['badgeType'] as String,
      badgeName: map['badgeName'] as String,
      badgeIcon: map['badgeIcon'] as String?,
      description: map['description'] as String?,
      createdAt: map['createdAt'] as String?,
    );
  }
}

