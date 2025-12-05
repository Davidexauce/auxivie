import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/reservation_model.dart';
import '../models/message_model.dart';
import '../models/badge_model.dart';
import '../models/rating_model.dart';
import '../models/review_model.dart';

import '../config/app_config.dart';

/// Service pour les appels API vers le backend (base de données unique)
class BackendApiService {
  static String get baseUrl => AppConfig.apiBaseUrl;

  // Token d'authentification (sera géré plus tard)
  static String? _token;

  static void setToken(String? token) {
    _token = token;
  }

  static Map<String, String> _getHeaders() {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // ========== AUTHENTIFICATION ==========

  static Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'x-request-type': 'mobile', // Pour permettre la connexion des utilisateurs non-admin
        },
        body: jsonEncode({'email': email, 'password': password}),
        ).timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['token'] != null) {
          _token = data['token'];
        }
        return data;
      } else {
        print('❌ Erreur login: ${response.statusCode} - ${response.body}');
      }
      return null;
    } catch (e) {
      print('❌ Erreur login: $e');
      return null;
    }
  }

  // ========== UTILISATEURS ==========

  static Future<UserModel?> getUserByEmail(String email) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/users?email=$email'),
        headers: _getHeaders(),
        ).timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          return UserModel.fromMap(data.first);
        }
      }
      return null;
    } catch (e) {
      print('❌ Erreur getUserByEmail: $e');
      return null;
    }
  }

  static Future<UserModel?> getUserById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/users/$id'),
        headers: _getHeaders(),
        ).timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        return UserModel.fromMap(json.decode(response.body));
      }
      return null;
    } catch (e) {
      print('❌ Erreur getUserById: $e');
      return null;
    }
  }

  static Future<List<UserModel>> getProfessionals() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/users?userType=professionnel'),
        headers: _getHeaders(),
        ).timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((map) => UserModel.fromMap(map)).toList();
      }
      return [];
    } catch (e) {
      print('❌ Erreur getProfessionals: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> createUser(UserModel user) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/users/sync'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': user.name,
          'email': user.email,
          'password': user.password,
          'phone': user.phone,
          'categorie': user.categorie,
          'ville': user.ville,
          'tarif': user.tarif,
          'experience': user.experience,
          'photo': user.photo,
          'userType': user.userType,
        }),
        ).timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        print('❌ Erreur createUser: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Erreur createUser: $e');
      return null;
    }
  }

  static Future<bool> updateUser(int userId, Map<String, dynamic> updates) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/users/$userId'),
        headers: _getHeaders(),
        body: jsonEncode(updates),
        ).timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        return true;
      } else {
        print('❌ Erreur updateUser: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Erreur updateUser: $e');
      return false;
    }
  }

  // ========== DISPONIBILITÉS ==========

  static Future<List<Map<String, dynamic>>> getAvailabilities(int professionnelId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/availabilities?professionnelId=$professionnelId'),
        headers: _getHeaders(),
        ).timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('❌ Erreur getAvailabilities: $e');
      return [];
    }
  }

  static Future<bool> saveAvailability({
    required int professionnelId,
    required int jourSemaine,
    required String heureDebut,
    required String heureFin,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/availabilities'),
        headers: _getHeaders(),
        body: jsonEncode({
          'professionnelId': professionnelId,
          'jourSemaine': jourSemaine,
          'heureDebut': heureDebut,
          'heureFin': heureFin,
        }),
        ).timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print('❌ Erreur saveAvailability: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Erreur saveAvailability: $e');
      return false;
    }
  }

  static Future<bool> deleteAvailability(int availabilityId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/availabilities/$availabilityId'),
        headers: _getHeaders(),
        ).timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        return true;
      } else {
        print('❌ Erreur deleteAvailability: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Erreur deleteAvailability: $e');
      return false;
    }
  }

  // ========== RÉSERVATIONS ==========

  static Future<List<ReservationModel>> getUserReservations(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/reservations?userId=$userId'),
        headers: _getHeaders(),
        ).timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((map) => ReservationModel.fromMap(map)).toList();
      }
      return [];
    } catch (e) {
      print('❌ Erreur getUserReservations: $e');
      return [];
    }
  }

  static Future<List<ReservationModel>> getProfessionalReservations(int professionnelId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/reservations?professionnelId=$professionnelId'),
        headers: _getHeaders(),
        ).timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((map) {
          // Convertir le format de date si nécessaire
          final dateStr = map['date'] as String;
          DateTime date;
          if (dateStr.contains('T')) {
            date = DateTime.parse(dateStr);
          } else {
            // Format YYYY-MM-DD
            final parts = dateStr.split('-');
            date = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
          }
          
          return ReservationModel(
            id: map['id'] as int?,
            userId: map['userId'] as int,
            professionnelId: map['professionnelId'] as int,
            date: date,
            heure: map['heure'] as String,
            status: map['status'] as String? ?? 'pending',
          );
        }).toList();
      }
      return [];
    } catch (e) {
      print('❌ Erreur getProfessionalReservations: $e');
      return [];
    }
  }

  static Future<bool> createReservation(ReservationModel reservation) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/reservations/sync'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': reservation.userId,
          'professionnelId': reservation.professionnelId,
          'date': reservation.date.toIso8601String().split('T')[0],
          'dateFin': reservation.dateFin != null ? reservation.dateFin!.toIso8601String().split('T')[0] : null,
          'heure': reservation.heure,
          'status': reservation.status,
        }),
        ).timeout(AppConfig.apiTimeout);

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('❌ Erreur createReservation: $e');
      return false;
    }
  }

  static Future<bool> updateReservation(ReservationModel reservation) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/reservations/${reservation.id}'),
        headers: _getHeaders(),
        body: jsonEncode({
          'status': reservation.status,
        }),
        ).timeout(AppConfig.apiTimeout);

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Erreur updateReservation: $e');
      return false;
    }
  }

  // ========== MESSAGES ==========

  static Future<List<MessageModel>> getConversation(int userId, int partnerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/messages?userId=$userId&partnerId=$partnerId'),
        headers: _getHeaders(),
        ).timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((map) {
          // Convertir le format de timestamp si nécessaire
          final timestampStr = map['timestamp'] as String;
          DateTime timestamp;
          try {
            timestamp = DateTime.parse(timestampStr);
          } catch (e) {
            timestamp = DateTime.now();
          }
          
          return MessageModel(
            id: map['id'] as int?,
            senderId: map['senderId'] as int,
            receiverId: map['receiverId'] as int,
            content: map['content'] as String,
            timestamp: timestamp,
            isRead: (map['isRead'] as int? ?? 0) == 1,
          );
        }).toList();
      }
      return [];
    } catch (e) {
      print('❌ Erreur getConversation: $e');
      return [];
    }
  }

  /// Récupère la liste des IDs des partenaires de conversation d'un utilisateur
  static Future<List<int>> getConversationPartners(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/messages/partners?userId=$userId'),
        headers: _getHeaders(),
        ).timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((id) => id as int).toList();
      }
      return [];
    } catch (e) {
      print('❌ Erreur getConversationPartners: $e');
      return [];
    }
  }

  static Future<bool> sendMessage(MessageModel message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/messages'),
        headers: _getHeaders(),
        body: jsonEncode({
          'senderId': message.senderId,
          'receiverId': message.receiverId,
          'content': message.content,
        }),
        ).timeout(AppConfig.apiTimeout);

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('❌ Erreur sendMessage: $e');
      return false;
    }
  }

  // ========== BADGES, RATINGS, REVIEWS ==========

  static Future<List<BadgeModel>> getBadges(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/badges?userId=$userId'),
        headers: _getHeaders(),
        ).timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((map) => BadgeModel.fromMap(map)).toList();
      }
      return [];
    } catch (e) {
      print('❌ Erreur getBadges: $e');
      return [];
    }
  }

  static Future<RatingModel?> getRating(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/ratings?userId=$userId'),
        headers: _getHeaders(),
        ).timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null) {
          return RatingModel.fromMap(data);
        }
      }
      return null;
    } catch (e) {
      print('❌ Erreur getRating: $e');
      return null;
    }
  }

  static Future<List<ReviewModel>> getReviews(int professionalId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/reviews'),
        headers: _getHeaders(),
        ).timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .where((review) => review['professionalId'] == professionalId)
            .map((map) => ReviewModel.fromMap(map))
            .toList();
      }
      return [];
    } catch (e) {
      print('❌ Erreur getReviews: $e');
      return [];
    }
  }

  // ========== UPLOAD DE FICHIERS ==========

  /// Upload un document
  static Future<Map<String, dynamic>?> uploadDocument({
    required int userId,
    required String type,
    required File file,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/documents/upload');
      final request = http.MultipartRequest('POST', uri);
      
      // Ajouter les champs
      request.fields['userId'] = userId.toString();
      request.fields['type'] = type;
      
      // Ajouter le fichier
      final fileStream = file.openRead();
      final fileLength = await file.length();
      final multipartFile = http.MultipartFile(
        'file',
        fileStream,
        fileLength,
        filename: file.path.split('/').last,
      );
      request.files.add(multipartFile);

      final streamedResponse = await request.send().timeout(AppConfig.apiTimeout);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('❌ Erreur upload document: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Erreur upload document: $e');
      return null;
    }
  }

  /// Upload une photo de profil
  static Future<String?> uploadProfilePhoto({
    required int userId,
    required File photo,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/users/$userId/photo');
      final request = http.MultipartRequest('POST', uri);
      
      // Ajouter le fichier
      final fileStream = photo.openRead();
      final fileLength = await photo.length();
      final multipartFile = http.MultipartFile(
        'photo',
        fileStream,
        fileLength,
        filename: photo.path.split('/').last,
      );
      request.files.add(multipartFile);

      final streamedResponse = await request.send().timeout(AppConfig.apiTimeout);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['photo'] as String?;
      } else {
        print('❌ Erreur upload photo: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Erreur upload photo: $e');
      return null;
    }
  }

  // ========== PAIEMENTS ==========

  /// Crée un PaymentIntent Stripe
  static Future<Map<String, dynamic>?> createPaymentIntent({
    required int reservationId,
    required int userId,
    required double amount,
    String currency = 'eur',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/payments/create-intent'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'reservationId': reservationId,
          'userId': userId,
          'amount': amount,
          'currency': currency,
        }),
      ).timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('❌ Erreur création PaymentIntent: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Erreur création PaymentIntent: $e');
      return null;
    }
  }

  /// Confirme un paiement
  static Future<bool> confirmPayment({
    required String paymentIntentId,
    required int reservationId,
    required int userId,
    required double amount,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/payments/confirm'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'paymentIntentId': paymentIntentId,
          'reservationId': reservationId,
          'userId': userId,
          'amount': amount,
        }),
      ).timeout(AppConfig.apiTimeout);

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Erreur confirmation paiement: $e');
      return false;
    }
  }
}

