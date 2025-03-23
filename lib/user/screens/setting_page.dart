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

  void confirmDelete(BuildContext conntext) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Hapus akun?"),
        content: Text("Apakah kamu yakin?"),
        actions: [
          // Batal
          TextButton(
            style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: AppColors.third),
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Batal",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          // Block
          TextButton(
            style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: AppColors.third),
            onPressed: () async {
              await AuthServices().deleteAccount();
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            child: Text(
              "Hapus",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
            title: "Hapus akun",
            action: IconButton(
              onPressed: () => confirmDelete(context),
              icon: Icon(Icons.delete),
            ),
          ),
          MySettingTile(
            title: "Keluar",
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
