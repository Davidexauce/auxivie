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
    };
  }

  /// Crée un UserModel à partir d'un Map SQLite
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      phone: map['phone'] as String?,
      categorie: map['categorie'] as String,
      ville: map['ville'] as String?,
      tarif: map['tarif'] != null ? (map['tarif'] as num).toDouble() : null,
      experience: map['experience'] as int?,
      photo: map['photo'] as String?,
      userType: map['userType'] as String,
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
    );
  }
}


