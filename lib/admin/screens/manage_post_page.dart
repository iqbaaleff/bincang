import 'package:bincang/helper/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManagePostsPage extends StatelessWidget {
  Stream<QuerySnapshot> _getAllPostsStream() {
    return FirebaseFirestore.instance.collection('Post').snapshots();
  }

  // Fungsi untuk mengambil data pengguna berdasarkan userId
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>?;
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
    return null;
  }

  Future<void> _deletePost(String postId, BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('Post').doc(postId).delete();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Post berhasil dihapus")));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Gagal menghapus post: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _getAllPostsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("Tidak ada postingan"));
                  }
                  return ListView(
                    children: snapshot.data!.docs.map((doc) {
                      // Ambil data pengguna berdasarkan uid di post
                      String userId = doc['uid'];
                      Future<Map<String, dynamic>?> userDataFuture =
                          getUserData(userId);

                      return FutureBuilder<Map<String, dynamic>?>(
                        future: userDataFuture,
                        builder: (context, userSnapshot) {
                          if (userSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Card(
                              color: AppColors.third,
                              elevation: 4,
                              margin: EdgeInsets.symmetric(vertical: 8.0),
                              child: ListTile(
                                title: Text(
                                  doc['message'] ?? "",
                                  style: TextStyle(
                                      color: AppColors.secondary,
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  "Memuat data pengguna...",
                                  style: TextStyle(
                                    color: AppColors.secondary,
                                  ),
                                ),
                                trailing: ElevatedButton(
                                  onPressed: () => _deletePost(doc.id, context),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red),
                                  child: Text(
                                    "Hapus",
                                    style: TextStyle(
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                          if (!userSnapshot.hasData) {
                            return Card(
                              color: AppColors.third,
                              elevation: 4,
                              margin: EdgeInsets.symmetric(vertical: 8.0),
                              child: ListTile(
                                title: Text(
                                  doc['message'] ?? "",
                                  style: TextStyle(
                                      color: AppColors.secondary,
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  "Post ID: ${doc.id} | Username: Tidak ditemukan",
                                  style: TextStyle(
                                    color: AppColors.secondary,
                                  ),
                                ),
                                trailing: ElevatedButton(
                                  onPressed: () => _deletePost(doc.id, context),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red),
                                  child: Text(
                                    "Hapus",
                                    style: TextStyle(
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                          String username =
                              userSnapshot.data?['username'] ?? 'Unknown User';

                          return Card(
                            color: AppColors.third,
                            elevation: 4,
                            margin: EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              title: Text(
                                doc['message'] ?? "",
                                style: TextStyle(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                "Post ID: ${doc.id} | Username: $username",
                                style: TextStyle(
                                  color: AppColors.secondary,
                                ),
                              ),
                              trailing: ElevatedButton(
                                onPressed: () => _deletePost(doc.id, context),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red),
                                child: Text(
                                  "Hapus",
                                  style: TextStyle(
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
