import 'package:flutter/material.dart';
import 'package:happy_tails/screens/ricerca/petsitter_model.dart';

class ProfiloPetsitter extends StatefulWidget {
  const ProfiloPetsitter({super.key});

  @override
  _ProfiloPetsitterState createState() => _ProfiloPetsitterState();
}

class _ProfiloPetsitterState extends State<ProfiloPetsitter> {
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  TimeOfDay? startTime;

  final List<Map<String, dynamic>> reviews = [
    {
      'author': 'Mario Bianchi',
      'rating': 5,
      'comment': 'Servizio eccellente! Giovanni è stato molto gentile con il mio cane.',
      'date': '12/12/2024',
      'profilePicture': 'assets/profile1.png',
    },
    {
      'author': 'Lucia Verdi',
      'rating': 4,
      'comment': 'Ottima esperienza, ma un po\' caro.',
      'date': '11/12/2024',
      'profilePicture': 'assets/profile2.png',
    },
    {
      'author': 'Giuseppe Rossi',
      'rating': 3,
      'comment': 'Giovanni ha fatto un buon lavoro, ma può migliorare la puntualità.',
      'date': '10/12/2024',
      'profilePicture': 'assets/profile3.png',
    },
  ];

  // Funzione per selezionare la data di inizio
  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedStartDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedStartDate) {
      setState(() {
        selectedStartDate = picked;
        selectedEndDate = null;
      });
    }
  }

  // Funzione per selezionare la data di fine
  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedEndDate ?? selectedStartDate!.add(const Duration(days: 1)),
      firstDate: selectedStartDate!,
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedEndDate) {
      setState(() {
        selectedEndDate = picked;
      });
    }
  }

  // Funzione per selezionare l'orario di inizio
  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: startTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != startTime) {
      setState(() {
        startTime = picked;
      });
    }
  }

  double calculateAverageRating() {
    if (reviews.isEmpty) return 0.0;
    double sum = reviews.fold(0.0, (total, review) => total + review['rating']);
    return sum / reviews.length;
  }
  
  @override
  Widget build(BuildContext context) {

    final PetSitter petsitter = ModalRoute.of(context)!.settings.arguments as PetSitter;
    final int petsitterId = petsitter.id;

    /*
    print(ModalRoute.of(context)?.settings.arguments); 
    final int? petsitterId = ModalRoute.of(context)?.settings.arguments as int?; // Controlla se l'argomento è valido
    print("ID del petsitter: ${petsitterId}");
    */

    print("ID del petsitter PETSITTER_PAGE: $petsitterId");

    double averageRating = calculateAverageRating();
    int fullStars = averageRating.floor();
    bool hasHalfStar = (averageRating - fullStars) >= 0.5;

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
              // Sezione del profilo
              Row(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: AssetImage('assets/puppies.png'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Nome: Giovanni Rossi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Città: Roma',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Form di prenotazione
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Prenota il pet-sitter per i giorni di cui hai bisogno, seleziona data e ora e conferma la prenotazione',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.black),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () => _selectStartDate(context),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                    ),
                                    child: Text(
                                      selectedStartDate == null
                                          ? 'Data Inizio'
                                          : '${selectedStartDate!.day}/${selectedStartDate!.month}/${selectedStartDate!.year}',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () => _selectEndDate(context),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                    ),
                                    child: Text(
                                      selectedEndDate == null
                                          ? 'Data Fine'
                                          : '${selectedEndDate!.day}/${selectedEndDate!.month}/${selectedEndDate!.year}',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Icon(Icons.access_time, color: Colors.black),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _selectStartTime(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: Text(
                                startTime == null
                                    ? 'Orario di inizio'
                                    : '${startTime!.hour}:${startTime!.minute.toString().padLeft(2, '0')}',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Prenotazione Confermata'),
                              content: const Text('La tua prenotazione è stata effettuata con successo!'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text('Prenota'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Sezione delle recensioni


              // Overall rating (Valutazione Complessiva)
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
                      'Basato su ${reviews.length} recensioni',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
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
                          backgroundImage: AssetImage(review['profilePicture']),
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
                                    review['author'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    review['date'],
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: List.generate(
                                  5,
                                  (index) => Icon(
                                    index < review['rating']
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.orange,
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                review['comment'],
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
