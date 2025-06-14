import 'package:bincang/helper/app_colors.dart';
import 'package:bincang/helper/navigate_pages.dart';
import 'package:bincang/models/post.dart';
import 'package:bincang/models/comment.dart';
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
  late final databaseProvider =
      Provider.of<DatabaseProvider>(context, listen: false);
  final TextEditingController _commentController = TextEditingController();
  bool _showCommentField = false;
  String? _replyingToCommentId;

  // Map untuk menyimpan status tampilan balasan komentar
  final Map<String, bool> _showReplies = {};

  @override
  void initState() {
    super.initState();
    databaseProvider.loadComments(widget.post.id);
  }

  void _toggleCommentField({String? parentId, String? replyingToUser}) {
    setState(() {
      _showCommentField = true;
      _replyingToCommentId = parentId;
      if (replyingToUser != null) {
        _commentController.text =
            "@$replyingToUser "; // Tambahkan username ke input
      }
    });
  }

  void _submitComment() {
    final text = _commentController.text.trim();
    if (text.isNotEmpty) {
      databaseProvider.addComments(widget.post.id, text,
          parentId: _replyingToCommentId);
      _commentController.clear();
      setState(() {
        _showCommentField = false;
        _replyingToCommentId = null;
      });
    }
  }

  // Fungsi untuk menampilkan atau menyembunyikan balasan komentar
  void _toggleRepliesVisibility(String commentId) {
    setState(() {
      _showReplies[commentId] = !(_showReplies[commentId] ?? false);
    });
  }

  List<Widget> _buildComments(List<Comment> allComments, {String? parentId}) {
    // Filter komentar berdasarkan parentId
    List<Comment> filteredComments =
        allComments.where((comment) => comment.parentId == parentId).toList();

    return filteredComments.map((comment) {
      // Cek apakah komentar ini memiliki balasan
      final hasReplies = allComments.any((c) => c.parentId == comment.id);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyCommentTile(
            comment: comment,
            onUserTap: () => goUserPage(context, comment.uid),
            onReplyTap: () => _toggleCommentField(
              parentId: comment.id,
              replyingToUser:
                  comment.username, // Tambahkan nama pengguna ke input
            ),
          ),
          // Tombol "Tampilkan Balasan" hanya muncul di komentar induk
          if (hasReplies && parentId == null)
            TextButton(
              onPressed: () => _toggleRepliesVisibility(comment.id),
              child: Text(
                _showReplies[comment.id] == true
                    ? "Sembunyikan Balasan"
                    : "Tampilkan Balasan",
                style: TextStyle(color: Colors.blue),
              ),
            ),
          // Tampilkan balasan jika status true
          if (_showReplies[comment.id] == true || parentId != null)
            ..._buildComments(allComments,
                parentId: comment.id), // Rekursif untuk menampilkan balasan
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title:
            Text(widget.post.message, style: TextStyle(color: AppColors.third)),
        backgroundColor: Colors.transparent,
      ),
      body: Consumer<DatabaseProvider>(
        builder: (context, provider, child) {
          final allComments =
              provider.getComments(widget.post.id).reversed.toList();

          return Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    MyPostsTile(
                      post: widget.post,
                      onUserTap: () => goUserPage(context, widget.post.uid),
                      onCommentTap: () => _toggleCommentField(),
                    ),
                    if (_showCommentField)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_replyingToCommentId != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 5),
                                child: Text(
                                  "Membalas komentar...",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            Row(
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
                                  icon:
                                      Icon(Icons.send, color: AppColors.third),
                                  onPressed: _submitComment,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    allComments.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("Tidak ada komentar..",
                                  style: TextStyle(color: Colors.black)),
                            ),
                          )
                        : Column(
                            children: _buildComments(
                                allComments), // Menampilkan nested comments
                          ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
