import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String postId;
  final String uid;
  final String name;
  final String username;
  final String message;
  final Timestamp timestamp;
  final String? replyTo; // Tambahan untuk reply comment

  Comment({
    required this.id,
    required this.postId,
    required this.uid,
    required this.name,
    required this.username,
    required this.message,
    required this.timestamp,
    this.replyTo, // Bisa null jika bukan balasan
  });

  factory Comment.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Comment(
      id: doc.id,
      postId: data['postId'],
      uid: data['uid'],
      name: data['name'],
      username: data['username'],
      message: data['message'],
      timestamp: data['timestamp'],
      replyTo: data['replyTo'], // Tambahkan ini
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'uid': uid,
      'name': name,
      'username': username,
      'message': message,
      'timestamp': timestamp,
      'replyTo': replyTo, // Tambahkan ini
    };
  }
}
