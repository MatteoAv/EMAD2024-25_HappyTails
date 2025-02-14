import 'package:flutter/material.dart';
import 'package:happy_tails/UserManage/model/pet.dart';
import 'package:happy_tails/UserManage/providers/profile_providers.dart';
import 'package:happy_tails/UserManage/repositories/local_database.dart';
import 'package:happy_tails/payment_service.dart';
import 'package:happy_tails/screens/ricerca/petsitter_model.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedDateRangeProvider = StateProvider<DateTimeRange?>((ref) => null);

class ProfiloPetsitter extends ConsumerStatefulWidget {
  const ProfiloPetsitter({
    Key? key,
    required this.petsitter,
    required this.indisp,
    required this.dateRange,
  }) : super(key: key);

  final PetSitter petsitter;
  final List indisp;
  final DateTimeRange dateRange;

  @override
  _ProfiloPetsitterState createState() => _ProfiloPetsitterState();
}

class _ProfiloPetsitterState extends ConsumerState<ProfiloPetsitter>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  Map<int, bool> petSelections = {};
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

  @override
  void initState() {
    super.initState();
    _loadReviews();
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
     final user = ref.read(userProvider).value;
     String? selectedCard;
     if(user != null && user.customerId != null){
      final cards = await PaymentService.getPaymentMethods(user.customerId!);
      if(cards.isEmpty){
        showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Nessun metodo di pagamento"),
          content: Text("Per effettuare una prenotazione, devi aggiungere un metodo di pagamento."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        ),
      );
      return; // Esce dalla funzione
    }
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Scegli un metodo di pagamento"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: cards.map((card) {
              return ListTile(
                leading: Icon(Icons.credit_card),
                title: Text("•••• ${card['card']['last4']}"),
                onTap: () {
                  selectedCard = card['id'];
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
    if (selectedCard == null) return; // L'utente ha annullato la selezione
  }  

    final success = await PaymentService.createPaymentIntent(prezzo * 100, selectedCard, user?.customerId);
    if(success != null){
     await Supabase.instance.client.rpc(
      'create_booking', 
      params: {
          'data_inizio': inizio, 
          'data_fine': fine, 
          'prezzo': prezzo,
          'pet_id': pet_id,
          'owner_id': owner_id,
          'petsitter_id': petsitter_id,
          'metapayment' : success['paymentIntentId']
      },
    );

    final db = await LocalDatabase.instance.database;
    await LocalDatabase.instance.syncData("bookings", "owner_id", owner_id, db);
    ref.watch(bookingsProvider.notifier).updateBooking();
    }
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
    final selectedDateRange = ref.watch(selectedDateRangeProvider) ?? widget.dateRange;

    final String iconPath = 'assets/IconPets';
    final animalTypes = {
      if (petsitter.cani) 'Cane': "$iconPath/dog.png",
      if (petsitter.gatti) 'Gatto': "$iconPath/cat.png",
      if (petsitter.pesci) 'Pesce': "$iconPath/fish.png",
      if (petsitter.uccelli) 'Uccello': "$iconPath/dove.png",
      if (petsitter.roditori) 'Altro': "$iconPath/hamster.png",
    };

    int fullStars = averageRating.floor();
    bool hasHalfStar = averageRating - fullStars >= 0.5;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Profilo PetSitter',
            style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 22,
                letterSpacing: -0.5)),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepOrange.shade700, Colors.deepOrange.shade400],
              stops: [0.1, 0.9],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Profile Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepOrange.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.deepOrange.shade200,
                              width: 2
                            ),
                            image: DecorationImage(
                              image: NetworkImage(petsitter.imageUrl),
                              fit: BoxFit.cover
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('$nome $cognome',
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.grey.shade700 )),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.location_pin,
                                      color: Colors.deepOrange.shade400, size: 20),
                                  const SizedBox(width: 8),
                                  Text(provincia,
                                      style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 16)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '${NumberFormat('0.00').format(prezzo)}€ ',
                                      style: TextStyle(
                                        color: Colors.deepOrange.shade600,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 20
                                      ),
                                    ),
                                    TextSpan(
                                      text: '/ giorno',
                                      style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 14
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Animal Type Selection
                  _SectionTitle(title: 'Seleziona categoria pet'),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 4,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.9,
                    children: animalTypes.entries.map((entry) {
                      final isSelected = selectedType == entry.key;
                      return GestureDetector(
                        onTap: () async {
                          setState(() => selectedType = entry.key);
                          await fetchPets(entry.key, user!.id);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? Colors.deepOrange.shade100
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected 
                                  ? Colors.deepOrange 
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                entry.value,
                                width: 32,
                                height: 32,
                                color: isSelected 
                                    ? Colors.deepOrange
                                    : Colors.grey.shade700,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                entry.key,
                                style: TextStyle(
                                  color: isSelected 
                                      ? Colors.deepOrange
                                      : Colors.grey.shade700 ,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          


          // Pet Selection
          if (selectedType != null)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _SectionTitle(title: 'Seleziona i tuoi pet'),
                  if (pets.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'Non hai pet di questo tipo, aggiungili dal tuo profilo',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w500
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    ...pets.map((pet) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        elevation: 2,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          leading: Checkbox(
                            value: petSelections[pet.id] ?? false,
                            onChanged: (value) {
                              setState(() {
                                petSelections[pet.id] = value!;
                                if (value) {
                                  if (!petsSelezionati.contains(pet)) {
                                    petsSelezionati.add(pet);
                                    print('Animale inserito: ${pet.name}');
                                  }
                                } else {
                                  petsSelezionati.removeWhere((p) => p.id == pet.id);
                                  print('Animale rimosso: ${pet.name}');
                                }
                              });
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6)),
                            fillColor: MaterialStateProperty.resolveWith<Color>((states) {
                              if (states.contains(MaterialState.selected)) {
                                // When the checkbox is SELECTED (checked), make it orange
                                return Colors.deepOrange;
                              } else {
                                // When the checkbox is NOT SELECTED (unchecked), make it a neutral color
                                return Colors.grey.shade400; // Or a different shade of grey you prefer for unselected
                              }
                            }),
                          ),
                          title: Text(pet.name,
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                          trailing: Icon(Icons.pets,
                              color: Colors.deepOrange.shade300),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    )),
                ]),
              ),
            ),

          // Date Selection
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle(title: 'Seleziona periodo'),
                  GestureDetector(
                    onTap: () async {
                      final dateRange = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                        selectableDayPredicate: (DateTime date, DateTime? start, DateTime? end) {
                          for (final entry in widget.indisp) {
                            final DateTimeRange range = DateTimeRange(
                              start: DateTime.parse(entry['data_inizio']),
                              end: DateTime.parse(entry['data_fine']),
                            );
                            if (date.isAfter(range.start) && date.isBefore(range.end)) {
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
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 12,
                            spreadRadius: 4,
                          )
                        ],
                        border: Border.all(
                          color: Colors.deepOrange.shade100,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_month_rounded,
                              color: Colors.deepOrange.shade300),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              // ignore: unnecessary_null_comparison
                              selectedDateRange == null
                                  ? "Seleziona date"
                                  : "${_dateFormat.format(selectedDateRange.start)} - ${_dateFormat.format(selectedDateRange.end)}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.deepOrange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "${selectedDateRange.duration.inDays} giorni",
                              style: TextStyle(
                                color: Colors.deepOrange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Prenota Button
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            sliver: SliverToBoxAdapter(
              child: ElevatedButton(
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
                                if (selectedType == null || petsSelezionati.isEmpty) {
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
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  minimumSize: const Size(double.infinity, 58),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shadowColor: Colors.deepOrange.withOpacity(0.3),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline_rounded, size: 24),
                    SizedBox(width: 12),
                    Text('CONFERMA PRENOTAZIONE',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5)),
                  ],
                ),
              ),
            ),
          ),

          // Sezione Recensioni (invariata)
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
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
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade700 ,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}