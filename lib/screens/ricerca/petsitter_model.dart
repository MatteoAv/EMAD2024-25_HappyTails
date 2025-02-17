class PetSitter {
  final int id;
  final String nome;
  final String cognome;
  final String email;
  final String provincia;
  final String comune;
  final String? imageUrl;
  final bool cani;
  final bool gatti;
  final bool uccelli;
  final bool pesci;
  final bool rettili;
  final bool roditori;
  final int distanza;
  final double prezzo;
  final double? rating;
  final int? numeroRecensioni;


  final List<dynamic>? disponibilita;
  

  PetSitter({
    required this.id,
    required this.nome,
    required this.cognome,
    required this.email,
    required this.provincia,
    required this.comune,
    required this.imageUrl,
    required this.cani,
    required this.gatti,
    required this.uccelli,
    required this.pesci,
    required this.rettili,
    required this.roditori,
    required this.distanza,
    required this.prezzo,
    this.disponibilita,
    this.rating,
    this.numeroRecensioni


  });

  factory PetSitter.fromMap(Map<String, dynamic> map) {
  return PetSitter(
    id: map['id'],
    nome: map['nome'],
    cognome: map['cognome'],
    email: map['email'],
    provincia: map['provincia'],
    comune: map['Comune'],  // matches 'Comune' from response
    imageUrl: map['imageurl'],  // matches 'imageurl' from response
    cani: map['cani'],
    gatti: map['gatti'],
    uccelli: map['uccelli'],
    pesci: map['pesci'],
    rettili: map['rettili'],
    roditori: map['roditori'],
    prezzo: map['prezzo_giornaliero'].toDouble(),  // matches 'prezzo_giornaliero'
    // Remove or provide defaults for missing fields:
    distanza: map['distanza'] ?? 0,
    disponibilita: map['disponibilita'] ?? [],
  );
}
}
