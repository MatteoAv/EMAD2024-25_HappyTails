class PetSitter {
  final String nome;
  final String cognome;
  final String email;
  final String provincia;
  final String imageUrl;
  //final String descrizione;
  //final String citta;
  //final int latitudine;
  //final int longitudine;


  PetSitter({
    required this.nome,
    required this.cognome,
    required this.email,
    required this.provincia,
    required this.imageUrl,
    //required this.descrizione,
    //required this.citta,
    //required this.latitudine,
    //required this.longitudine,

  });

  factory PetSitter.fromJson(Map<String, dynamic> json) {
    return PetSitter(
      nome: json['nome'],
      cognome: json['cognome'],
      email: json['email'],     
      provincia: json['provincia'], 
      imageUrl: json['imageUrl'],
      //descrizione: json['descrizione'],
      //citta: json['citta'],
      //latitudine: json['latitudine'],
      //longitudine: json['longitudine'],

    );
  }
}

/* VERSIONE VECCHIA
class PetSitter {
  final String nome;
  final String cognome;
  final String imageUrl;
  final String descrizione;
  final String citta;
  final int latitudine;
  final int longitudine;


  PetSitter({
    required this.nome,
    required this.cognome,
    required this.imageUrl,
    required this.descrizione,
    required this.citta,
    required this.latitudine,
    required this.longitudine,

  });

  factory PetSitter.fromJson(Map<String, dynamic> json) {
    return PetSitter(
      nome: json['nome'],
      cognome: json['cognome'],
      imageUrl: json['imageUrl'],
      descrizione: json['descrizione'],
      citta: json['citta'],
      latitudine: json['latitudine'],
      longitudine: json['longitudine'],

    );
  }
}

*/
