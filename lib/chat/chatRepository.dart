import 'package:happy_tails/UserManage/repositories/local_database.dart';
import 'package:happy_tails/chat/message_model.dart';


class ChatRepository {
  final LocalDatabase _localDatabase;

  ChatRepository({required LocalDatabase localDatabase}) : _localDatabase = localDatabase;

  Future<List<Message>> getConversation(String userId, String otherUserId) async {
    return _localDatabase.fetchMessagesForConversation(userId, otherUserId);
  }

  Future<void> sendMessage(Message message) async {
    await _localDatabase.addMessage(message);
    await _localDatabase.syncUnsyncedMessages(message.sender_id);
  }

  Future<void> syncMessages(String userId) async {
    await _localDatabase.syncUnsyncedMessages(userId);
  }
}