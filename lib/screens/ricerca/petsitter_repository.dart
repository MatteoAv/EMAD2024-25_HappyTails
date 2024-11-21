import 'package:happy_tails/screens/ricerca/petsitter_model.dart';

/// Repository per il recupero dei dati di PetSitter
/// 
/// Questa classe è responsabile di:
/// - Simulare il recupero dei dati (attualmente dati finti)
/// - Fornire un'interfaccia coerente per l'accesso ai dati
/// - Gestire potenziali cambiamenti futuri della fonte dei dati (API, DB locale, ecc.)

class CardRepository {
   /// Recupera un elenco di schede PetSitter
  /// 
  /// Implementazione attuale:
  /// - Introduce un ritardo artificiale per simulare la richiesta di rete
  /// - Genera un numero fisso di finte istanze di PetSitter
  /// 
  /// I miglioramenti futuri potrebbero includere:
  /// - Integrazione effettiva delle API
  /// - Gestione degli errori
  /// - Supporto alla paginazione
  /// 
  /// @return Future list delle istanze PetSitter
  Future<List<PetSitter>> fetchCards() async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate API delay. Per ora ci interessa solo il frontend, quindi simulo e genero una lista di esempio
    return  List.generate(
      10,
      (index) => PetSitter(
        nome: 'Esempio $index',
        cognome: 'Iannone $index',
        imageUrl: 'https://images.contentstack.io/v3/assets/blt6f84e20c72a89efa/blt2577cbc57a834982/6363df6833df8e693d1e44c7/img-pet-sitter-download-header.jpg',
        descrizione: 'Descrizione esempio $index',
        citta: '$index',
        latitudine: 12,
        longitudine: 12,
        
      ),
    );
  }
}
