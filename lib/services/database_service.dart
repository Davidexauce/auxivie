import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../models/reservation_model.dart';
import '../models/message_model.dart';
import '../models/document_model.dart';

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
      version: 1,
      onCreate: _createDB,
    );
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

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
