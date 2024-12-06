import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:happy_tails/UserManage/repositories/local_database.dart';

class LoginPage extends StatelessWidget {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool logged = false;
  Future<void> signIn(BuildContext context) async {
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
          print('Login effettuato con successo: ${response.user!.email}');
          logged = true;
          // Recupera i dettagli del profilo
          final profile = await supabase
              .from('profiles')
              .select()
              .eq('id', user.id)
              .single();
          if(await LocalDatabase.instance.getUser()==null){
          // Inserisci i dati nel database locale
          LocalDatabase.instance.insertUser(
            profile['userName'],
            profile['email'],
            profile['city'],
            "niente",
          );
          }
          // Naviga alla home o dashboard
          Navigator.pushReplacementNamed(context, '/');
        }
      } else {
        throw Exception('Credenziali non valide');
      }
    } catch (e) {
      print('Errore: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore durante il login: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
              onPressed: () => signIn(context),
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
