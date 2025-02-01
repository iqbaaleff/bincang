import 'package:bincang/models/post.dart';
import 'package:bincang/services/auth/auth_services.dart';
import 'package:bincang/services/database/database_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyPostsTile extends StatefulWidget {
  final void Function()? onUserTap;
  final void Function()? onPostTap;
  final Post post;
  const MyPostsTile(
      {super.key, required this.post, this.onUserTap, this.onPostTap});

  @override
  State<MyPostsTile> createState() => _MyPostsTileState();
}

class _MyPostsTileState extends State<MyPostsTile> {
  late final listeningProvider = Provider.of<DatabaseProvider>(context);
  late final databaseProvider =
      Provider.of<DatabaseProvider>(context, listen: false);

  // User tap like/unlike
  void _toggleLikePost() async {
    try {
      await databaseProvider.toggleLike(widget.post.id);
    } catch (e) {
      print(e);
    }
  }

  void showOption() {
    // Cek user
    String currentId = AuthServices().getCurrentUid();
    final bool isOwnPost = widget.post.uid == currentId;

    // Pilihan
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              if (isOwnPost)
                // Tombol hapus
                ListTile(
                  leading: Icon(Icons.delete),
                  title: Text("Hapus"),
                  onTap: () async {
                    Navigator.pop(context);
                    await databaseProvider.deletePost(widget.post.id);
                  },
                )
              else ...{
                // Report user
                ListTile(
                  leading: Icon(Icons.flag),
                  title: Text("Laporkan"),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                // Block user
                ListTile(
                  leading: Icon(Icons.block),
                  title: Text("Blokir"),
                  onTap: () {
                    Navigator.pop(context);
                  },
                )
              },
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Apakah current user like post ini?
    bool likedByCurrentUser =
        listeningProvider.isPostLikedByCurrentUser(widget.post.id);

    int likeCount = listeningProvider.getLikeCount(widget.post.id);
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: widget.onPostTap,
      child: Container(
        margin: EdgeInsets.symmetric(
            horizontal: size.width * 0.05, vertical: size.height * 0.004),
        padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.02, vertical: size.height * 0.02),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Bagian atas
            GestureDetector(
              onTap: widget.onUserTap,
              child: Row(
                children: [
                  Icon(
                    Icons.person,
                    color: Colors.black54,
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: size.width * 0.01),
                    child: Text(
                      widget.post.name,
                      style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    "@" + widget.post.username,
                    style: TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: showOption,
                    child: Icon(Icons.more_horiz),
                  ),
                ],
              ),
            ),

            SizedBox(
              height: size.height * 0.004,
            ),

            // Konten
            Padding(
              padding: EdgeInsets.symmetric(vertical: size.height * 0.01),
              child: Text(widget.post.message),
            ),

            // Button like comment
            Row(
              children: [
                GestureDetector(
                  onTap: _toggleLikePost,
                  child: likedByCurrentUser
                      ? Icon(
                          Icons.favorite,
                          color: Colors.red,
                        )
                      : Icon(
                          Icons.favorite_border,
                          color: Colors.black54,
                        ),
                ),

                // Like count
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.01),
                  child: Text(
                    likeCount != 0 ? likeCount.toString() : '',
                    style: TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
