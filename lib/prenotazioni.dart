import 'package:flutter/material.dart';
import 'header.dart'; // Importa il widget Header

//aggiunta di un commento perchè il commit non funzionava

class PrenotazioniPage extends StatelessWidget {
  const PrenotazioniPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Header(), // Aggiungi il widget Header in cima
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Per poter vedere le tue prenotazioni attive registrati o effettua il login',
                    style: TextStyle(fontSize: 24),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20), // Spaziatura tra il testo e i pulsanti
                  SizedBox(
                    width: 400, // Larghezza uniforme per i pulsanti
                    child: ElevatedButton(
                      onPressed: () {
                        // Azione per il pulsante Accedi
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange, // Colore arancione
                        foregroundColor: Colors.white, // Testo bianco
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // Angoli arrotondati
                        ),
                      ),
                      child: const Text('Accedi'),
                    ),
                  ),
                  const SizedBox(height: 10), // Spaziatura tra i due pulsanti
                  SizedBox(
                    width: 400, // Larghezza uniforme per i pulsanti
                    child: ElevatedButton(
                      onPressed: () {
                        // Azione per il pulsante Registrati
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange, // Colore arancione
                        foregroundColor: Colors.white, // Testo bianco
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // Angoli arrotondati
                        ),
                      ),
                      child: const Text('Registrati'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
