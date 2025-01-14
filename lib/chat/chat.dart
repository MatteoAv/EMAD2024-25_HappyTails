import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:happy_tails/UserManage/repositories/local_database.dart';
import 'package:happy_tails/chat/chatRepository.dart';
import 'package:happy_tails/chat/message_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart';
import 'package:sqflite/sqflite.dart'; // For SQLite
import 'package:riverpod/riverpod.dart'; // State management

import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'chat_provider.dart';
final SupabaseClient supabase = Supabase.instance.client;
class ChatPage extends ConsumerWidget {
  const ChatPage({Key? key, required this.otherUserId}) : super(key: key);
  final String otherUserId;

  static Route<void> route(String otherUserId) {
    return MaterialPageRoute(
      builder: (context) => ChatPage(otherUserId: otherUserId),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesState = ref.watch(chatProvider(otherUserId));
    final chatNotifier = ref.read(chatProvider(otherUserId).notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: messagesState.when(
        data: (messages) {
          return Column(
            children: [
              Expanded(
                child: messages.isEmpty
                    ? const Center(child: Text('Start your conversation now :)'))
                    : ListView.builder(
                        reverse: true,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          return _ChatBubble(
                            message: message,
                            isMine: message.sender_id == supabase.auth.currentUser!.id,
                          );
                        },
                      ),
              ),
              _MessageBar(onSend: (text) {
                final myUserId = supabase.auth.currentUser!.id;
                final message = Message(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  sender_id: myUserId,
                  receiver_id: otherUserId,
                  content: text,
                  timestamp: DateTime.now(),
                  status: 'unsynced',
                );
                chatNotifier.sendMessage(message);
              }),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _MessageBar extends StatefulWidget {
  const _MessageBar({Key? key, required this.onSend}) : super(key: key);
  final void Function(String) onSend;

  @override
  State<_MessageBar> createState() => _MessageBarState();
}

class _MessageBarState extends State<_MessageBar> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey[200],
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _textController,
                  decoration: const InputDecoration(
                    hintText: 'Type a message',
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.all(8),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  final text = _textController.text.trim();
                  if (text.isNotEmpty) {
                    widget.onSend(text);
                    _textController.clear();
                  }
                },
                child: const Text('Send'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({Key? key, required this.message, required this.isMine}) : super(key: key);

  final Message message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    List<Widget> chatContents = [
      if (!isMine) const CircleAvatar(child: Text('U')),
      const SizedBox(width: 12),
      Flexible(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: isMine ? Theme.of(context).primaryColorLight : Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(message.content),
        ),
      ),
      const SizedBox(width: 12),
      Text(format(message.timestamp, locale: 'en_short')),
    ];
    if (isMine) chatContents = chatContents.reversed.toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
      child: Row(
        mainAxisAlignment: isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: chatContents,
      ),
    );
  }
}