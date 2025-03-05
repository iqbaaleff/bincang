import 'package:bincang/admin/screens/manage_post_page.dart';
import 'package:bincang/admin/screens/report_page.dart';
import 'package:bincang/admin/screens/statistics_page.dart';
import 'package:bincang/helper/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:bincang/services/auth/auth_services.dart';
import '../../widget/my_setting_tile.dart';

class HomepageAdmin extends StatefulWidget {
  @override
  _HomepageAdminState createState() => _HomepageAdminState();
}

class _HomepageAdminState extends State<HomepageAdmin> {
  final _auth = AuthServices();
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    StatisticsPage(),
    ReportPage(),
    ManagePostsPage(),
  ];

  void _onSelectPage(int index) {
    setState(() => _selectedIndex = index);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppColors.secondary),
        title: Text(
          "Dashboard",
          style: TextStyle(
            color: AppColors.secondary,
          ),
        ),
        backgroundColor: AppColors.primary,
      ),
      drawer: Drawer(
        backgroundColor: AppColors.secondary,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 100,
              child: Center(
                child: Text("Dashboard",
                    style: TextStyle(color: AppColors.third, fontSize: 24)),
              ),
            ),
            _buildDrawerItem(Icons.analytics, "Statistik", 0),
            _buildDrawerItem(Icons.report, "Acc Report", 1),
            _buildDrawerItem(Icons.post_add, "Manajemen Postingan", 2),
            Spacer(),
            MySettingTile(
              title: "Keluar",
              action: IconButton(
                onPressed: _auth.logout,
                icon: Icon(Icons.logout_outlined, color: Colors.red),
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }

  ListTile _buildDrawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon,
          color: _selectedIndex == index ? AppColors.third : Colors.black54),
      title: Text(
        title,
        style: TextStyle(
          fontWeight:
              _selectedIndex == index ? FontWeight.bold : FontWeight.normal,
          color: _selectedIndex == index ? AppColors.third : Colors.black,
        ),
      ),
      onTap: () => _onSelectPage(index),
    );
  }
}
