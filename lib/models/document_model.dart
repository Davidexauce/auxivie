/// Modèle de données pour un document
class DocumentModel {
  final int? id;
  final int userId;
  final String type; // 'identite', 'diplome', 'rib', 'autre'
  final String path;
  final DateTime createdAt;

  DocumentModel({
    this.id,
    required this.userId,
    required this.type,
    required this.path,
    required this.createdAt,
  });

  /// Convertit le modèle en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'path': path,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Crée un DocumentModel à partir d'un Map SQLite
  factory DocumentModel.fromMap(Map<String, dynamic> map) {
    return DocumentModel(
      id: map['id'] as int?,
      userId: map['userId'] as int,
      type: map['type'] as String,
      path: map['path'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  /// Crée une copie du modèle avec des champs modifiés
  DocumentModel copyWith({
    int? id,
    int? userId,
    String? type,
    String? path,
    DateTime? createdAt,
  }) {
    return DocumentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      path: path ?? this.path,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

