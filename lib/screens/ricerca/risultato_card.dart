import 'package:flutter/material.dart';
import 'package:happy_tails/screens/ricerca/petsitter_model.dart';
import 'package:happy_tails/app/routes.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<double> fetchPetSitterScore(int petsitterId) async {
  final supabase = Supabase.instance.client;

  final response = await supabase.rpc('get_petsitterscore', params: {
    'petsitter_id_input': petsitterId,
  });

  print('Punteggio ricevuto per Petsitter ID $petsitterId: ${response.toString()}');
  return response?.toDouble() ?? 0.0;  // Restituisce il punteggio o 0 se è null
}

Future<int> fetchPetSitterReview(int petsitterId) async {
  final supabase = Supabase.instance.client;

  final response = await supabase.rpc('get_petsitterreviewcount', params: {
    'petsitter_id_input': petsitterId,
  });

  print('Recensioni per Petsitter ID $petsitterId: ${response.toString()}');
  return response as int;  
}
//Il widget del singolo risultato di ricerca
//da fare: usare la harverstine formula (in un modo efficiente, non è la formula diretta) per calcolare la distanza dalla latitudine,longitudine del pet sitter con quella selezionata nella ricerca
class VerticalCard extends StatelessWidget {
    final PetSitter item;
  final List disponibilita;
  final DateTimeRange dateRange;

  const VerticalCard({Key? key, required this.item, required this.disponibilita, required this.dateRange}) : super(key: key);

  // ... existing properties ...

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 200),
          tween: Tween(begin: 1.0, end: 1.0),
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: child,
            );
          },
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: Colors.grey.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
        List<dynamic> items = [item, disponibilita, dateRange];
        // Print ID to debug
        print('ID del petsitter RISULTATO_CARD: ${item.id}');
        print('Data passata: ${dateRange}');
        Navigator.pushNamed(
          context,
          AppRoutes.sitterpage,
          arguments: items,// Pass the pet sitter
        );
      },
              highlightColor: Colors.transparent,
              splashColor: theme.colorScheme.primary.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Image
                    Hero(
                      tag: item.id,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: DecorationImage(
                            image: NetworkImage(item.imageUrl),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Availability Badge
                            if (1>0)
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade600,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Verificato',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 20),

                    // Main Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Name
                                    Text(
                                      '${item.nome}',
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: -0.25,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),

                                    const SizedBox(height: 4),

                                    // Location
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on_outlined,
                                          size: 16,
                                          color: theme.colorScheme.outline,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${item.comune}',
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: theme.colorScheme.outline,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Price
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${NumberFormat('0.00').format(item.prezzo)}€',
                                    style: theme.textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  Text(
                                    'per day',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.outline,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Rating Row
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      item.rating.toString(),
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.star_rounded,
                                      color: Colors.amber.shade600,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${item.numeroRecensioni} recensioni',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Pet Types
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (item.cani)
                                _PetTypeChip(
                                  icon: Icons.pets,
                                  label: 'Cani',
                                  color: Colors.brown.shade400,
                                ),
                              if (item.gatti)
                                _PetTypeChip(
                                  icon: Icons.catching_pokemon,
                                  label: 'Gatti',
                                  color: Colors.blueGrey.shade400,
                                ),
                              // Add other pet types...
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Navigation Arrow
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 20,
                      color: theme.colorScheme.outline.withOpacity(0.5),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PetTypeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _PetTypeChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}

String formatDistance(int distanceInMeters) {
  // Convert meters to kilometers
  double distanceInKm = distanceInMeters / 1000;

  // Determine the appropriate format based on the distance
  if (distanceInKm < 1) {
    return "<1 km";
  } else if (distanceInKm < 10) {
    // Use one decimal place for distances less than 10 km
    return "${distanceInKm.toStringAsFixed(1).replaceAll('.', ',')} km";
  } else {
    // Round to the nearest whole number for distances 10 km or more
    return "${distanceInKm.round()} km";
  }
}