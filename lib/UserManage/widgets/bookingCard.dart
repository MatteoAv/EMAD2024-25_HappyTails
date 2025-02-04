import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';



class bookingCard extends StatefulWidget{

  final int id;
  final String bookingBegin;
  final String bookingEnd;
  final double bookPrice;
  final String bookState;
  final int petSitterId;
  final int petId;


  const bookingCard({
      Key? key,
      required this.id,
      required this.bookingBegin,
      required this.bookingEnd,
      required this.bookPrice,
      required this.bookState, 
      required this.petSitterId, 
      required this.petId,
    }): super(key : key);

  @override
  _BookingCardState createState() => _BookingCardState();
}
  

  class _BookingCardState extends State<bookingCard> {
  String petName = "Caricamento...";
  String petSitterName = "Caricamento...";

  Future<void> creaRecensione(int booking_id, int punteggio, String recensione) async {
     await Supabase.instance.client.rpc(
      'insert_booking_review', 
      params: {
          'p_id': booking_id, 
          'p_vote': punteggio, 
          'p_review': recensione,
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getPet(widget.petId);
    getPetSitter(widget.petSitterId);
  }

  Future<void> getPet(int petId) async {
    final response = await Supabase.instance.client.rpc(
      'get_pet_name',
      params: {'petid': petId},
    );

    print("Response from get_pet_name: $response");

    setState(() {
      petName = response as String? ?? "Nome non disponibile";
    });
  }

  Future<void> getPetSitter(int petSitterId) async {
    final response = await Supabase.instance.client.rpc(
      'get_petsitter_name',
      params: {'petsitterid': petSitterId},
    );

    print("Response from get_pet_name: $response");

    setState(() {
      petSitterName = response?.toString() ?? "Nome non disponibile";
    });
  }




  void _showReviewDialog(BuildContext context) {
    double rating = 0.5; // Valore iniziale
    TextEditingController reviewController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              content: SizedBox(
                width: 300, // Larghezza fissa
                height: 250, // Altezza fissa per non espandere il dialogo
                child: Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // RIGA 1: Nome del Pet Sitter
                        Row(
                          children: [
                            const Icon(
                              FontAwesomeIcons.user, 
                              size: 20, 
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              "PetSitter: ",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                letterSpacing: 1.2,
                              ),
                            ),
                            Text(
                              petSitterName.toString(),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.deepOrangeAccent,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 5),

                        // RIGA 2: Nome del Pet
                        Row(
                          children: [
                            const Icon(
                              FontAwesomeIcons.paw, 
                              size: 20, 
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              "Pet: ",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                letterSpacing: 1.2,
                              ),
                            ),
                            Text(
                              petName.toString(),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.deepOrangeAccent,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 5),

                        // RIGA 3: Prezzo
                        Row(
                          children: [
                            const Icon(
                              FontAwesomeIcons.moneyBillWave, 
                              size: 20, 
                              color: Colors.green,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              "Prezzo: ",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const Icon(
                              Icons.euro, 
                              size: 20, 
                              color: Colors.green,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.bookPrice.toStringAsFixed(2),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.8,
                                shadows: [
                                  Shadow(
                                    blurRadius: 2.0,
                                    color: Colors.black12,
                                    offset: Offset(1.0, 1.0),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Rating Bar con mezze stelle abilitate
                            RatingBar.builder(
                              initialRating: rating,
                              minRating: 0.5,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemBuilder: (context, _) => const Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              onRatingUpdate: (newRating) {
                                rating = newRating;
                              },
                            ),
                            const SizedBox(height: 10),
                            // Contenitore fisso per la recensione con scrolling
                            SizedBox(
                              height: 90, // Altezza fissa per il campo di testo
                              child: TextField(
                                controller: reviewController,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: "Scrivi una recensione...",
                                ),
                                maxLines: null, // Permette più righe senza espandere il dialog
                                keyboardType: TextInputType.multiline,
                                expands: true, // Riempie il contenitore senza allargarsi
                                textAlignVertical: TextAlignVertical.top, // Allinea il testo in alto
                                onChanged: (_) {
                                  setState(() {}); // Rende possibile l'aggiornamento dello stato
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context), // Chiude il dialogo
                  child: const Text("Annulla"),
                ),
                ElevatedButton(
                  onPressed: reviewController.text.isEmpty
                      ? null // Disabilita il pulsante se il campo è vuoto
                      : () {
                          int punteggio = (rating * 2).round(); // Converte il rating in punteggio (0.5 → 1, 1.5 → 3, ecc.)
                          String reviewText = reviewController.text;

                          // Simulazione della chiamata per inviare la recensione
                          try {
                            creaRecensione(widget.id, punteggio, reviewText); // Funzione di invio recensione
                            Navigator.pop(context); // Chiude il dialogo

                            // Mostra la notifica di successo
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Recensione effettuata con successo!"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            Navigator.pop(context); // Chiude il dialogo in caso di errore

                            // Mostra la notifica di errore
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Errore nell'invio della recensione. Riprova."),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  child: const Text("Conferma"),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 30),
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(16),
        color: Colors.deepOrange[50],
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.deepOrange[100],
          onTap: () {
            if (widget.bookState == 'Confermata') {
              _showReviewDialog(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Non puoi lasciare una recensione per una prenotazione non confermata."),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(
                  Icons.event_available,
                  color: Colors.orange,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.bookingBegin} → ${widget.bookingEnd}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text( 
                            petName.toString(), 
                            style: const TextStyle(fontSize: 14), 
                          ), 
                          const SizedBox(width: 15),
                          const Icon(Icons.euro, size: 16, color: Colors.green),
                          const SizedBox(width: 4),
                          Text(
                            widget.bookPrice.toStringAsFixed(2),
                            style: const TextStyle(fontSize: 14),
                          )
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            widget.bookState == 'Confermata' ? Icons.check_circle : Icons.error,
                            color: widget.bookState == 'Confermata' ? Colors.green : Colors.red,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.bookState,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: widget.bookState == 'Confermata' ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.rate_review,
                      size: 26,
                      color: Colors.orange,
                    ),
                    const Icon(Icons.chevron_right, color: Colors.grey)  
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}