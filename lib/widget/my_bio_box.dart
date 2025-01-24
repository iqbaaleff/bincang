import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MyBioBox extends StatelessWidget {
  final String text;
  const MyBioBox({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
        // border: Border.all(
        //   width: 2,
        // ),
        color: Colors.white,
      ),
      padding: EdgeInsets.all(25),
      child: Text(
        text.isNotEmpty ? text : "Tidak ada bio",
      ),
    );
  }
}
