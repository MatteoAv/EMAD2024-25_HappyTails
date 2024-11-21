import 'package:flutter/material.dart';
import 'package:happy_tails/screens/ricerca/petsitter_model.dart';


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
        onTap: () {/* Navigate to profile page */},
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
                        item.citta,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
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
                        '10 people happy',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Right Arrow
              Icon(
                Icons.chevron_right,
                color: Colors.grey[600],
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}