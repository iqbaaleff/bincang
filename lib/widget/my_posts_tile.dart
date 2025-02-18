import 'package:bincang/helper/app_colors.dart';
import 'package:bincang/helper/time_formatter.dart';
import 'package:bincang/models/post.dart';
import 'package:bincang/services/auth/auth_services.dart';
import 'package:bincang/services/database/database_provider.dart';
import 'package:bincang/widget/my_input_alert_box.dart';
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadComment();
  }

  // User tap like/unlike
  void _toggleLikePost() async {
    try {
      await databaseProvider.toggleLike(widget.post.id);
    } catch (e) {
      print(e);
    }
  }

  // Buka comment box
  final commentController = TextEditingController();
  void _openNewCommentBox() {
    showDialog(
      context: context,
      builder: (context) => MyInputAlertBox(
          textController: commentController,
          hintText: "Komentari...",
          onPressed: () async {
            await _addComment();
          },
          onPressedText: "Kirim"),
    );
  }

  Future<void> _addComment() async {
    if (commentController.text.trim().isEmpty) return;
    try {
      await databaseProvider.addComments(
          widget.post.id, commentController.text.trim());
    } catch (e) {
      print(e);
    }
  }

  // Load comment
  Future<void> loadComment() async {
    await databaseProvider.loadComments(widget.post.id);
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
                // Report userew
                ListTile(
                  leading: Icon(Icons.flag),
                  title: Text("Laporkan"),
                  onTap: () {
                    Navigator.pop(context);
                    _reportPostConfirmBox();
                  },
                ),
                // Block user
                ListTile(
                  leading: Icon(Icons.block),
                  title: Text("Blokir"),
                  onTap: () {
                    Navigator.pop(context);
                    _blockPostConfirmBox();
                  },
                )
              },
            ],
          ),
        );
      },
    );
  }

  void _reportPostConfirmBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Laporkan Postingan"),
        content: Text("Apakah kamu yakin akan melaporkannya?"),
        actions: [
          // Batal
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Batal"),
          ),
          // Laporkan
          TextButton(
            onPressed: () async {
              await databaseProvider.reportUser(
                  widget.post.id, widget.post.uid);
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Postingan telah dilaporkan"),
                ),
              );
            },
            child: Text("Laporkan"),
          ),
        ],
      ),
    );
  }

  void _blockPostConfirmBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Blokir pengguna"),
        content: Text("Apakah kamu yakin?"),
        actions: [
          // Batal
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Batal"),
          ),
          // Block
          TextButton(
            onPressed: () async {
              await databaseProvider.blockUser(widget.post.uid);
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("pengguna telah di blokir"),
                ),
              );
            },
            child: Text("Blokir"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Apakah current user like post ini?
    bool likedByCurrentUser =
        listeningProvider.isPostLikedByCurrentUser(widget.post.id);

    int likeCount = listeningProvider.getLikeCount(widget.post.id);
    int commentCount = listeningProvider.getComments(widget.post.id).length;
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        GestureDetector(
          onTap: widget.onPostTap,
          child: Container(
            color: Colors.transparent,
            margin: EdgeInsets.symmetric(
                horizontal: size.width * 0.03, vertical: size.height * 0.002),
            padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.01, vertical: size.height * 0.01),
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
                        color: AppColors.secondary,
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: size.width * 0.01),
                        child: Text(
                          widget.post.name,
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: showOption,
                        child: Icon(Icons.more_horiz, color: AppColors.third),
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
                  child: Text(
                    widget.post.message,
                    style: TextStyle(
                      color: AppColors.text,
                    ),
                  ),
                ),

                // Button like comment
                Row(
                  children: [
                    // LIKES
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
                                  color: AppColors.text,
                                ),
                        ),

                        // Like count
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.01),
                          child: Text(
                            likeCount != 0 ? likeCount.toString() : '',
                            style: TextStyle(
                              color: likedByCurrentUser
                                  ? Colors.red
                                  : AppColors.text,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: size.width * 0.03,
                    ),
                    // COMMENT
                    GestureDetector(
                      onTap: _openNewCommentBox,
                      child: Icon(
                        Icons.comment_outlined,
                        color: AppColors.text,
                      ),
                    ),

                    // Comment count
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: size.width * 0.01),
                      child: Text(
                        commentCount != 0 ? commentCount.toString() : '',
                        style: TextStyle(
                          color: AppColors.text,
                        ),
                      ),
                    ),

                    const Spacer(),

                    Text(
                      formatTimestamp(widget.post.timestamp),
                      style: TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Divider(
          color: Colors.white10,
        )
      ],
    );
  }
}
