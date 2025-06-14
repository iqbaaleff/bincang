import 'package:bincang/models/post.dart';
import 'package:bincang/user/screens/account_setting_page.dart';
import 'package:bincang/user/screens/add_post_page.dart';
import 'package:bincang/user/screens/blocked_user_page.dart';
import 'package:bincang/user/screens/home_page.dart';
import 'package:bincang/user/screens/post_page.dart';
import 'package:bincang/user/screens/profile_page.dart';
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

void goBlockedUsersPage(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => BlockedUsersPage(),
    ),
  );
}

void goAccountSettingPage(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => AccountSettingPage(),
    ),
  );
}

// pergi ke homepage tapi remove semua routes
void goHomePage(BuildContext context) {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (context) => Homepage(),
    ),
    (route) => route.isFirst,
  );
}

void goAddPostPage(BuildContext context, String uid) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => AddPostPage(uid: uid,),
    ),
  );
}
