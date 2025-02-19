import 'package:bincang/helper/app_colors.dart';
import 'package:bincang/models/user.dart';
import 'package:bincang/screens/profile_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MyUserTile extends StatelessWidget {
  final UserProfile user;
  const MyUserTile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(
              horizontal: size.width * 0.01, vertical: size.height * 0.002),
          child: ListTile(
            title: Text(
              user.name,
              style: TextStyle(color: Colors.black),
            ),
            leading: Icon(Icons.person, color: AppColors.text),
            subtitle: Text(
              '@${user.username}',
              style: TextStyle(color: AppColors.text),
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfilePage(uid: user.uid),
              ),
            ),
            trailing: Icon(Icons.arrow_forward_ios, color: AppColors.third),
          ),
        ),
        Divider(
          color: Colors.white10,
        )
      ],
    );
  }
}
