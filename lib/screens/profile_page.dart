import 'package:bincang/models/user.dart';
import 'package:bincang/services/auth/auth_services.dart';
import 'package:bincang/services/database/database_provider.dart';
import 'package:bincang/widget/my_bio_box.dart';
import 'package:bincang/widget/my_input_alert_box.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  final String uid;
  const ProfilePage({super.key, required this.uid});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Provider
  late final databaseProvider =
      Provider.of<DatabaseProvider>(context, listen: false);

  // User info
  UserProfile? user;
  String currentUserId = AuthServices().getCurrentUid();

  final bioController = TextEditingController();

  bool isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    user = await databaseProvider.userProfile(widget.uid);

    setState(() {
      isLoading = false;
    });
  }

  // Edit Bio
  void _showEditBioBox() {
    showDialog(
        context: context,
        builder: (context) => MyInputAlertBox(
            textController: bioController,
            hintText: "Edit Bio",
            onPressed: saveBio,
            onPressedText: "Simpan"));
  }

  Future<void> saveBio() async {
    setState(() {
      isLoading = true;
    });

    await databaseProvider.updateBio(bioController.text);
    await loadUser();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(isLoading ? '' : user!.name),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
        child: ListView(
          children: [
            // Username
            Center(
              child: Text(isLoading ? '' : '@${user!.username}'),
            ),
            // Profile Picture
            Padding(
              padding: EdgeInsets.symmetric(vertical: size.height * 0.05),
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(size.height * 1),
                  ),
                  padding: EdgeInsets.all(size.width * 0.08),
                  child: Icon(
                    Icons.person,
                    size: size.width * 0.2,
                  ),
                ),
              ),
            ),
            // Profile Stats

            // Follow/Unfollow Button

            // Edit bio
            Padding(
              padding: EdgeInsets.symmetric(vertical: size.height * 0.005),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Bio",
                    style: TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                  GestureDetector(
                      onTap: _showEditBioBox,
                      child: Icon(
                        Icons.edit,
                        color: Colors.black54,
                      )),
                ],
              ),
            ),

            // Bio Box
            MyBioBox(text: isLoading ? '' : user!.bio),
            // List Of Post From User
          ],
        ),
      ),
    );
  }
}
