import 'package:flutter/material.dart';
import 'package:happy_tails/screens/ricerca/petsitter_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SearchRepository {
  Future<List<dynamic>> searchPetSitters(
    List<String> selectedAnimals,
    String selectedLocation,
    DateTimeRange selectedDateRange,
  ) async {
    // Map animal types to database column names
    final animalColumnMap = {
      'Cane': 'cani',
      'Gatto': 'gatti',
      'Uccello': 'uccelli',
      'Pesce': 'pesci',
      'Rettile': 'rettili',
      'Roditore': 'roditori',
    };

    // Get the corresponding column names for the selected animals
    final selectedColumns = selectedAnimals
        .map((animal) => animalColumnMap[animal])
        .where((column) => column != null)
        .toList();

    if (selectedColumns.isEmpty) {
      return []; // Return an empty list if no valid animal types are selected
    }

    // Fetch coordinates for the selected location (Comune)
    final comuneResponse = await Supabase.instance.client.rpc(
      'get_comune_coordinates',
      params: {
        'comune_name': selectedLocation,
      },
    );

    if (comuneResponse == null || comuneResponse.isEmpty || comuneResponse is! List) {
      return []; // Return an empty list if location coordinates are not found
    }

    final double comuneLongitude = comuneResponse[0]['longitude'] as double;
    final double comuneLatitude = comuneResponse[0]['latitude'] as double;

    // Decide RPC based on the number of selected animal types
    final rpcName = _determineRpc(selectedColumns.length);

    // Query the pet sitters
    final petsitterResponse = await Supabase.instance.client.rpc(
      rpcName,
      params: {
        'input_longitude': comuneLongitude,
        'input_latitude': comuneLatitude,
        'animal_columns': selectedColumns,
      },
    );

    if (petsitterResponse == null || petsitterResponse.isEmpty || petsitterResponse is! List) {
      return []; // Return an empty list if no pet sitters are found
    }
    print(petsitterResponse);

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

  // Determines the appropriate RPC based on the number of selected animal types
  String _determineRpc(int numberOfSelectedAnimals) {
    if (numberOfSelectedAnimals == 1) {
      return 'get_nearest_petsitters_single';
    } else if (numberOfSelectedAnimals == 2) {
      return 'get_nearest_petsitters_double';
    } else {
      return 'get_nearest_petsitters_multiple';
    }
  }
}




/*
CREATE OR REPLACE FUNCTION get_nearest_petsitters_double(
 input_longitude DOUBLE PRECISION,
 input_latitude DOUBLE PRECISION,
 animal_columns TEXT[]
)
RETURNS TABLE (
    id INT,
    nome VARCHAR,
    cognome VARCHAR,
    email VARCHAR,
    provincia VARCHAR,
    imageurl VARCHAR,
    cani BOOLEAN,
    gatti BOOLEAN,
    uccelli BOOLEAN,
    pesci BOOLEAN,
    rettili BOOLEAN,
    roditori BOOLEAN,
    prezzo REAL,  -- Changed to REAL as you specified
    comune TEXT,
    posizione GEOGRAPHY,
    distance DOUBLE PRECISION,
    disponibilita JSONB
) AS $$

DECLARE
    query TEXT;
BEGIN
    query := format(
        '
        SELECT
            p.id,
            p.nome,
            p.cognome,
            p.email,
            p.provincia,
            p.imageurl,
            p.cani,
            p.gatti,
            p.uccelli,
            p.pesci,
            p.rettili,
            p.roditori,
            p.prezzo_giornaliero,
            p."Comune",
            p."Posizione",
            ST_Distance(p."Posizione"::geography, ST_SetSRID(ST_Point(%L, %L)::geography, 4326)) AS distance,
            (
                SELECT jsonb_agg(
                    jsonb_build_object(
                        ''id'', d.id,
                        ''data_inizio'', d.data_inizio,
                        ''data_fine'', d.data_fine
                    )
                )
                FROM indisponibilita d
                WHERE d.id = p.id
            ) AS disponibilita
        FROM petsitter p
        WHERE p.%I = TRUE OR p.%I = TRUE
        ORDER BY distance ASC
        LIMIT 10',
        input_longitude, input_latitude, animal_columns[1], animal_columns[2]
    );

 RETURN QUERY EXECUTE query;
END;
$$ LANGUAGE plpgsql;

*/

/*
CREATE OR REPLACE FUNCTION get_nearest_petsitters_multiple(
 input_longitude DOUBLE PRECISION,
 input_latitude DOUBLE PRECISION,
 animal_columns TEXT[]
)
RETURNS TABLE (
    id INT,
    nome VARCHAR,
    cognome VARCHAR,
    email VARCHAR,
    provincia VARCHAR,
    imageurl VARCHAR,
    cani BOOLEAN,
    gatti BOOLEAN,
    uccelli BOOLEAN,
    pesci BOOLEAN,
    rettili BOOLEAN,
    roditori BOOLEAN,
    prezzo REAL,  -- Changed to REAL as you specified
    comune TEXT,
    posizione GEOGRAPHY,
    distance DOUBLE PRECISION,
    disponibilita JSONB
) AS $$

DECLARE
    where_clause TEXT;
    query TEXT;
BEGIN
-- Construct the dynamic WHERE clause
    SELECT string_agg(format('p.%I = TRUE', col), ' OR ')
    INTO where_clause
    FROM unnest(animal_columns) AS col;
    query := format(
        '
        SELECT
            p.id,
            p.nome,
            p.cognome,
            p.email,
            p.provincia,
            p.imageurl,
            p.cani,
            p.gatti,
            p.uccelli,
            p.pesci,
            p.rettili,
            p.roditori,
            p.prezzo_giornaliero,
            p."Comune",
            p."Posizione",
            ST_Distance(p."Posizione"::geography, ST_SetSRID(ST_Point(%L, %L)::geography, 4326)) AS distance,
            (
                SELECT jsonb_agg(
                    jsonb_build_object(
                        ''id'', d.id,
                        ''data_inizio'', d.data_inizio,
                        ''data_fine'', d.data_fine
                    )
                )
                FROM indisponibilita d
                WHERE d.id = p.id
            ) AS disponibilita
        FROM petsitter p
        WHERE %s
        ORDER BY distance ASC
        LIMIT 10',
        input_longitude, input_latitude, where_clause
    );

 RETURN QUERY EXECUTE query;
END;
$$ LANGUAGE plpgsql;

*/

/*
SELECT 
  ST_X(ST_Transform("posizione"::geometry, 4326)) AS longitude,
  ST_Y(ST_Transform("posizione"::geometry, 4326)) AS latitude
FROM get_nearest_petsitters_multiple(14.79528841, 40.91404698, ARRAY['cani','gatti','uccelli','roditori']);

SELECT 
  ST_X(ST_Transform("posizione"::geometry, 4326)) AS longitude,
  ST_Y(ST_Transform("posizione"::geometry, 4326)) AS latitude
FROM get_nearest_petsitters_single(14.79528841, 40.91404698, ARRAY['cani']);

SELECT 
  ST_X(ST_Transform("posizione"::geometry, 4326)) AS longitude,
  ST_Y(ST_Transform("posizione"::geometry, 4326)) AS latitude
FROM get_nearest_petsitters(14.79528841, 40.91404698, 'cani');

*/