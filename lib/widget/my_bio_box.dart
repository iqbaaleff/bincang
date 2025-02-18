import 'package:bincang/helper/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MyBioBox extends StatelessWidget {
  final String text;
  const MyBioBox({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: size.width * 0.05, vertical: size.height * 0.004),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(15)),
        color: AppColors.third,
      ),
      padding: EdgeInsets.all(25),
      child: Text(
        text.isNotEmpty ? text : "Tidak ada bio",
        style: TextStyle(
          color: AppColors.secondary,
        ),
      ),
    );
  }
}
