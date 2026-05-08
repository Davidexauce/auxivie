/// Modèle de données pour un utilisateur
class UserModel {
  final int? id;
  final String name;
  final String? firstName; // ✅ NOUVEAU
  final String? lastName; // ✅ NOUVEAU
  final String email;
  final String password;
  final String? phone;
  final String? dateOfBirth; // ✅ NOUVEAU (format string "YYYY-MM-DD")
  final String? address; // ✅ NOUVEAU
  final String categorie; // 'Auxiliaire de vie' ou 'Aide-soignant' ou 'Famille'
  final String? ville;
  final double? tarif;
  final int? experience; // années d'expérience
  final String? photo;
  final String userType; // 'professionnel' ou 'famille'
  final DateTime? dateNaissance; // Date de naissance
  // Champs spécifiques aux familles
  final String? besoin; // Besoins de la famille
  final String? preference; // Préférences de la famille
  final String? mission; // Mission demandée
  final String? particularite; // Particularités

  // Infos de protection
  final bool? isPhoneVisible;
  final bool? isEmailVisible;
  final String? infoMessage;
  /// IBAN / RIB stocké côté backend (paiements sortants).
  final String? rib;

  UserModel({
    this.id,
    required this.name,
    this.firstName,
    this.lastName,
    required this.email,
    required this.password,
    this.phone,
    this.dateOfBirth,
    this.address,
    required this.categorie,
    this.ville,
    this.tarif,
    this.experience,
    this.photo,
    required this.userType,
    this.dateNaissance,
    this.besoin,
    this.preference,
    this.mission,
    this.particularite,
    this.isPhoneVisible,
    this.isEmailVisible,
    this.infoMessage,
    this.rib,
  });

  /// Convertit le modèle en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'phone': phone,
      'dateOfBirth': dateOfBirth,
      'address': address,
      'categorie': categorie,
      'ville': ville,
      'tarif': tarif,
      'experience': experience,
      'photo': photo,
      'userType': userType,
      'dateNaissance': dateNaissance?.toIso8601String(),
      'besoin': besoin,
      'preference': preference,
      'mission': mission,
      'particularite': particularite,
      'rib': rib,
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

  /// Helper pour convertir une valeur en DateTime de manière sécurisée
  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.tryParse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Crée un UserModel à partir d'un Map (API ou SQLite)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    final phone = map['phone']?.toString();
    final email = map['email']?.toString() ?? '';
    
    // ✅ Gérer dateOfBirth (string) ET dateNaissance (DateTime) pour compatibilité
    DateTime? parsedDate;
    String? dateOfBirthString;
    
    // Priorité à dateOfBirth (nouveau format string)
    if (map['dateOfBirth'] != null) {
      dateOfBirthString = map['dateOfBirth']?.toString();
      parsedDate = _parseDate(dateOfBirthString);
    } else if (map['dateNaissance'] != null) {
      // Fallback sur dateNaissance (ancien format)
      parsedDate = _parseDate(map['dateNaissance']);
      if (parsedDate != null) {
        // Convertir en string pour dateOfBirth
        dateOfBirthString = '${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}';
      }
    }
   
    return UserModel(
      id: _parseInt(map['id']),
      name: map['name']?.toString() ?? '',
      firstName: map['firstName']?.toString(),
      lastName: map['lastName']?.toString(),
      email: email,
      password: map['password']?.toString() ?? '', // Peut être absent depuis l'API
      phone: phone,
      dateOfBirth: dateOfBirthString,
      address: map['address']?.toString(),
      categorie: map['categorie']?.toString() ?? 'Famille',
      ville: map['ville']?.toString(),
      tarif: _parseDouble(map['tarif']),
      experience: _parseInt(map['experience']),
      photo: map['photo']?.toString(),
      userType: map['userType']?.toString() ??
          map['user_type']?.toString() ??
          'famille',
      dateNaissance: parsedDate, // Garder pour compatibilité interne
      besoin: map['besoin']?.toString(),
      preference: map['preference']?.toString(),
      mission: map['mission']?.toString(),
      particularite: map['particularite']?.toString(),
      isPhoneVisible: phone != null && phone != '***' && phone.isNotEmpty,
      isEmailVisible: email.isNotEmpty && !email.contains('***'),
      infoMessage: map['infoMessage']?.toString(),
      rib: map['rib']?.toString() ?? map['iban']?.toString(),
    );
  }

  String? get photoPath => null;

  /// Vérifie si le téléphone est masqué
  bool get isPhoneMasked {
    if (phone == null || phone == '***') return true;
    if (isPhoneVisible == false) return true;
    return phone!.isEmpty;
  }
 
  /// Vérifie si l'email est masqué
  bool get isEmailMasked => email.contains('***') || (isEmailVisible == false);

  /// Calcule l'âge à partir de la date de naissance
  int? get age {
    DateTime? birthDate;
    
    // Priorité à dateNaissance (DateTime), sinon parser dateOfBirth (string)
    if (dateNaissance != null) {
      birthDate = dateNaissance;
    } else if (dateOfBirth != null && dateOfBirth!.isNotEmpty) {
      try {
        if (dateOfBirth!.contains('-')) {
          birthDate = DateTime.tryParse(dateOfBirth!);
        } else if (dateOfBirth!.contains('/')) {
          final parts = dateOfBirth!.split('/');
          if (parts.length == 3) {
            birthDate = DateTime.tryParse('${parts[2]}-${parts[1]}-${parts[0]}');
          }
        }
      } catch (e) {
        return null;
      }
    }
    
    if (birthDate == null) return null;
    
    try {
      final now = DateTime.now();
      int calculatedAge = now.year - birthDate.year;
      if (now.month < birthDate.month || 
          (now.month == birthDate.month && now.day < birthDate.day)) {
        calculatedAge--;
      }
      // Vérifier que l'âge est valide (entre 0 et 150 ans)
      if (calculatedAge < 0 || calculatedAge > 150) return null;
      return calculatedAge;
    } catch (e) {
      return null;
    }
  }

  /// Retourne le nom complet (firstName + lastName ou name)
  String get fullName {
    if (firstName != null && lastName != null && firstName!.isNotEmpty && lastName!.isNotEmpty) {
      return '$firstName $lastName';
    } else if (firstName != null && firstName!.isNotEmpty) {
      return firstName!;
    } else if (lastName != null && lastName!.isNotEmpty) {
      return lastName!;
    }
    return name;
  }

  /// Crée une copie du modèle avec des champs modifiés
  UserModel copyWith({
    int? id,
    String? name,
    String? firstName,
    String? lastName,
    String? email,
    String? password,
    String? phone,
    String? dateOfBirth,
    String? address,
    String? categorie,
    String? ville,
    double? tarif,
    int? experience,
    String? photo,
    String? userType,
    DateTime? dateNaissance,
    String? besoin,
    String? preference,
    String? mission,
    String? particularite,
    bool? isPhoneVisible,
    bool? isEmailVisible,
    String? infoMessage,
    String? rib,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      address: address ?? this.address,
      categorie: categorie ?? this.categorie,
      ville: ville ?? this.ville,
      tarif: tarif ?? this.tarif,
      experience: experience ?? this.experience,
      photo: photo ?? this.photo,
      userType: userType ?? this.userType,
      dateNaissance: dateNaissance ?? this.dateNaissance,
      besoin: besoin ?? this.besoin,
      preference: preference ?? this.preference,
      mission: mission ?? this.mission,
      particularite: particularite ?? this.particularite,
      isPhoneVisible: isPhoneVisible ?? this.isPhoneVisible,
      isEmailVisible: isEmailVisible ?? this.isEmailVisible,
      infoMessage: infoMessage ?? this.infoMessage,
      rib: rib ?? this.rib,
    );
  }
}


