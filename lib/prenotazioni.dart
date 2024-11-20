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

          Container(
            margin: const EdgeInsets.all(10.0),
            height: 610,
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 150, 142, 125),
              borderRadius: BorderRadius.circular(10), // Arrotonda gli angoli del Container
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  //Testo
                  const Text(
                    'Per visualizzare le prenotazioni in corso accedi con il tuo account oppure registrati',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 20, fontWeight: FontWeight.bold
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20),

                  // Primo blocco: Immagine e bottone
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10), // Arrotonda gli angoli dell'immagine
                    child: Image.asset(
                      'assets/pawShaking.png', 
                      //dopo aver caricato un'immagine nella cartella assets e aver aggiornato il pubspec.yaml eseguire il comando flutter pub get
                      width: double.infinity, // Aggiunge larghezza per riempire il container
                      height: 190, // Imposta un'altezza per l'immagine
                      fit: BoxFit.cover, // Imposta il tipo di ritaglio dell'immagine
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 300,
                        child:                      
                        ElevatedButton(
                          onPressed: () {
                            // Azione per il pulsante 
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange, // Colore arancione
                            foregroundColor: Colors.white, // Testo bianco
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10), // Angoli arrotondati
                            ),
                          ),
                          child: const Text('Accedi'),
                        )
                      )

                    ],
                  ),
                  
                  const SizedBox(height: 20), // Spaziatura tra i due blocchi

                  // Secondo blocco: Immagine e bottone 
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10), // Arrotonda gli angoli dell'immagine
                    child: Image.asset(
                      'assets/puppies.png', 
                      //dopo aver caricato un'immagine nella cartella assets e aver aggiornato il pubspec.yaml eseguire il comando flutter pub get
                      width: double.infinity, // Aggiunge larghezza per riempire il container
                      height: 190, // Imposta un'altezza per l'immagine
                      fit: BoxFit.cover, // Imposta il tipo di ritaglio dell'immagine
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 300,
                        child:                      
                        ElevatedButton(
                          onPressed: () {
                            // Azione per il pulsante 
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange, // Colore arancione
                            foregroundColor: Colors.white, // Testo bianco
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10), // Angoli arrotondati
                            ),
                          ),
                          child: const Text('Registrati'),
                        )
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),

          /*
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
                    width: 350, // Larghezza uniforme per i pulsanti
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
                    width: 350, // Larghezza uniforme per i pulsanti
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
          ),*/
        ],
      ),
    );
  }
}
