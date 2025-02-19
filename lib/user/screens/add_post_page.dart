import 'package:bincang/helper/app_colors.dart';
import 'package:bincang/models/user.dart';
import 'package:bincang/services/auth/auth_services.dart';
import 'package:bincang/services/database/database_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddPostPage extends StatefulWidget {
  final String uid;
  const AddPostPage({super.key, required this.uid});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  late final databaseProvider =
      Provider.of<DatabaseProvider>(context, listen: false);

  UserProfile? user;
  bool isLoading = true;
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    final fetchedUser = await databaseProvider.userProfile(widget.uid);
    setState(() {
      user = fetchedUser;
      isLoading = false;
    });
  }

  void postMessage() async {
    if (_messageController.text.isNotEmpty) {
      await databaseProvider.postMessage(_messageController.text);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Postingan Baru",
          style: TextStyle(
            color: AppColors.third,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.third,
                    borderRadius: BorderRadius.circular(size.height * 1),
                  ),
                  padding: EdgeInsets.all(size.width * 0.02),
                  child: Icon(
                    Icons.person,
                    color: AppColors.secondary,
                    size: size.width * 0.08,
                  ),
                ),
                SizedBox(width: size.width * 0.03),
                Column(
                  children: [
                    isLoading
                        ? CircularProgressIndicator()
                        : Text(
                            user != null ? user!.name : "User tidak ditemukan",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                  ],
                ),
              ],
            ),
            SizedBox(height: size.height * 0.02),
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: "Apa yang baru?",
                hintStyle: TextStyle(color: AppColors.text.withOpacity(0.6)),
                border: InputBorder.none,
              ),
              style: TextStyle(color: AppColors.text),
            ),
            SizedBox(height: size.height * 0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                    onPressed: () {
                      postMessage();
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.send,
                      color: AppColors.third,
                    )),
              ],
            ),
            Divider(
              color: Colors.grey.shade400,
            )
          ],
        ),
      ),
    );
  }
}
