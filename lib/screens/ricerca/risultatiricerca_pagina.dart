import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_tails/screens/ricerca/petsitter_model.dart';
import 'package:happy_tails/screens/ricerca/risultati_provider.dart';
import 'package:happy_tails/screens/ricerca/risultato_card.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:happy_tails/screens/ricerca/locations.dart';
import 'package:happy_tails/screens/ricerca/risultati_repository.dart';

final searchRepository = SearchRepository();
// Definisci il provider per gestire la selezione delle date
final selectedDateRangeProvider = StateProvider<DateTimeRange?>((ref) {
  return null; // Nessun valore predefinito
});
const animalMap = {
  'Cane': 'cani',
  'Gatto': 'gatti',
  'Uccello': 'uccelli',
  'Pesce': 'pesci',
  'Rettile': 'rettili',
  'Roditore': 'roditori',
};
class RisultatiCercaPage extends ConsumerStatefulWidget {
  const RisultatiCercaPage({super.key});

  @override
  _RisultatiCercaPageState createState() => _RisultatiCercaPageState();
}
class _PremiumDropdown extends StatelessWidget {
  final String? value;
  final List<String> items;
  final IconData icon;
  final String hint;
  final ValueChanged<String?> onChanged;

  const _PremiumDropdown({
    required this.value,
    required this.items,
    required this.icon,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.outline),
        labelText: hint,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 2),
      ),
      dropdownColor: Theme.of(context).colorScheme.surface,
      icon: Icon(Icons.arrow_drop_down_rounded,
        color: Theme.of(context).colorScheme.outline),
      style: Theme.of(context).textTheme.bodyLarge,
      items: items.map((animal) => DropdownMenuItem<String>(
        value: animal,
        child: Text(animal),
      )).toList(),
      onChanged: onChanged,
    );
  }
}

class _RisultatiCercaPageState extends ConsumerState<RisultatiCercaPage> {
  
  List<Map<String, dynamic>> _petSitters = [];
  bool _isLoading = false;
  bool cliccato = false;
  String? selectedAnimal;
  String selectedLocation = "";

  @override
  Widget build(BuildContext context) {
    final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
    final selectedDateRange = ref.watch(selectedDateRangeProvider);

    return Scaffold(
     
      body: Column(
        children: [
          // Filters Section (Animal, Location, Date Range)
          Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 24),
      Card(
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),

          
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Animal & Location Row
              Row(
                children: [
                  // In your state management (where selectedAnimal is defined)
                  // In your DropdownButtonFormField
                  Expanded(
  child: DropdownButtonFormField<String>(
    value: selectedAnimal,
    decoration: InputDecoration(
      labelText: "Animale",
      filled: true,
      prefixIcon: Icon(
        Icons.pets_rounded,
        color: Theme.of(context).colorScheme.outline,
      ),
      suffixIcon: Padding(
        padding: const EdgeInsets.only(right: 8), // Control right spacing
        child: Icon(
          Icons.arrow_drop_down_rounded,
          color: Theme.of(context).colorScheme.outline,
          size: 24,
        ),
      ),
     
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.error,
          width: 1.5,
        ),
      ),
      // ... keep other border properties from previous version
    ),
    dropdownColor: Theme.of(context).colorScheme.surface,
    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
      color: Theme.of(context).colorScheme.onSurface,
    ),
    icon: const SizedBox.shrink(), // Hide default icon
    isExpanded: true, // Ensure text doesn't overflow
    items: [
      DropdownMenuItem<String>(
        value: null,
        enabled: false,
        child: Text(
          "Seleziona animale",
          style: TextStyle(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      ),
      ...animalMap.keys.map((String animal) {
        return DropdownMenuItem<String>(
          value: animal,
          child: Text(
            animal,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        );
      }),
    ],
    onChanged: (value) {
      if (value != null) {
        cliccato = false;
        setState(() => selectedAnimal = value);
      }
    },
    validator: (value) => value == null ? 'Seleziona un animale' : null,
  ),
),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Autocomplete<String>(
                      initialValue: TextEditingValue(text: selectedLocation),
                      optionsBuilder: (textEditingValue) {
                        if (textEditingValue.text.isEmpty) return const Iterable.empty();
                        return locations.where((loc) => 
                          loc.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                      },
                      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                        return TextFormField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.location_on_outlined, 
                              color: Theme.of(context).colorScheme.outline),
                            labelText: "Comune",
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        );
                      },
                      onSelected: (selection) {
                        cliccato = false;
                        setState(() => selectedLocation = selection);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Date Range Picker
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () async {
                    cliccato = false;
                    final range = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                      initialDateRange: selectedDateRange,
                
                    );
                    if (range != null) {
                      ref.read(selectedDateRangeProvider.notifier).state = range;
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_month_rounded,
                              color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  selectedDateRange == null 
                                    ? "Seleziona date" 
                                    : "${_dateFormat.format(selectedDateRange.start)} - ${_dateFormat.format(selectedDateRange.end)}",
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                if (selectedDateRange != null)
                                  Text(
                                    "${selectedDateRange.duration.inDays} ${selectedDateRange.duration.inDays == 1 ? 'giorno' : 'giorni'}",
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.outline),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        Icon(Icons.chevron_right_rounded,
                          color: Theme.of(context).colorScheme.outline),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Search Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    cliccato = true;
                    if (selectedAnimal is Null || selectedLocation.isEmpty || selectedDateRange == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text("Per favore, compila tutti i campi prima di proseguire."),
                          backgroundColor: Theme.of(context).colorScheme.error,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    } else {
                      setState(() => _isLoading = true);
                      
                      try {
                        final searchResults = await searchRepository.searchPetSitters(
                          [selectedAnimal.toString()], 
                          selectedLocation, 
                          selectedDateRange
                        );
                        setState(() => _petSitters = List<Map<String,dynamic>>.from(searchResults));
                      } catch (e) {
                        print('Errore: $e');
                      } finally {
                        setState(() => _isLoading = false);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.orangeAccent,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search_rounded, size: 20,color: Color.fromARGB(255, 253, 238, 213),),
                            const SizedBox(width: 8),
                            Text(
                              'Cerca',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                                color: const Color.fromARGB(255, 253, 238, 213)
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
    ],
  ),
),
          // Risultati Info Row
          cliccato 
          ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Results count
                _petSitters.isNotEmpty

                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${_petSitters.length} ${_petSitters.length == 1 ? 'risultato' : 'risultati'}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18, 
                        ),
                      ),

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
                           child: Consumer(
                            builder: (context, ref, _) {
                              return DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isDense: true,
                                  isExpanded: true,
                                  hint: const Text("Ordina"),
                                  value: ref.watch(sortProvider), // Show current selection
                                  icon: const Icon(Icons.arrow_drop_down, size: 16),
                                  items: <String>["Alfabetico", "Distanza", "Popolarità"]
                                      .map((String value) => DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          ))
                                      .toList(),
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      ref.read(sortProvider.notifier).state = newValue;
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                        )
                    ],
                  )
                
                :  Column(
                    children: [
                      SizedBox(height: 100),
                      Container(
                        height: 100, // Adjust height as needed
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.sentiment_dissatisfied, color: Colors.red),
                            SizedBox(height: 8),
                            Text(
                              "Nessun risultato trovato",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18, // Text size
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

              ],
            ),
          )

          //Se il pulsante di ricerca non è mai cliccato la schermata risulta vuota
          : Padding(padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),),



          // List of Results
          Expanded(
          child: Consumer(
            builder: (context, ref, _) {
              final sortBy = ref.watch(sortProvider);
              final sortedSitters = sortPetSitters(_petSitters, sortBy);

              return _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: sortedSitters.length,
                      itemBuilder: (context, index) {

                      final petSitter = sortedSitters[index];
                        print(petSitter['rating']);
      print(petSitter['id']);

                      

                // Convert data to a PetSitter object
                final petSitterItem = PetSitter(
                  id: petSitter['id'] as int,
                  nome: petSitter['nome'],
                  cognome: petSitter['cognome'],
                  email: petSitter['email'],
                  provincia: petSitter['provincia'],
                  comune: petSitter['comune'],
                  imageUrl: petSitter['imageurl'] ??
                      'https://images.contentstack.io/v3/assets/blt6f84e20c72a89efa/blt2577cbc57a834982/6363df6833df8e693d1e44c7/img-pet-sitter-download-header.jpg',
                  cani: petSitter['cani'],
                  gatti: petSitter['gatti'],
                  uccelli: petSitter['uccelli'],
                  pesci: petSitter['pesci'],
                  rettili: petSitter['rettili'],
                  roditori: petSitter['roditori'],
                  distanza: petSitter['distance'].toInt(),
                  prezzo: petSitter['prezzo'].toDouble(),
                  numeroRecensioni: petSitter['numeroRecensioni'],
                  rating:petSitter['rating']

                );

                final data = selectedDateRange;
                
                return VerticalCard(item: petSitterItem, disponibilita: petSitter['disponibilita'] ?? [], dateRange: data!,);
              },
            );},),)

        ],
      ),
    );
  }
}