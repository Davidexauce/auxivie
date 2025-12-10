import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/reservation_model.dart';
import '../models/message_model.dart';
import '../models/badge_model.dart';
import '../models/rating_model.dart';
import '../models/review_model.dart';
import '../config/app_config.dart';

/// Service pour les appels API vers le backend Dashboard Auxivie
class BackendApiService {
  static String get baseUrl => AppConfig.apiBaseUrl;

  // Token d'authentification (géré avec SharedPreferences)
  static String? _token;
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'current_user';

  /// Initialise le service en récupérant le token depuis SharedPreferences
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString(_tokenKey);
      if (AppConfig.enableLogging && _token != null) {
        print('✅ Token restauré depuis SharedPreferences');
      }
    } catch (e) {
      // Si SharedPreferences n'est pas disponible, continuer sans token
      if (AppConfig.enableLogging) {
        print('⚠️ Impossible d\'accéder à SharedPreferences: $e');
      }
      _token = null;
    }
  }

  /// Récupère le token depuis SharedPreferences
  static Future<String?> getToken() async {
    if (_token != null) return _token;
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString(_tokenKey);
    } catch (e) {
      if (AppConfig.enableLogging) {
        print('⚠️ Erreur lors de la récupération du token: $e');
      }
      _token = null;
    }
    return _token;
  }

  /// Sauvegarde le token dans SharedPreferences
  static Future<void> setToken(String? token) async {
    _token = token;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (token != null) {
        await prefs.setString(_tokenKey, token);
        if (AppConfig.enableLogging) {
          print('✅ Token sauvegardé dans SharedPreferences');
        }
      } else {
        await prefs.remove(_tokenKey);
      }
    } catch (e) {
      if (AppConfig.enableLogging) {
        print('⚠️ Erreur lors de la sauvegarde du token: $e');
      }
      // Le token reste en mémoire même si la sauvegarde échoue
    }
  }

  /// Supprime le token (déconnexion)
  static Future<void> clearToken() async {
    _token = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
    } catch (e) {
      if (AppConfig.enableLogging) {
        print('⚠️ Erreur lors de la suppression du token: $e');
      }
    }
  }

  /// Headers pour requêtes publiques
  static Map<String, String> _getPublicHeaders() {
    return {
      'Content-Type': 'application/json',
      'x-request-type': 'mobile',
    };
  }

  /// Headers pour requêtes authentifiées
  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await getToken();
    final headers = {
      'Content-Type': 'application/json',
      'x-request-type': 'mobile',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// Sauvegarde l'utilisateur actuel
  static Future<void> saveCurrentUser(Map<String, dynamic> user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(user));
    } catch (e) {
      if (AppConfig.enableLogging) {
        print('⚠️ Erreur lors de la sauvegarde de l\'utilisateur: $e');
      }
    }
  }

  /// Récupère l'utilisateur actuel
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      if (userJson != null) {
        return jsonDecode(userJson) as Map<String, dynamic>;
      }
    } catch (e) {
      if (AppConfig.enableLogging) {
        print('⚠️ Erreur lors de la récupération de l\'utilisateur: $e');
      }
    }
    return null;
  }

  // ========== AUTHENTIFICATION ==========

  static Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _getPublicHeaders(),
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(AppConfig.apiTimeout);

      // Vérifier que la réponse est bien du JSON
      final contentType = response.headers['content-type'] ?? '';
      if (!contentType.contains('application/json') && response.body.isNotEmpty) {
        if (response.body.trim().startsWith('<!DOCTYPE') || response.body.trim().startsWith('<html')) {
          if (AppConfig.enableLogging) {
            print('❌ Erreur login: Le serveur a retourné du HTML au lieu de JSON');
            print('URL appelée: $baseUrl/auth/login');
            print('Vérifiez que l\'API est correctement configurée et accessible');
          }
          throw Exception('Le serveur API n\'est pas accessible. Vérifiez la configuration de l\'URL dans app_config.dart');
        }
      }

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body) as Map<String, dynamic>;
          if (data['token'] != null) {
            await setToken(data['token'] as String);
            if (data['user'] != null) {
              await saveCurrentUser(data['user'] as Map<String, dynamic>);
            }
          }
          return data;
        } on FormatException catch (e) {
          if (AppConfig.enableLogging) {
            print('❌ Erreur parsing JSON login: $e');
            print('Réponse reçue (premiers 500 caractères): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');
          }
          throw Exception('Réponse invalide du serveur. L\'API est-elle correctement configurée ?');
        }
      } else {
        try {
          final error = json.decode(response.body);
          if (AppConfig.enableLogging) {
            print('❌ Erreur login: ${response.statusCode} - ${error['message'] ?? response.body}');
          }
          throw Exception(error['message'] ?? 'Erreur de connexion');
        } on FormatException {
          // Si ce n'est pas du JSON, afficher un message générique
          if (AppConfig.enableLogging) {
            print('❌ Erreur login: ${response.statusCode} - Réponse non-JSON');
            print('Réponse (premiers 200 caractères): ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');
          }
          throw Exception('Erreur de connexion (${response.statusCode}) - Le serveur a retourné une réponse non-JSON');
        }
      }
    } catch (e) {
      if (AppConfig.enableLogging) {
        print('❌ Erreur login: $e');
      }
      rethrow;
    }
  }

  /// Déconnexion
  static Future<void> logout() async {
    await clearToken();
  }

  // ========== UTILISATEURS ==========

  static Future<UserModel?> getUserById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$id'),
        headers: _getPublicHeaders(),
      ).timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        return UserModel.fromMap(json.decode(response.body) as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      if (AppConfig.enableLogging) {
        print('❌ Erreur getUserById: $e');
      }
      return null;
    }
  }

  static Future<List<UserModel>> getProfessionals() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users?userType=professionnel'),
        headers: _getPublicHeaders(),
      ).timeout(AppConfig.apiTimeout);

      // Vérifier que la réponse est bien du JSON
      final contentType = response.headers['content-type'] ?? '';
      if (!contentType.contains('application/json') && response.body.isNotEmpty) {
        if (response.body.trim().startsWith('<!DOCTYPE') || response.body.trim().startsWith('<html')) {
          if (AppConfig.enableLogging) {
            print('❌ Erreur getProfessionals: Le serveur a retourné du HTML au lieu de JSON');
            print('URL appelée: $baseUrl/users?userType=professionnel');
            print('Vérifiez que l\'API est correctement configurée et accessible');
          }
          return [];
        }
      }

      if (response.statusCode == 200) {
        try {
          final List<dynamic> data = json.decode(response.body);
          if (AppConfig.enableLogging) {
            print('✅ ${data.length} professionnel(s) récupéré(s) depuis l\'API');
          }
          
          final List<UserModel> professionals = [];
          for (final item in data) {
            try {
              final map = item as Map<String, dynamic>;
              if (AppConfig.enableLogging && data.length <= 3) {
                print('📋 Données professionnel: id=${map['id']}, tarif=${map['tarif']}, experience=${map['experience']}');
              }
              professionals.add(UserModel.fromMap(map));
            } catch (e, stackTrace) {
              if (AppConfig.enableLogging) {
                print('❌ Erreur conversion professionnel: $e');
                print('Données: $item');
                print('Stack: $stackTrace');
              }
              // Continuer avec les autres professionnels même si un échoue
            }
          }
          
          if (AppConfig.enableLogging) {
            print('✅ ${professionals.length} professionnel(s) converti(s) avec succès');
          }
          return professionals;
        } on FormatException catch (e) {
          if (AppConfig.enableLogging) {
            print('❌ Erreur parsing JSON getProfessionals: $e');
            print('Réponse reçue (premiers 500 caractères): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');
          }
          return [];
        } catch (e, stackTrace) {
          if (AppConfig.enableLogging) {
            print('❌ Erreur inattendue getProfessionals: $e');
            print('Stack: $stackTrace');
          }
          return [];
        }
      } else {
        if (AppConfig.enableLogging) {
          print('❌ Erreur getProfessionals: ${response.statusCode}');
          if (response.body.isNotEmpty) {
            print('Réponse: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');
          }
        }
        return [];
      }
    } on FormatException catch (e) {
      if (AppConfig.enableLogging) {
        print('❌ Erreur getProfessionals (FormatException): $e');
        print('L\'API a probablement retourné du HTML au lieu de JSON. Vérifiez l\'URL: $baseUrl/users?userType=professionnel');
      }
      return [];
    } catch (e) {
      if (AppConfig.enableLogging) {
        print('❌ Erreur getProfessionals: $e');
      }
      return [];
    }
  }

  /// Synchronise un utilisateur (création ou mise à jour)
  static Future<Map<String, dynamic>?> syncUser(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/sync'),
        headers: _getPublicHeaders(),
        body: jsonEncode(userData),
      ).timeout(AppConfig.apiTimeout);

      // Vérifier que la réponse est bien du JSON
      final contentType = response.headers['content-type'] ?? '';
      if (!contentType.contains('application/json')) {
        if (AppConfig.enableLogging) {
          print('❌ Erreur syncUser: Le serveur a retourné du ${contentType} au lieu de JSON');
          print('URL appelée: $baseUrl/users/sync');
          print('Réponse (premiers 200 caractères): ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');
        }
        throw Exception('Le serveur API n\'est pas accessible. Vérifiez la configuration de l\'URL.');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          return json.decode(response.body) as Map<String, dynamic>;
        } on FormatException catch (e) {
          if (AppConfig.enableLogging) {
            print('❌ Erreur parsing JSON: $e');
            print('Réponse reçue: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');
          }
          throw Exception('Réponse invalide du serveur. L\'API est-elle correctement configurée ?');
        }
      } else {
        // Essayer de parser l'erreur JSON
        try {
          final error = json.decode(response.body);
          if (AppConfig.enableLogging) {
            print('❌ Erreur syncUser: ${response.statusCode} - ${error['message'] ?? response.body}');
          }
        } catch (_) {
          // Si ce n'est pas du JSON, afficher la réponse brute
          if (AppConfig.enableLogging) {
            print('❌ Erreur syncUser: ${response.statusCode} - ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');
          }
        }
        return null;
      }
    } on FormatException catch (e) {
      if (AppConfig.enableLogging) {
        print('❌ Erreur syncUser (FormatException): $e');
        print('L\'API a probablement retourné du HTML au lieu de JSON. Vérifiez l\'URL: $baseUrl/users/sync');
      }
      return null;
    } catch (e) {
      if (AppConfig.enableLogging) {
        print('❌ Erreur syncUser: $e');
      }
      return null;
    }
  }

  static Future<Map<String, dynamic>?> createUser(UserModel user) async {
    return await syncUser({
      'name': user.name,
      'email': user.email,
      'password': user.password,
      'phone': user.phone,
      'categorie': user.categorie,
      'ville': user.ville,
      'tarif': user.tarif?.toString(),
      'experience': user.experience?.toString(),
      'photo': user.photo,
      'userType': user.userType,
      'besoin': user.besoin,
      'preference': user.preference,
      'mission': user.mission,
      'particularite': user.particularite,
    });
  }

  /// Met à jour un utilisateur
  static Future<bool> updateUser(int userId, Map<String, dynamic> updates) async {
    // Récupérer l'utilisateur actuel
    final user = await getUserById(userId);
    if (user == null) return false;

    // Fusionner les mises à jour
    final userData = {
      'id': userId,
      'name': updates['name'] ?? user.name,
      'email': updates['email'] ?? user.email,
      'password': updates['password'] ?? user.password,
      'phone': updates['phone'] ?? user.phone,
      'categorie': updates['categorie'] ?? user.categorie,
      'ville': updates['ville'] ?? user.ville,
      'tarif': updates['tarif']?.toString() ?? user.tarif?.toString(),
      'experience': updates['experience']?.toString() ?? user.experience?.toString(),
      'photo': updates['photo'] ?? user.photo,
      'userType': user.userType,
      'besoin': updates['besoin'] ?? user.besoin,
      'preference': updates['preference'] ?? user.preference,
      'mission': updates['mission'] ?? user.mission,
      'particularite': updates['particularite'] ?? user.particularite,
    };

    final result = await syncUser(userData);
    return result != null;
  }

  // ========== DISPONIBILITÉS ==========

  static Future<List<Map<String, dynamic>>> getAvailabilities(int professionnelId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/availabilities?professionnelId=$professionnelId'),
        headers: _getPublicHeaders(),
      ).timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      if (AppConfig.enableLogging) {
        print('❌ Erreur getAvailabilities: $e');
      }
      return [];
    }
  }

  /// Sauvegarde une disponibilité
  static Future<bool> saveAvailability({
    required int professionnelId,
    required int jourSemaine,
    required String heureDebut,
    required String heureFin,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/availabilities'),
        headers: _getPublicHeaders(),
        body: jsonEncode({
          'professionnelId': professionnelId,
          'jourSemaine': jourSemaine,
          'heureDebut': heureDebut,
          'heureFin': heureFin,
        }),
      ).timeout(AppConfig.apiTimeout);

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      if (AppConfig.enableLogging) {
        print('❌ Erreur saveAvailability: $e');
      }
      return false;
    }
  }

  /// Supprime une disponibilité
  static Future<bool> deleteAvailability(int availabilityId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/availabilities/$availabilityId'),
        headers: _getPublicHeaders(),
      ).timeout(AppConfig.apiTimeout);

      return response.statusCode == 200;
    } catch (e) {
      if (AppConfig.enableLogging) {
        print('❌ Erreur deleteAvailability: $e');
      }
      return false;
    }
  }

  // ========== RÉSERVATIONS ==========

  static Future<List<ReservationModel>> getReservations({int? userId, int? professionnelId}) async {
    try {
      String url = '$baseUrl/reservations?';
      if (userId != null) {
        url += 'userId=$userId';
      } else if (professionnelId != null) {
        url += 'professionnelId=$professionnelId';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: _getPublicHeaders(),
      ).timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((map) {
          final m = map as Map<String, dynamic>;
          // Convertir le format de date
          final dateStr = m['date'] as String;
          DateTime date;
          if (dateStr.contains('T')) {
            date = DateTime.parse(dateStr);
          } else {
            // Format YYYY-MM-DD
            final parts = dateStr.split('-');
            date = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
          }

          DateTime? dateFin;
          if (m['dateFin'] != null) {
            final dateFinStr = m['dateFin'] as String;
            if (dateFinStr.contains('T')) {
              dateFin = DateTime.parse(dateFinStr);
            } else {
              final parts = dateFinStr.split('-');
              dateFin = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
            }
          }

          return ReservationModel(
            id: m['id'] as int?,
            userId: m['userId'] as int,
            professionnelId: m['professionnelId'] as int,
            date: date,
            dateFin: dateFin,
            heure: m['heure'] as String,
            status: m['status'] as String? ?? 'pending',
          );
        }).toList();
      }
      return [];
    } catch (e) {
      if (AppConfig.enableLogging) {
        print('❌ Erreur getReservations: $e');
      }
      return [];
    }
  }

  static Future<List<ReservationModel>> getUserReservations(int userId) async {
    return await getReservations(userId: userId);
  }

  static Future<List<ReservationModel>> getProfessionalReservations(int professionnelId) async {
    return await getReservations(professionnelId: professionnelId);
  }

  /// Synchronise une réservation (création ou mise à jour)
  static Future<Map<String, dynamic>?> syncReservation(Map<String, dynamic> reservationData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reservations/sync'),
        headers: _getPublicHeaders(),
        body: jsonEncode(reservationData),
      ).timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        final error = json.decode(response.body);
        if (AppConfig.enableLogging) {
          print('❌ Erreur syncReservation: ${response.statusCode} - ${error['message'] ?? response.body}');
        }
        return null;
      }
    } catch (e) {
      if (AppConfig.enableLogging) {
        print('❌ Erreur syncReservation: $e');
      }
      return null;
    }
  }

  static Future<bool> createReservation(ReservationModel reservation) async {
    final result = await syncReservation({
      'userId': reservation.userId,
      'professionnelId': reservation.professionnelId,
      'date': reservation.date.toIso8601String().split('T')[0],
      'dateFin': reservation.dateFin != null ? reservation.dateFin!.toIso8601String().split('T')[0] : null,
      'heure': reservation.heure,
      'heureFin': reservation.heureFin,
      'besoins': reservation.besoins,
      'status': reservation.status,
    });
    return result != null;
  }

  /// Crée une réservation et retourne l'ID de la réservation créée
  static Future<int?> createReservationAndGetId(ReservationModel reservation) async {
    final result = await syncReservation({
      'userId': reservation.userId,
      'professionnelId': reservation.professionnelId,
      'date': reservation.date.toIso8601String().split('T')[0],
      'dateFin': reservation.dateFin != null ? reservation.dateFin!.toIso8601String().split('T')[0] : null,
      'heure': reservation.heure,
      'heureFin': reservation.heureFin,
      'besoins': reservation.besoins,
      'status': reservation.status,
    });
    if (result != null && result['id'] != null) {
      return result['id'] as int;
    }
    return null;
  }
  
  /// Crée plusieurs réservations et retourne la liste des IDs créés
  static Future<List<int>> createMultipleReservations(List<ReservationModel> reservations) async {
    final List<int> createdIds = [];
    for (final reservation in reservations) {
      final id = await createReservationAndGetId(reservation);
      if (id != null) {
        createdIds.add(id);
      }
    }
    return createdIds;
  }

  /// Met à jour une réservation
  static Future<bool> updateReservation(ReservationModel reservation) async {
    final result = await syncReservation({
      'id': reservation.id,
      'userId': reservation.userId,
      'professionnelId': reservation.professionnelId,
      'date': reservation.date.toIso8601String().split('T')[0],
      'dateFin': reservation.dateFin != null ? reservation.dateFin!.toIso8601String().split('T')[0] : null,
      'heure': reservation.heure,
      'heureFin': reservation.heureFin,
      'besoins': reservation.besoins,
      'status': reservation.status,
    });
    return result != null;
  }

  // ========== MESSAGES ==========

  static Future<List<MessageModel>> getConversation(int userId, int partnerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/messages?userId=$userId&partnerId=$partnerId'),
        headers: _getPublicHeaders(),
      ).timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((map) {
          final m = map as Map<String, dynamic>;
          final timestampStr = m['timestamp'] as String;
          DateTime timestamp;
          try {
            timestamp = DateTime.parse(timestampStr);
          } catch (e) {
            timestamp = DateTime.now();
          }

          return MessageModel(
            id: m['id'] as int?,
            senderId: m['senderId'] as int,
            receiverId: m['receiverId'] as int,
            content: m['content'] as String,
            timestamp: timestamp,
            isRead: (m['isRead'] as int? ?? 0) == 1,
          );
        }).toList();
      }
      return [];
    } catch (e) {
      if (AppConfig.enableLogging) {
        print('❌ Erreur getConversation: $e');
      }
      return [];
    }
  }

  /// Récupère la liste des IDs des partenaires de conversation
  static Future<List<int>> getConversationPartners(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/messages/partners?userId=$userId'),
        headers: _getPublicHeaders(),
      ).timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((id) => id as int).toList();
      }
      return [];
    } catch (e) {
      if (AppConfig.enableLogging) {
        print('❌ Erreur getConversationPartners: $e');
      }
      return [];
    }
  }

  /// Envoie un message avec des paramètres séparés
  static Future<Map<String, dynamic>?> sendMessageParams(int senderId, int receiverId, String content) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/messages'),
        headers: _getPublicHeaders(),
        body: jsonEncode({
          'senderId': senderId,
          'receiverId': receiverId,
          'content': content,
        }),
      ).timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        final error = json.decode(response.body);
        if (AppConfig.enableLogging) {
          print('❌ Erreur sendMessage: ${response.statusCode} - ${error['message'] ?? response.body}');
        }
        return null;
      }
    } catch (e) {
      if (AppConfig.enableLogging) {
        print('❌ Erreur sendMessage: $e');
      }
      return null;
    }
  }

  /// Envoie un message (version avec MessageModel pour compatibilité)
  static Future<bool> sendMessage(MessageModel message) async {
    final result = await sendMessageParams(message.senderId, message.receiverId, message.content);
    return result != null;
  }

  // ========== AVIS (REVIEWS) ==========

  /// Récupère tous les avis ou ceux d'un professionnel spécifique
  static Future<List<ReviewModel>> getReviews([int? professionalId]) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reviews'),
        headers: _getPublicHeaders(),
      ).timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        List<ReviewModel> reviews = data.map((map) => ReviewModel.fromMap(map as Map<String, dynamic>)).toList();
        if (professionalId != null) {
          reviews = reviews.where((r) => r.professionalId == professionalId).toList();
        }
        return reviews;
      }
      return [];
    } catch (e) {
      if (AppConfig.enableLogging) {
        print('❌ Erreur getReviews: $e');
      }
      return [];
    }
  }

  /// Crée un avis (authentifié)
  static Future<Map<String, dynamic>?> createReview({
    required int professionalId,
    required int userId,
    required int rating,
    String? comment,
    String? userName,
    int? reservationId,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/reviews'),
        headers: headers,
        body: jsonEncode({
          'professionalId': professionalId,
          'userId': userId,
          'rating': rating,
          'comment': comment,
          'userName': userName,
          'reservationId': reservationId ?? 0,
        }),
      ).timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        final error = json.decode(response.body);
        if (AppConfig.enableLogging) {
          print('❌ Erreur createReview: ${response.statusCode} - ${error['message'] ?? response.body}');
        }
        return null;
      }
    } catch (e) {
      if (AppConfig.enableLogging) {
        print('❌ Erreur createReview: $e');
      }
      return null;
    }
  }

  // ========== NOTES (RATINGS) ==========

  static Future<RatingModel?> getRating(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/ratings?userId=$userId'),
        headers: _getPublicHeaders(),
      ).timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null) {
          return RatingModel.fromMap(data as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      if (AppConfig.enableLogging) {
        print('❌ Erreur getRating: $e');
      }
      return null;
    }
  }

  // ========== BADGES ==========

  static Future<List<BadgeModel>> getBadges(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/badges?userId=$userId'),
        headers: _getPublicHeaders(),
      ).timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((map) => BadgeModel.fromMap(map as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      if (AppConfig.enableLogging) {
        print('❌ Erreur getBadges: $e');
      }
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
      final uri = Uri.parse('$baseUrl/documents/upload');
      final request = http.MultipartRequest('POST', uri);

      request.fields['userId'] = userId.toString();
      request.fields['type'] = type;
      request.headers['x-request-type'] = 'mobile';

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
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        final error = json.decode(response.body);
        if (AppConfig.enableLogging) {
          print('❌ Erreur upload document: ${response.statusCode} - ${error['message'] ?? response.body}');
        }
        return null;
      }
    } catch (e) {
      if (AppConfig.enableLogging) {
        print('❌ Erreur upload document: $e');
      }
      return null;
    }
  }

  /// Upload une photo de profil
  static Future<String?> uploadProfilePhoto({
    required int userId,
    required File photo,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/users/$userId/photo');
      final request = http.MultipartRequest('POST', uri);

      request.headers['x-request-type'] = 'mobile';

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
        final data = json.decode(response.body) as Map<String, dynamic>;
        return data['photo'] as String?;
      } else {
        final error = json.decode(response.body);
        if (AppConfig.enableLogging) {
          print('❌ Erreur upload photo: ${response.statusCode} - ${error['message'] ?? response.body}');
        }
        return null;
      }
    } catch (e) {
      if (AppConfig.enableLogging) {
        print('❌ Erreur upload photo: $e');
      }
      return null;
    }
  }

  // ========== PAIEMENTS ==========

  /// Crée un PaymentIntent Stripe
  /// [amount] : Montant en euros (le backend convertira en centimes pour Stripe si nécessaire)
  static Future<Map<String, dynamic>?> createPaymentIntent({
    required int reservationId,
    required int userId,
    required double amount,
    String currency = 'eur',
  }) async {
    try {
      // L'API attend le montant en euros selon le guide
      final requestBody = {
        'amount': amount, // Montant en euros
        'currency': currency,
        'reservationId': reservationId,
        'userId': userId,
      };
      
      if (AppConfig.enableLogging) {
        print('📡 Création PaymentIntent: $amount € pour réservation $reservationId');
        print('📡 Body: $requestBody');
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/payments/create-intent'),
        headers: _getPublicHeaders(),
        body: jsonEncode(requestBody),
      ).timeout(AppConfig.apiTimeout);

      // Vérifier le Content-Type
      final contentType = response.headers['content-type'] ?? '';
      if (!contentType.contains('application/json') && response.body.isNotEmpty) {
        if (response.body.trim().startsWith('<!DOCTYPE') || response.body.trim().startsWith('<html')) {
          if (AppConfig.enableLogging) {
            print('❌ Erreur création PaymentIntent: Le serveur a retourné du HTML');
            print('Réponse: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');
          }
          return null;
        }
      }

      if (response.statusCode == 200) {
        try {
          return json.decode(response.body) as Map<String, dynamic>;
        } on FormatException catch (e) {
          if (AppConfig.enableLogging) {
            print('❌ Erreur parsing JSON PaymentIntent: $e');
            print('Réponse: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');
          }
          return null;
        }
      } else {
        try {
          final error = json.decode(response.body) as Map<String, dynamic>;
          if (AppConfig.enableLogging) {
            print('❌ Erreur création PaymentIntent: ${response.statusCode}');
            print('Message: ${error['message'] ?? error['error'] ?? response.body}');
            print('Détails: $error');
          }
        } catch (_) {
          if (AppConfig.enableLogging) {
            print('❌ Erreur création PaymentIntent: ${response.statusCode}');
            print('Réponse: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');
          }
        }
        return null;
      }
    } catch (e, stackTrace) {
      if (AppConfig.enableLogging) {
        print('❌ Erreur création PaymentIntent: $e');
        print('Stack: $stackTrace');
      }
      return null;
    }
  }

  /// Confirme un paiement
  static Future<Map<String, dynamic>?> confirmPayment({
    required String paymentIntentId,
    required int reservationId,
    required int userId,
    required double amount,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/payments/confirm'),
        headers: _getPublicHeaders(),
        body: jsonEncode({
          'paymentIntentId': paymentIntentId,
          'reservationId': reservationId,
          'userId': userId,
          'amount': amount,
        }),
      ).timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        final error = json.decode(response.body);
        if (AppConfig.enableLogging) {
          print('❌ Erreur confirmation paiement: ${response.statusCode} - ${error['message'] ?? response.body}');
        }
        return null;
      }
    } catch (e) {
      if (AppConfig.enableLogging) {
        print('❌ Erreur confirmation paiement: $e');
      }
      return null;
    }
  }

  // ========== HEALTH CHECK ==========

  /// Vérifie l'état de l'API
  static Future<bool> healthCheck() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: _getPublicHeaders(),
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      if (AppConfig.enableLogging) {
        print('❌ Erreur health check: $e');
      }
      return false;
    }
  }
}
