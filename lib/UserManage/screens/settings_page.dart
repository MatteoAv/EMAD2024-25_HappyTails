import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_tails/app/routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:happy_tails/UserManage/providers/profile_providers.dart';


class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  late final TextEditingController _nickController;
  late final TextEditingController _cittaController;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProvider).valueOrNull;
    _nickController = TextEditingController(text: user?.userName);
    _cittaController = TextEditingController(text: user?.citta);
  }

  @override
  void dispose() {
    _nickController.dispose();
    _cittaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Impostazioni'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: userAsync.when(
          data: (user) {
            return Form(
              child: ListView(
                children: [
                  // Modifica Username
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.account_circle),
                    ),
                    controller: _nickController,
                  ),
                  const SizedBox(height: 16),

                  // Modifica Città
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Città',
                      prefixIcon: Icon(Icons.location_city),
                    ),
                    controller: _cittaController,
                  ),
                  const SizedBox(height: 24),

                  // Pulsante per confermare le modifiche
                  ElevatedButton(
                    onPressed: userAsync.isLoading
                        ? null
                        : () async {
                            final success = await ref
                                .read(userProvider.notifier)
                                .updateUser(
                                  user!.id,
                                  _nickController.text.trim(),
                                  _cittaController.text.trim(),
                                );

                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Modifiche salvate con successo!'),
                                ),
                              );
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Errore nel salvataggio delle modifiche.'),
                                ),
                              );
                            }
                          },
                    child: userAsync.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Conferma modifiche"),
                  ),
                  const SizedBox(height: 24),

                  // Metodo di pagamento
                  ListTile(
                    leading: const Icon(Icons.payment),
                    title: const Text('Payment Methods'),
                    onTap: () {
                     // Navigator.pushNamed(context, AppRoutes.paymentMethods);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Pulsante per effettuare il logout
                  ElevatedButton(
                    onPressed: () {
                        Supabase.instance.client.auth.signOut();
                        ref.read(userProvider.notifier).state = const AsyncData(null);
                        ref.invalidate(petsProvider);
                        ref.invalidate(bookingsProvider);
                        print('Logout effettuato');
                        Navigator.popUntil(context, ModalRoute.withName(AppRoutes.homePage));
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.red,
                    ),
                    child: const Text(
                      'Logout',
                      style: TextStyle(fontSize: 18, color: Colors.white),
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
