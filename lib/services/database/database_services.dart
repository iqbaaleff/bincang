import 'package:bincang/models/post.dart';
import 'package:bincang/models/user.dart';
import 'package:bincang/services/auth/auth_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DatabaseServices {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  /*
    USER INFO
  */

  // Save user info
  Future<void> saveUserInfoInFirebase({
    required String name,
    required String email,
    required String noTel,
  }) async {
    try {
      // Ambil UID pengguna yang sedang login
      String uid = auth.currentUser!.uid;
      String username = email.split("@")[0];

      // Buat objek user profile
      UserProfile user = UserProfile(
        uid: uid,
        name: name,
        email: email,
        noTel: noTel,
        username: username,
        bio: '',
      );

      final userMap = user.toMap();

      // **Simpan data dengan UID sebagai document ID**
      await db.collection('Users').doc(uid).set(userMap);

      print("User info saved successfully!");
    } catch (e) {
      print("Error saving user info: $e");
    }
  }

  // Get user info
  Future<UserProfile?> getUserFromFirebase(String uid) async {
    try {
      DocumentSnapshot userDoc = await db.collection("Users").doc(uid).get();

      if (userDoc.exists) {
        return UserProfile.fromDocument(userDoc);
      } else {
        print("User not found!");
        return null;
      }
    } catch (e) {
      print("Error getting user info: $e");
      return null;
    }
  }

  // Edit user info
  Future<void> updateUserBioInFirebase(String bio) async {
    String uid = AuthServices().getCurrentUid();

    try {
      await db.collection('Users').doc(uid).update({'bio': bio});
    } catch (e) {
      print(e);
    }
  }

  /*
   POST MESSAGE
  */

  // Post message
  Future<void> postMessageInFirebase(String message) async {
    try {
      String uid = auth.currentUser!.uid;
      UserProfile? user = await getUserFromFirebase(uid);
      // Create post
      Post newPost = Post(
        id: '',
        uid: uid,
        name: user!.name,
        username: user.username,
        message: message,
        timestamp: Timestamp.now(),
        likeCount: 0,
        likedBy: [],
      );

      Map<String, dynamic> newPostMap = newPost.toMap();

      await db.collection("Post").add(newPostMap);
    } catch (e) {
      print(e);
    }
  }

  // Delete post

  // Get all post
  Future<List<Post>> getAllPostsFromFirebase() async {
    try {
      QuerySnapshot snapshot = await db
          .collection('Post')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    } catch (e) {
      return [];
    }
  }

  // Get individual post
}
