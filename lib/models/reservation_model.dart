/// Modèle de données pour une réservation
class ReservationModel {
  final int? id;
  final int userId; // ID de la famille
  final int professionnelId; // ID du professionnel
  final DateTime date;
  final DateTime? dateFin; // Date de fin pour les réservations multi-jours
  final String heure; // Format "HH:mm"
  final String status; // 'pending', 'confirmed', 'completed', 'cancelled'

  ReservationModel({
    this.id,
    required this.userId,
    required this.professionnelId,
    required this.date,
    this.dateFin,
    required this.heure,
    this.status = 'pending',
  });

  /// Convertit le modèle en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'professionnelId': professionnelId,
      'date': date.toIso8601String(),
      'dateFin': dateFin?.toIso8601String(),
      'heure': heure,
      'status': status,
    };
  }

  /// Crée un ReservationModel à partir d'un Map SQLite
  factory ReservationModel.fromMap(Map<String, dynamic> map) {
    return ReservationModel(
      id: map['id'] as int?,
      userId: map['userId'] as int,
      professionnelId: map['professionnelId'] as int,
      date: DateTime.parse(map['date'] as String),
      dateFin: map['dateFin'] != null ? DateTime.parse(map['dateFin'] as String) : null,
      heure: map['heure'] as String,
      status: map['status'] as String,
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
    String? status,
  }) {
    return ReservationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      professionnelId: professionnelId ?? this.professionnelId,
      date: date ?? this.date,
      dateFin: dateFin ?? this.dateFin,
      heure: heure ?? this.heure,
      status: status ?? this.status,
    );
  }
}
