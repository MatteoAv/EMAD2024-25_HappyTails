import 'package:happy_tails/screens/ricerca/petsitter_model.dart';

class CardRepository {
  Future<List<PetSitter>> fetchCards() async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate API delay
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
