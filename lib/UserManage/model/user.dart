class User{
  final int id;
  String userName;
  String imageUrl;
  String citta;


  User({
    required this.id,
    required this.userName,
    required this.imageUrl,
    required this.citta
  });



  factory User.fromMap(Map<String, dynamic> map){
    return User(
     id: map['id'],
     userName: map ['userName'],
     imageUrl: map ['imageUrl'],
     citta: map ['citta']
    
    );
  }

  Map <String, dynamic> toMap(){
    return{
      'id': id,
      'userName': userName,
      'imageUrl': imageUrl,
      'citta': citta
    };
  }

  User copyWith(String newUsername, String newCity){
    citta = newCity;
    userName = newUsername;
    return this;
  }
}