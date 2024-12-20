class User{
  final String id;
  String userName;
  String email;
  String imageUrl;
  String citta;
  bool isPetSitter;


  User({
    required this.id,
    required this.email,
    required this.imageUrl,
    required this.userName,
    required this.citta,
    required this.isPetSitter
  });



  factory User.fromMap(Map<String, dynamic> map){
    return User(
     id: map['id'],
     email: map['email'],
     userName: map ['userName'],
     imageUrl: map ['imageUrl'],
     citta: map ['citta'],
     isPetSitter: map ['isPetSitter'] == 0 ? false : true
    
    );
  }

  Map <String, dynamic> toMap(){
    return{
      'id': id,
      'email' : email,
      'userName': userName,
      'imageUrl': imageUrl,
      'citta': citta,
      'isPetSitter': isPetSitter == 0 ? false : true
    };
  }

  User copyWith(String newUsername, String newCity){
    citta = newCity;
    userName = newUsername;
    return this;
  }
}