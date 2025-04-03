import 'package:bincang/helper/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManagePostsPage extends StatelessWidget {
  final Stream<QuerySnapshot> _postsStream =
      FirebaseFirestore.instance.collection('Post').snapshots();

  Future<Map<String, dynamic>?> _getUserData(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();
      return userDoc.data();
    } catch (e) {
      debugPrint("Error fetching user data: $e");
      return null;
    }
  }

  Future<void> _deletePost(String postId, BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('Post').doc(postId).delete();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Post berhasil dihapus")),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menghapus post: $e")),
        );
      }
    }
  }

  Future<void> _showDeleteConfirmationDialog(
      String postId, BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Hapus Post'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Apakah Anda yakin ingin menghapus post ini?'),
                SizedBox(height: 8),
                Text('Aksi ini tidak dapat dibatalkan.'),
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
                _deletePost(postId, context);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildPostCard(
    DocumentSnapshot doc,
    Map<String, dynamic>? userData,
    BuildContext context,
  ) {
    final username = userData?['username'] ?? 'Unknown User';

    return Card(
      color: AppColors.third,
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(
          doc['message'] ?? "",
          style: TextStyle(
            color: AppColors.secondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          "Post ID: ${doc.id} | Username: $username",
          style: TextStyle(color: AppColors.secondary),
        ),
        trailing: ElevatedButton(
          onPressed: () => _showDeleteConfirmationDialog(doc.id, context),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: Text(
            "Hapus",
            style: TextStyle(color: AppColors.secondary),
          ),
        ),
      ),
    );
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
              child: _PostsListView(postsStream: _postsStream),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostsListView extends StatelessWidget {
  final Stream<QuerySnapshot> postsStream;

  const _PostsListView({required this.postsStream});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: postsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("Tidak ada postingan"));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            return _PostItem(doc: doc);
          },
        );
      },
    );
  }
}

class _PostItem extends StatelessWidget {
  final DocumentSnapshot doc;

  const _PostItem({required this.doc});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: ManagePostsPage()._getUserData(doc['uid']),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingPostCard(doc, context);
        }

        return ManagePostsPage()._buildPostCard(
          doc,
          userSnapshot.data,
          context,
        );
      },
    );
  }

  Widget _buildLoadingPostCard(DocumentSnapshot doc, BuildContext context) {
    return Card(
      color: AppColors.third,
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(
          doc['message'] ?? "",
          style: TextStyle(
            color: AppColors.secondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          "Memuat data pengguna...",
          style: TextStyle(color: AppColors.secondary),
        ),
        trailing: ElevatedButton(
          onPressed: () =>
              ManagePostsPage()._showDeleteConfirmationDialog(doc.id, context),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: Text(
            "Hapus",
            style: TextStyle(color: AppColors.secondary),
          ),
        ),
      ),
    );
  }
}
