import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service pour les appels API vers le backend
class ApiService {
  // Pour iOS Simulator : localhost fonctionne
  // Pour Android Emulator : utiliser 10.0.2.2 au lieu de localhost
  // Pour appareil physique : utiliser l'IP de la machine (ex: 192.168.x.x)
  static const String baseUrl = 'http://localhost:3001';
  
  // Alternative pour Android Emulator
  // static const String baseUrl = 'http://10.0.2.2:3001';

  /// Récupère les badges d'un utilisateur
  static Future<List<Map<String, dynamic>>> getBadges(int userId) async {
    try {
      final url = Uri.parse('$baseUrl/api/badges?userId=$userId');
      print('🔍 Récupération badges depuis: $url');
      
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      print('📡 Réponse badges - Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('✅ ${data.length} badge(s) récupéré(s)');
        return data.cast<Map<String, dynamic>>();
      } else {
        print('❌ Erreur HTTP ${response.statusCode}: ${response.body}');
      }
      return [];
    } catch (e) {
      print('❌ Erreur récupération badges: $e');
      return [];
    }
  }

  /// Récupère la note moyenne d'un utilisateur
  static Future<Map<String, dynamic>?> getRating(int userId) async {
    try {
      final url = Uri.parse('$baseUrl/api/ratings?userId=$userId');
      print('🔍 Récupération rating depuis: $url');
      
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      print('📡 Réponse rating - Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data is Map) {
          print('✅ Rating récupéré: $data');
          return data as Map<String, dynamic>;
        }
      } else {
        print('❌ Erreur HTTP ${response.statusCode}: ${response.body}');
      }
      return null;
    } catch (e) {
      print('❌ Erreur récupération rating: $e');
      return null;
    }
  }

  /// Récupère les avis d'un professionnel
  static Future<List<Map<String, dynamic>>> getReviews(int professionalId) async {
    try {
      final url = Uri.parse('$baseUrl/api/reviews');
      print('🔍 Récupération reviews depuis: $url (professionalId: $professionalId)');
      
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      print('📡 Réponse reviews - Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('📊 ${data.length} avis récupéré(s) au total');
        
        if (data.isNotEmpty) {
          print('🔍 Premier avis (debug): ${data.first}');
        }
        
        // Filtrer les avis pour ce professionnel
        final filtered = <Map<String, dynamic>>[];
        for (final review in data) {
          final profId = review['professionalId'];
          final profIdInt = profId is int ? profId : (profId is String ? int.tryParse(profId) : null);
          
          if (profIdInt == professionalId) {
            filtered.add(review as Map<String, dynamic>);
          } else {
            print('⚠️ Avis ignoré - professionalId: $profId (type: ${profId.runtimeType}), recherché: $professionalId');
          }
        }
        
        print('✅ ${filtered.length} avis pour le professionnel $professionalId');
        return filtered;
      } else {
        print('❌ Erreur HTTP ${response.statusCode}: ${response.body}');
      }
      return [];
    } catch (e) {
      print('❌ Erreur récupération reviews: $e');
      return [];
    }
  }
}

