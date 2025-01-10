import 'package:flutter/material.dart';
import 'package:happy_tails/chat/chat.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserListPage extends StatelessWidget {
  const UserListPage({Key? key}) : super(key: key);

  Future<List<Map<String, dynamic>>> _fetchUsers() async {
    final response = await Supabase.instance.client
        .from('profiles') // Assuming "profiles" is the user table
        .select('id, userName');
    
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final users = snapshot.data!;
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  title: Text(user['userName']),
                  onTap: () {
                    Navigator.push(
                      context,
                      ChatPage.route(user['id']),
                    );
                  },
                );
              },
            );
          } else {
            return const Center(child: Text('No users found.'));
          }
        },
      ),
    );
  }
}