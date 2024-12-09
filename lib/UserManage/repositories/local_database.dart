//import 'package:happy_tails/UserManage/providers/profile_providers.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:happy_tails/UserManage/model/user.dart' as model;
import 'package:happy_tails/UserManage/model/pet.dart';
import 'package:happy_tails/UserManage/model/booking.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LocalDatabase {
  static final LocalDatabase instance = LocalDatabase._init();
  final supabase = Supabase.instance.client;
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
        id TEXT PRIMARY KEY,
        userName TEXT NOT NULL,
        imageUrl TEXT NOT NULL DEFAULT 'https://images.rawpixel.com/image_png_social_square/cHJpdmF0ZS9sci9pbWFnZXMvd2Vic2l0ZS8yMDIzLTAxL3JtNjA5LXNvbGlkaWNvbi13LTAwMi1wLnBuZw.png',
        email TEXT NOT NULL,
        citta TEXT NOT NULL
      );
    ''');
    await db.execute('''
      CREATE TABLE pets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        owner_id TEXT NOT NULL,
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
        owner_id TEXT NOT NULL,
        FOREIGN KEY (pet_id) REFERENCES pets(id) ON DELETE CASCADE,
        FOREIGN KEY (owner_id) REFERENCES users(id) ON DELETE CASCADE
      );
    ''');
  }

  Future<void> deleteDatabaseFile() async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'app.db');
  await deleteDatabase(path); // Elimina il database esistente
  print("Database eliminato con successo!");
}

// Aggiungi una funzione per aggiornare i dati dell'utente nel database
Future<bool> updateUser(String ?userId, String ?userName, String ?citta) async {
  final db = await database;
  int res = await db.update(
    'users',
    {'userName': userName, 'citta': citta},
    where: 'id = ?',
    whereArgs: [userId],
  );
  if(res==1) return true;
  
  return false;
}



  Future<List<Pet>> getPets(String userId) async {
    final db = await instance.database;
    var maps = await db.query('pets',
    where : 'owner_id = ?',
    whereArgs: [userId],
    );
    if(maps.isEmpty){
      /* chiedi al db principale*/
      maps = await supabase.from('pets')
      .select()
      .eq('owner_id', userId);
    }
    print(maps);
    return maps.map((map) => Pet.fromMap(map)).toList();
  }


  Future <Pet?> AddPets(String name, String type, String owner_id) async{
    final db = await database;
    int res = 0;
    res = await db.insert('pets', {'name': name, 'type': type, 'owner_id': owner_id} );
    if(res!=0){
      return Pet(id: res, name: name, type: type);
    }
    return null;
  }

  Future<List<Booking>> getBookings(String user_id) async {
    final db = await instance.database;
    var maps = await db.query('bookings',
    where: 'owner_id = ?',
    whereArgs: [user_id],
    );
    if(maps.isEmpty){
      //Chiedi al database principale
      maps = await supabase.from('bookings')
      .select()
      .eq('owner_id', user_id);
    }
    print(maps);
    return maps.map((map) => Booking.fromMap(map)).toList();
  }


  void insertUser(String userId,String userName, String email, String citta) async{
    final db = await instance.database;
    await db.insert('users',{ 
    'id' : userId, 
    'userName' : userName,
    'citta' : citta,
    'email' : email
    }
    );
  }


  Future<model.User?> getUser(String userId) async {
    final db = await instance.database;
    final maps = await db.query('users',
    where: 'id = ?',
    whereArgs: [userId]);
    if (maps.isNotEmpty) {
      return model.User.fromMap(maps.first);
    }
    print(maps);
    return null;
  }
}