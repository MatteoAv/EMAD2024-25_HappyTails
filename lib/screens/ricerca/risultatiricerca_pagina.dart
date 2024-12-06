import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_tails/screens/ricerca/petsitter_model.dart';
import 'package:happy_tails/screens/ricerca/risultato_card.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Definisci il provider per gestire la selezione delle date
final selectedDateRangeProvider = StateProvider<DateTimeRange?>((ref) {
  return null; // Nessun valore predefinito
});

class RisultatiCercaPage extends ConsumerStatefulWidget {
  const RisultatiCercaPage({super.key});

  @override
  _RisultatiCercaPageState createState() => _RisultatiCercaPageState();
}

class _RisultatiCercaPageState extends ConsumerState<RisultatiCercaPage> {
  List<Map<String, dynamic>> _petSitters = [];
  bool _isLoading = false;
  String selectedAnimal = "";
  String selectedProvince = "";

  @override
  Widget build(BuildContext context) {
    final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
    final selectedDateRange = ref.watch(selectedDateRangeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ricerca Pet Sitter'),
      ),
      body: Column(
        children: [
          // Filters Section (Animal, Location, Date Range)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16.0),
                // Filters Row
                Container(
                  padding: const EdgeInsets.all(12.0),
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
                  ),
                  child: Column(
                    children: [
                      // First Row (Animal Filter and Location)
                      Row(
                        children: [
                          // Animal filter (DropdownButtonFormField)
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedAnimal.isEmpty ? null : selectedAnimal,
                              decoration: InputDecoration(
                                labelText: "Animale",
                                border: OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.pets),
                              ),
                              items: ["Cane", "Gatto", "Uccello","Pesce","Rettile","Roditore"]
                                  .map((animal) => DropdownMenuItem<String>(value: animal, child: Text(animal)))
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    selectedAnimal = value;
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          // Location filter (Combobox/Autocomplete)
                          Expanded(
                            child: Autocomplete<String>(
                              initialValue: TextEditingValue(text: selectedProvince),
                              optionsBuilder: (TextEditingValue textEditingValue) {
                                final List<String> locations = ["Avellino", "Salerno", "Benevento"];
                                if (textEditingValue.text.isEmpty) {
                                  return const Iterable<String>.empty();
                                }
                                return locations.where((location) => location
                                    .toLowerCase()
                                    .contains(textEditingValue.text.toLowerCase()));
                              },
                              fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                                return TextField(
                                  controller: controller,
                                  focusNode: focusNode,
                                  decoration: InputDecoration(
                                    labelText: "Provincia",
                                    border: OutlineInputBorder(),
                                    prefixIcon: const Icon(Icons.location_on),
                                  ),
                                );
                              },
                              onSelected: (String selection) {
                                setState(() {
                                  selectedProvince = selection;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      // Date Range Selector
                      Row(
                        children: [
                          // Date Range Picker
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final dateRange = await showDateRangePicker(
                                  context: context,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2100),
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
                                ? "${selectedDateRange!.duration.inDays} giorni"
                                : "",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      // Search Button
                      Center(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (selectedAnimal.isEmpty || selectedProvince.isEmpty || selectedDateRange == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Per favore, compila tutti i campi prima di proseguire."),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            } else {
                              setState(() {
                                _isLoading = true;
                              });


    try {
      String animalColumn = '';
      switch (selectedAnimal) {
        case 'Cane':
          animalColumn = 'cani';
          break;
        case 'Gatto':
          animalColumn = 'gatti';
          break;
        case 'Uccello':
          animalColumn = 'uccelli';
          break;
        case 'Pesce':
          animalColumn = 'pesci';
          break;
        case 'Rettile':
          animalColumn = 'rettili';
          break;
        case 'Roditore':
          animalColumn = 'roditori';
          break;
        default:
          animalColumn = '';
      }

      if (animalColumn.isNotEmpty) {
        // Query per ottenere i pet sitters
        final response = await Supabase.instance.client
            .from('petsitter')
            .select(
                '''
                *,
                disponibilita(id, data_inizio, data_fine)
                ''')
            .eq('provincia', selectedProvince)
            .eq(animalColumn, true);

        final filteredResults = (response as List).where((petSitter) {
          final disponibilita = petSitter['disponibilita'] as List<dynamic>? ?? [];
          for (final range in disponibilita) {
            final DateTime start = DateTime.parse(range['data_inizio']);
            final DateTime end = DateTime.parse(range['data_fine']);
            if(
                selectedDateRange.start.isBefore(end) && 
                (selectedDateRange.start.isAfter(start) || selectedDateRange.start.isAtSameMomentAs(start)) && 
                selectedDateRange.end.isAfter(start) && 
                (selectedDateRange.end.isBefore(end) ||  selectedDateRange.end.isAtSameMomentAs(end))
              )
              {
                return true; // Intersezione trovata
              }
          }
          return false; // Nessuna disponibilità valida
        }).toList();

        setState(() {
          _petSitters = List<Map<String, dynamic>>.from(filteredResults);
        });
      }
    } catch (e) {
                                print('Errore: $e');
                              } finally {
                                setState(() {
                                  _isLoading = false;
                                });
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            minimumSize: Size(double.infinity, 50),
                          ),
                          child: const Text('Cerca'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Risultati Info Row
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${_petSitters.length} risultati",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          // List of Results
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
                  child: ListView.builder(
                    itemCount: _petSitters.length,
                    itemBuilder: (context, index) {
                      final petSitter = _petSitters[index];

                      final petSitterItem = PetSitter(
                        nome: petSitter['nome'],
                        cognome: petSitter['cognome'],
                        email: petSitter['email'],
                        provincia: petSitter['provincia'],
                        imageUrl: petSitter['image_url'] ??
                            'https://images.contentstack.io/v3/assets/blt6f84e20c72a89efa/blt2577cbc57a834982/6363df6833df8e693d1e44c7/img-pet-sitter-download-header.jpg',
                      );

                      return VerticalCard(item: petSitterItem);
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
