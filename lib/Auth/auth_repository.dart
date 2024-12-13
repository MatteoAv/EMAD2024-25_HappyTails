import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_tails/UserManage/providers/profile_providers.dart';
import 'package:happy_tails/UserManage/repositories/local_database.dart';
import 'package:happy_tails/app/routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';
import 'package:happy_tails/UserManage/model/user.dart' as model;

class LoginPage extends ConsumerWidget {
  final logger = Logger();
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();


  Future<void> signIn(BuildContext context, WidgetRef ref) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();


    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inserisci sia email che password')),
      );
      return;
    }

    try {
      // Effettua il login con email e password
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final user = response.user;
        if (user != null) {
          final profile = await supabase
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();
          logger.d('Login effettuato con successo: ${profile['email']}');

          //Salva i dati nel db locale se non presenti
          if(await LocalDatabase.instance.getUser(user.id) == null){
            LocalDatabase.instance.insertUser(user.id, profile['userName'], email, profile['city']);
          }
          
          ref.read(userProvider.notifier).state = AsyncData(model.User(id: user.id, userName: profile['userName'], email: email, 
          citta: profile['city'], imageUrl: profile['imageUrl']));
          Navigator.pushNamed(context, AppRoutes.homePage);
        }
      } else {
        throw Exception('Credenziali non valide');
      }
    } catch (e,stackTrace) {
      logger.d('Errore: $e, $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore durante il login: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => signIn(context, ref),
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
