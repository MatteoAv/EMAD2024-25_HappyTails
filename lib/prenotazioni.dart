import 'package:flutter/material.dart';
import 'header.dart'; // Importa il widget Header

class PrenotazioniPage extends StatelessWidget {
  const PrenotazioniPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Header(), // Aggiungi il widget Header in cima
          const Expanded(
            child: Center(
              child: Text(
                'Prenotazioni',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
