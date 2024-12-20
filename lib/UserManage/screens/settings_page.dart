import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_tails/UserManage/providers/managePetSitter.dart';
import 'package:happy_tails/app/routes.dart';
import 'package:happy_tails/screens/ricerca/risultatiricerca_pagina.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:happy_tails/UserManage/providers/profile_providers.dart';


final selectionDateProvider = StateProvider<DateTimeRange?>((ref){
  return null;
});

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  late final TextEditingController _nickController;
  late final TextEditingController _cittaController;
  File? _selected_image;


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

  //Seleziona l'immagine dalla galleria foto
  Future <void> _pickImage() async{
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if(pickedFile != null){
      setState(() {
        _selected_image = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(String user_id) async{

    if(_selected_image == null) return null;

    try{
      final fileName = '${user_id}_${basename(_selected_image!.path)}';
      await Supabase.instance.client.storage
      .from('imageProfile').
      upload(fileName, _selected_image!, fileOptions: const FileOptions(upsert:true));

      final publicUrl = Supabase.instance.client.storage
      .from('imageProfile').getPublicUrl(fileName);

      return publicUrl;                

    }catch(e){
        print(e);
    }
    return null;
  }

  Future<void> _updateImageProfile(String user_id)async{
      final publicUrl = await _uploadImage(user_id);
      if(publicUrl == null) return;

      try{

        final response = await Supabase.instance.client
          .from('profiles')
          .update({'imageUrl': publicUrl})
          .eq('id', user_id).select();

        if(response.isEmpty){
          throw Exception("Errore nel salvare la foto profilo");
        }

        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          const SnackBar(content: Text("Immagine profilo salvata con successo"))
        );  
      }catch(e){
            print(e);
      }
  }


  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);
    final selectedRange = ref.watch(selectedDateRangeProvider);

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
                  CircleAvatar(
                    radius : 60,
                    backgroundImage: _selected_image != null ?
                     FileImage(_selected_image!)
                     : (user?.imageUrl != null ?
                      NetworkImage(user!.imageUrl,):
                      null),
                  ),
                  const SizedBox(height: 16,),
                  ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Seleziona Foto'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _updateImageProfile(user!.id),
                child: const Text('Salva Foto Profilo'),
              ),
              const Divider(),
                  ExpansionTile(
                    title: const Text("Dati Personali",
                    style : TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    leading: Icon(Icons.person, size: 30, color: Colors.black),
                    trailing: Transform.translate(
                      offset: Offset(-10, 0),
                      ),
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
                  ],
                  ),
                  // Metodo di pagamento
                  ListTile(
                    leading: const Icon(Icons.payment),
                    title: const Text('Payment Methods'),
                    onTap: () {
                     // Navigator.pushNamed(context, AppRoutes.paymentMethods);
                    },
                  ),
                  if(user!= null && user.isPetSitter)
                  ExpansionTile(
                    title: const Text("Gestione PetSitting"),
                    leading: Icon(Icons.pets, size:30, color: Colors.black,),
                  children : [
                    ListTile(
                    leading: const Icon(Icons.calendar_month),
                    title: const Text('Indisponibilità'),
                    onTap: ()async {
                      final dateRange = await showDateRangePicker(
                        context: context, 
                        firstDate: DateTime.now(), 
                        lastDate: DateTime(DateTime.now().year + 100),
                        initialDateRange: selectedRange, 
                        );
                      if(dateRange!=null){
                        ref.read(selectionDateProvider.notifier).state = dateRange;
                      }
                    },
                  ),
                    ListTile(
                      leading : const Icon(Icons.add_task),
                      title : const Text("Pets gestiti"),
                      onTap: () {
                        showDialog(
                          context: context, builder: (context) => const AddPetDialog());
                      }
                    ),
                  ],
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

class AddPetDialog extends ConsumerWidget {
  const AddPetDialog({Key? key}) : super(key: key);
  final String iconPath = 'assets/IconPets';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final managePetState = ref.watch(managePetsNotifierProvider);
    final managePetNotifier = ref.read(managePetsNotifierProvider.notifier);

    final animalTypes = {
      'Dog': "$iconPath/dog.png",
      'Cat': "$iconPath/cat.png",
      'Fish': "$iconPath/fish.png",
      'Bird': "$iconPath/dove.png",
      'Other': "$iconPath/hamster.png",
    };

    return AlertDialog(
      title: const Text('Che Pet Gestici'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: animalTypes.entries.map((entry) {
                final type = entry.key;
                final icon = entry.value;

                return GestureDetector(
                  onTap: () {
                    managePetNotifier.togglePet(type);
                  },
                  child: AnimatedScale(
                    scale: managePetState.selectedPets.containsKey(type) ? 1.2 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: CircleAvatar(
                      backgroundColor: managePetState.selectedPets.containsKey(type)
                          ? Colors.deepOrange
                          : Colors.grey[300],
                      radius: 30,
                      child: Image.asset(icon.toString(), width: 30, height: 30),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: null,
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}
