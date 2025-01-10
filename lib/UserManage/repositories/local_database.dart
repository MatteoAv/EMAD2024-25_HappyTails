

import 'package:happy_tails/chat/message_model.dart';
import 'package:logger/logger.dart';
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
  final logger = Logger();

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
        citta TEXT NOT NULL,
        isPetSitter BOOL NOT NULL
      );
    ''');
    await db.execute('''
      CREATE TABLE pets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        owner_id TEXT NOT NULL,
        FOREIGN KEY (owner_id) REFERENCES users(id) ON UPDATE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE petsitter (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome VARCHAR (30) NOT NULL,
        cognome VARCHAR (30) NOT NULL,
        email VARCHAR(50) NOT NULL,
        provincia VARCHAR(40) NOT NULL,
        imageUrl TEXT,
        cani BOOLEAN NOT NULL,
        gatti BOOLEAN NOT NULL,
        uccelli BOOLEAN NOT NULL,
        pesci BOOLEAN NOT NULL,
        rettili BOOLEAN NOT NULL,
        roditori BOOLEAN NOT NULL,
        Comune VARCHAT (50) NOT NULL,
        Posizione TEXT NOT NULL
      );
    '''
      );

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
        review TEXT,
        pet_id INTEGER NOT NULL,
        owner_id TEXT NOT NULL,
        petsitter_id INTEGER NOT NULL,
        FOREIGN KEY (pet_id) REFERENCES pets(id) ON UPDATE CASCADE,
        FOREIGN KEY (owner_id) REFERENCES users(id) ON UPDATE CASCADE,
        FOREIGN KEY (petSitter_id) REFERENCES petsitter(id) ON UPDATE CASCADE
      );
    ''');
    await db.execute('''
    CREATE TABLE messages (
      id TEXT PRIMARY KEY,
      sender_id TEXT NOT NULL,
      receiver_id TEXT NOT NULL,
      content TEXT NOT NULL,
      timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      status TEXT DEFAULT 'unsynced' 
    );
  ''');

    db.insert('petsitter', {'id':1, 'nome': 'Giulia', 'cognome' : 'Rossi', 'email' : 'giuliarossi@example.com', 'provincia' : 'Avellino', 'cani' : 1, 'gatti' : 1, 'uccelli' : 0,
    'pesci' : 1, 'rettili': 0, 'roditori' : 1, 'Comune': 'Avellino', 'Posizione' : '0101000020E6100000F9ACDF0A30972D40C50DCF7DFF744440'});
  }

  Future<void> deleteDatabaseFile() async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'app.db');
  await deleteDatabase(path); // Elimina il database esistente
  print("Database eliminato con successo!");
}


Future<List<Map<String, dynamic>>> fetchRemoteData(String tableName, String nameColumn, String valueColumn) async {
  final response = await Supabase.instance.client
      .from(tableName)
      .select('*').eq(nameColumn, valueColumn);

  if (response.isEmpty) {
    throw Exception('Errore durante il recupero dei dati');
  }

  return List<Map<String, dynamic>>.from(response as List);
}


Future<void> insertDataIntoLocalDatabase(Database db, String tableName, List<Map<String, dynamic>> data) async {
  final batch = db.batch();

  for (final row in data) {
    batch.insert(
      tableName,
      row,
      conflictAlgorithm: ConflictAlgorithm.replace, // Sostituisci se esiste già
    );
  }

  await batch.commit(noResult: true); // Commit in batch senza risultati
}

Future<void> syncData(String tableName,String columnName, String columnValue, Database localDb) async {
  try {
    // Recupera i dati dal database principale
    final remoteData = await fetchRemoteData(tableName,columnName,columnValue);

    if (remoteData.isNotEmpty) {
      logger.d("Inzio sincronizzazione Database");
      // Inserisci i dati nel database locale
      await insertDataIntoLocalDatabase(localDb, tableName, remoteData);
      logger.d("Sincronizzazione completata con successo");
    } else {
      logger.d("Sincronizzazione dei dati fallita");
    }
  } catch (e) {
    logger.d("Errore nella sincronizzazione dei dati $e");
  }
}


// Aggiungi una funzione per aggiornare i dati dell'utente nel database
Future<bool> updateUser(String userId, String userName, String citta) async {
  final db = await database;
  int res = await db.update(
    'users',
    {'userName': userName, 'citta': citta},
    where: 'id = ?',
    whereArgs: [userId],
  );
  await supabase.from('profiles').update({'userName': userName.trim(), 'city' : citta.trim(),})
  .eq('id', userId);

  if(res==1) return true;
  
  return false;
}



  Future<List<Pet>> getPets(String userId) async {
    final db = await instance.database;
    List<Map<String, dynamic>>maps; 
    maps = await db.query('pets',
    where : 'owner_id = ?',
    whereArgs: [userId],
    );
    if(maps.isEmpty){
      /* chiedi al db principale*/
      maps = await supabase.rpc("get_pets_by_user", params: {'_user_id':userId});
      syncData('pets', 'owner_id', userId, db);
    }
  
    return maps.map((map) => Pet.fromMap(map)).toList();
  }


  Future <Pet?> AddPets(String name, String type, String owner_id) async{
    final db = await database;
    int res = 0;
    bool resSupa;
    final isPresent = await db.query('pets',
    where: 'name = ? AND type = ?',
    whereArgs: [name,type]);;

    if(isPresent.isEmpty){
    resSupa = await supabase.rpc('add_pet', params:{'_name': name, '_type': type, '_user_id': owner_id}); 
    res = await db.insert('pets', {'name': name, 'type': type, 'owner_id': owner_id} );
    
    if(res!=0 && resSupa){
      return Pet(id: res, name: name, type: type);
    }
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
      syncData("bookings", "owner_id", user_id, db);
    }
    return maps.map((map) => Booking.fromMap(map)).toList();
  }


  void insertUser(String userId,String userName, String email, String citta, bool isPetSitter) async{
    final db = await instance.database;
    await db.insert('users',{ 
    'id' : userId, 
    'userName' : userName,
    'citta' : citta,
    'email' : email,
    'isPetSitter' : isPetSitter 
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
    return null;
  }

  Future<void> addMessage(Message message) async {
    final db = await database;
    await db.insert('messages', message.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }
 Future<List<Message>> getUnsyncedMessages(String userId) async {
    final db = await database;
    final maps = await db.query(
      'messages',
      where: 'sender_id = ? AND status = ?',
      whereArgs: [userId, 'unsynced'],
    );
    return maps.map((map) => Message.fromMap(map, userId)).toList();
  }
   Future<void> updateMessageStatus(String messageId, String status) async {
    final db = await database;
    await db.update(
      'messages',
      {'status': status},
      where: 'id = ?',
      whereArgs: [messageId],
    );
  }
  Future<void> updateMessageKey(String messageId, int id) async {
    final db = await database;
    await db.update(
      'messages',
      {'id': id},
      where: 'id = ?',
      whereArgs: [messageId],
    );
  }
   Future<void> syncUnsyncedMessages(String userId) async {
  final unsyncedMessages = await getUnsyncedMessages(userId);

  for (final message in unsyncedMessages) {
    try {
      // Insert into Supabase
      final response = await supabase
          .from('messages')
          .insert({
            'sender_id': message.sender_id,
            'receiver_id': message.receiver_id,
            'content': message.content,
            'created_at': message.timestamp.toIso8601String(),
          })
          .select('id')
          .single();

      // Update local database with Supabase-generated ID
      final supabaseId = response['id'];
      await updateMessageKey(message.id, supabaseId);
      await updateMessageStatus(message.id, "synced");
    } catch (error) {
      // Handle sync error (e.g., retry later)
      print('Error syncing message: $error');
    }
  }
}
  Future<List<Message>> fetchMessagesForConversation(String userId, String otherUserId) async {
    final db = await database;
    final localMessages = await db.query(
      'messages',
      where: '(sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?)',
      whereArgs: [userId, otherUserId, otherUserId, userId],
      orderBy: 'timestamp DESC',
    );

    try {
      if (await _isOnline()) {
        final remoteMessages = await supabase
            .from('messages')
            .select('*')
            .or('sender_id.eq.$userId.and.receiver_id.eq.$otherUserId,sender_id.eq.$otherUserId.and.receiver_id.eq.$userId')
            .order('timestamp', ascending: false);

        if (remoteMessages.isNotEmpty) {
           await syncMessages(List<Map<String, dynamic>>.from(remoteMessages));
        }
      }
    } catch (e) {
      // Handle network or Supabase errors gracefully. Log the error
      print('Error fetching remote messages: $e');
      // Optionally, you could show a snackbar to the user or take other actions.
    }
    return localMessages.map((map) => Message.fromMap(map, userId)).toList();
  }

  Future<void> syncMessages(List<Map<String, dynamic>> messages) async {
    final db = await database;
    final batch = db.batch();
    for (final message in messages) {
      batch.insert(
        'messages',
        message,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<bool> _isOnline() async {
    try {
      final response = await supabase.rpc('ping');
      return response == 'ok';
    } catch (_) {
      return false;
    }
  }

  Future<List<Message>> getMessagesFromLocalDb(String userId, String otherUserId) async {
    final db = await database;
    final localMessages = await db.query(
      'messages',
      where: '(sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?)',
      whereArgs: [userId, otherUserId, otherUserId, userId],
      orderBy: 'timestamp DESC',
    );
    return localMessages.map((map) => Message.fromMap(map, userId)).toList();
  }
  
}


