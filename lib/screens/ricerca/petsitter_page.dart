import 'package:flutter/material.dart';
import 'package:happy_tails/UserManage/model/pet.dart';
import 'package:happy_tails/screens/ricerca/petsitter_model.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';




final selectedDateRangeProvider = StateProvider<DateTimeRange?>((ref) => null);

class ProfiloPetsitter extends ConsumerStatefulWidget {
  const ProfiloPetsitter({Key? key, required this.petsitter, required this.indisp, required this.dateRange}) : super(key: key);
  final PetSitter petsitter;
  final List indisp;
  final DateTimeRange dateRange;

  @override
  _ProfiloPetsitterState createState() => _ProfiloPetsitterState();
}

class _ProfiloPetsitterState extends ConsumerState<ProfiloPetsitter> with AutomaticKeepAliveClientMixin{

  @override
  bool get wantKeepAlive => true;
  Map<int, bool> petSelections = {}; // Map per tenere traccia delle selezioni

  List<Map<String, dynamic>> reviews = [];
  double totalRating = 0;  // Variabile per il punteggio totale
  int totalReviews = 0;    // Variabile per il numero di recensioni
  String? selectedType; // Varibile per l'animale selezionato
  List<dynamic> pets = []; // lista di pet dell'utente da cui puo scegliere
  List<dynamic> petsSelezionati = []; // lista di pet selezionati dall'utente
  String? selectedPet; // Pet selezionato tra quelli della lista dell'utente
  int petID=0;
  List<int> checkbooking = []; // per ogni animale selezionato si controlla se la data selezionata e' gia stata prenotata, il risultato viene messo in questa lista
                               // durante il controllo se nella lista e' presente anche un solo 1, cioe anche un solo animale risulta gia prenotato per quella data allora viene restituito
                               // un messaggio di errore

  
  //late Pet nuovo;

  @override
  void initState() {
    super.initState();
    _loadReviews(); // Call _loadReviews here
  }

  Future<void> fetchPets(String type, String userId) async {
    final petResponse = await Supabase.instance.client.rpc(
      'get_pets_by_user_and_type', // Nome della funzione RPC in Supabase
      params: {
        '_user_id': userId, // Id dell'utente petsitter
        '_type': type, // Tipo di animale selezionato
      },
    );

    final animals = petResponse.map((animal) => Pet.fromMap(animal as Map<String, dynamic>)).toList();
    setState(() {
      pets = animals;
    });

  }

  Future<int> checkPrenotazione(int petid, String inizio, String fine) async {
    final prenotazioneResponse = await Supabase.instance.client.rpc(
      'check_booking_overlap', // Nome della funzione RPC in Supabase
      params: {
        'pet_id_input': petid, // Id dell'utente petsitter
        'datainizio_input': inizio, // Tipo di animale selezionato
        'datafine_input': fine
      },
    );

    if(prenotazioneResponse ==1){
      return 1;
    } 
    else{
      return 0;
    } 
  }

  Future<void> prenota(String inizio, String fine, double prezzo, int pet_id, String owner_id, int petsitter_id) async {
     await Supabase.instance.client.rpc(
      'create_booking', 
      params: {
          'data_inizio': inizio, 
          'data_fine': fine, 
          'prezzo': prezzo,
          'pet_id': pet_id,
          'owner_id': owner_id,
          'petsitter_id': petsitter_id,
      },
    );



  }

  Future<void> _loadReviews() async {
    final PetSitter petsitter = widget.petsitter;
    final int petsitterId = petsitter.id;

    try {
      if (petsitterId != 0) {
        final reviewsResponse = await Supabase.instance.client.rpc(
          'get_reviews_for_petsitter',
          params: {
            'petsitter_id_input': petsitterId,
          },
        );

        // Stampa la risposta della query per verificarne il formato
        //print('Risposta della query: $reviewsResponse');

        // Assicurati che la risposta sia una lista
        if (reviewsResponse is List) {
          List<Map<String, dynamic>> reviewsList = (reviewsResponse).map((review) {
            // Aggiungi il controllo per verificare se i campi sono corretti
            //print('Review data: $review');
            return {
              'data': review['date_end'] ?? 'Sconosciuto',
              'recensione': review['review'] ?? 'Sconosciuto',
              'voto': review['vote'] ?? 0,
              'proprietario': review['owner_name'] ?? 'Sconosciuto',
              'profilePicture': review['profile_picture'] ?? 'assets/default_profile.png',
            };
          }).toList();

          setState(() {
            reviews = reviewsList;
            totalReviews = reviewsList.length;
            totalRating = reviewsList.fold(0, (sum, review) => sum + (review['voto'] ?? 0));
          });
        } else {
          print('Errore: la risposta della query non è una lista');
        }
      }
    } catch (e) {
      print('Errore durante il caricamento delle recensioni: $e');
    }
  }

  Future<bool> isUserLoggedIn() async {
    final session = Supabase.instance.client.auth.currentSession;
    return session != null;
  }

  double get averageRating {
    if (totalReviews == 0) {
      return 0;
    }
    // Media dei voti su una scala da 1 a 10
    return totalRating / totalReviews / 2; // Diviso per 2 per trasformare da scala 1-10 a scala 1-5 stelle
  }


  final user = Supabase.instance.client.auth.currentUser;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final PetSitter petsitter = widget.petsitter;
    final int petsitterId = petsitter.id;
    final String nome = petsitter.nome;
    final String cognome = petsitter.cognome;
    final String provincia = petsitter.provincia;
    final double prezzo = petsitter.prezzo;
    final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
    final selectedDateRange = widget.dateRange;    


    print("ID del petsitter PETSITTER_PAGE: $petsitterId");

    final String iconPath = 'assets/IconPets';
    final animalTypes = {
      if (petsitter.cani) 'Cane': "$iconPath/dog.png",
      if (petsitter.gatti) 'Gatto': "$iconPath/cat.png",
      if (petsitter.pesci) 'Pesce': "$iconPath/fish.png",
      if (petsitter.uccelli) 'Uccello': "$iconPath/dove.png",
      //icona rettili
      if (petsitter.roditori) 'Altro': "$iconPath/hamster.png",
    };

    // Calcoliamo il numero di stelle piene, metà stelle e stelle vuote
    int fullStars = averageRating.floor();
    bool hasHalfStar = averageRating - fullStars >= 0.5;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Profilo del Pet-Sitter'),
        backgroundColor: Colors.deepOrange[50],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Sezione del profilo
              Row(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(petsitter.imageUrl),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:[

                            Text(
                              ' $nome $cognome',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            

                        SizedBox(height: 5),
                        Row(
                          children: [

                            Icon(
                              Icons.location_on, // Icona per la posizione
                              color: Colors.red, // Colore dell'icona
                              size: 20, // Dimensione dell'icona
                            ),

                            Text(
                              '$provincia',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(width: 15),
                            Text(
                              '${NumberFormat('0.00').format(prezzo)} €/giorno',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),

                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              // Sezione prenotazione
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [

                    const SizedBox(height: 20),

                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Scegli il tipo di pet per cui prenotare:',
                          style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: animalTypes.entries.map((entry) {
                            final type = entry.key;
                            final icon = entry.value;

                            return GestureDetector(
                              onTap: () async {
                                setState(() {
                                  selectedType = type;
                                });
                                await fetchPets(type, user!.id); 
                              },
                              child: AnimatedScale(
                                scale: selectedType == type ? 1.2 : 1.0,
                                duration: const Duration(milliseconds: 200),
                                child: CircleAvatar(
                                  backgroundColor: selectedType == type
                                      ? Colors.deepOrange
                                      : Colors.grey[300],
                                  radius: 30,
                                  child: Image.asset(icon, width: 30, height: 30),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 30),
                        if (selectedType != null)
                          Column(
                            children: [
                              if (pets.isEmpty) // Se la lista di animali è vuota, mostra il messaggio
                                const Text(
                                  'Non hai pet di questo tipo, aggiungili dal tuo profilo',
                                  style: TextStyle(color: Colors.black),
                                )
                              else
                                // Usa una ListView invece di un DropdownButton per gestire meglio le checkbox
                                ListView(
                                  shrinkWrap: true, // Evita l'overflow
                                  physics: NeverScrollableScrollPhysics(), // Disabilita lo scorrimento
                                  children: pets.map((pet) {
                                    return CheckboxListTile(
                                      title: Text(pet.name),
                                      value: petSelections[pet.id] ?? false, // Verifica se il pet è selezionato
                                      onChanged: (bool? value) {
                                        setState(() {
                                          if (value == true) {
                                            // Se la casella viene selezionata, aggiungi il pet alla lista
                                            if(!petsSelezionati.contains(pet)){
                                              petsSelezionati.add(pet);
                                              print('Animale inserito nella lista: ${pet.name}, Stato: ${value}');
                                            }

                                          } else {
                                            // Se la casella viene deselezionata, rimuovi il pet dalla lista
                                            petsSelezionati.removeWhere((selectedPet) => selectedPet.id == pet.id);
                                            print('Animale rimosso dalla lista nella lista: ${pet.name}, Stato: ${value}');
                                          }
                                          petSelections[pet.id] = value ?? false;
                                        });

                                        for(int i=0; i<petsSelezionati.length; i++){
                                          String animal = petsSelezionati[i].name;
                                          print('Animale $i : $animal');
                                        }
                                      },
                                    );
                                  }).toList(),
                                ),
                            ],
                          ),
                      ],
                    ),


                    const SizedBox(height: 20),

                    Row(
                      children: [
                        const SizedBox(width: 10),
                        // Date Range Picker
                        Expanded(
                          
                          child: GestureDetector(
                            onTap: () async {
                              final dateRange = await showDateRangePicker(
                                context: context,
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100),
                                selectableDayPredicate: (DateTime date, DateTime? start, DateTime? end){
                                  for(final entry in widget.indisp){
                                    final DateTimeRange range = DateTimeRange(start: DateTime.parse(entry['data_inizio']), 
                                    end: DateTime.parse(entry['data_fine']));
                                    if(date.isAfter(range.start) && date.isBefore(range.end)){
                                      return false;
                                    }
                                  }
                                  return true;
                                },
                                initialDateRange: selectedDateRange,
                              );
                              if (dateRange != null) {
                                ref.read(selectedDateRangeProvider.notifier).state = dateRange;
                              }
                            },

                            
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                                border: Border.all(color: Colors.grey),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
                                  const SizedBox(width: 8.0),
                                  Text(
                                    selectedDateRange == null
                                        ? "Data"
                                        : "${_dateFormat.format(selectedDateRange.start)} - ${_dateFormat.format(selectedDateRange.end)}",
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        // Number of Days
                        Text(
                          selectedDateRange?.duration.inDays != null
                              ? "${selectedDateRange!.duration.inDays} ${selectedDateRange.duration.inDays == 1 ? 'giorno' : 'giorni'}"
                              : "",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    ElevatedButton(

                        onPressed: () async {
                              if(await isUserLoggedIn() == false){
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Per effettuare una prenotazione devi effettuare l'accesso alla piattaforma."),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                              else{
                                if (selectedDateRange == null || selectedType == null || petsSelezionati.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Per favore, compila tutti i campi prima di proseguire."),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                } 

                                else {
                                    for(int i=0; i<petsSelezionati.length; i++){
                                      final alreadyPrenotato = await checkPrenotazione(petsSelezionati[i].id, selectedDateRange.start.toIso8601String().split('T')[0], selectedDateRange.end.toIso8601String().split('T')[0]);
                                      checkbooking.add(alreadyPrenotato);
                                    }
                                    
                                    if(checkbooking.contains(1)){
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text("Prenotazione Fallita"),
                                              content: const Text("L'intervallo di date selezionato è già prenotato per uno dei pet selezionati."),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text("OK"),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                    }
                                    else{
                                      int durationDays = selectedDateRange.end.difference(selectedDateRange.start).inDays;
                                      print('Durata:  $durationDays');
                                      double totalPrice = petsitter.prezzo * durationDays;
                                      for(int j=0; j<petsSelezionati.length; j++){
                                        await prenota(selectedDateRange.start.toIso8601String().split('T')[0], selectedDateRange.end.toIso8601String().split('T')[0], totalPrice, petsSelezionati[j].id ,user!.id, petsitterId);
                                      }
                                      showDialog(
                                        context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text("Prenotazione Avvenuta"),
                                              content: const Text("La tua prenotazione è stata effettuata con successo."),
                                              actions: <Widget>[
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop(); // Chiude l'alert box
                                                },
                                                child: const Text("OK"),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }


                                }
                              }


                        },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        minimumSize: const Size(double.infinity, 45),
                      ),
                      child: const Text(
                        'Prenota',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              
              // Valutazione complessiva
              Center(
                child: Column(
                  children: [
                    const Text(
                      'Valutazione Complessiva',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      averageRating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        5,
                        (index) {
                          if (index < fullStars) {
                            return const Icon(Icons.star, color: Colors.orange, size: 28);
                          } else if (index == fullStars && hasHalfStar) {
                            return const Icon(Icons.star_half, color: Colors.orange, size: 28);
                          } else {
                            return const Icon(Icons.star_border, color: Colors.orange, size: 28);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Basato su $totalReviews recensioni',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Recensioni
              const SizedBox(height: 25),

              Column(
                children: reviews.map((review) {
                  double rating = (review['voto'] ?? 0) / 2;  // Adattiamo il voto da 1-10 a 1-5 stelle

                  // Calcoliamo il numero di stelle piene, metà stelle e stelle vuote
                  int fullStars = rating.floor();
                  bool hasHalfStar = rating - fullStars >= 0.5;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundImage: AssetImage(review['profilePicture'] ?? 'assets/puppies.png'),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    review['proprietario'] ?? 'Sconosciuto',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    review['data'] ?? 'Sconosciuto',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: List.generate(
                                  5,
                                  (index) => Icon(
                                    index < fullStars
                                        ? Icons.star
                                        : (index == fullStars && hasHalfStar ? Icons.star_half : Icons.star_border),
                                    color: Colors.orange,
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                review['recensione'] ?? 'Sconosciuto',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
}
