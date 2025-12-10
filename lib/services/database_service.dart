import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../models/reservation_model.dart';
import '../models/message_model.dart';
import '../models/document_model.dart';
import '../models/badge_model.dart';
import '../models/rating_model.dart';
import '../models/review_model.dart';

/// Service de gestion de la base de données SQLite locale
class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'auxivie.db');

    return await openDatabase(
      path,
      version: 3, // Version mise à jour pour inclure toutes les tables
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    print('🔄 Mise à jour de la base de données de v$oldVersion à v$newVersion');
    
    if (oldVersion < 2) {
      // Migration vers v2 : Ajouter les tables badges, ratings, reviews
      // Ajouter les tables pour badges, ratings et reviews si elles n'existent pas
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS user_badges (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId INTEGER NOT NULL,
            badgeType TEXT NOT NULL,
            badgeName TEXT NOT NULL,
            badgeIcon TEXT,
            description TEXT,
            createdAt TEXT,
            FOREIGN KEY (userId) REFERENCES users(id)
          )
        ''');
        print('✅ Table user_badges créée/vérifiée');
      } catch (e) {
        print('⚠️ Erreur création user_badges: $e');
      }

      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS user_ratings (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId INTEGER NOT NULL UNIQUE,
            averageRating REAL NOT NULL DEFAULT 0,
            totalRatings INTEGER NOT NULL DEFAULT 0,
            updatedAt TEXT,
            FOREIGN KEY (userId) REFERENCES users(id)
          )
        ''');
        print('✅ Table user_ratings créée/vérifiée');
      } catch (e) {
        print('⚠️ Erreur création user_ratings: $e');
      }

      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS reviews (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            reservationId INTEGER,
            userId INTEGER NOT NULL,
            professionalId INTEGER NOT NULL,
            rating INTEGER NOT NULL,
            comment TEXT,
            createdAt TEXT,
            userName TEXT,
            FOREIGN KEY (userId) REFERENCES users(id),
            FOREIGN KEY (professionalId) REFERENCES users(id)
          )
        ''');
        print('✅ Table reviews créée/vérifiée');
      } catch (e) {
        print('⚠️ Erreur création reviews: $e');
      }
    }
    
    if (oldVersion < 3) {
      // Migration vers v3 : Vérifier et ajouter les colonnes manquantes
      print('🔄 Migration vers v3 : Vérification des colonnes...');
      
      // Vérifier si la colonne userName existe dans reviews
      try {
        await db.execute('ALTER TABLE reviews ADD COLUMN userName TEXT');
        print('✅ Colonne userName ajoutée à reviews');
      } catch (e) {
        if (!e.toString().contains('duplicate column')) {
          print('⚠️ Erreur ajout colonne userName: $e');
        }
      }
      
      // Vérifier si la colonne reservationId existe dans reviews
      try {
        await db.execute('ALTER TABLE reviews ADD COLUMN reservationId INTEGER DEFAULT 0');
        print('✅ Colonne reservationId ajoutée à reviews');
      } catch (e) {
        if (!e.toString().contains('duplicate column')) {
          print('⚠️ Erreur ajout colonne reservationId: $e');
        }
      }
      
      print('✅ Migration v3 terminée');
    }
  }

  Future<void> _createDB(Database db, int version) async {
    // Table users
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        phone TEXT,
        categorie TEXT NOT NULL,
        ville TEXT,
        tarif REAL,
        experience INTEGER,
        photo TEXT,
        userType TEXT NOT NULL
      )
    ''');

    // Table reservations
    await db.execute('''
      CREATE TABLE reservations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        professionnelId INTEGER NOT NULL,
        date TEXT NOT NULL,
        heure TEXT NOT NULL,
        status TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users(id),
        FOREIGN KEY (professionnelId) REFERENCES users(id)
      )
    ''');

    // Table messages
    await db.execute('''
      CREATE TABLE messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        senderId INTEGER NOT NULL,
        receiverId INTEGER NOT NULL,
        content TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        isRead INTEGER DEFAULT 0,
        FOREIGN KEY (senderId) REFERENCES users(id),
        FOREIGN KEY (receiverId) REFERENCES users(id)
      )
    ''');

    // Table documents
    await db.execute('''
      CREATE TABLE documents (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        type TEXT NOT NULL,
        path TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users(id)
      )
    ''');

    // Table user_badges
    await db.execute('''
      CREATE TABLE user_badges (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        badgeType TEXT NOT NULL,
        badgeName TEXT NOT NULL,
        badgeIcon TEXT,
        description TEXT,
        createdAt TEXT,
        FOREIGN KEY (userId) REFERENCES users(id)
      )
    ''');

    // Table user_ratings
    await db.execute('''
      CREATE TABLE user_ratings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL UNIQUE,
        averageRating REAL NOT NULL DEFAULT 0,
        totalRatings INTEGER NOT NULL DEFAULT 0,
        updatedAt TEXT,
        FOREIGN KEY (userId) REFERENCES users(id)
      )
    ''');

    // Table reviews
    await db.execute('''
      CREATE TABLE reviews (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        reservationId INTEGER,
        userId INTEGER NOT NULL,
        professionalId INTEGER NOT NULL,
        rating INTEGER NOT NULL,
        comment TEXT,
        createdAt TEXT,
        userName TEXT,
        FOREIGN KEY (userId) REFERENCES users(id),
        FOREIGN KEY (professionalId) REFERENCES users(id)
      )
    ''');
  }

  /// Initialise la base de données (méthode publique)
  Future<void> initDatabase() async {
    await database;
  }

  // ========== USER METHODS ==========

  Future<int> createUser(UserModel user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<UserModel?> getUserById(int id) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  Future<List<UserModel>> getProfessionals() async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'userType = ?',
      whereArgs: ['professionnel'],
    );
    return maps.map((map) => UserModel.fromMap(map)).toList();
  }

  Future<List<UserModel>> searchProfessionals({
    String? ville,
    String? categorie,
  }) async {
    final db = await database;
    String where = 'userType = ?';
    List<dynamic> whereArgs = ['professionnel'];

    if (ville != null && ville.isNotEmpty) {
      where += ' AND ville = ?';
      whereArgs.add(ville);
    }

    if (categorie != null && categorie.isNotEmpty) {
      where += ' AND categorie = ?';
      whereArgs.add(categorie);
    }

    final maps = await db.query(
      'users',
      where: where,
      whereArgs: whereArgs,
    );
    return maps.map((map) => UserModel.fromMap(map)).toList();
  }

  Future<int> updateUser(UserModel user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // ========== RESERVATION METHODS ==========

  Future<int> createReservation(ReservationModel reservation) async {
    final db = await database;
    return await db.insert('reservations', reservation.toMap());
  }

  Future<List<ReservationModel>> getUserReservations(int userId) async {
    final db = await database;
    final maps = await db.query(
      'reservations',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC, heure DESC',
    );
    return maps.map((map) => ReservationModel.fromMap(map)).toList();
  }

  Future<List<ReservationModel>> getProfessionalReservations(int professionnelId) async {
    final db = await database;
    final maps = await db.query(
      'reservations',
      where: 'professionnelId = ?',
      whereArgs: [professionnelId],
      orderBy: 'date DESC, heure DESC',
    );
    return maps.map((map) => ReservationModel.fromMap(map)).toList();
  }

  Future<int> updateReservation(ReservationModel reservation) async {
    final db = await database;
    return await db.update(
      'reservations',
      reservation.toMap(),
      where: 'id = ?',
      whereArgs: [reservation.id],
    );
  }

  Future<int> deleteReservation(int reservationId) async {
    final db = await database;
    return await db.delete(
      'reservations',
      where: 'id = ?',
      whereArgs: [reservationId],
    );
  }

  // ========== MESSAGE METHODS ==========

  Future<int> createMessage(MessageModel message) async {
    final db = await database;
    return await db.insert('messages', message.toMap());
  }

  Future<List<MessageModel>> getConversation(int userId, int partnerId) async {
    final db = await database;
    final maps = await db.query(
      'messages',
      where: '(senderId = ? AND receiverId = ?) OR (senderId = ? AND receiverId = ?)',
      whereArgs: [userId, partnerId, partnerId, userId],
      orderBy: 'timestamp ASC',
    );
    return maps.map((map) => MessageModel.fromMap(map)).toList();
  }

  Future<List<int>> getConversationPartners(int userId) async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT DISTINCT 
        CASE 
          WHEN senderId = ? THEN receiverId 
          ELSE senderId 
        END AS partnerId
      FROM messages
      WHERE senderId = ? OR receiverId = ?
    ''', [userId, userId, userId]);
    return maps.map((map) => map['partnerId'] as int).toList();
  }

  // ========== DOCUMENT METHODS ==========

  Future<int> addDocument(DocumentModel document) async {
    final db = await database;
    return await db.insert('documents', document.toMap());
  }

  Future<int> createDocument(DocumentModel document) async {
    return await addDocument(document);
  }

  Future<List<DocumentModel>> getDocumentsByUserIdAndType(int userId, String type) async {
    final db = await database;
    final maps = await db.query(
      'documents',
      where: 'userId = ? AND type = ?',
      whereArgs: [userId, type],
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => DocumentModel.fromMap(map)).toList();
  }

  // ========== BADGE METHODS ==========

  Future<List<BadgeModel>> getBadgesByUserId(int userId) async {
    final db = await database;
    final maps = await db.query(
      'user_badges',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => BadgeModel.fromMap(map)).toList();
  }

  Future<void> syncBadges(int userId, Map<String, dynamic> badgeData) async {
    try {
      final db = await database;
      await db.insert(
        'user_badges',
        {
          'userId': userId,
          'badgeType': badgeData['badgeType'] ?? '',
          'badgeName': badgeData['badgeName'] ?? '',
          'badgeIcon': badgeData['badgeIcon'],
          'description': badgeData['description'],
          'createdAt': badgeData['createdAt'] ?? DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('✅ Badge synchronisé: ${badgeData['badgeName']}');
    } catch (e) {
      print('❌ Erreur syncBadges: $e');
      rethrow;
    }
  }

  // ========== RATING METHODS ==========

  Future<RatingModel?> getRatingByUserId(int userId) async {
    final db = await database;
    final maps = await db.query(
      'user_ratings',
      where: 'userId = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return RatingModel.fromMap(maps.first);
  }

  Future<void> upsertRating(int userId, double averageRating, int totalRatings) async {
    final db = await database;
    await db.insert(
      'user_ratings',
      {
        'userId': userId,
        'averageRating': averageRating,
        'totalRatings': totalRatings,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ========== REVIEW METHODS ==========

  Future<List<ReviewModel>> getReviewsByProfessionalId(int professionalId) async {
    final db = await database;
    final maps = await db.query(
      'reviews',
      where: 'professionalId = ?',
      whereArgs: [professionalId],
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => ReviewModel.fromMap(map)).toList();
  }

  Future<void> syncReviews(Map<String, dynamic> reviewData) async {
    try {
      final db = await database;
      // Convertir professionalId en int si nécessaire
      final professionalId = reviewData['professionalId'] is int 
          ? reviewData['professionalId'] 
          : int.tryParse(reviewData['professionalId'].toString()) ?? 0;
      
      await db.insert(
        'reviews',
        {
          'id': reviewData['id'],
          'reservationId': reviewData['reservationId'] ?? 0,
          'userId': reviewData['userId'] ?? 0,
          'professionalId': professionalId,
          'rating': reviewData['rating'],
          'comment': reviewData['comment'],
          'createdAt': reviewData['createdAt'] ?? DateTime.now().toIso8601String(),
          'userName': reviewData['userName'],
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('✅ Review synchronisé: ${reviewData['userName'] ?? "Anonyme"} - ${reviewData['rating']} étoiles (profId: $professionalId)');
    } catch (e) {
      print('❌ Erreur syncReviews: $e');
      print('   Données: $reviewData');
      rethrow;
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
