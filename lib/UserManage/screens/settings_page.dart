import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_tails/UserManage/repositories/local_database.dart';
import 'package:happy_tails/app/routes.dart';
import '../providers/profile_providers.dart'; // Aggiungi il provider per la gestione del profilo

class SettingsPage extends ConsumerWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: userAsync.when(
          data: (user) {
            return Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Modifica Username
                  TextFormField(
                    initialValue: user?.userName,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.account_circle),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Modifica Città
                  TextFormField(
                    initialValue: user?.citta,
                    decoration: const InputDecoration(
                      labelText: 'City',
                      prefixIcon: Icon(Icons.location_city),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: (){
                      LocalDatabase.instance.updateUser(user?.id, user?.userName, user?.citta);
                    }, 
                    child: Text("Conferma modifiche")
                    ),
                  const SizedBox(height: 16),

                  // Metodo di pagamento
                  ListTile(
                    leading: const Icon(Icons.payment),
                    title: const Text('Payment Methods'),
                    onTap: () {
                      // Logica per gestire i metodi di pagamento
                      // Naviga a una pagina di gestione metodi di pagamento
                    },
                  ),
                  const SizedBox(height: 16),

                  // Interruttore per ricevere notifiche
                  Row(
                    children: [
                      const Icon(Icons.notifications),
                      const SizedBox(width: 8),
                      const Text('Receive Notifications'),
                      //Switch(
                        //value: user?.receiveNotifications ?? false,
                        //onChanged: (value) {
                          // Gestisci l'aggiornamento della preferenza
                          //ref.read(userProvider.notifier).updateNotificationPreference(value);
                        //},
                      //),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Pulsante per effettuare il logout
                  ElevatedButton(
                     onPressed: () {
                      // Gestisci il logout dell'utente
                      //ref.read(userProvider.notifier).logout();
                      //Navigator.pop(context); // Torna indietro dopo il logout
                    },
                    style: ElevatedButton.styleFrom(
                      iconColor: Colors.deepOrange, // Colore del bottone
                      minimumSize: const Size(double.infinity, 50), // Larghezza del bottone
                    ),
                    child: const Text(
                      'Logout',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }
}
