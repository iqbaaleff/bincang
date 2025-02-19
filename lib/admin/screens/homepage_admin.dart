import 'package:bincang/services/auth/auth_services.dart';
import 'package:bincang/widget/my_setting_tile.dart';
import 'package:flutter/material.dart';

class HomepageAdmin extends StatefulWidget {
  const HomepageAdmin({super.key});

  @override
  State<HomepageAdmin> createState() => _HomepageAdminState();
}

class _HomepageAdminState extends State<HomepageAdmin> {
  final _auth = AuthServices();

  void logout() {
    _auth.logout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
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
