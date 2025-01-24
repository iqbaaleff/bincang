import 'package:bincang/models/post.dart';
import 'package:bincang/screens/post_page.dart';
import 'package:bincang/screens/profile_page.dart';
import 'package:flutter/material.dart';

void goUserPage(BuildContext context, String uid) {
  // Navigasi ke page user
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ProfilePage(uid: uid),
    ),
  );
}

void goPostPage(BuildContext context, Post post) {
  // Navigasi ke page user
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PostPage(post: post),
    ),
  );
}
