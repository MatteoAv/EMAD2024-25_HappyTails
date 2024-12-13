import 'package:flutter/material.dart';
import 'package:happy_tails/screens/ricerca/petsitter_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfiloPetsitter extends StatefulWidget {
  final PetSitter petsitter;

  const ProfiloPetsitter({Key? key, required this.petsitter}) : super(key: key);

  @override
  _ProfiloPetsitterState createState() => _ProfiloPetsitterState();
}

class _ProfiloPetsitterState extends State<ProfiloPetsitter> {
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  TimeOfDay? startTime;

  List<Map<String, dynamic>> reviews = [];

  @override
  void initState() {
    super.initState();
    _loadReviews(); // Call _loadReviews here
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
        print('Risposta della query: $reviewsResponse');

        // Assicurati che la risposta sia una lista
        if (reviewsResponse is List) {
          List<Map<String, dynamic>> reviewsList = (reviewsResponse).map((review) {
            // Aggiungi il controllo per verificare se i campi sono corretti
            print('Review data: $review');
            return {
              'data': review['date_end'] ?? 'Sconosciuto',  // Usa un valore di fallback se 'dateEnd' è null
              'recensione': review['review'] ?? 'Sconosciuto',  // Usa un valore di fallback se 'review' è null
              'voto': review['vote'] ?? 0,  // Usa un valore di fallback se 'vote' è null
              'proprietario': review['owner_name'] ?? 'Sconosciuto',  // Usa un valore di fallback se 'owner_id' è null
              'profilePicture': review['profile_picture'] ?? 'assets/default_profile.png',  // Usa un valore di fallback per 'profile_picture'
            };
          }).toList();

          setState(() {
            reviews = reviewsList; // Aggiorna la lista delle recensioni
          });
        } else {
          print('Errore: la risposta della query non è una lista');
        }
      }
    } catch (e) {
      print('Errore durante il caricamento delle recensioni: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final PetSitter petsitter = widget.petsitter;
    final int petsitterId = petsitter.id;


    print("ID del petsitter PETSITTER_PAGE: $petsitterId");

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

              // Recensioni
              const SizedBox(height: 16),
              Column(
                children: reviews.map((review) {
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
                                    index < (review['voto'] ?? 0)  // Usa 0 se 'voto' è null
                                        ? Icons.star
                                        : Icons.star_border,
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
