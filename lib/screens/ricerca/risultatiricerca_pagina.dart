import 'package:flutter/material.dart';
import 'package:happy_tails/screens/ricerca/risultato_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_tails/screens/ricerca/risultati_provider.dart';
import 'package:intl/intl.dart';

class RisultatiCercaPage extends ConsumerWidget {
  RisultatiCercaPage(this.animale, this.provincia, this.DateStart, this.DateEnd, {super.key});

  final String animale;
  final String provincia;
  final DateTime DateStart;
  final DateTime DateEnd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardListAsyncValue = ref.watch(cardListProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous page
          },
        ),
        title: const Text('Risultati di ricerca'),
      ),
      body: Column(
        children: [
          // Pass parameters to the advanced header
          _AdvancedHeader(
            animale: animale,
            provincia: provincia,
            DateStart: DateStart,
            DateEnd: DateEnd,
          ),

          // Results Info Row
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left: Results count
                const Text(
                  "17 risultati",
                  style: TextStyle(
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
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Results List
          Expanded(
            child: cardListAsyncValue.when(
              data: (cards) {
                if (cards.isEmpty) {
                  return const Center(child: Text('No cards available'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: cards.length,
                  itemBuilder: (context, index) {
                    return VerticalCard(item: cards[index]);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdvancedHeader extends StatefulWidget {
  const _AdvancedHeader({
    Key? key,
    required this.animale,
    required this.provincia,
    required this.DateStart,
    required this.DateEnd,
  }) : super(key: key);

  final String animale;
  final String provincia;
  final DateTime DateStart;
  final DateTime DateEnd;

  @override
  State<_AdvancedHeader> createState() => _AdvancedHeaderState();
}

class _AdvancedHeaderState extends State<_AdvancedHeader> {
  late String selectedAnimal;
  late String selectedProvince;
  late DateTimeRange selectedDateRange;

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    selectedAnimal = widget.animale;
    selectedProvince = widget.provincia;
    selectedDateRange = DateTimeRange(start: widget.DateStart, end: widget.DateEnd);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                        value: selectedAnimal,
                        decoration: InputDecoration(
                          labelText: "Pet",
                          border: OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.pets),
                        ),
                        items: ["Cane", "Gatto", "Uccello"]
                            .map((animal) => DropdownMenuItem<String>(
                                  value: animal,
                                  child: Text(animal),
                                ))
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
                    const SizedBox(width: 16.0), // Reduced spacing
                    // Location filter (Combobox/Autocomplete)
                    Expanded(
                      child: Autocomplete<String>(
                        initialValue: TextEditingValue(text: selectedProvince),
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          final List<String> locations = [
                            "Monreale, PA",
                            "Palermo, Italy",
                            "Rome, Italy",
                            "Milan, Italy",
                          ];
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
                              labelText: "Location",
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
            firstDate: DateTime.now(), // Prevent past date selection
            lastDate: DateTime(2100),
            initialDateRange: selectedDateRange,
          );
          if (dateRange != null) {
            setState(() {
              selectedDateRange = dateRange;
            });
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
                "${_dateFormat.format(selectedDateRange.start)} - ${_dateFormat.format(selectedDateRange.end)}",
              ),
            ],
          ),
        ),
      ),
    ),
    const SizedBox(width: 16.0),
    // Number of Days
    Text(
      "${selectedDateRange.duration.inDays} giorni",
      style: const TextStyle(fontWeight: FontWeight.bold),
    ),
  ],
),

              ],
            ),
          ),
        ],
      ),
    );
  }
}
