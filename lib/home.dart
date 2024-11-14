import 'package:flutter/material.dart';
import 'header.dart'; // Importa il widget Header

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Header(), // Aggiungi il widget Header in cima

          SizedBox(height: 50), // Distanza tra Header e i rettangoli

          // Usa un Row per affiancare due colonne
          Row(
            mainAxisAlignment: MainAxisAlignment.center, // Centra le due colonne
            children: <Widget>[
              // Colonna con il rettangolo grande a sinistra
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start, // Allinea verso l'alto
                  children: <Widget>[
                    FractionallySizedBox(
                      alignment: Alignment.center, // Allinea al centro
                      widthFactor: 0.8, // Definisce la larghezza del rettangolo (80% della larghezza del dispositivo)
                      child: Container(
                        height: 300, // Grande rettangolo
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(20), // Angoli arrotondati
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Colonna con 3 rettangoli più piccoli a destra
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start, // Allinea verso l'alto
                  children: <Widget>[
                    FractionallySizedBox(
                      alignment: Alignment.center, // Allinea al centro
                      widthFactor: 0.8, // Rettangolo piccolo (80% della larghezza del dispositivo)
                      child: Container(
                        height: 90,
                        margin: EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(10), // Angoli arrotondati
                        ),
                      ),
                    ),
                    FractionallySizedBox(
                      alignment: Alignment.center,
                      widthFactor: 0.8,
                      child: Container(
                        height: 90,
                        margin: EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    FractionallySizedBox(
                      alignment: Alignment.center,
                      widthFactor: 0.8,
                      child: Container(
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.purple,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Expanded(
            child: Center(
              child: Text(
                'Homepage',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
