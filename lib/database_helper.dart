import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:developer' as developer;

class DatabaseHelper {
  // Δημιουργία ενός μοναδικού instance (Singleton)
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Έλεγχος αν η βάση υπάρχει ήδη, αλλιώς δημιουργία
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tribe_persist.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  // Δημιουργία των πινάκων (εδώ ορίζεις τη δομή των δεδομένων σου)
  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE activities (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      userName TEXT,
      sportCategory TEXT,
      title TEXT,
      date TEXT,
      time TEXT,
      location TEXT,
      description TEXT,
      maxPlayers INTEGER,
      currentPlayers INTEGER
    )
  ''');
    
    // Πίνακας για το Profile (για persistence του ονόματος/bio)
    await db.execute('''
    CREATE TABLE profile (
      id INTEGER PRIMARY KEY,
      name TEXT,
      location TEXT,
      bio TEXT
    )
  ''');
  }

  // Μέθοδοι για Activities
  Future<int> insertActivity(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('activities', row);
  }

  Future<List<Map<String, dynamic>>> getAllActivities() async {
    final db = await instance.database;
    return await db.query('activities', orderBy: 'id DESC');
  }
 // --- ΜΕΘΟΔΟΙ ΓΙΑ ΤΟ PROFILE ---

  // Παίρνει τα δεδομένα του προφίλ από τη βάση
  Future<Map<String, dynamic>?> getProfile() async {
    final db = await instance.database;
    // Ψάχνουμε τον χρήστη με id = 1 (αφού έχουμε μόνο έναν χρήστη στην εφαρμογή)
    final maps = await db.query('profile', where: 'id = ?', whereArgs: [1]);
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  // Αποθηκεύει ή ενημερώνει τα δεδομένα του προφίλ
  Future<void> saveProfile(Map<String, dynamic> profile) async {
    final db = await instance.database;
    try {
      await db.insert(
        'profile',
        profile,
        conflictAlgorithm: ConflictAlgorithm.replace, // Αν υπάρχει ήδη το id 1, κάνει αντικατάσταση
      );
    } catch (e, st) {
      developer.log('DB saveProfile error', name: 'DatabaseHelper', level: 1000, error: e, stackTrace: st);
      rethrow;
    }
  }

  // Πάρε μία δραστηριότητα από το id
  Future<Map<String, dynamic>?> getActivity(int id) async {
    final db = await instance.database;
    try {
      final maps = await db.query('activities', where: 'id = ?', whereArgs: [id]);
      if (maps.isNotEmpty) return maps.first;
      return null;
    } catch (e, st) {
      developer.log('DB getActivity error', name: 'DatabaseHelper', level: 1000, error: e, stackTrace: st);
      rethrow;
    }
  }

  // Ενημέρωση δραστηριότητας
  Future<int> updateActivity(int id, Map<String, dynamic> row) async {
    final db = await instance.database;
    try {
      return await db.update('activities', row, where: 'id = ?', whereArgs: [id]);
    } catch (e, st) {
      developer.log('DB updateActivity error', name: 'DatabaseHelper', level: 1000, error: e, stackTrace: st);
      rethrow;
    }
  }

  // Διαγραφή δραστηριότητας
  Future<int> deleteActivity(int id) async {
    final db = await instance.database;
    try {
      return await db.delete('activities', where: 'id = ?', whereArgs: [id]);
    } catch (e, st) {
      developer.log('DB deleteActivity error', name: 'DatabaseHelper', level: 1000, error: e, stackTrace: st);
      rethrow;
    }
  }

  // Κλείσιμο της βάσης δεδομένων
  Future<void> close() async {
    try {
      final db = _database;
      if (db != null) {
        await db.close();
        _database = null;
      }
    } catch (e, st) {
      developer.log('DB close error', name: 'DatabaseHelper', level: 1000, error: e, stackTrace: st);
      rethrow;
    }
  }

  // OnUpgrade hook για μελλοντικές μεταναστεύσεις σχήματος
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Εδώ προσθέστε migrations όταν αυξάνετε το version
    // Παράδειγμα:
    // if (oldVersion < 2) {
    //   await db.execute('ALTER TABLE activities ADD COLUMN price TEXT;');
    // }
  }

}