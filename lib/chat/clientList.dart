import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:happy_tails/chat/chat.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClientListPage extends StatelessWidget {
  const ClientListPage({Key? key}) : super(key: key);

  Future<List<Map<String, dynamic>>> _fetchChatPartners() async {
  final currentUserId = Supabase.instance.client.auth.currentUser?.id;
  print("JKfjadjf");

  if (currentUserId == null) return [];
  print(currentUserId);
  print("JKfjadjf");


  final response = await Supabase.instance.client
  .from('bookings')
  .select('owner_id!inner(id,userName)');
  final uniquePartners = <Map<String, dynamic>>[];
  final seenUuids = <String>{};
  print(response);

  for (final booking in response) {
    final user = booking['owner_id'] as Map<String, dynamic>?; // Get user data

    if (user != null) {
      final uuid = user['id'] as String?;

      if (uuid != null) {
        if (!seenUuids.contains(uuid)) {
          uniquePartners.add(user);
          seenUuids.add(uuid);
        }
      }
    }
  }

  return uniquePartners;
}
  


  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats', style: TextStyle(fontSize: 20)),
        scrolledUnderElevation: 1,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchChatPartners(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final partners = snapshot.data ?? [];
          if (partners.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.forum_outlined, size: 64, color: colorScheme.outline),
                  const SizedBox(height: 16),
                  Text(
                    'No conversations yet',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.outline,
                        ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: partners.length,
            separatorBuilder: (_, __) => const Divider(height: 24),
            itemBuilder: (context, index) {
              final partner = partners[index];
              final displayName = '${partner['userName']}';

              return Material(
                color: colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.push(
                    context,
                     ChatPage.route(partner['id']),
                    
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: colorScheme.primaryContainer,
                          child: Text(
                            partner['userName'][0],
                            style: TextStyle(
                              fontSize: 18,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Online',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: colorScheme.outline,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: colorScheme.outline,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}