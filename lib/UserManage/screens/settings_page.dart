import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    final isLoading = ref.watch(userProvider.notifier).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
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
                      labelText: 'City',
                      prefixIcon: Icon(Icons.location_city),
                    ),
                    controller: _cittaController,
                  ),
                  const SizedBox(height: 24),

                  // Pulsante per confermare le modifiche
                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            final success = await ref
                                .read(userProvider.notifier)
                                .updateUser(
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
                    child: isLoading
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
                        print('Logout effettuato');
                        Navigator.pushNamed(context, "/");
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
