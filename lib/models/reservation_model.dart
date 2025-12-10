/// Modèle de données pour une réservation
class ReservationModel {
  final int? id;
  final int userId; // ID de la famille
  final int professionnelId; // ID du professionnel
  final DateTime date;
  final DateTime? dateFin; // Date de fin pour les réservations multi-jours (obsolète - utiliser plusieurs réservations)
  final String heure; // Format "HH:mm" - Heure de début
  final String? heureFin; // Format "HH:mm" - Heure de fin (nouveau)
  final String? besoins; // Besoins spécifiques communiqués par la famille pour cette réservation
  final String status; // 'pending', 'confirmed', 'completed', 'cancelled'

  ReservationModel({
    this.id,
    required this.userId,
    required this.professionnelId,
    required this.date,
    this.dateFin,
    required this.heure,
    this.heureFin,
    this.besoins,
    this.status = 'pending',
  });

  /// Convertit le modèle en Map pour SQLite ou API
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'professionnelId': professionnelId,
      'date': date.toIso8601String(),
      'dateFin': dateFin?.toIso8601String(),
      'heure': heure,
      'heureFin': heureFin,
      'besoins': besoins,
      'status': status,
    };
  }

  /// Crée un ReservationModel à partir d'un Map SQLite ou API
  factory ReservationModel.fromMap(Map<String, dynamic> map) {
    // Gérer le format de date (ISO 8601 avec T ou format YYYY-MM-DD)
    DateTime parseDate(String dateStr) {
      if (dateStr.contains('T')) {
        return DateTime.parse(dateStr);
      } else {
        // Format YYYY-MM-DD
        final parts = dateStr.split('-');
        if (parts.length == 3) {
          return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
        }
        return DateTime.parse(dateStr);
      }
    }

    return ReservationModel(
      id: map['id'] as int?,
      userId: map['userId'] as int,
      professionnelId: map['professionnelId'] as int,
      date: parseDate(map['date'] as String),
      dateFin: map['dateFin'] != null ? parseDate(map['dateFin'] as String) : null,
      heure: map['heure'] as String,
      heureFin: map['heureFin'] as String?,
      besoins: map['besoins'] as String?,
      status: map['status'] as String? ?? 'pending',
    );
  }

  /// Crée une copie du modèle avec des champs modifiés
  ReservationModel copyWith({
    int? id,
    int? userId,
    int? professionnelId,
    DateTime? date,
    DateTime? dateFin,
    String? heure,
    String? heureFin,
    String? besoins,
    String? status,
  }) {
    return ReservationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      professionnelId: professionnelId ?? this.professionnelId,
      date: date ?? this.date,
      dateFin: dateFin ?? this.dateFin,
      heure: heure ?? this.heure,
      heureFin: heureFin ?? this.heureFin,
      besoins: besoins ?? this.besoins,
      status: status ?? this.status,
    );
  }
  
  /// Calcule le nombre d'heures entre heure de début et heure de fin
  double get heures {
    if (heureFin == null || heureFin!.isEmpty) return 0.0;
    try {
      final debutParts = heure.split(':');
      final finParts = heureFin!.split(':');
      if (debutParts.length != 2 || finParts.length != 2) return 0.0;
      
      final debut = int.parse(debutParts[0]) * 60 + int.parse(debutParts[1]);
      final fin = int.parse(finParts[0]) * 60 + int.parse(finParts[1]);
      
      if (fin <= debut) return 0.0; // Heure de fin doit être après heure de début
      
      return (fin - debut) / 60.0; // Retourne en heures (double)
    } catch (e) {
      return 0.0;
    }
  }
}
