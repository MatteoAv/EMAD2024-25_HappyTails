import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_tails/UserManage/providers/profile_providers.dart';
import 'package:happy_tails/app/bottom_navbar.dart';
import 'package:happy_tails/app/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';

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

      final pref = await SharedPreferences.getInstance();
      final UserMap = {
        'id' : profile['id'],
        'email': email,
        'userName' : profile['userName'],
        'citta' : profile['city'],
        'isPetSitter' : profile['isPetSitter'],
        'imageUrl' : '',
        'customerId' : profile['customerId']
        };
        await pref.setString("user", jsonEncode(UserMap));
        ref.read(userProvider.notifier).updateUser(user.id, profile['userName'], profile['city'], '', email, profile['isPetSitter'], profile['customerId']);
        ref.read(pageProvider.notifier).updatePages();
      }

    } else {
      throw Exception('Credenziali non valide');
    }
  } catch (e) {
    logger.d('Errore: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore durante il login: credenziali fornite non valide'), backgroundColor: Colors.red,),
      );
    }
  }
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Immagine di benvenuto
                Image.asset(
                  'assets/IconPets/catLogin.png', // Inserisci il percorso della tua immagine
                  height: 150,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 16),
                // Titolo
                const Text(
                  'Accedi al tuo account',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
                const SizedBox(height: 16),
                // Campo email
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                // Campo password
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                // Bottone login
                ElevatedButton(
                  onPressed: () => signIn(context, ref),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.deepOrange,
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                // Testo di registrazione
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.registrationPage);
                  },
                  child: const Text(
                    'Non hai un account? Registrati',
                    style: TextStyle(
                      color: Colors.deepOrange,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}