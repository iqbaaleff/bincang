import 'package:bincang/models/comment.dart';
import 'package:bincang/models/notif.dart';
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
        role: 'user',
        createdAt: Timestamp.now(),
      );

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

  // Get individual post

  /*
  LIKES
  */

  // Like post
  Future<void> toggleLikeInFirebase(String postId) async {
    try {
      String uid = _auth.currentUser!.uid;
      DocumentReference postDoc = _db.collection('Post').doc(postId);

      await _db.runTransaction((transaction) async {
        DocumentSnapshot postSnapshot = await transaction.get(postDoc);
        List<String> likedBy = List<String>.from(postSnapshot['likedBy'] ?? []);
        int currentLikeCount = postSnapshot['likes'];

        if (!likedBy.contains(uid)) {
          likedBy.add(uid);
          currentLikeCount++;

          // Kirim notifikasi ke pemilik postingan
          String receiverUid = postSnapshot['uid'];
          if (receiverUid != uid) {
            // Hindari notifikasi ke diri sendiri
            UserProfile? senderProfile = await getUserFromFirebase(uid);
            if (senderProfile != null) {
              await sendNotification(
                type: 'like',
                postId: postId,
                senderUid: uid,
                senderName: senderProfile.name,
                senderUsername: senderProfile.username,
                receiverUid: receiverUid,
                message: 'Menyukai postingan Anda',
              );
            }
          }
        } else {
          likedBy.remove(uid);
          currentLikeCount--;
        }

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

  // Add Comment (Bisa Komentar Baru atau Balasan)
  Future<void> addCommentInFirebase(String postId, String message,
      {String? parentId}) async {
    if (message.trim().isEmpty) return;

    try {
      String uid = _auth.currentUser!.uid;
      UserProfile? user = await getUserFromFirebase(uid);

      DocumentReference docRef = _db.collection('Comments').doc();
      await docRef.set({
        'postId': postId,
        'uid': uid,
        'name': user!.name,
        'username': user.username,
        'message': message,
        'timestamp': Timestamp.now(),
        'parentId': parentId,
      });

      // Kirim notifikasi ke pemilik postingan
      DocumentSnapshot postSnapshot =
          await _db.collection('Post').doc(postId).get();
      String receiverUid = postSnapshot['uid'];
      if (receiverUid != uid) {
        // Hindari notifikasi ke diri sendiri
        await sendNotification(
          type: 'comment',
          postId: postId,
          senderUid: uid,
          senderName: user.name,
          senderUsername: user.username,
          receiverUid: receiverUid,
          message: 'Mengomentari postingan Anda: $message',
        );
      }
    } catch (e) {
      print("Error adding comment: $e");
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

  // Ambil komentar berdasarkan `postId`
  Future<List<Comment>> getCommentFromFirebase(String postId) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection('Comments')
          .where("postId", isEqualTo: postId)
          .orderBy("timestamp", descending: false) // Pastikan orderBy ada
          .get();

      print(
          "Jumlah komentar diambil: ${snapshot.docs.length}"); // Log jumlah data

      return snapshot.docs.map((doc) => Comment.fromDocument(doc)).toList();
    } catch (e) {
      print("Error fetching comments: $e");
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
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      print("User is not signed in.");
      return []; // Return an empty list instead of throwing an error
    }

    final snapshot = await _db
        .collection("Users")
        .doc(currentUser.uid)
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

  /*
  NOTIF
  */

  // Fungsi untuk mengirim notifikasi
  Future<void> sendNotification({
    required String type, // 'like' atau 'comment'
    required String postId,
    required String senderUid,
    required String senderName, // Nama user yang memberikan like/comment
    required String
        senderUsername, // Username user yang memberikan like/comment
    required String receiverUid,
    required String message,
  }) async {
    try {
      await _db.collection('Notifications').add({
        'type': type,
        'postId': postId,
        'senderUid': senderUid,
        'senderName': senderName,
        'senderUsername': senderUsername,
        'receiverUid': receiverUid,
        'message': message,
        'timestamp': Timestamp.now(),
        'isRead': false,
      });
    } catch (e) {
      print("Error sending notification: $e");
    }
  }

  // Fungsi untuk mengambil notifikasi
  Future<List<Notif>> getNotifications(String receiverUid) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection('Notifications')
          .where('receiverUid', isEqualTo: receiverUid)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return Notif.fromDocument(doc);
      }).toList();
    } catch (e) {
      print("Error fetching notifications: $e");
      return [];
    }
  }

  // Fungsi untuk menandai notifikasi sebagai sudah dibaca
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _db.collection('Notifications').doc(notificationId).update({
        'isRead': true,
      });
    } catch (e) {
      print("Error marking notification as read: $e");
    }
  }

  // Fungsi untuk mengambil postingan berdasarkan ID
  Future<Post?> getPostById(String postId) async {
    try {
      DocumentSnapshot doc = await _db.collection('Post').doc(postId).get();
      if (doc.exists) {
        return Post.fromDocument(doc);
      } else {
        return null;
      }
    } catch (e) {
      print("Error fetching post: $e");
      return null;
    }
  }
}
