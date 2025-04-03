import 'package:bincang/helper/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bincang/services/auth/auth_services.dart';

class UserListPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _deleteUser(String userId, BuildContext context) async {
    try {
      WriteBatch deleteBatch = _firestore.batch();
      WriteBatch updateBatch = _firestore.batch();

      // Hapus dokumen pengguna
      DocumentReference userDoc = _firestore.collection('Users').doc(userId);
      deleteBatch.delete(userDoc);

      // Hapus semua postingan pengguna
      QuerySnapshot userPosts = await _firestore
          .collection('Post')
          .where('uid', isEqualTo: userId)
          .get();
      for (var post in userPosts.docs) {
        deleteBatch.delete(post.reference);
      }

      // Hapus semua komentar pengguna
      QuerySnapshot userComments = await _firestore
          .collection('Comments')
          .where('uid', isEqualTo: userId)
          .get();
      for (var comment in userComments.docs) {
        deleteBatch.delete(comment.reference);
      }

      // Commit batch pertama untuk menghapus data
      await deleteBatch.commit();
      print("Batch pertama selesai: Semua data pengguna dihapus");

      // Hapus like yang dilakukan oleh pengguna dari semua postingan
      QuerySnapshot allPosts = await _firestore.collection('Post').get();
      for (var post in allPosts.docs) {
        Map<String, dynamic> postData = post.data() as Map<String, dynamic>;
        var likedBy = postData['likedBy'] as List<dynamic>? ?? [];
        if (likedBy.contains(userId)) {
          updateBatch.update(post.reference, {
            'likedBy': FieldValue.arrayRemove([userId]),
            'likes': FieldValue.increment(-1),
          });
        }
      }

      // Commit batch kedua untuk update data
      await updateBatch.commit();
      print("Batch kedua selesai: Data postingan diperbarui");

      if (context.mounted) { // Only show if context is still valid
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Akun dan semua data terkait berhasil dihapus")),
    );
  }
    } catch (e) {
      if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Gagal menghapus akun: $e")),
    );
  }
    }
  }

  Future<void> _showDeleteConfirmationDialog(
      String userId, BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Hapus'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Apakah Anda yakin ingin menghapus pengguna ini?'),
                SizedBox(height: 8),
                Text(
                    'Semua data terkait (postingan, komentar, dll) juga akan dihapus.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: AppColors.third),
              child: Text('Batal', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: AppColors.third),
              child: Text('Hapus', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteUser(userId, context);
              },
            ),
          ],
        );
      },
    );
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
                      onPressed: () =>
                          _showDeleteConfirmationDialog(userId, context),
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
