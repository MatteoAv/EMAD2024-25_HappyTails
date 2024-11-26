import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:happy_tails/screens/ricerca/risultato_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_tails/screens/ricerca/risultati_provider.dart';

import 'package:intl/intl.dart';



import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class RisultatiCercaPage extends ConsumerWidget {
  const RisultatiCercaPage({Key? key}) : super(key: key);

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
          // Custom Header Section (Replaced with the advanced header)
          const _AdvancedHeader(),

          // Results Info Row
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
  const _AdvancedHeader({Key? key}) : super(key: key);

  @override
  State<_AdvancedHeader> createState() => _AdvancedHeaderState();
}

class _AdvancedHeaderState extends State<_AdvancedHeader> {
  DateTimeRange? _selectedDateRange;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                        decoration: InputDecoration(
                          labelText: "Cane",
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
                          // Handle animal selection
                        },
                      ),
                    ),
                    const SizedBox(width: 16.0), // Reduced spacing
                    // Location filter (Combobox/Autocomplete)
                    Expanded(
                      child: Autocomplete<String>(
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
                          // Handle location selection
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
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                            initialDateRange: _selectedDateRange ??
                                DateTimeRange(
                                  start: DateTime.now(),
                                  end: DateTime.now().add(const Duration(days: 7)),
                                ),
                          );
                          if (dateRange != null) {
                            setState(() {
                              _selectedDateRange = dateRange;
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
                                _selectedDateRange == null
                                    ? "Select Date Range"
                                    : "${_dateFormat.format(_selectedDateRange!.start)} - ${_dateFormat.format(_selectedDateRange!.end)}",
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    // Number of Days
                    Text(
                      _selectedDateRange == null
                          ? "0 giorni"
                          : "${_selectedDateRange!.duration.inDays} giorni",
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
