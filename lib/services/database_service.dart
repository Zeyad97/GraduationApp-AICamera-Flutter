import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../models/alert_model.dart';
import '../models/contact_model.dart';
import '../models/message_model.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('smart_ai_camera.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users(
        id TEXT PRIMARY KEY,
        fullName TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        phoneNumber TEXT NOT NULL,
        profileImage TEXT,
        createdAt TEXT NOT NULL
      )
    ''');

    // Alerts table
    await db.execute('''
      CREATE TABLE alerts(
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        alertType INTEGER NOT NULL,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        location TEXT,
        timestamp TEXT NOT NULL,
        status INTEGER NOT NULL,
        acknowledgedAt TEXT,
        resolvedAt TEXT,
        confidence REAL,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Contacts table
    await db.execute('''
      CREATE TABLE contacts(
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        name TEXT NOT NULL,
        phoneNumber TEXT NOT NULL,
        email TEXT,
        relationship INTEGER NOT NULL,
        isEmergencyContact INTEGER NOT NULL,
        profileImage TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Messages table
    await db.execute('''
      CREATE TABLE messages(
        id TEXT PRIMARY KEY,
        senderId TEXT NOT NULL,
        receiverId TEXT NOT NULL,
        message TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        isRead INTEGER NOT NULL,
        attachmentUrl TEXT
      )
    ''');
  }

  // User operations
  Future<void> insertUser(UserModel user) async {
    final db = await database;
    await db.insert('users', user.toMap());
  }

  Future<UserModel?> getUserById(String id) async {
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

  Future<void> updateUser(UserModel user) async {
    final db = await database;
    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // Alert operations
  Future<void> insertAlert(AlertModel alert) async {
    final db = await database;
    await db.insert('alerts', alert.toMap());
  }

  Future<List<AlertModel>> getAllAlerts() async {
    final db = await database;
    final maps = await db.query('alerts', orderBy: 'timestamp DESC');
    return maps.map((map) => AlertModel.fromMap(map)).toList();
  }

  Future<List<AlertModel>> getAlertsByUserId(String userId) async {
    final db = await database;
    final maps = await db.query(
      'alerts',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'timestamp DESC',
    );
    return maps.map((map) => AlertModel.fromMap(map)).toList();
  }

  Future<void> updateAlert(AlertModel alert) async {
    final db = await database;
    await db.update(
      'alerts',
      alert.toMap(),
      where: 'id = ?',
      whereArgs: [alert.id],
    );
  }

  Future<void> deleteAlert(String id) async {
    final db = await database;
    await db.delete(
      'alerts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Contact operations
  Future<void> insertContact(ContactModel contact) async {
    final db = await database;
    await db.insert('contacts', contact.toMap());
  }

  Future<List<ContactModel>> getContactsByUserId(String userId) async {
    final db = await database;
    final maps = await db.query(
      'contacts',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return maps.map((map) => ContactModel.fromMap(map)).toList();
  }

  Future<void> updateContact(ContactModel contact) async {
    final db = await database;
    await db.update(
      'contacts',
      contact.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

  Future<void> deleteContact(String id) async {
    final db = await database;
    await db.delete(
      'contacts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Message operations
  Future<void> insertMessage(MessageModel message) async {
    final db = await database;
    await db.insert('messages', message.toMap());
  }

  Future<List<MessageModel>> getMessagesBetweenUsers(
    String userId1,
    String userId2,
  ) async {
    final db = await database;
    final maps = await db.query(
      'messages',
      where: '(senderId = ? AND receiverId = ?) OR (senderId = ? AND receiverId = ?)',
      whereArgs: [userId1, userId2, userId2, userId1],
      orderBy: 'timestamp ASC',
    );
    return maps.map((map) => MessageModel.fromMap(map)).toList();
  }

  Future<void> updateMessage(MessageModel message) async {
    final db = await database;
    await db.update(
      'messages',
      message.toMap(),
      where: 'id = ?',
      whereArgs: [message.id],
    );
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
