import 'package:flutter/material.dart';
import 'header.dart'; // Importa il widget Header

class CercaPage extends StatelessWidget {
  const CercaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Header(), // Aggiungi il widget Header in cima
          const Expanded(
            child: Center(
              child: Text(
                'Pagina di ricerca',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
