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
  double rating = 0.5;
  TextEditingController reviewController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            elevation: 8,
            insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              child: SingleChildScrollView(
                physics: ClampingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Row(
                        children: [
                          Icon(Icons.reviews, color: Colors.deepOrange, size: 28),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Lascia una recensione",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey[800],
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),

                      // Info Cards
                      _buildInfoTile(
                        icon: FontAwesomeIcons.user,
                        title: "PetSitter",
                        value: petSitterName,
                        color: Colors.blueAccent),
                      SizedBox(height: 12),
                      _buildInfoTile(
                        icon: FontAwesomeIcons.paw,
                        title: "Pet",
                        value: petName,
                        color: Colors.orange),
                      SizedBox(height: 12),
                      _buildInfoTile(
                        icon: FontAwesomeIcons.moneyBill,
                        title: "Prezzo",
                        value: "€${widget.bookPrice.toStringAsFixed(2)}",
                        color: Colors.green),

                      SizedBox(height: 24),

                      // Rating Section
                      Center(
                        child: RatingBar.builder(
                          initialRating: rating,
                          minRating: 0.5,
                          glowColor: Colors.amber[100],
                          unratedColor: Colors.grey[300],
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemSize: 40,
                          itemPadding: EdgeInsets.symmetric(horizontal: 4),
                          itemBuilder: (context, _) => Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                          ),
                          onRatingUpdate: (newRating) {
                            rating = newRating;
                          },
                        ),
                      ),
                      SizedBox(height: 24),

                      // Review Input
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: 100,
                          maxHeight: 100,
                        ),
                        child: TextField(
                          controller: reviewController,
                          maxLines: null,
                          expands: true,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[50],
                            hintText: "Descrivi la tua esperienza...",
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none),
                            contentPadding: EdgeInsets.all(16),
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            suffixIcon: Icon(Icons.edit, color: Colors.grey)),
                            onChanged: (text) {
                              setState(() {}); // Aggiungi questo
                            },
                        ),
                      ),
                      SizedBox(height: 24),

                      // Action Buttons
                      Wrap(
                        alignment: WrapAlignment.end,
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          TextButton.icon(
                            icon: Icon(Icons.close, size: 20),
                            label: Text("ANNULLA"),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.grey,
                              backgroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8))),
                            onPressed: () => Navigator.pop(context)),
                          ElevatedButton.icon(
                            icon: Icon(Icons.check_circle, size: 20),
                            label: Text("INVIA"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrangeAccent,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8))),
                            onPressed: reviewController.text.isEmpty
                                ? null
                                : () {
                                    int punteggio = (rating * 2).round();
                                    String reviewText = reviewController.text;
                                    try {
                                      creaRecensione(widget.id, punteggio, reviewText);
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Recensione effettuata con successo!"),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    } catch (e) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Errore nell'invio della recensione. Riprova."),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
Widget _buildInfoTile({IconData? icon, String? title, String? value, Color? color}) {
  return Container(
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.grey[50],
      borderRadius: BorderRadius.circular(12)),
    child: Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color!.withOpacity(0.1),
            shape: BoxShape.circle),
          child: Icon(icon, size: 20, color: color)),
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500)),
            SizedBox(height: 2),
            Text(value!,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    ),
  );
}



  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Colors.deepOrange.shade50,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.deepOrange.withOpacity(0.1),
              blurRadius: 12,
              spreadRadius: 2,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            splashColor: Colors.deepOrange.withOpacity(0.1),
            onTap: () {
              if (widget.bookState == 'Confermata') {
                _showReviewDialog(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Non puoi lasciare una recensione per una prenotazione non confermata."),
                    duration: Duration(seconds: 2),
                ));
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  // Icona sinistra
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.calendar_month,
                      color: Colors.deepOrangeAccent,
                      size: 28,
                    ),
                  ),
                  SizedBox(width: 16),

                  // Contenuto centrale
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Riga data e prezzo
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                '${widget.bookingBegin} ${widget.bookingEnd}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                  letterSpacing: -0.2,
                                ),
                                overflow: TextOverflow.ellipsis, // Aggiungi questo
                                maxLines: 2,
                              ),
                            ),
                            _PriceTag(price: widget.bookPrice),
                          ],
                        ),
                        SizedBox(height: 12),

                        // Riga nome pet e stato
                        Row(
                          children: [
                            _PetInfo(name: petName), // Già contiene Expanded
                            _StatusIndicator(state: widget.bookState),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12),

                  // Freccia destra
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.grey[400],
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Widget per lo stato
class _StatusIndicator extends StatelessWidget {
  final String state;

  const _StatusIndicator({required this.state});

  @override
  Widget build(BuildContext context) {
    // Define a map to hold styles for different states
    const Map<String, Map<String, dynamic>> stateStyles = {
      'Confermata': {
        'color': Colors.green,
        'icon': Icons.check_circle_rounded,
      },
      'Richiesta': {
        'color': Colors.orange,
        'icon': Icons.warning_rounded, // Changed to warning for 'Richiesta'
      },
      'Rifiutata': {
        'color': Colors.red,
        'icon': Icons.cancel_rounded, // Using cancel for 'Rifiutata'
      },
    };

    // Get the style for the current state, default to orange if state is not found
    final currentStyle = stateStyles[state] ?? stateStyles['Richiesta']!; // Default to 'Richiesta' style if state is unknown

    final Color color = currentStyle['color']!.withOpacity(0.15); // Background color
    final Color textColor = currentStyle['color']!; // Text and Icon color
    final IconData iconData = currentStyle['icon']!; // Icon

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            iconData,
            size: 16,
            color: textColor,
          ),
          const SizedBox(width: 6),
          Text(
            state,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

}

// Widget per il pet
class _PetInfo extends StatelessWidget {
  final String name;

  const _PetInfo({required this.name});

  @override
  Widget build(BuildContext context) {
    return Expanded( // Usa Expanded invece di Row
      child: Row(
        children: [
          Icon(
            Icons.pets_rounded,
            color: Colors.grey[600],
            size: 18,
          ),
          SizedBox(width: 8),
          Expanded( // Aggiungi un altro Expanded
            child: Text(
              name,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// Modifica il widget _PriceTag
class _PriceTag extends StatelessWidget {
  final double price;

  const _PriceTag({required this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 120), // Aggiungi questo
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.deepOrangeAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: FittedBox( // Aggiungi FittedBox
        fit: BoxFit.scaleDown,
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '€${price.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.deepOrangeAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextSpan(
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
