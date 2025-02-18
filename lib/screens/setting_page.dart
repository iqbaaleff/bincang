import 'package:bincang/helper/app_colors.dart';
import 'package:bincang/helper/navigate_pages.dart';
import 'package:bincang/services/auth/auth_services.dart';
import 'package:bincang/widget/my_setting_tile.dart';
import 'package:flutter/material.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final _auth = AuthServices();

  void logout() {
    _auth.logout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          "Pengaturan",
          style: TextStyle(
            color: AppColors.third,
          ),
        ),
      ),
      body: Column(
        children: [
          MySettingTile(
            title: "Blocked Users",
            action: IconButton(
              onPressed: () => goBlockedUsersPage(context),
              icon: Icon(Icons.arrow_forward_ios),
            ),
          ),
          MySettingTile(
            title: "Pengaturan akun",
            action: IconButton(
              onPressed: () => goAccountSettingPage(context),
              icon: Icon(Icons.arrow_forward_ios),
            ),
          ),
          MySettingTile(
            title: "Keluar akun",
            action: IconButton(
              onPressed: logout,
              icon: Icon(Icons.logout_outlined),
            ),
          ),
        ],
      ),
    );
  }
}
