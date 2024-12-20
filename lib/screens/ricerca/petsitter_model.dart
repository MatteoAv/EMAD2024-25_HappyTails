class PetSitter {
  final int id;
  final String nome;
  final String cognome;
  final String email;
  final String provincia;
  final String imageUrl;
  final int distanza;

  PetSitter({
    required this.id,
    required this.nome,
    required this.cognome,
    required this.email,
    required this.provincia,
    required this.imageUrl,
    required this.distanza,

  });

  factory PetSitter.fromMap(Map<String, dynamic> map) {
    return PetSitter(
      id: map['id'],
      nome: map['nome'],
      cognome: map['cognome'],
      email: map['provincia'],
      provincia: map['provincia'],
      imageUrl: map['imageUrl'],
      distanza: map['distanza'],

    );
  }
}
