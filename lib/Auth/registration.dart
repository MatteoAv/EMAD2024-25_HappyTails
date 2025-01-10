import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_tails/UserManage/repositories/local_database.dart';
import 'package:happy_tails/UserManage/providers/profile_providers.dart';
import 'package:happy_tails/app/routes.dart';
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

  bool isPetSitter = false;

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
          'isPetSitter': isPetSitter,
        });

        // Inserisci i dati nel database locale se non esistono
        if (await LocalDatabase.instance.getUser(user.id) == null) {
          LocalDatabase.instance.insertUser(
            user.id,
            username,
            email,
            city,
            isPetSitter,
          );
        }

        final newUser = model.User(
          id: user.id,
          userName: username,
          email: email,
          citta: city,
          imageUrl: "",
          isPetSitter: isPetSitter,
        );
        // Aggiorna il provider con il nuovo utente
        ref.read(userProvider.notifier).state = AsyncData(newUser);

        if(isPetSitter){
          _showPetSitterAlert(context);
        }
        else{
        // Mostra messaggio di successo
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrazione completata!')),
        );
        // Naviga alla home page
        Navigator.pop(context);
        }
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

  void _showPetSitterAlert(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Completa la registrazione'),
      content: const Text(
          'Hai scelto di registrarti come PetSitter. Completa la tua registrazione andando nelle impostazioni.'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Chiudi'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context); // Chiude il dialog
            Navigator.pushNamed(context, AppRoutes.settings); // Naviga alla pagina delle impostazioni
          },
          child: const Text('Vai alle Impostazioni'),
        ),
      ],
    ),
  );
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Immagine in alto
                Image.asset(
                  'assets/IconPets/dogRegistration.png', // Inserisci il percorso della tua immagine
                  height: 150,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 16),
                // Titolo
                const Text(
                  'Crea il tuo account',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
                const SizedBox(height: 16),
                // Campi di input
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
                // Switch per PetSitter
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Vuoi registrarti come PetSitter?',
                      style: TextStyle(fontSize: 16),
                    ),
                    Switch(
                      value: isPetSitter,
                      onChanged: (value) {
                        setState(() {
                          isPetSitter = value;
                        });
                      },
                      activeColor: Colors.deepOrange,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Bottone di registrazione
                ElevatedButton(
                  onPressed: signUp,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.deepOrange,
                  ),
                  child: const Text(
                    'Registrati',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
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