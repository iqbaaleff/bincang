import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String noTel;
  final String username;
  final String bio;
  final String role;
  final Timestamp createdAt;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.noTel,
    required this.username,
    required this.bio,
    required this.role,
    required this.createdAt,
  });

  // Firebase -> app
  factory UserProfile.fromDocument(DocumentSnapshot doc) {
    return UserProfile(
      uid: doc['uid'],
      name: doc['name'],
      email: doc['email'],
      noTel: doc['noTel'],
      username: doc['username'],
      bio: doc['bio'],
      role: doc['role'],
      createdAt: doc['createdAt'],
    );
  }

  // App -> firebase
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'noTel': noTel,
      'username': username,
      'bio': bio,
      'role': role,
      'createdAt': createdAt,
    };
  }
}
