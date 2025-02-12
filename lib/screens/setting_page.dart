import 'package:bincang/helper/navigate_pages.dart';
import 'package:bincang/widget/my_setting_tile.dart';
import 'package:flutter/material.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Pengaturan",
        ),
      ),
      body: Column(
        children: [
          MySettingTile(
            title: "Blocked Users",
            action: IconButton(
              onPressed: () => goAccountSettingPage(context),
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
        ],
      ),
    );
  }
}
