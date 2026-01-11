import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
      onCreate: _createDB
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
    await db.insert(
      'profile',
      profile,
      conflictAlgorithm: ConflictAlgorithm.replace, // Αν υπάρχει ήδη το id 1, κάνει αντικατάσταση
    );
  }

}