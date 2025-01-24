import 'package:bincang/models/post.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MyPostsTile extends StatefulWidget {
  final Post post;
  const MyPostsTile({super.key, required this.post});

  @override
  State<MyPostsTile> createState() => _MyPostsTileState();
}

class _MyPostsTileState extends State<MyPostsTile> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: size.width * 0.05, vertical: size.height * 0.004),
      padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.02, vertical: size.height * 0.02),
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Bagian atas
          Row(
            children: [
              Icon(
                Icons.person,
                color: Colors.black54,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.01),
                child: Text(
                  widget.post.name,
                  style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                "@" + widget.post.username,
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
            ],
          ),

          SizedBox(
            height: size.height * 0.004,
          ),

          // Konten
          Text(widget.post.message),
        ],
      ),
    );
  }
}
