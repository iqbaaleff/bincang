import 'package:bincang/helper/navigate_pages.dart';
import 'package:bincang/models/post.dart';
import 'package:bincang/widget/my_posts_tile.dart';
import 'package:flutter/material.dart';

class PostPage extends StatefulWidget {
  final Post post;
  const PostPage({super.key, required this.post});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(widget.post.message),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        children: [
          MyPostsTile(
            post: widget.post,
            onUserTap: () => goUserPage(context, widget.post.uid),
            onPostTap: () {},
          )
        ],
      ),
    );
  }
}
