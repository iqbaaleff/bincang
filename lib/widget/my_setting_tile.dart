import 'package:flutter/material.dart';

class MySettingTile extends StatelessWidget {
  final String title;
  final Widget action;
  final void Function()? onTap;

  const MySettingTile({super.key, required this.title, required this.action, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(title),
      trailing: action,
    );
  }
}
