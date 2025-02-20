import 'package:bincang/helper/time_formatter.dart';
import 'package:bincang/models/comment.dart';
import 'package:bincang/helper/app_colors.dart';
import 'package:bincang/services/auth/auth_services.dart';
import 'package:bincang/services/database/database_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyCommentTile extends StatelessWidget {
  final Comment comment;
  final VoidCallback onUserTap;
  final VoidCallback onReplyTap;

  const MyCommentTile({
    Key? key,
    required this.comment,
    required this.onUserTap,
    required this.onReplyTap,
  }) : super(key: key);

  void showOption(BuildContext context) {
    final currentId = AuthServices().getCurrentUid();
    if (currentId == null) return; // Hindari error jika currentId null
    final bool isOwnComment = comment.uid == currentId;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              if (isOwnComment)
                ListTile(
                  leading: Icon(Icons.delete, color: AppColors.third),
                  title: Text("Hapus"),
                  onTap: () async {
                    Navigator.pop(context);
                    await Provider.of<DatabaseProvider>(context, listen: false)
                        .deleteComments(comment.id, comment.postId);
                  },
                )
              else ...[
                ListTile(
                  leading: Icon(Icons.flag, color: AppColors.third),
                  title: Text("Laporkan"),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: Icon(Icons.block, color: AppColors.third),
                  title: Text("Blokir"),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onUserTap,
                child: Row(
                  children: [
                    Icon(Icons.person, color: AppColors.text),
                    SizedBox(width: size.width * 0.01),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              comment.name,
                              style: TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(width: size.width * 0.03),
                            Text(
                              formatTimestamp(comment.timestamp),
                              style: TextStyle(
                                color: AppColors.third,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "@${comment.username}",
                          style: TextStyle(
                            color: AppColors.third,
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Spacer(),
              GestureDetector(
                onTap: () => showOption(context), // Perbaikan panggilan fungsi
                child: Icon(Icons.more_horiz, color: AppColors.third),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text.rich(_buildStyledText(comment.message)),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: GestureDetector(
              onTap: onReplyTap,
              child: Text(
                "Balas",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.third,
                ),
              ),
            ),
          ),
          Divider(color: Colors.grey.shade300),
        ],
      ),
    );
  }

  TextSpan _buildStyledText(String text) {
    final regex = RegExp(r'@\w+');
    final spans = <TextSpan>[];
    int lastMatchEnd = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
          style: TextStyle(color: Colors.black),
        ));
      }
      spans.add(TextSpan(
        text: match.group(0),
        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
      ));
      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: TextStyle(color: Colors.black),
      ));
    }

    return TextSpan(children: spans);
  }
}
