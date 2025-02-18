import 'package:bincang/helper/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MyInputAlertBox extends StatelessWidget {
  final TextEditingController textController;
  final String hintText;
  final void Function()? onPressed;
  final String onPressedText;
  const MyInputAlertBox(
      {super.key,
      required this.textController,
      required this.hintText,
      this.onPressed,
      required this.onPressedText});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AlertDialog(
      backgroundColor: AppColors.third,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      content: Padding(
        padding: EdgeInsets.only(top: size.height * 0.01),
        child: TextField(
          controller: textController,
          maxLength: 140,
          maxLines: 3,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hintText,
            hintStyle: TextStyle(color: AppColors.text),
            counterStyle: TextStyle(color: AppColors.text),
          ),
          style: TextStyle(
            color: AppColors.text,
          ),
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                textController.clear();
              },
              child: Text(
                "Batal",
                style: TextStyle(
                  color: AppColors.text,
                ),
              ),
            ),
            SizedBox(
              width: size.width * 0.03,
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                onPressed!();
                textController.clear();
              },
              child: Text(
                onPressedText,
                style: TextStyle(color: AppColors.text),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
