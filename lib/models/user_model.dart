/// Modèle de données pour un utilisateur
class UserModel {
  final int? id;
  final String name;
  final String email;
  final String password;
  final String? phone;
  final String categorie; // 'Auxiliaire de vie' ou 'Aide-soignant' ou 'Famille'
  final String? ville;
  final double? tarif;
  final int? experience; // années d'expérience
  final String? photo;
  final String userType; // 'professionnel' ou 'famille'
  // Champs spécifiques aux familles
  final String? besoin; // Besoins de la famille
  final String? preference; // Préférences de la famille
  final String? mission; // Mission demandée
  final String? particularite; // Particularités

  UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    this.phone,
    required this.categorie,
    this.ville,
    this.tarif,
    this.experience,
    this.photo,
    required this.userType,
    this.besoin,
    this.preference,
    this.mission,
    this.particularite,
  });

  /// Convertit le modèle en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'categorie': categorie,
      'ville': ville,
      'tarif': tarif,
      'experience': experience,
      'photo': photo,
      'userType': userType,
      'besoin': besoin,
      'preference': preference,
      'mission': mission,
      'particularite': particularite,
    };
  }

  /// Helper pour convertir un valeur en int de manière sécurisée
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is num) return value.toInt();
    return null;
  }

  /// Helper pour convertir une valeur en double de manière sécurisée
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    if (value is num) return value.toDouble();
    return null;
  }

  /// Crée un UserModel à partir d'un Map (API ou SQLite)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: _parseInt(map['id']),
      name: map['name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      password: map['password']?.toString() ?? '', // Peut être absent depuis l'API
      phone: map['phone']?.toString(),
      categorie: map['categorie']?.toString() ?? 'Famille',
      ville: map['ville']?.toString(),
      tarif: _parseDouble(map['tarif']),
      experience: _parseInt(map['experience']),
      photo: map['photo']?.toString(),
      userType: map['userType']?.toString() ?? 'famille',
      besoin: map['besoin']?.toString(),
      preference: map['preference']?.toString(),
      mission: map['mission']?.toString(),
      particularite: map['particularite']?.toString(),
    );
  }

  get photoPath => null;

  /// Crée une copie du modèle avec des champs modifiés
  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? password,
    String? phone,
    String? categorie,
    String? ville,
    double? tarif,
    int? experience,
    String? photo,
    String? userType,
    String? besoin,
    String? preference,
    String? mission,
    String? particularite,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      categorie: categorie ?? this.categorie,
      ville: ville ?? this.ville,
      tarif: tarif ?? this.tarif,
      experience: experience ?? this.experience,
      photo: photo ?? this.photo,
      userType: userType ?? this.userType,
      besoin: besoin ?? this.besoin,
      preference: preference ?? this.preference,
      mission: mission ?? this.mission,
      particularite: particularite ?? this.particularite,
    );
  }
}


