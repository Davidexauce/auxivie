# 📱 Guide d'Intégration Flutter - API Auxivie

Ce document contient toutes les informations nécessaires pour intégrer votre application Flutter avec le Dashboard Admin Auxivie.

---

## 📋 Table des matières

1. [Configuration de base](#configuration-de-base)
2. [Authentification](#authentification)
3. [Endpoints API](#endpoints-api)
4. [Structures de données](#structures-de-données)
5. [Exemples de code Flutter](#exemples-de-code-flutter)
6. [Gestion des erreurs](#gestion-des-erreurs)
7. [Upload de fichiers](#upload-de-fichiers)
8. [Paiements Stripe](#paiements-stripe)

---

## 🔧 Configuration de base

### URL de l'API

```
Base URL: https://auxivie.org
API Base: https://auxivie.org/api
```

### Headers requis

Pour toutes les requêtes authentifiées, inclure le header suivant :

```dart
headers: {
  'Content-Type': 'application/json',
  'Authorization': 'Bearer $token',
  'x-request-type': 'mobile',  // Important pour les requêtes depuis l'app mobile
}
```

### Package Flutter recommandé

Ajoutez dans votre `pubspec.yaml` :

```yaml
dependencies:
  http: ^1.1.0
  dio: ^5.4.0  # Alternative plus complète que http
  shared_preferences: ^2.2.2  # Pour stocker le token
```

---

## 🔐 Authentification

### 1. Connexion (Login)

**Endpoint:** `POST /api/auth/login`

**Headers:**
```dart
{
  'Content-Type': 'application/json',
  'x-request-type': 'mobile',
}
```

**Body:**
```json
{
  "email": "user@example.com",
  "password": "motdepasse123"
}
```

**Réponse réussie (200):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "user@example.com",
    "userType": "professionnel"  // ou "famille", "admin"
  }
}
```

**Réponse erreur (401):**
```json
{
  "message": "Email ou mot de passe incorrect"
}
```

**Exemple Flutter:**
```dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

Future<Map<String, dynamic>?> login(String email, String password) async {
  try {
    final response = await http.post(
      Uri.parse('https://auxivie.org/api/auth/login'),
      headers: {
        'Content-Type': 'application/json',
        'x-request-type': 'mobile',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      // Sauvegarder le token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      await prefs.setString('user', jsonEncode(data['user']));
      
      return data;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Erreur de connexion');
    }
  } catch (e) {
    throw Exception('Erreur réseau: $e');
  }
}
```

### 2. Récupérer le token stocké

```dart
Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('token');
}

Future<Map<String, dynamic>?> getCurrentUser() async {
  final prefs = await SharedPreferences.getInstance();
  final userJson = prefs.getString('user');
  if (userJson != null) {
    return jsonDecode(userJson);
  }
  return null;
}
```

### 3. Déconnexion

```dart
Future<void> logout() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('token');
  await prefs.remove('user');
}
```

---

## 📡 Endpoints API

### Utilisateurs

#### 1. Récupérer tous les professionnels (Public)

**Endpoint:** `GET /api/users?userType=professionnel`

**Headers:** Aucun (route publique)

**Réponse:**
```json
[
  {
    "id": 1,
    "name": "Marie Dupont",
    "email": "marie@example.com",
    "phone": "0612345678",
    "categorie": "Aide à domicile",
    "ville": "Paris",
    "tarif": "25.00",
    "experience": "5 ans",
    "photo": "https://auxivie.org/uploads/photos/photo-123.jpg",
    "userType": "professionnel"
  }
]
```

#### 2. Récupérer un utilisateur par ID (Public)

**Endpoint:** `GET /api/users/:id`

**Exemple:** `GET /api/users/1`

**Réponse:**
```json
{
  "id": 1,
  "name": "Marie Dupont",
  "email": "marie@example.com",
  "phone": "0612345678",
  "categorie": "Aide à domicile",
  "ville": "Paris",
  "tarif": "25.00",
  "experience": "5 ans",
  "photo": "https://auxivie.org/uploads/photos/photo-123.jpg",
  "userType": "professionnel",
  "besoin": "Aide ménagère",
  "preference": "Matin",
  "mission": "Nettoyage",
  "particularite": "Animaux acceptés"
}
```

#### 3. Synchroniser un utilisateur (Créer/Mettre à jour)

**Endpoint:** `POST /api/users/sync`

**Headers:** Aucun (route publique pour synchronisation)

**Body:**
```json
{
  "name": "Marie Dupont",
  "email": "marie@example.com",
  "password": "motdepasse123",
  "phone": "0612345678",
  "categorie": "Aide à domicile",
  "ville": "Paris",
  "tarif": "25.00",
  "experience": "5 ans",
  "photo": "https://example.com/photo.jpg",
  "userType": "professionnel",
  "besoin": "Aide ménagère",
  "preference": "Matin",
  "mission": "Nettoyage",
  "particularite": "Animaux acceptés"
}
```

**Réponse:**
```json
{
  "message": "Utilisateur créé",  // ou "Utilisateur mis à jour"
  "id": 1,
  "user": {
    "id": 1,
    "name": "Marie Dupont",
    "email": "marie@example.com",
    "userType": "professionnel",
    "besoin": "Aide ménagère",
    "preference": "Matin",
    "mission": "Nettoyage",
    "particularite": "Animaux acceptés"
  }
}
```

### Réservations

#### 1. Récupérer les réservations d'un utilisateur (Public)

**Endpoint:** `GET /api/reservations?userId=1`

**Ou pour un professionnel:**
**Endpoint:** `GET /api/reservations?professionnelId=2`

**Réponse:**
```json
[
  {
    "id": 1,
    "userId": 1,
    "professionnelId": 2,
    "date": "2025-01-15",
    "dateFin": null,
    "heure": "10:00",
    "status": "pending",  // pending, confirmed, completed, cancelled
    "createdAt": "2025-01-10T10:00:00.000Z",
    "familleName": "Jean Dupont",
    "professionalName": "Marie Martin"
  }
]
```

#### 2. Synchroniser une réservation (Créer/Mettre à jour)

**Endpoint:** `POST /api/reservations/sync`

**Headers:** Aucun (route publique)

**Body:**
```json
{
  "userId": 1,
  "professionnelId": 2,
  "date": "2025-01-15",
  "dateFin": "2025-01-15",  // Optionnel
  "heure": "10:00",
  "status": "pending"  // Optionnel, par défaut "pending"
}
```

**Réponse:**
```json
{
  "id": 1,
  "message": "Réservation synchronisée"  // ou "Réservation mise à jour"
}
```

### Messages

#### 1. Récupérer les messages entre deux utilisateurs (Public)

**Endpoint:** `GET /api/messages?userId=1&partnerId=2`

**Réponse:**
```json
[
  {
    "id": 1,
    "senderId": 1,
    "receiverId": 2,
    "content": "Bonjour, êtes-vous disponible ?",
    "timestamp": "2025-01-10T10:00:00.000Z",
    "isRead": 0
  }
]
```

#### 2. Envoyer un message (Public)

**Endpoint:** `POST /api/messages`

**Body:**
```json
{
  "senderId": 1,
  "receiverId": 2,
  "content": "Bonjour, êtes-vous disponible ?"
}
```

**Réponse:**
```json
{
  "id": 1,
  "message": "Message envoyé"
}
```

#### 3. Récupérer les partenaires de conversation (Public)

**Endpoint:** `GET /api/messages/partners?userId=1`

**Réponse:**
```json
[2, 3, 5]  // Liste des IDs des utilisateurs avec qui l'utilisateur a échangé
```

### Avis (Reviews)

#### 1. Récupérer tous les avis (Public)

**Endpoint:** `GET /api/reviews`

**Réponse:**
```json
[
  {
    "id": 1,
    "reservationId": 1,
    "userId": 1,
    "professionalId": 2,
    "rating": 5,
    "comment": "Excellent service !",
    "createdAt": "2025-01-10T10:00:00.000Z",
    "userName": "Jean Dupont",
    "professionalName": "Marie Martin"
  }
]
```

#### 2. Créer un avis (Authentifié)

**Endpoint:** `POST /api/reviews`

**Headers:** `Authorization: Bearer $token`

**Body:**
```json
{
  "professionalId": 2,
  "userId": 1,
  "rating": 5,
  "comment": "Excellent service !",
  "userName": "Jean Dupont",  // Optionnel
  "reservationId": 1  // Optionnel, 0 par défaut
}
```

**Réponse:**
```json
{
  "id": 1,
  "message": "Avis créé avec succès"
}
```

### Notes (Ratings)

#### 1. Récupérer les notes d'un utilisateur (Public)

**Endpoint:** `GET /api/ratings?userId=1`

**Réponse:**
```json
{
  "userId": 1,
  "averageRating": 4.5,
  "totalRatings": 10,
  "updatedAt": "2025-01-10T10:00:00.000Z"
}
```

**Ou `null` si aucune note n'existe.**

### Badges

#### 1. Récupérer les badges d'un utilisateur (Public)

**Endpoint:** `GET /api/badges?userId=1`

**Réponse:**
```json
[
  {
    "id": 1,
    "userId": 1,
    "badgeType": "verified",
    "badgeName": "Profil vérifié",
    "badgeIcon": "✓",
    "description": "Ce professionnel a été vérifié",
    "createdAt": "2025-01-10T10:00:00.000Z"
  }
]
```

### Disponibilités

#### 1. Récupérer les disponibilités d'un professionnel (Public)

**Endpoint:** `GET /api/availabilities?professionnelId=1`

**Réponse:**
```json
[
  {
    "id": 1,
    "professionnelId": 1,
    "jourSemaine": 1,  // 0=Dimanche, 1=Lundi, ..., 6=Samedi
    "heureDebut": "09:00",
    "heureFin": "17:00"
  }
]
```

### Documents

#### 1. Uploader un document (Public)

**Endpoint:** `POST /api/documents/upload`

**Content-Type:** `multipart/form-data`

**Body (FormData):**
```
file: [Fichier JPEG, PNG ou PDF - Max 10MB]
userId: 1
type: "identity"  // ou "diploma", "certificate", etc.
```

**Réponse:**
```json
{
  "id": 1,
  "message": "Document uploadé avec succès",
  "path": "/uploads/documents/doc-1-1234567890.pdf",
  "url": "https://auxivie.org/uploads/documents/doc-1-1234567890.pdf"
}
```

### Photos de profil

#### 1. Uploader une photo de profil (Public)

**Endpoint:** `POST /api/users/:id/photo`

**Content-Type:** `multipart/form-data`

**Body (FormData):**
```
photo: [Fichier JPEG ou PNG - Max 5MB]
```

**Réponse:**
```json
{
  "message": "Photo de profil mise à jour",
  "photo": "https://auxivie.org/uploads/photos/photo-1-1234567890.jpg"
}
```

### Paiements Stripe

#### 1. Créer un PaymentIntent (Public)

**Endpoint:** `POST /api/payments/create-intent`

**Body:**
```json
{
  "amount": 50.00,
  "currency": "eur",
  "reservationId": 1,
  "userId": 1
}
```

**Réponse:**
```json
{
  "clientSecret": "pi_xxx_secret_xxx",
  "paymentIntentId": "pi_xxx"
}
```

#### 2. Confirmer un paiement (Public)

**Endpoint:** `POST /api/payments/confirm`

**Body:**
```json
{
  "paymentIntentId": "pi_xxx",
  "reservationId": 1,
  "userId": 1,
  "amount": 50.00
}
```

**Réponse:**
```json
{
  "id": 1,
  "message": "Paiement confirmé et enregistré"
}
```

### Health Check

#### 1. Vérifier l'état de l'API (Public)

**Endpoint:** `GET /api/health`

**Réponse:**
```json
{
  "status": "ok",
  "message": "Auxivie API"
}
```

---

## 📊 Structures de données

### User (Utilisateur)

```dart
class User {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String categorie;
  final String? ville;
  final String? tarif;
  final String? experience;
  final String? photo;
  final String userType;  // "professionnel", "famille", "admin"
  final String? besoin;
  final String? preference;
  final String? mission;
  final String? particularite;

  User({
    required this.id,
    required this.name,
    required this.email,
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

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      categorie: json['categorie'],
      ville: json['ville'],
      tarif: json['tarif'],
      experience: json['experience'],
      photo: json['photo'],
      userType: json['userType'],
      besoin: json['besoin'],
      preference: json['preference'],
      mission: json['mission'],
      particularite: json['particularite'],
    );
  }
}
```

### Reservation (Réservation)

```dart
class Reservation {
  final int id;
  final int userId;
  final int professionnelId;
  final String date;
  final String? dateFin;
  final String heure;
  final String status;  // "pending", "confirmed", "completed", "cancelled"
  final String createdAt;
  final String? familleName;
  final String? professionalName;

  Reservation({
    required this.id,
    required this.userId,
    required this.professionnelId,
    required this.date,
    this.dateFin,
    required this.heure,
    required this.status,
    required this.createdAt,
    this.familleName,
    this.professionalName,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      userId: json['userId'],
      professionnelId: json['professionnelId'],
      date: json['date'],
      dateFin: json['dateFin'],
      heure: json['heure'],
      status: json['status'],
      createdAt: json['createdAt'],
      familleName: json['familleName'],
      professionalName: json['professionalName'],
    );
  }
}
```

### Message

```dart
class Message {
  final int id;
  final int senderId;
  final int receiverId;
  final String content;
  final String timestamp;
  final int isRead;  // 0 = non lu, 1 = lu

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    required this.isRead,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      content: json['content'],
      timestamp: json['timestamp'],
      isRead: json['isRead'],
    );
  }
}
```

### Review (Avis)

```dart
class Review {
  final int id;
  final int reservationId;
  final int userId;
  final int professionalId;
  final int rating;  // 1-5
  final String? comment;
  final String createdAt;
  final String? userName;
  final String? professionalName;

  Review({
    required this.id,
    required this.reservationId,
    required this.userId,
    required this.professionalId,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.userName,
    this.professionalName,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      reservationId: json['reservationId'],
      userId: json['userId'],
      professionalId: json['professionalId'],
      rating: json['rating'],
      comment: json['comment'],
      createdAt: json['createdAt'],
      userName: json['userName'],
      professionalName: json['professionalName'],
    );
  }
}
```

---

## 💻 Exemples de code Flutter

### Service API complet

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class ApiService {
  static const String baseUrl = 'https://auxivie.org/api';
  
  // Récupérer le token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
  
  // Headers pour requêtes authentifiées
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'x-request-type': 'mobile',
    };
  }
  
  // Headers pour requêtes publiques
  Map<String, String> _getPublicHeaders() {
    return {
      'Content-Type': 'application/json',
      'x-request-type': 'mobile',
    };
  }
  
  // ========== AUTHENTIFICATION ==========
  
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _getPublicHeaders(),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      await prefs.setString('user', jsonEncode(data['user']));
      return data;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Erreur de connexion');
    }
  }
  
  // ========== UTILISATEURS ==========
  
  Future<List<User>> getProfessionals() async {
    final response = await http.get(
      Uri.parse('$baseUrl/users?userType=professionnel'),
      headers: _getPublicHeaders(),
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors de la récupération des professionnels');
    }
  }
  
  Future<User> getUser(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$id'),
      headers: _getPublicHeaders(),
    );
    
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Utilisateur non trouvé');
    }
  }
  
  Future<Map<String, dynamic>> syncUser(Map<String, dynamic> userData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/sync'),
      headers: _getPublicHeaders(),
      body: jsonEncode(userData),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Erreur de synchronisation');
    }
  }
  
  // ========== RÉSERVATIONS ==========
  
  Future<List<Reservation>> getReservations({int? userId, int? professionnelId}) async {
    String url = '$baseUrl/reservations?';
    if (userId != null) {
      url += 'userId=$userId';
    } else if (professionnelId != null) {
      url += 'professionnelId=$professionnelId';
    }
    
    final response = await http.get(
      Uri.parse(url),
      headers: _getPublicHeaders(),
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Reservation.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors de la récupération des réservations');
    }
  }
  
  Future<Map<String, dynamic>> syncReservation(Map<String, dynamic> reservationData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reservations/sync'),
      headers: _getPublicHeaders(),
      body: jsonEncode(reservationData),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Erreur de synchronisation');
    }
  }
  
  // ========== MESSAGES ==========
  
  Future<List<Message>> getMessages(int userId, int partnerId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/messages?userId=$userId&partnerId=$partnerId'),
      headers: _getPublicHeaders(),
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Message.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors de la récupération des messages');
    }
  }
  
  Future<Map<String, dynamic>> sendMessage(int senderId, int receiverId, String content) async {
    final response = await http.post(
      Uri.parse('$baseUrl/messages'),
      headers: _getPublicHeaders(),
      body: jsonEncode({
        'senderId': senderId,
        'receiverId': receiverId,
        'content': content,
      }),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Erreur lors de l\'envoi du message');
    }
  }
  
  Future<List<int>> getMessagePartners(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/messages/partners?userId=$userId'),
      headers: _getPublicHeaders(),
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<int>();
    } else {
      throw Exception('Erreur lors de la récupération des partenaires');
    }
  }
  
  // ========== AVIS ==========
  
  Future<List<Review>> getReviews() async {
    final response = await http.get(
      Uri.parse('$baseUrl/reviews'),
      headers: _getPublicHeaders(),
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Review.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors de la récupération des avis');
    }
  }
  
  Future<Map<String, dynamic>> createReview({
    required int professionalId,
    required int userId,
    required int rating,
    String? comment,
    String? userName,
    int? reservationId,
  }) async {
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
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Erreur lors de la création de l\'avis');
    }
  }
  
  // ========== NOTES ==========
  
  Future<Map<String, dynamic>?> getRatings(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/ratings?userId=$userId'),
      headers: _getPublicHeaders(),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;  // Peut être null si aucune note
    } else {
      throw Exception('Erreur lors de la récupération des notes');
    }
  }
  
  // ========== BADGES ==========
  
  Future<List<Map<String, dynamic>>> getBadges(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/badges?userId=$userId'),
      headers: _getPublicHeaders(),
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Erreur lors de la récupération des badges');
    }
  }
  
  // ========== DISPONIBILITÉS ==========
  
  Future<List<Map<String, dynamic>>> getAvailabilities(int professionnelId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/availabilities?professionnelId=$professionnelId'),
      headers: _getPublicHeaders(),
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Erreur lors de la récupération des disponibilités');
    }
  }
  
  // ========== UPLOAD DE FICHIERS ==========
  
  Future<Map<String, dynamic>> uploadDocument(
    File file,
    int userId,
    String type,
  ) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/documents/upload'),
    );
    
    request.files.add(
      await http.MultipartFile.fromPath('file', file.path),
    );
    request.fields['userId'] = userId.toString();
    request.fields['type'] = type;
    request.headers['x-request-type'] = 'mobile';
    
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Erreur lors de l\'upload');
    }
  }
  
  Future<Map<String, dynamic>> uploadPhoto(File photo, int userId) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/users/$userId/photo'),
    );
    
    request.files.add(
      await http.MultipartFile.fromPath('photo', photo.path),
    );
    request.headers['x-request-type'] = 'mobile';
    
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Erreur lors de l\'upload de la photo');
    }
  }
  
  // ========== PAIEMENTS ==========
  
  Future<Map<String, dynamic>> createPaymentIntent({
    required double amount,
    required int reservationId,
    required int userId,
    String currency = 'eur',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/payments/create-intent'),
      headers: _getPublicHeaders(),
      body: jsonEncode({
        'amount': amount,
        'currency': currency,
        'reservationId': reservationId,
        'userId': userId,
      }),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Erreur lors de la création du paiement');
    }
  }
  
  Future<Map<String, dynamic>> confirmPayment({
    required String paymentIntentId,
    required int reservationId,
    required int userId,
    required double amount,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/payments/confirm'),
      headers: _getPublicHeaders(),
      body: jsonEncode({
        'paymentIntentId': paymentIntentId,
        'reservationId': reservationId,
        'userId': userId,
        'amount': amount,
      }),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Erreur lors de la confirmation du paiement');
    }
  }
}
```

---

## ⚠️ Gestion des erreurs

### Codes de statut HTTP

- **200** : Succès
- **400** : Requête invalide (champs manquants, format incorrect)
- **401** : Non authentifié (token manquant ou invalide)
- **403** : Accès refusé (pas les permissions)
- **404** : Ressource non trouvée
- **409** : Conflit (ex: email déjà utilisé)
- **500** : Erreur serveur

### Exemple de gestion d'erreurs

```dart
try {
  final professionals = await apiService.getProfessionals();
  // Traiter les données
} on http.ClientException catch (e) {
  // Erreur réseau
  print('Erreur réseau: $e');
  // Afficher un message à l'utilisateur
} on FormatException catch (e) {
  // Erreur de parsing JSON
  print('Erreur de format: $e');
} catch (e) {
  // Autre erreur
  print('Erreur: $e');
}
```

---

## 📤 Upload de fichiers

### Exemple complet d'upload de document

```dart
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

Future<void> uploadDocumentExample() async {
  // Sélectionner un fichier
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  
  if (pickedFile != null) {
    final file = File(pickedFile.path);
    
    try {
      final result = await apiService.uploadDocument(
        file,
        1,  // userId
        'identity',  // type
      );
      
      print('Document uploadé: ${result['url']}');
    } catch (e) {
      print('Erreur upload: $e');
    }
  }
}
```

### Limites de taille

- **Documents** : Maximum 10 MB (JPEG, PNG, PDF)
- **Photos de profil** : Maximum 5 MB (JPEG, PNG)

---

## 💳 Paiements Stripe

### Configuration Stripe dans Flutter

Ajoutez dans `pubspec.yaml` :

```yaml
dependencies:
  flutter_stripe: ^9.0.0
```

### Exemple d'intégration Stripe

```dart
import 'package:flutter_stripe/flutter_stripe.dart';

Future<void> processPayment({
  required double amount,
  required int reservationId,
  required int userId,
}) async {
  try {
    // 1. Créer le PaymentIntent
    final intentData = await apiService.createPaymentIntent(
      amount: amount,
      reservationId: reservationId,
      userId: userId,
    );
    
    // 2. Confirmer le paiement avec Stripe
    await Stripe.instance.confirmPayment(
      intentData['clientSecret'],
      paymentMethod: PaymentMethodParams.card(
        paymentMethodData: PaymentMethodData(),
      ),
    );
    
    // 3. Confirmer le paiement côté serveur
    await apiService.confirmPayment(
      paymentIntentId: intentData['paymentIntentId'],
      reservationId: reservationId,
      userId: userId,
      amount: amount,
    );
    
    print('Paiement réussi !');
  } catch (e) {
    print('Erreur paiement: $e');
  }
}
```

---

## 🔍 Notes importantes

1. **Header `x-request-type: mobile`** : Important pour que l'API accepte les requêtes depuis l'app mobile (notamment pour le login).

2. **Token JWT** : Le token expire après 24h. Implémentez un mécanisme de rafraîchissement si nécessaire.

3. **Synchronisation** : Les routes `/sync` permettent de créer ou mettre à jour des ressources. Elles sont idempotentes (peuvent être appelées plusieurs fois sans effet de bord).

4. **CORS** : L'API est configurée pour accepter les requêtes depuis les applications mobiles.

5. **Format des dates** : Utilisez le format ISO 8601 (`YYYY-MM-DD` pour les dates, `HH:mm` pour les heures).

6. **Images** : Les URLs des images sont accessibles directement via `https://auxivie.org/uploads/...`

---

## 📞 Support

Pour toute question ou problème d'intégration, contactez l'équipe technique.

**Email** : contact@auxivie.org

---

**Dernière mise à jour** : Janvier 2025
**Version API** : 1.0.0

