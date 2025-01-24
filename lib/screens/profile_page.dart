import 'package:bincang/helper/navigate_pages.dart';
import 'package:bincang/models/user.dart';
import 'package:bincang/services/auth/auth_services.dart';
import 'package:bincang/services/database/database_provider.dart';
import 'package:bincang/widget/my_bio_box.dart';
import 'package:bincang/widget/my_input_alert_box.dart';
import 'package:bincang/widget/my_posts_tile.dart';
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
  late final listeningProvider = Provider.of<DatabaseProvider>(context);
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

    // Get user posts
    final allUserPost = listeningProvider.filterUserPosts(widget.uid);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(isLoading ? '' : user!.name),
        centerTitle: true,
      ),
      body: ListView(
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
            padding: EdgeInsets.symmetric(
                vertical: size.height * 0.005, horizontal: size.width * 0.05),
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

          Padding(
            padding: EdgeInsets.only(
                left: size.width * 0.05,
                top: size.height * 0.03,
                bottom: size.height * 0.005),
            child: Text(
              "Postingan",
              style: TextStyle(color: Colors.black54),
            ),
          ),
          // List postingan user
          allUserPost.isEmpty
              ?
              // Postingan user kosong
              const Center(
                  child: Text("Belum ada postingan"),
                )
              :
              // Postingan user ada
              ListView.builder(
                  itemCount: allUserPost.length,
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    // Get postingan individu
                    final post = allUserPost[index];
                    // Post tile UI
                    return MyPostsTile(
                      post: post,
                      onPostTap: () => goPostPage(context, post),
                      onUserTap: () {},
                    );
                  },
                )
        ],
      ),
    );
  }
}
