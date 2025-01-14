import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_tails/UserManage/repositories/local_database.dart';
import 'package:happy_tails/chat/chatRepository.dart';
import 'package:happy_tails/chat/message_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final SupabaseClient supabase = Supabase.instance.client;
final chatProvider = StateNotifierProvider.family<ChatNotifier, AsyncValue<List<Message>>, String>((ref, otherUserId) {
  return ChatNotifier(chatRepository: ref.read(chatRepositoryProvider), otherUserId: otherUserId);
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(localDatabase: LocalDatabase.instance);
});

class ChatNotifier extends StateNotifier<AsyncValue<List<Message>>> {
  final ChatRepository chatRepository;
  final String otherUserId;

  ChatNotifier({required this.chatRepository, required this.otherUserId}) : super(const AsyncLoading()) {
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    try {
      final myUserId = supabase.auth.currentUser!.id;
      // Fetch messages (both local and remote)
      final messages = await chatRepository.getConversation(myUserId, otherUserId);
      state = AsyncValue.data(messages);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> sendMessage(Message message) async {
    try {
      await chatRepository.sendMessage(message);
      // Update state after sending
      _loadMessages();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}