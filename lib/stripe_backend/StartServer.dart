import 'dart:io';

class ServerController {
  Process? _serverProcess;

  // Metodo per avviare il server
  Future<void> startServer() async {
    try {
      // Avvia il server (sostituisci con il percorso del tuo server.js)
      _serverProcess = await Process.start(
        'node', 
        ['lib/stripe_backend/server.js'], // Modifica il percorso del tuo server
        mode: ProcessStartMode.detached
      );
      print('Server avviato');
    } catch (e) {
      print('Errore nell\'avvio del server: $e');
    }
  }

  // Metodo per fermare il server
  Future<void> stopServer() async {
    if (_serverProcess != null) {
      await _serverProcess!.kill();
      print('Server fermato');
    }
  }
}