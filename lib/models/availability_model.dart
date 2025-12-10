/// Modèle de données pour une disponibilité d'un professionnel
class AvailabilityModel {
  final int? id;
  final int professionnelId;
  final int jourSemaine; // 0 = Dimanche, 1 = Lundi, ..., 6 = Samedi
  final String heureDebut; // Format "HH:mm"
  final String heureFin; // Format "HH:mm"

  AvailabilityModel({
    this.id,
    required this.professionnelId,
    required this.jourSemaine,
    required this.heureDebut,
    required this.heureFin,
  });

  /// Convertit le modèle en Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'professionnelId': professionnelId,
      'jourSemaine': jourSemaine,
      'heureDebut': heureDebut,
      'heureFin': heureFin,
    };
  }

  /// Crée un AvailabilityModel à partir d'un Map
  factory AvailabilityModel.fromMap(Map<String, dynamic> map) {
    return AvailabilityModel(
      id: map['id'] as int?,
      professionnelId: map['professionnelId'] as int,
      jourSemaine: map['jourSemaine'] as int,
      heureDebut: map['heureDebut'] as String,
      heureFin: map['heureFin'] as String,
    );
  }

  /// Nom du jour de la semaine
  String get jourNom {
    const jours = ['Dimanche', 'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'];
    return jours[jourSemaine];
  }

  /// Crée une copie du modèle avec des champs modifiés
  AvailabilityModel copyWith({
    int? id,
    int? professionnelId,
    int? jourSemaine,
    String? heureDebut,
    String? heureFin,
  }) {
    return AvailabilityModel(
      id: id ?? this.id,
      professionnelId: professionnelId ?? this.professionnelId,
      jourSemaine: jourSemaine ?? this.jourSemaine,
      heureDebut: heureDebut ?? this.heureDebut,
      heureFin: heureFin ?? this.heureFin,
    );
  }
}

