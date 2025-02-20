import 'package:bincang/models/comment.dart';
import 'package:bincang/models/post.dart';
import 'package:bincang/models/user.dart';
import 'package:bincang/services/auth/auth_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DatabaseServices {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /*
    USER INFO
  */

  // Save user info
  Future<void> saveUserInfoInFirebase({
    required String name,
    required String email,
    required String noTel,
    String? role,
  }) async {
    try {
      // Ambil UID pengguna yang sedang login
      String uid = _auth.currentUser!.uid;
      String username = email.split("@")[0];

      // Buat objek user profile
      UserProfile user = UserProfile(
          uid: uid,
          name: name,
          email: email,
          noTel: noTel,
          username: username,
          bio: '',
          role: 'user');

      final userMap = user.toMap();

      // **Simpan data dengan UID sebagai document ID**
      await _db.collection('Users').doc(uid).set(userMap);

      print("User info saved successfully!");
    } catch (e) {
      print("Error saving user info: $e");
    }
  }

  // Get user info
  Future<UserProfile?> getUserFromFirebase(String uid) async {
    try {
      DocumentSnapshot userDoc = await _db.collection("Users").doc(uid).get();

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
    String uid = AuthServices().getCurrentUid()!;

    try {
      await _db.collection('Users').doc(uid).update({'bio': bio});
    } catch (e) {
      print(e);
    }
  }

  // Delete user info
  Future<void> deleteUserInfoFromFirebase(String uid) async {
    WriteBatch batch = _db.batch();

    // delete user doc
    DocumentReference userDoc = _db.collection("Users").doc(uid);
    batch.delete(userDoc);
    // delete user post
    QuerySnapshot userPosts =
        await _db.collection("Posts").where('uid', isEqualTo: uid).get();
    for (var post in userPosts.docs) {
      batch.delete(post.reference);
    }
    // delete user comments
    QuerySnapshot userComments =
        await _db.collection("Comments").where('uid', isEqualTo: uid).get();
    for (var comment in userComments.docs) {
      batch.delete(comment.reference);
    }
    // delete like yang dilakukan user
    QuerySnapshot allPosts = await _db.collection("Post").get();
    for (QueryDocumentSnapshot post in allPosts.docs) {
      Map<String, dynamic> postData = post.data() as Map<String, dynamic>;
      var likedBy = postData['likedBy'] as List<dynamic>? ?? [];
      if (likedBy.contains(uid)) {
        batch.update(post.reference, {
          'likedBy': FieldValue.arrayRemove([uid]),
          'likes': FieldValue.increment(-1),
        });
      }
    }

    // update follower dan following record

    // commit batch
    await batch.commit();
  }

  /*
   POST MESSAGE
  */

  // Post message
  Future<void> postMessageInFirebase(String message) async {
    try {
      String uid = _auth.currentUser!.uid;
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

      await _db.collection("Post").add(newPostMap);
    } catch (e) {
      print(e);
    }
  }

  // Delete post
  Future<void> deletePostFromFirebase(String postId) async {
    try {
      await _db.collection("Post").doc(postId).delete();
    } catch (e) {
      print(e);
    }
  }

  // Get all post
  Future<List<Post>> getAllPostsFromFirebase() async {
    try {
      QuerySnapshot snapshot = await _db
          .collection('Post')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    } catch (e) {
      return [];
    }
  }

  /*
  LIKES
  */

  // Like post
  Future<void> toggleLikeInFirebase(String postId) async {
    try {
      // Get id
      String uid = _auth.currentUser!.uid;
      // Pergi ke doc buat postingan
      DocumentReference postDoc = _db.collection('Post').doc(postId);
      // Eksekusi like
      await _db.runTransaction((transaction) async {
        // Get post data
        DocumentSnapshot postSnapshot = await transaction.get(postDoc);
        // Get like dari user
        List<String> likedBy = List<String>.from(postSnapshot['likedBy'] ?? []);
        // Get jumlah like
        int currentLikeCount = postSnapshot['likes'];
        // If user belum like -> like
        if (!likedBy.contains(uid)) {
          likedBy.add(uid);

          currentLikeCount++;
        }
        // if user sudah like -> unlike
        else {
          likedBy.remove(uid);
          currentLikeCount--;
        }

        // Update ke firebase
        transaction
            .update(postDoc, {'likes': currentLikeCount, 'likedBy': likedBy});
      });
    } catch (e) {
      print(e);
    }
  }

  /* 
  COMMENT
  */

  // Add comment
  Future<void> addCommentInFirebase(String postId, message) async {
    try {
      // Get user
      String uid = _auth.currentUser!.uid;
      UserProfile? user = await getUserFromFirebase(uid);

      // Buat Comment baru
      Comment newComment = Comment(
        id: '',
        postId: postId,
        uid: uid,
        name: user!.name,
        username: user!.username,
        message: message,
        timestamp: Timestamp.now(),
      );

      Map<String, dynamic> newCommentMap = newComment.toMap();

      // Simpan data ke firebase
      await _db.collection('Comments').add(newCommentMap);
    } catch (e) {
      print(e);
    }
  }

  // Delete comment
  Future<void> deleteCommentInFirebase(String commentId) async {
    try {
      await _db.collection('Comments').doc(commentId).delete();
    } catch (e) {
      print(e);
    }
  }

  // Fetch comment
  Future<List<Comment>> getCommentFromFirebase(String postId) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection('Comments')
          .where("postId", isEqualTo: postId)
          .get();
      return snapshot.docs.map((doc) => Comment.fromDocument(doc)).toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

  /* 
  REPORT, BLOCK, DELETE AKUN
  */

  // Report
  Future<void> reportUserInFirebase(String postId, userId) async {
    final currentUserId = _auth.currentUser!.uid;
    final report = {
      'reportedBy': currentUserId,
      'messageId': postId,
      'messageOwnerId': userId,
      'timestamp': FieldValue.serverTimestamp(),
    };

    await _db.collection("Reports").add(report);
  }

  // Block
  Future<void> blockUserInFirebase(String userId) async {
    final currentUserId = _auth.currentUser!.uid;

    await _db
        .collection("Users")
        .doc(currentUserId)
        .collection("BlockedUsers")
        .doc(userId)
        .set({});
  }

  // Unblock
  Future<void> unblockUserInFirebase(String blockedUserId) async {
    final currentUserId = _auth.currentUser!.uid;

    await _db
        .collection("Users")
        .doc(currentUserId)
        .collection("BlockedUsers")
        .doc(blockedUserId)
        .delete();
  }

  // Get list blocked uid
  Future<List<String>> getBlockedUidFromFirebase() async {
    final currentUserId = _auth.currentUser!.uid;

    final snapshot = await _db
        .collection("Users")
        .doc(currentUserId)
        .collection("BlockedUsers")
        .get();

    return snapshot.docs.map((doc) => doc.id).toList();
  }

  /* 
  FOLLOW
  */

  // Follow user
  Future<void> followUserInFirebase(String uid) async {
    final currentUserId = _auth.currentUser!.uid;

    // add target user ke current user following
    await _db
        .collection("Users")
        .doc(currentUserId)
        .collection("Following")
        .doc(uid)
        .set({
      "followedAt":
          FieldValue.serverTimestamp(), // Tambahkan data agar koleksi muncul
      "userId": uid // Bisa juga simpan user ID
    });

    await _db
        .collection("Users")
        .doc(uid)
        .collection("Followers")
        .doc(currentUserId)
        .set({
      "followedAt": FieldValue.serverTimestamp(),
      "userId": currentUserId
    });
  }

  // Unfollow user
  Future<void> unfollowUserInFirebase(String uid) async {
    final currentUserId = _auth.currentUser!.uid;

    // remove target user dari current user following
    await _db
        .collection("Users")
        .doc(currentUserId)
        .collection("Following")
        .doc(uid)
        .delete();

    // remove target user dari current user followers
    await _db
        .collection("Users")
        .doc(uid)
        .collection("Followers")
        .doc(currentUserId)
        .delete();
  }

  // Get list uid follower
  Future<List<String>> getFollowerUidsFromFirebase(String uid) async {
    final snapshot =
        await _db.collection("Users").doc(uid).collection("Followers").get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  // Get list uid following
  Future<List<String>> getFollowingUidsFromFirebase(String uid) async {
    final snapshot =
        await _db.collection("Users").doc(uid).collection("Following").get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  // Search
  Future<List<UserProfile>> searchUserInFirebase(String searchTerm) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection("Users")
          .where('username', isGreaterThan: searchTerm)
          .where('username', isLessThan: '$searchTerm\uf8ff')
          .get();

      return snapshot.docs.map((doc) => UserProfile.fromDocument(doc)).toList();
    } catch (e) {
      return [];
    }
  }
}
