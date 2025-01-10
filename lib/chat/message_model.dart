class Message {
  final String id;
  final String sender_id;
  final String receiver_id;
  final String content;
  final DateTime timestamp;
  //final bool isMine;
  final String? status; // Optional status field for message delivery tracking


  Message({
    required this.id,
    required this.sender_id,
    required this.receiver_id,
    required this.content,
    required this.timestamp,
    //required this.isMine,
    this.status,
  });

  factory Message.fromMap(Map<String, dynamic> map, String myUserId) {
    return Message(
      id: map['id'] ?? '',
      sender_id: map['sender_id'],
      receiver_id: map['receiver_id'],
      content: map['content'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      //isMine: map['sender_id'] == User.id,
      status: map['status'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'sender_id': sender_id,
      'receiver_id': receiver_id,
      'content': content,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'status': status, // Optional status inclusion
    };
  }
}
