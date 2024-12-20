import 'package:flutter/material.dart';

class bookingCard extends StatelessWidget{

  final int id;
  final String bookingBegin;
  final String bookingEnd;
  final double bookPrice;
  final String bookState;


  const bookingCard({
      Key? key,
      required this.id,
      required this.bookingBegin,
      required this.bookingEnd,
      required this.bookPrice,
      required this.bookState,
    }): super(key : key);

  @override
  Widget build (BuildContext context){
    return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 30),
                  child: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.deepOrange[50],
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      splashColor: Colors.deepOrange[100],
                      onTap: () {
                      // Gestisci l'interazione
                      print('Tapped on booking: $id');
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                        Icon(
                        Icons.event_available,
                        color: Colors.orange,
                        size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                            '$bookingBegin → $bookingEnd',
                            style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                            Row(
                            children: [
                            const Icon(Icons.euro, size: 16, color: Colors.green),
                            const SizedBox(width: 4),
                            Text(
                              bookPrice.toStringAsFixed(2),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                          const SizedBox(height: 6),
                          Row(
                          children: [
                            Icon(
                              bookState == 'Confermata' ? Icons.check_circle : Icons.error,
                              color: bookState == 'Confermata' ? Colors.green : Colors.red,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              bookState,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: bookState == 'Confermata' ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
          ),
        ),
      );
  }

}