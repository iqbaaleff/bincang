import 'package:bincang/user/screens/profile_page.dart';
import 'package:bincang/user/screens/search_page.dart';
import 'package:bincang/widget/my_drawer_tile.dart';
import 'package:bincang/user/screens/setting_page.dart';
import 'package:bincang/services/auth/auth_services.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  MyDrawer({super.key});

  final _auth = AuthServices();

  void logout() {
    _auth.logout();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          //logo

          Container(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 50),
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 72,
                  ),
                ),
                //home
                MyDrawerTile(
                  title: "Beranda",
                  icon: Icons.home,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                //profil
                MyDrawerTile(
                  title: "Profil",
                  icon: Icons.person,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProfilePage(uid: _auth.getCurrentUid()!),
                        ));
                  },
                ),
                //search
                MyDrawerTile(
                  title: "Pencarian",
                  icon: Icons.search,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchPage(),
                      ),
                    );
                  },
                ),
                //setting
                MyDrawerTile(
                  title: "Pengaturan",
                  icon: Icons.settings,
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingPage(),
                        ));
                  },
                ),
              ],
            ),
          ),

          //logout
          SizedBox(
            width: 200,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber, // Warna latar belakang tombol
                foregroundColor: Colors.black, // Warna teks tombol
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ), // Border radius
                ),
              ),
              onPressed: logout,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: Text(
                      "Keluar",
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
