import 'package:bincang/helper/app_colors.dart';
import 'package:flutter/material.dart';

class MySettingTile extends StatelessWidget {
  final String title;
  final Widget action;
  final void Function()? onTap;

  const MySettingTile(
      {super.key, required this.title, required this.action, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(
        title,
        style: TextStyle(color: AppColors.secondary),
      ),
      trailing: action,
      iconColor: AppColors.third,
    );
  }
}
