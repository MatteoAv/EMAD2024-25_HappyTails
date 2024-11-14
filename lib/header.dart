import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,  // Prende tutta la larghezza dello schermo
      height: 90.0,  // Imposta l'altezza del header
      color: Colors.orange,  // Imposta il colore di sfondo arancione
      child: Center(
        child: Image.asset(
          'assets/logo.png',  // Sostituisci con il percorso dell'immagine
          width: 100,  // Imposta la larghezza dell'immagine (puoi cambiarla come preferisci)
          height: 100,  // Imposta l'altezza dell'immagine (puoi cambiarla come preferisci)
        ),
      ),
    );
  }
}
