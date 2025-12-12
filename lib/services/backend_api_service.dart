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
import '../models/document_model.dart';
import '../models/report_model.dart';
import '../models/settings_model.dart';
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
    if (_token != null) {
      // Nettoyer le token en mémoire aussi
      if (_token!.trim().startsWith('Bearer ')) {
        _token = _token!.trim().substring(7).trim();
      }
      return _token;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString(_tokenKey);
      // Nettoyer le token récupéré s'il contient "Bearer "
      if (_token != null && _token!.trim().startsWith('Bearer ')) {
        _token = _token!.trim().substring(7).trim();
        // Réenregistrer le token nettoyé
        await prefs.setString(_tokenKey, _token!);
        if (AppConfig.enableLogging) {
          print('⚠️ [TOKEN] Token nettoyé lors de la récupération (suppression de "Bearer ")');
        }
      }
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
    // Nettoyer le token si "Bearer " est déjà présent (ne stocker que le token JWT pur)
    if (token != null && token.trim().startsWith('Bearer ')) {
      token = token.trim().substring(7).trim();
      if (AppConfig.enableLogging) {
        print('⚠️ [TOKEN] Token nettoyé: "Bearer " supprimé du début avant stockage');
      }
    }
    _token = token;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (token != null) {
        await prefs.setString(_tokenKey, token);
        if (AppConfig.enableLogging) {
          print('✅ Token sauvegardé dans SharedPreferences (${token.length} caractères)');
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
      // Nettoyer le token si "Bearer " est déjà présent
      final cleanToken = token.trim().startsWith('Bearer ') 
          ? token.trim().substring(7).trim() 
          : token.trim();
      headers['Authorization'] = 'Bearer $cleanToken';
    }
    return headers;
  }

  /// Gère les erreurs d'authentification (401/403) en déconnectant l'utilisateur
  static Future<void> _handleAuthError(int statusCode, String? message) async {
    if (statusCode == 401 || statusCode == 403) {
      if (AppConfig.enableLogging) {
        print('🔐 [AUTH ERROR] Erreur d\'authentification ($statusCode): ${message ?? "Token invalide ou expiré"}');
        print('🔐 [AUTH ERROR] Déconnexion automatique...');
      }
      // Supprimer le token invalide
      await clearToken();
      // Note: La redirection vers l'écran de connexion doit être gérée au niveau de l'UI
      // via un callback ou un stream d'événements
    }
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

  /// Décode le payload d'un token JWT pour diagnostiquer son contenu
  /// Retourne null si le token est invalide
  static Map<String, dynamic>? _decodeJwtPayload(String token) {
    try {
      // Un JWT est composé de 3 parties séparées par des points : header.payload.signature
      final parts = token.split('.');
      if (parts.length != 3) {
        return null;
      }
      
      // Décoder le payload (2ème partie)
      final payload = parts[1];
      
      // Base64URL decode (JWT utilise Base64URL, pas Base64 standard)
      // Remplacer les caractères spéciaux Base64URL
      String normalized = payload.replaceAll('-', '+').replaceAll('_', '/');
      
      // Ajouter le padding si nécessaire
      switch (normalized.length % 4) {
        case 1:
          normalized += '===';
          break;
        case 2:
          normalized += '==';
          break;
        case 3:
          normalized += '=';
          break;
      }
      
      // Décoder Base64
      final decoded = utf8.decode(base64Decode(normalized));
      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (e) {
      if (AppConfig.enableLogging) {
        print('⚠️ [JWT DECODE] Erreur lors du décodage du token: $e');
      }
      return null;
    }
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

  /// Récupérer tous les avis d'un professionnel
  static Future<List<ReviewModel>> getProfessionalReviews(int professionalId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reviews/professional/$professionalId'),
        headers: _getPublicHeaders(),
      ).timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((review) => ReviewModel.fromMap(review as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      if (AppConfig.enableLogging) {
        print('❌ Erreur getProfessionalReviews: $e');
      }
      return [];
    }
  }

  /// Récupérer tous les avis de l'utilisateur connecté
  static Future<List<ReviewModel>> getUserReviews() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/reviews/my'),
        headers: headers,
      ).timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((review) => ReviewModel.fromMap(review as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      if (AppConfig.enableLogging) {
        print('❌ Erreur getUserReviews: $e');
      }
      return [];
    }
  }

  /// Supprimer un avis
  static Future<bool> deleteReview(int reviewId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/reviews/$reviewId'),
        headers: headers,
      ).timeout(AppConfig.apiTimeout);

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      if (AppConfig.enableLogging) {
        print('❌ Erreur deleteReview: $e');
      }
      return false;
    }
  }

  /// Vérifier si l'utilisateur a déjà noté une réservation
  static Future<bool> hasUserReviewedReservation(int reservationId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/reviews/check/$reservationId'),
        headers: headers,
      ).timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['hasReviewed'] == true;
      }
      return false;
    } catch (e) {
      if (AppConfig.enableLogging) {
        print('❌ Erreur hasUserReviewedReservation: $e');
      }
      return false;
    }
  }

  /// Obtenir les statistiques d'un professionnel
  static Future<Map<String, dynamic>?> getProfessionalStats(int professionalId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reviews/stats/$professionalId'),
        headers: _getPublicHeaders(),
      ).timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      if (AppConfig.enableLogging) {
        print('❌ Erreur getProfessionalStats: $e');
      }
      return null;
    }
  }

  /// Crée un avis (authentifié)
  /// Le userId (reviewerId - utilisateur qui donne l'avis) est automatiquement extrait du token JWT côté backend
  /// Le backend utilise req.user.userId extrait du token JWT (même configuration que createReport)
  static Future<Map<String, dynamic>?> createReview({
    required int professionalId, // L'utilisateur noté (peut être un professionnel ou une famille)
    required int rating,
    String? comment,
    int? reservationId,
  }) async {
    try {
      final token = await getToken();
      
      // Vérifier que le token est présent
      if (token == null) {
        if (AppConfig.enableLogging) {
          print('❌ [REVIEW] Erreur: Token d\'authentification manquant');
        }
        return null;
      }

      final headers = await _getAuthHeaders();
      
      // Configuration identique à createReport :
      // - Le reviewerId (userId de l'utilisateur qui donne l'avis) est extrait automatiquement du token JWT côté backend
      // - Le backend utilise req.user.userId extrait du token JWT
      // - On envoie uniquement les données nécessaires (professionalId, rating, reservationId, comment)
      final payload = <String, dynamic>{
        'professionalId': professionalId, // L'utilisateur noté (professionnel ou famille)
        'rating': rating,
      };
      
      if (reservationId != null && reservationId > 0) {
        payload['reservationId'] = reservationId;
      }
      
      if (comment != null && comment.trim().isNotEmpty) {
        payload['comment'] = comment.trim();
      }
      
      // Décoder le token JWT pour diagnostiquer
      Map<String, dynamic>? jwtPayload;
      if (token != null) {
        jwtPayload = _decodeJwtPayload(token);
      }
      
      if (AppConfig.enableLogging) {
        print('📡 [REVIEW] Création avis (même config que createReport):');
        print('   professionalId (utilisateur noté): $professionalId');
        print('   rating: $rating');
        if (reservationId != null && reservationId > 0) {
          print('   reservationId: $reservationId');
        }
        if (comment != null && comment.trim().isNotEmpty) {
          print('   comment: ${comment.trim().length > 50 ? comment.trim().substring(0, 50) + "..." : comment.trim()}');
        }
        print('   Le reviewerId (userId qui donne l\'avis) sera extrait du token JWT côté backend');
        print('   Le backend utilise req.user.userId (comme pour createReport)');
        
        // Afficher le contenu du token JWT pour diagnostic
        if (jwtPayload != null) {
          final userId = jwtPayload['userId'] ?? jwtPayload['id'];
          final email = jwtPayload['email'];
          print('   🔍 [DIAGNOSTIC] Contenu du token JWT:');
          print('      - userId dans le token: $userId (${userId?.runtimeType})');
          print('      - id dans le token: ${jwtPayload['id']}');
          print('      - email dans le token: $email');
          print('      - Toutes les clés du token: ${jwtPayload.keys.join(", ")}');
          print('   ⚠️ [DIAGNOSTIC] Le backend doit utiliser ce userId pour l\'insertion dans reviews');
          print('   ⚠️ [DIAGNOSTIC] Si userId est null ou invalide, le backend doit gérer cette erreur');
        } else {
          print('   ⚠️ [DIAGNOSTIC] Impossible de décoder le token JWT');
        }
        
        print('📡 [REVIEW] Payload JSON: ${jsonEncode(payload)}');
        print('📡 [REVIEW] URL: $baseUrl/reviews');
        print('📡 [REVIEW] Headers: ${headers.keys.join(", ")}');
        print('📡 [REVIEW] Token présent: ${headers.containsKey('Authorization')}');
        if (headers.containsKey('Authorization')) {
          final authHeader = headers['Authorization']!;
          final previewLength = authHeader.length > 30 ? 30 : authHeader.length;
          print('📡 [REVIEW] Authorization header (premiers $previewLength chars): ${authHeader.substring(0, previewLength)}...');
        }
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/reviews'),
        headers: headers,
        body: jsonEncode(payload),
      ).timeout(AppConfig.apiTimeout);

      if (AppConfig.enableLogging) {
        print('📡 [REVIEW] Status Code: ${response.statusCode}');
        print('📡 [REVIEW] Response Headers: ${response.headers}');
      }

      // Gérer les erreurs d'authentification (même logique que createReport)
      if (response.statusCode == 401 || response.statusCode == 403) {
        try {
          final errorData = json.decode(response.body);
          final errorMessage = errorData['message'] as String?;
          await _handleAuthError(response.statusCode, errorMessage);
        } catch (e) {
          await _handleAuthError(response.statusCode, 'Token invalide ou expiré');
        }
        
        if (AppConfig.enableLogging) {
          print('❌ [REVIEW] Token invalide - L\'utilisateur doit se reconnecter pour créer un avis');
        }
        return null;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (AppConfig.enableLogging) {
          print('✅ [REVIEW] Avis créé avec succès');
          print('📡 [REVIEW] Response Body: ${response.body}');
        }
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        // Vérifier le Content-Type
        final contentType = response.headers['content-type'] ?? '';
        if (!contentType.contains('application/json') && response.body.isNotEmpty) {
          if (AppConfig.enableLogging) {
            print('❌ [REVIEW] Erreur createReview: Le serveur a retourné du HTML');
            print('Réponse: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');
          }
          return null;
        }
        
        try {
          final error = json.decode(response.body);
          final errorMessage = error['message'] ?? response.body;
          final errorDetails = error['error'] as String?;
          
          if (AppConfig.enableLogging) {
            print('❌ [REVIEW] Erreur createReview: ${response.statusCode} - $errorMessage');
            if (errorDetails != null) {
              print('❌ [REVIEW] Détails de l\'erreur: $errorDetails');
            }
            print('📡 [REVIEW] Response Body complet:');
            print('${response.body}');
            
            // Analyser l'erreur de contrainte de clé étrangère (même diagnostic que createReport)
            if (errorDetails != null && errorDetails.contains('foreign key constraint')) {
              print('⚠️ [REVIEW] PROBLÈME: Contrainte de clé étrangère échouée');
              print('⚠️ [REVIEW] Cela signifie que le userId extrait du token JWT n\'existe pas dans la table users');
              print('⚠️ [REVIEW] Solutions côté backend (identique à createReport):');
              print('   1. Vérifier que le backend utilise req.user.userId (et non req.user.id)');
              print('   2. Vérifier que req.user.userId existe dans la table users avant insertion');
              print('   3. Le token JWT doit contenir userId (comme pour createReport)');
              print('⚠️ [REVIEW] Solutions côté client:');
              print('   1. Se reconnecter pour obtenir un nouveau token valide');
              print('   2. Vérifier que l\'utilisateur est bien connecté');
            }
          }
        } catch (parseError) {
          if (AppConfig.enableLogging) {
            print('❌ [REVIEW] Erreur parsing JSON: $parseError');
            print('❌ [REVIEW] Réponse brute: ${response.body}');
          }
        }
        return null;
      }
    } catch (e) {
      if (AppConfig.enableLogging) {
        print('❌ [REVIEW] Erreur createReview: $e');
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
      request.fields['documentType'] = type;
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

  // ========== DOCUMENTS ==========

  /// Récupère les documents d'un utilisateur
  static Future<List<DocumentModel>> getDocuments(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/documents?userId=$userId'),
        headers: _getPublicHeaders(),
      ).timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((map) => DocumentModel.fromMap(map as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      if (AppConfig.enableLogging) {
        print('❌ Erreur getDocuments: $e');
      }
      return [];
    }
  }

  /// Récupère les documents d'un utilisateur par type
  static Future<List<DocumentModel>> getDocumentsByType({
    required int userId,
    String? documentType,
  }) async {
    try {
      String url = '$baseUrl/documents?userId=$userId';
      if (documentType != null) {
        url += '&documentType=$documentType';
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: _getPublicHeaders(),
      ).timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((map) => DocumentModel.fromMap(map as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      if (AppConfig.enableLogging) {
        print('❌ Erreur getDocumentsByType: $e');
      }
      return [];
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

  // ========== SIGNALEMENTS (REPORTS) ==========

  /// Créer un signalement
  /// Le reporterId (userId de l'utilisateur qui signale) est automatiquement extrait du token JWT côté backend
  /// Le backend utilise req.user.userId extrait du token JWT
  static Future<ReportModel?> createReport({
    required int reportedUserId, // L'utilisateur signalé (userId)
    required String reason, // Le type/raison du signalement
    String? description, // La description/message
  }) async {
    try {
      final token = await getToken();
      
      // Vérifier que le token est présent
      if (token == null) {
        print('❌ [REPORT] Erreur: Token d\'authentification manquant');
        return null;
      }
      
      // Validation: le message est requis
      final messageText = description?.trim() ?? '';
      if (messageText.isEmpty) {
        print('❌ [REPORT] Erreur: Le message (description) est requis');
        return null;
      }
      
      // Le backend attend: reportedUserId (utilisateur signalé), type, message
      // Le userId (utilisateur qui signale) est extrait automatiquement du token JWT côté backend
      final payload = <String, dynamic>{
        'reportedUserId': reportedUserId, // L'utilisateur signalé
        'type': reason, // Le type/raison du signalement
        'message': messageText, // La description (requis et non vide)
      };
      
      print('📡 [REPORT] Payload adapté à la structure backend (reportedUserId, type, message)');
      print('📡 [REPORT] Le userId (celui qui signale) sera extrait automatiquement du token JWT côté backend');
      
      print('📡 [REPORT] Création signalement:');
      print('   userId (celui qui signale): (sera extrait du token JWT côté backend)');
      print('   reportedUserId (utilisateur signalé): $reportedUserId');
      print('   type: $reason');
      if (description != null && description.trim().isNotEmpty) {
        final desc = description.trim();
        print('   message: ${desc.length > 50 ? desc.substring(0, 50) + '...' : desc}');
      } else {
        print('   message: (vide - peut causer une erreur)');
      }
      
      final headers = await _getAuthHeaders();
      
      // Toujours logger les informations critiques
      print('📡 [REPORT] URL complète: $baseUrl/reports');
      print('📡 [REPORT] Headers: ${headers.keys.join(", ")}');
      print('📡 [REPORT] Token présent: ${headers.containsKey('Authorization')}');
      print('📡 [REPORT] Token (premiers 20 chars): ${token.substring(0, token.length > 20 ? 20 : token.length)}...');
      print('📡 [REPORT] Payload JSON: ${jsonEncode(payload)}');
      
      final response = await http.post(
        Uri.parse('$baseUrl/reports'),
        headers: headers,
        body: jsonEncode(payload),
      ).timeout(AppConfig.apiTimeout);

      // Toujours logger le status code pour le diagnostic
      print('📡 [REPORT] Status Code: ${response.statusCode}');
      print('📡 [REPORT] Response Headers: ${response.headers}');

      // Vérifier le Content-Type
      final contentType = response.headers['content-type'] ?? '';
      if (!contentType.contains('application/json') && response.body.isNotEmpty) {
        if (response.body.trim().startsWith('<!DOCTYPE') || response.body.trim().startsWith('<html')) {
          if (AppConfig.enableLogging) {
            print('❌ Erreur createReport: Le serveur a retourné du HTML');
            print('Réponse: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');
          }
          return null;
        }
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ [REPORT] Signalement créé avec succès - Status: ${response.statusCode}');
        print('📡 [REPORT] Réponse complète du backend:');
        print('${response.body}');
        
        try {
          final data = json.decode(response.body) as Map<String, dynamic>;
          
          // Logs détaillés pour vérifier la sauvegarde en base
          print('📊 [REPORT] ========== ANALYSE RÉPONSE CRÉATION ==========');
          print('📊 [REPORT] Données brutes retournées par le backend:');
          print('   🔑 ID du signalement: ${data['id']} ${data['id'] != null ? "✅" : "❌ MANQUANT"}');
          print('   👤 reporterId: ${data['reporterId']} ${data['reporterId'] != null ? "✅" : "❌ MANQUANT"}');
          print('   🎯 reportedUserId: ${data['reportedUserId'] ?? data['userId']} ${(data['reportedUserId'] ?? data['userId']) != null ? "✅" : "❌ MANQUANT"}');
          print('   📝 reason/type: ${data['reason'] ?? data['type']} ${(data['reason'] ?? data['type']) != null ? "✅" : "❌ MANQUANT"}');
          print('   📄 description/message: ${(data['description'] ?? data['message'] ?? '').toString().substring(0, (data['description'] ?? data['message'] ?? '').toString().length > 50 ? 50 : (data['description'] ?? data['message'] ?? '').toString().length)}... ${(data['description'] ?? data['message']) != null ? "✅" : "❌ MANQUANT"}');
          print('   📊 status: ${data['status']} ${data['status'] != null ? "✅" : "❌ MANQUANT"}');
          print('   📅 createdAt: ${data['createdAt']} ${data['createdAt'] != null ? "✅" : "❌ MANQUANT"}');
          
          // Vérifier si le signalement a bien été sauvegardé en base
          if (data['id'] != null) {
            print('✅ [REPORT] Signalement sauvegardé en base avec ID: ${data['id']}');
          } else {
            print('❌ [REPORT] PROBLÈME: L\'ID du signalement est manquant - Le signalement n\'a peut-être pas été sauvegardé en base');
          }
          
          if (data['reporterId'] != null && data['reporterId'] != 0) {
            print('✅ [REPORT] reporterId correctement sauvegardé: ${data['reporterId']}');
          } else {
            print('⚠️ [REPORT] ATTENTION: reporterId est ${data['reporterId']} - Le backend ne l\'a peut-être pas sauvegardé correctement');
          }
          
          print('📊 [REPORT] ===============================================');
          
          final report = ReportModel.fromMap(data);
          
          if (AppConfig.enableLogging) {
            print('✅ [REPORT] Signalement parsé avec succès:');
            print('   ID: ${report.id}');
            print('   reporterId: ${report.reporterId}');
            print('   reportedUserId: ${report.reportedUserId}');
            print('   status: ${report.status}');
            
            if (report.reporterId == 0) {
              print('⚠️ [REPORT] ATTENTION: reporterId parsé est 0 - le backend ne l\'a peut-être pas retourné dans la réponse');
            }
            
            // Vérifier immédiatement si on peut récupérer le signalement via /api/reports/my
            print('🔍 [REPORT] Vérification: Test de récupération via /api/reports/my dans 2 secondes...');
            Future.delayed(const Duration(seconds: 2), () async {
              if (report.id != null) {
                print('🔍 [REPORT] Vérification en cours...');
                final allMyReports = await getMyReports();
                final foundReport = allMyReports.firstWhere(
                  (r) => r.id == report.id,
                  orElse: () => ReportModel(
                    id: null,
                    reporterId: 0,
                    reportedUserId: 0,
                    reason: '',
                    createdAt: DateTime.now(),
                  ),
                );
                
                if (foundReport.id != null && foundReport.id == report.id) {
                  print('✅ [REPORT] ✅✅✅ VÉRIFICATION RÉUSSIE ✅✅✅');
                  print('   Le signalement #${report.id} est bien accessible via /api/reports/my');
                  print('   reporterId dans le signalement récupéré: ${foundReport.reporterId}');
                  print('   status: ${foundReport.status}');
                } else {
                  print('❌ [REPORT] ❌❌❌ PROBLÈME DÉTECTÉ ❌❌❌');
                  print('   Le signalement #${report.id} N\'EST PAS retourné par /api/reports/my');
                  print('   Nombre total de signalements retournés: ${allMyReports.length}');
                  if (allMyReports.isNotEmpty) {
                    print('   IDs des signalements retournés: ${allMyReports.map((r) => r.id).join(", ")}');
                  }
                  print('   ⚠️ Cela suggère que le backend ne filtre pas correctement par reporterId');
                }
              }
            });
          }
          
          return report;
        } catch (e, stackTrace) {
          if (AppConfig.enableLogging) {
            print('❌ [REPORT] Erreur lors du parsing de la réponse: $e');
            print('   Stack trace: $stackTrace');
            print('📡 Body brut: ${response.body}');
          }
          return null;
        }
      } else {
        // Toujours logger les erreurs pour le diagnostic
        print('❌ [REPORT] Erreur createReport: ${response.statusCode}');
        print('📡 [REPORT] Response Body complet:');
        print('${response.body}');
        print('📡 [REPORT] Response Body length: ${response.body.length}');
        try {
          final error = json.decode(response.body) as Map<String, dynamic>;
          final errorMessage = error['message'] ?? error['error'] ?? 'Erreur inconnue';
          print('❌ [REPORT] Message: $errorMessage');
          print('❌ [REPORT] Détails complets: $error');
          if (error.containsKey('stack')) {
            print('❌ [REPORT] Stack trace serveur: ${error['stack']}');
          }
          // Si c'est une erreur 500, suggérer de vérifier les logs serveur
          if (response.statusCode == 500) {
            print('⚠️ [REPORT] Erreur 500 - Vérifiez les logs serveur pour plus de détails');
            print('⚠️ [REPORT] Causes possibles:');
            print('   1. La table "reports" n\'existe pas dans la base de données');
            print('   2. La fonction NOW() n\'est pas supportée (utiliser datetime(\'now\') pour SQLite)');
            print('   3. Erreur SQL dans la requête INSERT');
            print('   4. Problème de connexion à la base de données');
          }
        } catch (parseError) {
          print('❌ [REPORT] Erreur parsing JSON: $parseError');
          print('❌ [REPORT] Réponse brute (500 premiers chars):');
          final bodyPreview = response.body.length > 500 
              ? response.body.substring(0, 500) + '...'
              : response.body;
          print(bodyPreview);
        }
        return null;
      }
    } catch (e, stackTrace) {
      if (AppConfig.enableLogging) {
        print('❌ Erreur createReport (exception): $e');
        print('   Stack: $stackTrace');
      }
      return null;
    }
  }

  /// Récupère les signalements de l'utilisateur connecté
  static Future<List<ReportModel>> getReports() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/reports'),
        headers: headers,
      ).timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((map) => ReportModel.fromMap(map as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      if (AppConfig.enableLogging) {
        print('❌ Erreur getReports: $e');
      }
      return [];
    }
  }

  /// Récupérer mes signalements envoyés
  /// Utilise le token JWT pour identifier automatiquement l'utilisateur connecté
  /// Le backend filtre automatiquement via la route /api/reports/my
  /// Le backend utilise req.user.userId extrait du token JWT
  /// Fallback vers /api/reports avec filtrage côté client si la nouvelle route échoue (compatibilité)
  static Future<List<ReportModel>> getMyReports() async {
    try {
      final headers = await _getAuthHeaders();
      final url = '$baseUrl/reports/my';
      
      if (AppConfig.enableLogging) {
        print('📡 [GET MY REPORTS] Appel de la route sécurisée: $url');
        print('📡 [GET MY REPORTS] Token présent: ${headers.containsKey('Authorization')}');
        if (headers.containsKey('Authorization')) {
          final authHeader = headers['Authorization']!;
          final previewLength = authHeader.length > 30 ? 30 : authHeader.length;
          print('📡 [GET MY REPORTS] Authorization header (premiers $previewLength chars): ${authHeader.substring(0, previewLength)}...');
          // Vérifier que le format est correct (doit commencer par "Bearer ")
          if (!authHeader.startsWith('Bearer ')) {
            print('⚠️ [GET MY REPORTS] ATTENTION: Le header Authorization ne commence pas par "Bearer "');
          } else {
            print('✅ [GET MY REPORTS] Format du header Authorization correct');
          }
          print('📡 [GET MY REPORTS] Le backend extraira userId depuis le token JWT');
        } else {
          print('❌ [GET MY REPORTS] PROBLÈME: Pas de header Authorization dans les headers');
        }
      }
      
      final response = await http.get(
        Uri.parse(url), // Nouvelle route qui filtre par token JWT
        headers: headers,
      ).timeout(AppConfig.apiTimeout);

      if (AppConfig.enableLogging) {
        print('📡 [GET MY REPORTS] Status Code: ${response.statusCode}');
      }

      // Gérer les erreurs d'authentification
      if (response.statusCode == 401 || response.statusCode == 403) {
        try {
          final errorData = json.decode(response.body);
          final errorMessage = errorData['message'] as String?;
          await _handleAuthError(response.statusCode, errorMessage);
        } catch (e) {
          await _handleAuthError(response.statusCode, 'Token invalide ou expiré');
        }
        
        if (AppConfig.enableLogging) {
          print('❌ [GET MY REPORTS] Token invalide - L\'utilisateur doit se reconnecter');
        }
        
        // Essayer le fallback avant de retourner vide
        return await _getMyReportsFallback();
      }

      // Si la nouvelle route fonctionne (200), retourner les résultats
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        if (AppConfig.enableLogging) {
          print('📡 [GET MY REPORTS] Nombre de signalements reçus: ${data.length}');
          if (data.isNotEmpty) {
            print('📡 [GET MY REPORTS] Premier signalement brut (échantillon):');
            print('   ${jsonEncode(data[0])}');
          }
        }
        
        // Parser tous les signalements (le backend a déjà filtré par utilisateur)
        final reports = data
            .map((json) {
              try {
                final map = json as Map<String, dynamic>;
                if (AppConfig.enableLogging) {
                  print('📡 [GET MY REPORTS] Signalement brut:');
                  print('   ID: ${map['id']}');
                  print('   reporterId: ${map['reporterId']}');
                  print('   reportedUserId: ${map['reportedUserId'] ?? map['userId']}');
                  print('   reason/type: ${map['reason'] ?? map['type']}');
                  print('   status: ${map['status']}');
                }
                final report = ReportModel.fromMap(map);
                if (AppConfig.enableLogging) {
                  print('✅ [GET MY REPORTS] Signalement parsé - ID: ${report.id}, reporterId: ${report.reporterId}, status: ${report.status}');
                }
                return report;
              } catch (e) {
                if (AppConfig.enableLogging) {
                  print('❌ [GET MY REPORTS] Erreur parsing signalement: $e');
                  print('   Données: $json');
                }
                return null;
              }
            })
            .whereType<ReportModel>()
            .toList();
        
        if (AppConfig.enableLogging) {
          print('✅ [GET MY REPORTS] ${reports.length} signalement(s) retourné(s) pour l\'utilisateur connecté');
          if (reports.isNotEmpty) {
            for (final report in reports) {
              print('   - Signalement #${report.id}: reporterId=${report.reporterId}, reportedUserId=${report.reportedUserId}, status=${report.status}');
            }
          }
        }
        
        return reports;
      }
      
      // Si la nouvelle route échoue (404 ou 500), essayer avec l'ancienne route + filtrage client
      if (response.statusCode == 404 || response.statusCode == 500) {
        if (AppConfig.enableLogging) {
          print('⚠️ [GET MY REPORTS] Nouvelle route échoue (${response.statusCode}), fallback vers ancienne route');
          if (response.statusCode == 404) {
            print('   ⚠️ La route /api/reports/my n\'existe pas encore sur le backend');
          } else if (response.statusCode == 500) {
            print('   ⚠️ Erreur serveur sur /api/reports/my - Vérifiez les logs du backend');
          }
          print('   🔄 Utilisation de l\'ancienne méthode avec filtrage côté client...');
        }
        
        // Fallback: utiliser l'ancienne route et récupérer userId depuis le token ou currentUser
        return await _getMyReportsFallback();
      }
      
      // Autre erreur
      if (AppConfig.enableLogging) {
        print('❌ [GET MY REPORTS] Erreur HTTP: ${response.statusCode}');
        print('   URL appelée: $url');
        print('   Réponse complète: ${response.body}');
      }
      return [];
    } catch (e, stackTrace) {
      if (AppConfig.enableLogging) {
        print('❌ [GET MY REPORTS] Exception lors de l\'appel à la nouvelle route: $e');
        print('   Stack: $stackTrace');
        print('   🔄 Tentative avec l\'ancienne méthode...');
      }
      
      // En cas d'exception, essayer le fallback
      try {
        return await _getMyReportsFallback();
      } catch (fallbackError) {
        if (AppConfig.enableLogging) {
          print('❌ [GET MY REPORTS] Le fallback a également échoué: $fallbackError');
        }
        return [];
      }
    }
  }
  
  /// Méthode de fallback utilisant l'ancienne route /api/reports avec filtrage côté client
  /// Utilisée si la nouvelle route /api/reports/my n'est pas disponible
  static Future<List<ReportModel>> _getMyReportsFallback() async {
    try {
      // Récupérer l'userId depuis l'utilisateur sauvegardé
      final currentUser = await getCurrentUser();
      if (currentUser == null || currentUser['id'] == null) {
        if (AppConfig.enableLogging) {
          print('⚠️ [GET MY REPORTS FALLBACK] Impossible de récupérer userId, retour de liste vide');
        }
        return [];
      }
      
      final userId = currentUser['id'] as int;
      
      if (AppConfig.enableLogging) {
        print('📡 [GET MY REPORTS FALLBACK] Utilisation de l\'ancienne route pour userId: $userId');
      }
      
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/reports'),
        headers: headers,
      ).timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        // Filtrer côté client par reporterId
        final reports = data
            .map((json) {
              try {
                final map = json as Map<String, dynamic>;
                return ReportModel.fromMap(map);
              } catch (e) {
                return null;
              }
            })
            .whereType<ReportModel>()
            .where((report) => report.reporterId == userId)
            .toList();
        
        if (AppConfig.enableLogging) {
          print('✅ [GET MY REPORTS FALLBACK] ${reports.length} signalement(s) filtré(s) côté client');
        }
        
        return reports;
      }
      
      return [];
    } catch (e) {
      if (AppConfig.enableLogging) {
        print('❌ [GET MY REPORTS FALLBACK] Erreur: $e');
      }
      return [];
    }
  }

  /// Récupérer les détails d'un signalement
  static Future<ReportModel?> getReportById(int reportId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/reports/$reportId'),
        headers: headers,
      ).timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return ReportModel.fromMap(data);
      }
      return null;
    } catch (e) {
      if (AppConfig.enableLogging) {
        print('❌ Erreur récupération signalement: $e');
      }
      return null;
    }
  }

  // ========== PARAMÈTRES SYSTÈME ==========

  static SettingsModel? _cachedSettings;
  static DateTime? _settingsCacheTime;
  static const Duration _settingsCacheDuration = Duration(hours: 24);

  /// Récupère les paramètres système (avec cache de 24h)
  static Future<SettingsModel?> getSettings({bool forceRefresh = false}) async {
    // Vérifier le cache
    if (!forceRefresh &&
        _cachedSettings != null &&
        _settingsCacheTime != null &&
        DateTime.now().difference(_settingsCacheTime!) < _settingsCacheDuration) {
      return _cachedSettings;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/settings'),
        headers: _getPublicHeaders(),
      ).timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        _cachedSettings = SettingsModel.fromMap(data);
        _settingsCacheTime = DateTime.now();
        return _cachedSettings;
      }
      return null;
    } catch (e) {
      if (AppConfig.enableLogging) {
        print('❌ Erreur getSettings: $e');
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

  /// Demande un remboursement Stripe
  static Future<Map<String, dynamic>?> requestRefund({
    required String paymentIntentId,
    double? amount, // Montant partiel en euros (optionnel, sinon remboursement total)
    String reason = 'requested_by_customer', // 'requested_by_customer' | 'duplicate' | 'fraudulent'
  }) async {
    try {
      final requestBody = <String, dynamic>{
        'paymentIntentId': paymentIntentId,
        'reason': reason,
      };
      
      if (amount != null) {
        requestBody['amount'] = amount; // Montant en euros
      }

      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/stripe/refund'),
        headers: headers,
        body: jsonEncode(requestBody),
      ).timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        final error = json.decode(response.body);
        if (AppConfig.enableLogging) {
          print('❌ Erreur remboursement: ${response.statusCode} - ${error['message'] ?? response.body}');
        }
        return null;
      }
    } catch (e) {
      if (AppConfig.enableLogging) {
        print('❌ Erreur remboursement: $e');
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
