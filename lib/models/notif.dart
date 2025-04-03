import 'package:cloud_firestore/cloud_firestore.dart';

class Notif {
  final String id;
  final String type; // 'like' atau 'comment'
  final String postId; // ID postingan yang terkait
  final String senderUid;
  final String senderName; // Nama user yang memberikan like/comment
  final String senderUsername; // Username user yang memberikan like/comment
  final String receiverUid;
  final String message;
  final Timestamp timestamp;
  final bool isRead;

  Notif({
    required this.id,
    required this.type,
    required this.postId,
    required this.senderUid,
    required this.senderName,
    required this.senderUsername,
    required this.receiverUid,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });

  // Factory method untuk membuat objek Notif dari DocumentSnapshot
  factory Notif.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>; // Konversi data ke Map

    return Notif(
      id: doc.id,
      type: data['type'] ?? 'unknown',
      postId: data['postId'] ?? '',
      senderUid: data['senderUid'] ?? '',
      senderName:
          data.containsKey('senderName') ? data['senderName'] : 'Unknown',
      senderUsername: data['senderUsername'] ?? '',
      receiverUid: data['receiverUid'] ?? '',
      message: data['message'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      isRead: data['isRead'] ?? false,
    );
  }

  // Method untuk mengonversi objek Notif ke Map
  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'postId': postId,
      'senderUid': senderUid,
      'senderName': senderName,
      'senderUsername': senderUsername,
      'receiverUid': receiverUid,
      'message': message,
      'timestamp': timestamp,
      'isRead': isRead,
    };
  }
}
