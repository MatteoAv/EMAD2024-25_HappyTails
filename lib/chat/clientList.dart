import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:happy_tails/UserManage/model/booking.dart';
import 'package:happy_tails/chat/chat.dart';
import 'package:happy_tails/chat/chatWithClient.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClientListPage extends StatelessWidget {
  const ClientListPage({Key? key}) : super(key: key);

  Future<Map<String, List<Booking>>> _fetchChatPartners() async {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    
    if (currentUserId == null) return {};

    print("Fetching chat partners for: $currentUserId");

    final response = await Supabase.instance.client
      .rpc('get_my_bookings_with_owners')
       .select('booking_id, owner_username, pet_name, pet_type, booking_details');
      print(response);
      
    

  
    final List<dynamic> bookings = response as List<dynamic>;
    final Map<String, List<Booking>> uniqueClients = {};

    for (final booking in bookings) {
      final String clientName = booking['owner_username'];
      booking['booking_details']['owner_name']=booking['owner_username'];
      final bookingDetails = booking['booking_details'];
      
      

      if (clientName != null && bookingDetails != null) {
        final actualBooking = Booking.fromMapFull(bookingDetails);

        if (!uniqueClients.containsKey(clientName)) {
          uniqueClients[clientName] = [];
        }
        uniqueClients[clientName]!.add(actualBooking);
      }
    }
    print(uniqueClients);

    print("Fetched ${uniqueClients.length} unique clients.");
    return uniqueClients;
  }
  


  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats', style: TextStyle(fontSize: 20)),
        scrolledUnderElevation: 1,
      ),
      body: FutureBuilder<Map<String, List<Booking>>>(
        future: _fetchChatPartners(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final clients = (snapshot.data as Map<String, List<Booking>>);
          if ((clients).isEmpty) {
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
            itemCount: clients.length,
            separatorBuilder: (_, __) => const Divider(height: 24),
            itemBuilder: (context, index) {
              final clientName = clients.keys.elementAt(index);

              final booking = clients[clientName]!;
              final clientId = booking[0].owner_id;


              return Material(
                color: colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.push(
                    context,
                     ChatWithClientPage.route(clientId),
                    
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: colorScheme.primaryContainer,
                          child: Text(
                            clientName[0],
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
                                clientName,
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


/*
 *
 
SQL
  
  
-- Helper function to get petsitter ID
CREATE OR REPLACE FUNCTION get_current_petsitter_id()
RETURNS int
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN (SELECT id FROM petsitter WHERE uuid = auth.uid());
END;
$$;

-- Main data access function
CREATE OR REPLACE FUNCTION get_my_bookings_with_owners()
RETURNS TABLE (
  booking_id bigint,
  owner_username text,
  booking_details jsonb
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT
    b.id,
    p."userName"::text,
    to_jsonb(b) - 'owner_id' - 'petsitter_id'
  FROM bookings b
  JOIN profiles p ON b.owner_id = p.id
  WHERE b.petsitter_id = get_current_petsitter_id();
END;
$$;

GRANT EXECUTE ON FUNCTION get_my_bookings_with_owners() TO authenticated;

EXPLAIN ANALYZE SELECT * FROM get_my_bookings_with_owners();

CREATE INDEX CONCURRENTLY idx_petsitter_uuid ON petsitter(uuid);
CREATE INDEX CONCURRENTLY idx_bookings_petsitter ON bookings(petsitter_id);
CREATE INDEX CONCURRENTLY idx_profiles_id ON profiles(id);
 */