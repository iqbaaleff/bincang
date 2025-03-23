import 'package:bincang/helper/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bincang/services/auth/auth_services.dart';

class UserListPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _deleteUser(String userId, BuildContext context) async {
    try {
      WriteBatch batch = _firestore.batch();

      // Hapus dokumen pengguna
      DocumentReference userDoc = _firestore.collection('Users').doc(userId);
      batch.delete(userDoc);

      // Hapus semua postingan pengguna
      QuerySnapshot userPosts = await _firestore
          .collection('Post')
          .where('uid', isEqualTo: userId)
          .get();
      for (var post in userPosts.docs) {
        batch.delete(post.reference);
      }

      // Hapus semua komentar pengguna
      QuerySnapshot userComments = await _firestore
          .collection('Comments')
          .where('uid', isEqualTo: userId)
          .get();
      for (var comment in userComments.docs) {
        batch.delete(comment.reference);
      }

      // Hapus like yang dilakukan oleh pengguna
      QuerySnapshot allPosts = await _firestore.collection('Post').get();
      for (var post in allPosts.docs) {
        Map<String, dynamic> postData = post.data() as Map<String, dynamic>;
        var likedBy = postData['likedBy'] as List<dynamic>? ?? [];
        if (likedBy.contains(userId)) {
          batch.update(post.reference, {
            'likedBy': FieldValue.arrayRemove([userId]),
            'likes': FieldValue.increment(-1),
          });
        }
      }

      // Commit batch untuk menghapus semua data sekaligus
      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Akun dan semua data terkait berhasil dihapus")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menghapus akun: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: Padding(
        padding: EdgeInsets.all(16),
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('Users').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text("Tidak ada pengguna"));
            }
            return ListView(
              children: snapshot.data!.docs.map((doc) {
                Map<String, dynamic> userData =
                    doc.data() as Map<String, dynamic>;
                String userId = doc.id;
                String username = userData['username'] ?? 'Unknown User';
                String email = userData['email'] ?? 'No Email';

                return Card(
                  color: AppColors.third,
                  elevation: 4,
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(
                      username,
                      style: TextStyle(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      email,
                      style: TextStyle(
                        color: AppColors.secondary,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteUser(userId, context),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
