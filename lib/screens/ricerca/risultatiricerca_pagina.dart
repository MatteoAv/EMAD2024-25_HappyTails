import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_tails/screens/ricerca/petsitter_model.dart';
import 'package:happy_tails/screens/ricerca/risultato_card.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:happy_tails/screens/ricerca/locations.dart';


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
  String selectedLocation = "";

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
                              items: ["Cane", "Gatto", "Uccello", "Pesce", "Rettile", "Roditore"]
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
                              initialValue: TextEditingValue(text: selectedLocation),
                              optionsBuilder: (TextEditingValue textEditingValue) {
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
                                    labelText: "Comune",
                                    border: OutlineInputBorder(),
                                    prefixIcon: const Icon(Icons.location_on),
                                  ),
                                );
                              },
                              onSelected: (String selection) {
                                setState(() {
                                  selectedLocation = selection;
                                });
                              },
                            ),
                          )

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
                            if (selectedAnimal.isEmpty || selectedLocation.isEmpty || selectedDateRange == null) {
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
                                  // The selected `Comune` sent from Flutter
                                  // Step 1: Fetch coordinates for the selected `Comune`
                                  final comuneResponse = await Supabase.instance.client.rpc(
                                    'get_comune_coordinates',
                                    params: {
                                      'comune_name': selectedLocation, // Pass the parameter
                                    },
                                  );

                                  if (comuneResponse == null) {
                                    print("Error: RPC call returned null.");
                                  } else if (comuneResponse is List && comuneResponse.isNotEmpty) {
                                    print("RPC Response: $comuneResponse");
                                    print("Selected Location: $selectedLocation");
                                    print("RPC Response: $comuneResponse");
                                  }

                                  print(comuneResponse);

                                  // Then extract coordinates
                                  final double comuneLongitude = comuneResponse[0]['longitude'] as double;
                                  final double comuneLatitude = comuneResponse[0]['latitude'] as double;
                                  print("Comune Longitude: $comuneLongitude, Comune Latitude: $comuneLatitude");

                                  // Step 2: Query the nearest pet sitters
                                  final petsitterResponse = await Supabase.instance.client.rpc(
                                    'get_nearest_petsitters',
                                    params: {
                                      'input_longitude': comuneLongitude,
                                      'input_latitude': comuneLatitude,
                                      'animal_column': animalColumn
                                    },
                                  );
                                  print(petsitterResponse);

                                  final filteredResults = (petsitterResponse as List).where((petSitter) {
                                    final disponibilita = petSitter['disponibilita'] as List? ?? [];

                                    // If no availability, return true
                                    if (disponibilita.isEmpty) return true;

                                    return disponibilita.any((range) {
                                      final DateTime start = DateTime.parse(range['data_inizio']);
                                      final DateTime end = DateTime.parse(range['data_fine']);

                                      // Check if the selected date range overlaps with the availability
                                      return (selectedDateRange.end.isBefore(start) ||
                                          selectedDateRange.start.isAfter(end));
                                    });
                                  }).toList();
                                  print(filteredResults);

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
                // Left: Results count
                Text(
                  "${_petSitters.length} risultati",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18, // Bigger text size
                  ),
                ),
                // Right: Sort dropdown
                Container(
                  constraints: const BoxConstraints(
                    minWidth: 80, // Minimum width to fit the "Ordina" text
                    maxWidth: 100, // Slightly restrict the maximum width
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0), // Compact padding
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0), // Rounded corners
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isDense: true, // Reduce the height of the dropdown
                      isExpanded: true, // Allow text and icon to fit within the container
                      hint: const Text(
                        "Ordina",
                        style: TextStyle(fontSize: 14), // Text size is good
                      ),
                      icon: const Icon(Icons.arrow_drop_down, size: 16), // Smaller dropdown icon
                      items: <String>["Alphabetical", "Date", "Popularity"]
                          .map((String value) => DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              ))
                          .toList(),
                      onChanged: (String? newValue) {
                        // Handle sorting logic here
                        print("Selected sorting method: $newValue");
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          // List of Results
          Expanded(
  child: _isLoading
      ? const Center(child: CircularProgressIndicator())
      : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _petSitters.length,
              itemBuilder: (context, index) {
                final petSitter = _petSitters[index];

                // Convert data to a PetSitter object
                final petSitterItem = PetSitter(
                  id: petSitter['id'] as int,
                  nome: petSitter['nome'],
                  cognome: petSitter['cognome'],
                  email: petSitter['email'],
                  provincia: petSitter['provincia'],
                  imageUrl: petSitter['image_url'] ??
                      'https://images.contentstack.io/v3/assets/blt6f84e20c72a89efa/blt2577cbc57a834982/6363df6833df8e693d1e44c7/img-pet-sitter-download-header.jpg',
                  distanza: petSitter['distance'].toInt(),

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
