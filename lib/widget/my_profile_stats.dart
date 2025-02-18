import 'package:bincang/helper/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MyProfileStats extends StatelessWidget {
  final int postCount;
  final int followerCount;
  final int followingCount;
  final void Function()? onTap;
  const MyProfileStats(
      {super.key,
      required this.postCount,
      required this.followerCount,
      required this.followingCount,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    var textStyleForCount = TextStyle(fontSize: 20, color: Colors.black);
    var textStyleForText = TextStyle(color: AppColors.text);
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // post
          SizedBox(
            width: 100,
            child: Column(
              children: [
                Text(
                  postCount.toString(),
                  style: textStyleForCount,
                ),
                Text(
                  "Postingan",
                  style: textStyleForText,
                ),
              ],
            ),
          ),

          // follower
          SizedBox(
            width: 100,
            child: Column(
              children: [
                Text(
                  followerCount.toString(),
                  style: textStyleForCount,
                ),
                Text(
                  "Pengikut",
                  style: textStyleForText,
                ),
              ],
            ),
          ),

          //following
          SizedBox(
            width: 100,
            child: Column(
              children: [
                Text(
                  followingCount.toString(),
                  style: textStyleForCount,
                ),
                Text(
                  "Mengikuti",
                  style: textStyleForText,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
