import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/user.dart';
import '../model/pet.dart';
import '../model/booking.dart';

class LocalDatabase {
  static final LocalDatabase instance = LocalDatabase._init();

  static Database? _database;

  LocalDatabase._init();

  Future<Database> get database async {
    if (_database != null){ 
      return _database!;
      }
    _database = await _initDB('app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onConfigure: (db) async {
      await db.execute('PRAGMA foreign_keys = ON');
    },onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY autoincrement,
        userName TEXT NOT NULL,
        imageUrl TEXT NOT NULL,
        citta TEXT NOT NULL
      );
    ''');
    await db.execute('''
      CREATE TABLE pets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        owner_id INTEGER NOT NULL,
        FOREIGN KEY (owner_id) REFERENCES users(id) ON DELETE CASCADE
      );
    ''');
    await db.execute('''
      CREATE TABLE bookings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_trans INTEGER NOT NULL,
        dateBegin DATE NOT NULL,
        dateEnd DATE NOT NULL,
        price REAL NOT NULL,
        state TEXT NOT NULL DEFAULT 'Richiesta',
        state_Payment TEXT NOT NULL DEFAULT 'In Attesa',
        metaPayment TEXT,
        vote INTEGER ,
        summary TEXT,
        pet_id INTEGER NOT NULL,
        FOREIGN KEY (pet_id) REFERENCES pets(id) ON DELETE CASCADE
      );
    ''');
  }

  Future<void> deleteDatabaseFile() async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'app.db');
  await deleteDatabase(path); // Elimina il database esistente
  print("Database eliminato con successo!");
}



  Future<List<Pet>> getPets() async {
    final db = await instance.database;
    final maps = await db.query('pets');

    return maps.map((map) => Pet.fromMap(map)).toList();
  }

  Future<List<Booking>> getBookings() async {
    final db = await instance.database;
    final maps = await db.query('bookings');
    return maps.map((map) => Booking.fromMap(map)).toList();
  }

  Future<User?> getUser() async {
    final db = await instance.database;
    final maps = await db.query('users', limit: 1);

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<void> initializeDummyData() async {
  final db = await instance.database;
  // Aggiungi un utente fittizio
  await db.insert('users', {
    'id': 1,
    'userName': 'John Doe',
    'citta': 'Springfield',
    'imageUrl':'https://marketplace.canva.com/EAF-i9Rhbp4/1/0/1600w/canva-sfondo-neutro-cerchio-immagine-di-profilo-linkedin-3nYoZ1kUL0s.jpg'
  });

  // Aggiungi animali fittizi
  await db.insert('pets', {'id': 1, 'name': 'Buddy', 'type': 'Dog', 'owner_id': 1});
  await db.insert('pets', {'id': 2, 'name': 'Mittens', 'type': 'Cat', 'owner_id':1});
  // Aggiungi prenotazioni fittizie
  await db.insert('bookings', {'id': 1, 'dateBegin': '2024-11-25', 'id_trans': 10, 'dateEnd':'2024-12-02', 'price':10.20, 'state':'Confermata','state_Payment': 'Pagata','pet_id':1});
  }
}
