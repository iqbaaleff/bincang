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
  @override
  Widget build(BuildContext context) {
    final allComments = listeningProvider.getComments(widget.post.id);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.post.message,
          style: TextStyle(color: AppColors.third),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        children: [
          MyPostsTile(
            post: widget.post,
            onUserTap: () => goUserPage(context, widget.post.uid),
            onPostTap: () {},
          ),

          // Comment di postingan ini
          allComments.isEmpty
              ? Center(
                  child: Text(
                    "Tidak ada komentar..",
                    style: TextStyle(color: Colors.black),
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
                )
        ],
      ),
    );
  }
}
