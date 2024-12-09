import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_tails/UserManage/repositories/local_database.dart';
import 'package:happy_tails/UserManage/providers/profile_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:happy_tails/UserManage/model/user.dart' as model;

class SignUpPage extends ConsumerStatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final SupabaseClient supabase = Supabase.instance.client;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController cityController = TextEditingController();

  Future<void> signUp() async {
    final email = emailController.text;
    final password = passwordController.text;
    final username = usernameController.text;
    final city = cityController.text;

    if (email.isEmpty || password.isEmpty || username.isEmpty || city.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tutti i campi sono obbligatori')),
      );
      return;
    }

    try {
      // Registra l'utente con email e password
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );
      final user = response.user;

      if (user != null) {
        // Inserisce i dati aggiuntivi nella tabella profiles
        await supabase.from('profiles').insert({
          'id': user.id,
          'email': email,
          'userName': username,
          'city': city,
        });

        // Inserisci i dati nel database locale se non esistono
        if (await LocalDatabase.instance.getUser(user.id) == null) {
          LocalDatabase.instance.insertUser(
            user.id,
            username,
            email,
            city
          );
        }
         final newUser = model.User(
        id: user.id,  
        userName: username,
        email: email,
        citta: city,
        imageUrl: ""
      );
        // Aggiorna il provider con il nuovo utente
        ref.read(userProvider.notifier).state = AsyncData(newUser);

        // Mostra messaggio di successo
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrazione completata!')),
        );

        // Naviga alla home page
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Errore durante la registrazione')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrazione')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
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
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: cityController,
                  decoration: const InputDecoration(
                    labelText: 'Città di provenienza',
                    prefixIcon: Icon(Icons.location_city),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: signUp,
                  child: const Text('Registrati'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
