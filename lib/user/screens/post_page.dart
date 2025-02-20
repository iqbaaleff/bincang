import 'package:bincang/helper/app_colors.dart';
import 'package:bincang/helper/navigate_pages.dart';
import 'package:bincang/models/post.dart';
import 'package:bincang/services/database/database_provider.dart';
import 'package:bincang/widget/my_comment_tile.dart';
import 'package:bincang/widget/my_posts_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PostPage extends StatefulWidget {
  final Post post;
  const PostPage({super.key, required this.post});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  late final listeningProvider = Provider.of<DatabaseProvider>(context);
  late final databaseProvider =
      Provider.of<DatabaseProvider>(context, listen: false);

  bool _showCommentField = false;
  final TextEditingController _commentController = TextEditingController();

  void _toggleCommentField() {
    setState(() {
      _showCommentField = !_showCommentField;
    });
  }

  void _submitComment() {
    final text = _commentController.text.trim();
    if (text.isNotEmpty) {
      databaseProvider.addComments(widget.post.id, text);
      _commentController.clear();
      setState(() {
        _showCommentField = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final allComments =
        listeningProvider.getComments(widget.post.id).reversed.toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.post.message,
          style: TextStyle(color: AppColors.third),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                MyPostsTile(
                  post: widget.post,
                  onUserTap: () => goUserPage(context, widget.post.uid),
                  onCommentTap: _toggleCommentField,
                ),
                if (_showCommentField)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            decoration: InputDecoration(
                              hintText: "Tulis komentar...",
                              border: UnderlineInputBorder(),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.send, color: AppColors.third),
                          onPressed: _submitComment,
                        ),
                      ],
                    ),
                  ),
                allComments.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Tidak ada komentar..",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: allComments.length,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          final comment = allComments[index];
                          return MyCommentTile(
                            comment: comment,
                            onUserTap: () => goUserPage(context, comment.uid),
                          );
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
