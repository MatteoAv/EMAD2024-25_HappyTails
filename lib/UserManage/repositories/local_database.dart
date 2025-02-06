
import 'package:happy_tails/chat/message_model.dart';
import 'package:logger/logger.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
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
      CREATE TABLE pets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        owner_id TEXT NOT NULL
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
        datereview DATE,
        FOREIGN KEY (pet_id) REFERENCES pets(id) 
        ON UPDATE CASCADE 
        ON DELETE CASCADE
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
  try{
  for (final row in data) {
    batch.insert(
      tableName,
      row,
      conflictAlgorithm: ConflictAlgorithm.replace, // Sostituisci se esiste già
    );
  }

  await batch.commit(noResult: true); // Commit in batch senza risultati
  }catch(e){
    logger.d(e);
  }
}

Future<void> syncData(String tableName,String columnName, String columnValue, Database localDb) async {
  try {
    // Recupera i dati dal database principale
    final remoteData = await fetchRemoteData(tableName,columnName,columnValue);

    if (remoteData.isNotEmpty) {
      logger.d("Inzio sincronizzazione Database");
      // Inserisci i dati nel database locale
      await insertDataIntoLocalDatabase(localDb, tableName, remoteData);
      logger.d("Sincronizzazione completata con successo $tableName");
    } else {
      logger.d("Sincronizzazione dei dati fallita");
    }
  } catch (e) {
    logger.d("Errore nella sincronizzazione dei dati $e");
  }
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


  Future <bool> UpdatePet(int id, String name, String type, String owner_id) async{
    final db = await database;
    int res = 0;
    res = await db.update('pets', {'name': name, 'type' : type}, where: 'owner_id = ? AND id = ?', whereArgs: [owner_id,id]);
    if(res != 0){
      await supabase.from('pets').update({'name' : name, 'type' : type}).eq('id', id);
      return true;
    }
    return false;
  }

  Future <bool> DeletePet(int id)async{
    final db = await database;
    int res = 0;
    res = await db.delete('pets', where: 'id = ?', whereArgs: [id]);
    if(res != 0){
      await supabase.from('pets').delete().eq('id', id);
      return true;
    }
    return false;
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


  Future<void> addMessage(Message message) async {
    final db = await database;
    print("addMessage");
    print(message.id);
    print("1111111111111");

    print(message.toMap());
    print("sdjkgjajrghjrs");
        print("1111111111");

    await db.insert('messages', message.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }
 Future<List<Message>> getUnsyncedMessages() async {
    final db = await database;
    final maps = await db.query(
      'messages',
      where: 'status = ?',
      whereArgs: ['unsynced'],
    );
    return maps.map((map) => Message.fromMap(map)).toList();
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
  final unsyncedMessages = await getUnsyncedMessages();
  print("SyncUnsincedMessages");

  print(unsyncedMessages.toString());


  for (final message in unsyncedMessages) {
    try {
      // Insert into Supabase
      final response = await supabase
          .from('messages')
          .insert({
            'sender_id': message.sender_id,
            'receiver_id': message.receiver_id,
            'content': message.content,

          })
          .select('id')
          .single();

      // Update local database with Supabase-generated ID
      final supabaseId = response['id'];
      print("here is the id");
      print(supabaseId);
      await updateMessageKey(message.id, supabaseId);
      await updateMessageStatus(supabaseId.toString(), "synced");
    } catch (error) {
      // Handle sync error (e.g., retry later)
      print('Error syncing message: $error');
    }
  }
}
  Future<List<Message>> fetchMessagesForConversation(String userId, String otherUserId) async {
  final db = await database;

  // Step 1: Fetch local messages
  final localMessages = await db.query(
    'messages',
    where: '(sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?)',
    whereArgs: [userId, otherUserId, otherUserId, userId],
    orderBy: 'timestamp DESC',
  );

  // Step 2: Fetch remote unsynced messages for the receiver
  final remoteMessages = await supabase
      .from('messages')
      .select('*')
      .eq('receiver_id', userId) // Fetch only messages meant for the receiver
      .eq('sender_id', otherUserId) // From the other user
      .eq('status', 'unsynced') // Only unsynced messages
      .order('timestamp', ascending: false);

  if (remoteMessages.isNotEmpty) {
    final messageList = List<Map<String, dynamic>>.from(remoteMessages);

    // Step 3: Store remote messages locally
    await syncMessages(messageList);
    final messageIds = messageList.map((message) => message['id']).toList();

     await supabase
    .from('messages')
    .delete()
    .filter('id', 'in', messageIds);
  }

  // Step 5: Combine and return local messages
  final messages= localMessages.map((map) => Message.fromMap(map)).toList();
  messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  return messages;
}

  Future<void> syncMessages(List<Map<String, dynamic>> messages) async {
  final db = await database;


  // Use batch operation for efficient insertion
  final batch = db.batch();
  for (final message in messages) {
    batch.insert(
      'messages',
      {
        ...message,
        'status': 'synced', // Mark as synced when inserting locally
      },
      conflictAlgorithm: ConflictAlgorithm.replace, // Avoid duplicates
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
    return localMessages.map((map) => Message.fromMap(map)).toList();
  }
  
}


