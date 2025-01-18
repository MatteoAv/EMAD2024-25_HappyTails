import 'package:flutter/material.dart';
import 'package:happy_tails/screens/ricerca/petsitter_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SearchRepository {
  Future<List<dynamic>> searchPetSitters(
    String selectedAnimal,
    String selectedLocation,
    DateTimeRange selectedDateRange,
  ) async {
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
      // Fetch coordinates for the selected `Comune`
      final comuneResponse = await Supabase.instance.client.rpc(
        'get_comune_coordinates',
        params: {
          'comune_name': selectedLocation,
        },
      );

      if (comuneResponse != null && comuneResponse is List && comuneResponse.isNotEmpty) {
        final double comuneLongitude = comuneResponse[0]['longitude'] as double;
        final double comuneLatitude = comuneResponse[0]['latitude'] as double;

        // Query the nearest pet sitters
        final petsitterResponse = await Supabase.instance.client.rpc(
          'get_nearest_petsitters',
          params: {
            'input_longitude': comuneLongitude,
            'input_latitude': comuneLatitude,
            'animal_column': animalColumn,
          },
        );

        // Filter results based on date availability
        return (petsitterResponse as List).where((petSitter) {
          final disponibilita = petSitter['disponibilita'] as List? ?? [];

          if (disponibilita.isEmpty) return true;

          return disponibilita.any((range) {
            final DateTime start = DateTime.parse(range['data_inizio']);
            final DateTime end = DateTime.parse(range['data_fine']);

            return (selectedDateRange.end.isBefore(start) ||
                selectedDateRange.start.isAfter(end));
          });
        }).toList();
      }
    }

    return []; // Return an empty list if no results are found
  }
}