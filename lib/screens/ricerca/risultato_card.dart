import 'package:flutter/material.dart';
import 'package:happy_tails/screens/ricerca/petsitter_model.dart';
import 'package:happy_tails/app/routes.dart';


//Il widget del singolo risultato di ricerca
//da fare: usare la harverstine formula (in un modo efficiente, non è la formula diretta) per calcolare la distanza dalla latitudine,longitudine del pet sitter con quella selezionata nella ricerca
class VerticalCard extends StatelessWidget {
  final PetSitter item;

  const VerticalCard({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
  return Card(
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    elevation: 3,
    child: InkWell(
      onTap: () {
        // Print ID to debug
        print('ID del petsitter RISULTATO_CARD: ${item.id}');
        Navigator.pushNamed(
          context,
          AppRoutes.sitterpage,
          arguments: item, // Pass the pet sitter
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Profile Avatar (1/4 of horizontal space)
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.25,
              child: CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(item.imageUrl),
                backgroundColor: Colors.grey[200],
              ),
            ),
            
            // Content Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // City (above name)
                    Text(
                      '${item.provincia}, ${formatDistance(item.distanza)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.black,
                          ),
                    ),
                    
                    // Name and Surname
                    Text(
                      '${item.nome} ${item.cognome}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    
                    // Star Rating
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          index < 4 ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 20,
                        ),
                      ),
                    ),
                    
                    // Happy People Text
                    Text(
                      '10 persone felici',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Right Column: Price and Arrow
            Column(
              mainAxisSize: MainAxisSize.min, // Shrinks to fit content
              children: [
                // Price Text
                Text(
                  '26\$/d',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8), // Space between text and icon
                
                // Right Arrow
                Icon(
                  Icons.chevron_right,
                  color: Colors.orange[600],
                  size: 27,
                ),
              ],
            ),
          ],
        ),
      ),
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