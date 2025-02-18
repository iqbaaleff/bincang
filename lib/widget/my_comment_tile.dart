import 'package:bincang/models/comment.dart';
import 'package:bincang/services/auth/auth_services.dart';
import 'package:bincang/services/database/database_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyCommentTile extends StatelessWidget {
  final Comment comment;
  final void Function()? onUserTap;
  MyCommentTile({super.key, required this.comment, this.onUserTap});

  void showOption(BuildContext context) {
    // Cek user
    String currentId = AuthServices().getCurrentUid();
    final bool isOwnComment = comment.uid == currentId;

    // Pilihan
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              if (isOwnComment)
                // Tombol hapus
                ListTile(
                  leading: Icon(Icons.delete),
                  title: Text("Hapus"),
                  onTap: () async {
                    Navigator.pop(context);
                    await Provider.of<DatabaseProvider>(context, listen: false)
                        .deleteComments(comment.id, comment.postId);
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
    final size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: size.width * 0.05, vertical: size.height * 0.004),
      padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.02, vertical: size.height * 0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Bagian atas
          GestureDetector(
            onTap: onUserTap,
            child: Row(
              children: [
                Icon(
                  Icons.person,
                  color: Colors.black54,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.01),
                  child: Text(
                    comment.name,
                    style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  "@" + comment.username,
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => showOption(context),
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
            child: Text(comment.message),
          ),
        ],
      ),
    );
  }
}
