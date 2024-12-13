

class Booking {
  final int id;
  final int id_trans;
  final double price;
  final String dateBegin;
  final String dateEnd;
  final String state;
  final String state_Payment;
  final String? metaPayment;
  final int? vote;
  final String? summary;
  final int pet_id;
  final String owner_id;
  final int petsitter_id;

  Booking({
    required this.id,
    required this.id_trans,
    required this.dateBegin,
    required this.dateEnd,
    required this.price,
    required this.metaPayment,
    required this.state,
    required this.vote,
    required this.summary,
    required this.state_Payment,
    required this.pet_id,
    required this.owner_id,
    required this.petsitter_id
  });

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'],
      id_trans: map['id_trans'],
      dateBegin: map['dateBegin'],
      dateEnd: map ['dateEnd'],
      price: (map['price'] is int)
          ? (map['price'] as int).toDouble()
          : map['price'] as double,
      state : map ['state'],
      state_Payment: map ['state_Payment'],
      metaPayment: map ['metaPayment'],
      vote : map ['vote'],
      summary: map ['review'],
      pet_id: map ['pet_id'],
      owner_id: map['owner_id'],
      petsitter_id: map['petsitter_id']
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_trans': id_trans,
      'dateBegin': dateBegin,
      'dateEnd' : dateEnd,
      'price' : price,
      'state' : state,
      'metaPayment' : metaPayment,
      'state_Payment' : state_Payment,
      'vote' : vote,
      'review' : summary,
      'pet_id' : pet_id,
      'owner_id' : owner_id,
      'petsitter_id': petsitter_id
    };
  }
}
