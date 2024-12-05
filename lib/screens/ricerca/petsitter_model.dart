class PetSitter {
  final String nome;
  final String cognome;
  final String email;
  final String provincia;
  final String imageUrl;

  PetSitter({
    required this.nome,
    required this.cognome,
    required this.email,
    required this.provincia,
    required this.imageUrl,
  });

  factory PetSitter.fromMap(Map<String, dynamic> map) {
    return PetSitter(
      nome: map['nome'],
      cognome: map['cognome'],
      email: map['provincia'],
      provincia: map['provincia'],
      imageUrl: map['imageUrl'],
    );
  }
}
