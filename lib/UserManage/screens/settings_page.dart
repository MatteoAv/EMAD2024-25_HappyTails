
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_tails/UserManage/providers/managePetSitter.dart';
import 'package:happy_tails/UserManage/repositories/local_database.dart';
import 'package:happy_tails/app/routes.dart';
import 'package:happy_tails/chat/chat_provider.dart';
import 'package:happy_tails/screens/ricerca/risultatiricerca_pagina.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
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
    TextEditingController? _nameController;
    TextEditingController? _surnameController;
    TextEditingController? _provinciaController;
    TextEditingController? _priceController;
  late final fileName;
  Map<String,dynamic>? petSitter;
  File? _selected_image;
  double prezzo = 10.0 ;


  @override
  void initState(){
    super.initState();
    final user = ref.read(userProvider).valueOrNull;
    _nickController = TextEditingController(text: user?.userName);
    _cittaController = TextEditingController(text: user?.citta);
    if(user != null && user!.imageUrl!=null){
    _selected_image = File(user.imageUrl!);
    }
    if(user != null && user.isPetSitter){
      checkPetSitter();
    }
  }

  @override
  void dispose() {
    _nickController.dispose();
    _cittaController.dispose();
    super.dispose();
  }

  void checkPetSitter ()async{
    final user = ref.read(userProvider).valueOrNull;
    if(user!=null && user.isPetSitter){
      final result = await get_petsitter_by_email(user.email);
      if(result != null){
       petSitter = result.first;
       Map<String, bool> pets ={
        'Dog' : petSitter!['cani'],
        'Cat' : petSitter!['gatti'],
        'Fish': petSitter!['pesci'],
        'Bird': petSitter!['uccelli'],
        'Other': petSitter!['roditori'] || petSitter!['rettili']
       };
      _nameController = TextEditingController(text: petSitter!['nome']);
      _surnameController = TextEditingController(text: petSitter!['cognome']);
      _provinciaController = TextEditingController(text: petSitter!['provincia']);
      _priceController = TextEditingController(text: petSitter!['prezzo_giornaliero'].toString());
      prezzo = petSitter!['prezzo_giornaliero'] is int ? (petSitter!['prezzo_giornaliero'] as int).toDouble() 
      : petSitter!['prezzo_giornaliero'] ;
      setState(() {
        petSitter = result.first;
        ref.read(managePetsNotifierProvider).copyWith(selectedPets: pets);
      });
      
            }else{
              _nameController = TextEditingController(text: "Nome");
      _surnameController = TextEditingController(text: "cognome");
      _provinciaController = TextEditingController(text: "provincia");
      _priceController = TextEditingController(text: "Prezzo Giornaliero");
        petSitter = null;
        
      }
      return;
    }
  }

  Future<List<dynamic>?> get_petsitter_by_email(String email)async{
    final supabase = Supabase.instance.client;
    
    final response = await supabase.rpc("get_petsitter_by_email", params: {'email_input': email});
    if(response.length != 0){

      return response;

    }
    return null;
  }

  //Seleziona l'immagine dalla galleria foto
  Future <void> _pickImage() async{
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if(pickedFile != null){
      final directory = await getApplicationDocumentsDirectory();
      final joinPath = join(directory.path, 'profile_image.png');

      final previousFile = File(joinPath);
      if (await previousFile.exists()) {
      await previousFile.delete();
      }

      File localFile = await File(pickedFile.path).copy(joinPath);

      await FileImage(localFile).evict();

      setState(() {
        _selected_image = localFile;
      });


      await ref.read(userProvider.notifier).updateUser(
        ref.read(userProvider).value!.id, 
      _nickController.text.trim(), _cittaController.text.trim(), _selected_image!.path);
    }
  }


  Future<void> _updateImageProfile(String user_id)async{
      try{
        final response = await LocalDatabase.instance.updateImage(user_id, _selected_image?.path);
        if(response){
          fileName = "${user_id}_${basename(_selected_image!.path)}";
          await Supabase.instance.client.storage.from('imageProfile').
          upload(fileName, _selected_image!, fileOptions: const FileOptions(upsert: true));

          final publicUrl = Supabase.instance.client.storage.
          from('imageProfile').getPublicUrl(fileName);

          await Supabase.instance.client.from("petsitter").update({"imageurl": publicUrl})
          .eq("idd", user_id);
        }
      }catch(e){
            print(e);
      }
  }


  void _showPriceSliderDialog(BuildContext context) {
    double _tempPrezzo = prezzo;
    showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Imposta Prezzo Giornaliero'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Prezzo (€)"),
                  onChanged: (value){
                    double? newValue = double.tryParse(value);
                    if(newValue != null && newValue >= 5 && newValue <= 100){
                      setStateDialog((){
                        _tempPrezzo = newValue;
                      });
                    }
                  },
                ),
                Slider(
                  value: _tempPrezzo,
                  min: 5,
                  max: 100,
                  divisions: 1000,
                  label: _tempPrezzo.toStringAsFixed(2),
                  onChanged: (value) {
                    setStateDialog(() {
                       if(_priceController != null){
                      _priceController!.text = value.toStringAsFixed(2);
                       }
                      _tempPrezzo = value; // Aggiorna il valore dello slider
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Chiudi'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    prezzo = _tempPrezzo; // Salva il valore definitivo
                  });
                  Navigator.pop(context);
                },
                child: const Text('Conferma'),
              ),
            ],
          );
        },
      );
    },
  );
}
    


  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);
    final selectedRange = ref.watch(selectedDateRangeProvider);
    final managePets = ref.watch(managePetsNotifierProvider).selectedPets;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Impostazioni'),
        automaticallyImplyLeading: userAsync.value != null && userAsync.value!.isPetSitter,
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
                    radius : 100,
                    backgroundImage: _selected_image != null ?
                     FileImage(_selected_image!)
                     : null,
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

                  //Modifica nome
                  if(user != null && user.isPetSitter)
                  TextFormField(
                    decoration : const InputDecoration(
                      labelText: 'Nome',
                      prefixIcon: Icon(Icons.person_2_sharp),
                    ),
                    controller: _nameController,
                    
                  ),

                  const SizedBox(height:16),

                  //Modifica cognome
                  if(user != null && user.isPetSitter)
                  TextFormField(
                    decoration : const InputDecoration(
                      labelText: "Cognome",
                    ),
                    controller: _surnameController,
                    
                  ),

                  const SizedBox(height: 16,),

                  // Modifica Città
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Città',
                      prefixIcon: Icon(Icons.location_city),
                    ),
                    controller: _cittaController,
                  ),
                  const SizedBox(height: 24),
                  
                  //Modifica Provincia
                  if(user != null && user.isPetSitter)
                  TextFormField(
                    decoration : const InputDecoration(
                      labelText: "Provincia",
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    controller : _provinciaController
                    
                  ),

                  const SizedBox(height: 16,),

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
                                  _selected_image!.path,
                                );
                                if(user.isPetSitter){
                                  final supabase = Supabase.instance.client;
                                  var comune = await supabase.rpc('get_comune_coordinates', params: {'comune_name' : 'Airasca'});
                                  final double latitudine = comune.first['latitude'];
                                  final double longitude = comune.first['longitude'];
                                  final String formatPoint = 'POINT($longitude $latitudine)';
                                  await supabase
                                  .rpc('insert_or_update_petsitter', params: {'_nome' : _nameController!.text, '_cognome' : _surnameController!.text,
                                  '_email' : user.email, '_provincia': _provinciaController!.text, '_imageurl' : fileName, '_cani' : managePets['Dog'],
                                  '_gatti': managePets['Cat'], '_pesci': managePets['Fish'], '_uccelli' : managePets['Bird'], '_rettili': managePets['Other']
                                  , '_roditori': managePets['Other'], '_comune' : user.citta.trim(), '_posizione' : formatPoint, '_prezzo_giornaliero' : prezzo, '_idd': user.id});

                                }
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
                    ListTile(
                      leading: const Icon(Icons.money),
                      title: const Text("Prezzo giornaliero"),
                      subtitle: Text('€${prezzo.toStringAsFixed(2)}'),
                      onTap: () => _showPriceSliderDialog(context)
                    ),
                  ],
                  ),
                  
                  const SizedBox(height: 16),

                  // Pulsante per effettuare il logout
                  ElevatedButton(
                    onPressed: () {
                        Supabase.instance.client.auth.signOut();
                        //ref.invalidate(userProvider);
                        ref.invalidate(petsProvider);
                        ref.invalidate(bookingsProvider);
                        ref.invalidate(chatProvider);
                        print('Logout effettuato');
                        if(user!=null && user.isPetSitter){
                         Navigator.pop(context);
                        }
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
      title: const Text('Che Pet Gestisci'),
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
                    scale: managePetState.selectedPets[type]!=null && managePetState.selectedPets[type]! ? 1.2 : 1.0 ,
                    duration: const Duration(milliseconds: 200),
                    child: CircleAvatar(
                      backgroundColor: managePetState.selectedPets.containsKey(type)
                      && managePetState.selectedPets[type]!
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
          onPressed: () {
            managePetNotifier.confirmSelection();
            Navigator.pop(context);
          },
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}
