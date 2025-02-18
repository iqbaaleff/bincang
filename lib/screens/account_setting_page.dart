import 'package:bincang/helper/app_colors.dart';
import 'package:bincang/services/auth/auth_services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AccountSettingPage extends StatefulWidget {
  const AccountSettingPage({super.key});

  @override
  State<AccountSettingPage> createState() => _AccountSettingPageState();
}

class _AccountSettingPageState extends State<AccountSettingPage> {
  void confirmDelete(BuildContext conntext) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Hapus akun?"),
        content: Text("Apakah kamu yakin?"),
        actions: [
          // Batal
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Batal"),
          ),
          // Block
          TextButton(
            onPressed: () async {
              await AuthServices().deleteAccount();
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            child: Text("Hapus"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          "Pengaturan akun",
          style: TextStyle(color: AppColors.third),
        ),
      ),
      body: Column(
        children: [
          GestureDetector(
            onTap: () => confirmDelete(context),
            child: Container(
              margin: EdgeInsets.symmetric(
                  horizontal: size.width * 0.05, vertical: size.height * 0.004),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15)),
                color: Colors.red,
              ),
              padding: EdgeInsets.all(25),
              child: Center(
                child: Text(
                  "Hapus akun",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
