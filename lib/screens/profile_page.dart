import 'package:bincang/helper/app_colors.dart';
import 'package:bincang/helper/navigate_pages.dart';
import 'package:bincang/models/user.dart';
import 'package:bincang/screens/follow_list_page.dart';
import 'package:bincang/services/auth/auth_services.dart';
import 'package:bincang/services/database/database_provider.dart';
import 'package:bincang/widget/my_bio_box.dart';
import 'package:bincang/widget/my_follow_button.dart';
import 'package:bincang/widget/my_input_alert_box.dart';
import 'package:bincang/widget/my_posts_tile.dart';
import 'package:bincang/widget/my_profile_stats.dart';
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
  bool _isFollowing = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    user = await databaseProvider.userProfile(widget.uid);

    await databaseProvider.loadUserFollower(widget.uid);
    await databaseProvider.loadUserFollowing(widget.uid);

    _isFollowing = databaseProvider.isFollowing(widget.uid);

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

  Future<void> toggleFollow() async {
    // unfoll
    if (_isFollowing) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Berhenti mengikuti"),
          content: Text("Apakah kamu yakin?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Batal"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await databaseProvider.unfollowUser(widget.uid);
              },
              child: Text("Yakin"),
            ),
          ],
        ),
      );
    } else {
      await databaseProvider.followUser(widget.uid);
    }
    setState(() {
      _isFollowing = !_isFollowing;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Get user posts
    final allUserPost = listeningProvider.filterUserPosts(widget.uid);

    final followerCount = listeningProvider.getFollowerCount(widget.uid);
    final followingCount = listeningProvider.getFollowingCount(widget.uid);

    _isFollowing = listeningProvider.isFollowing(widget.uid);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          isLoading ? '' : user!.name,
          style: TextStyle(
            color: AppColors.third,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // Username
          Padding(
            padding: EdgeInsets.symmetric(vertical: size.height * 0.01),
            child: Center(
              child: Text(isLoading ? '' : '@${user!.username}',
                  style: TextStyle(
                    color: AppColors.third,
                  )),
            ),
          ),
          // Profile Picture
          Padding(
            padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.third,
                  borderRadius: BorderRadius.circular(size.height * 1),
                ),
                padding: EdgeInsets.all(size.width * 0.08),
                child: Icon(
                  Icons.person,
                  color: AppColors.secondary,
                  size: size.width * 0.2,
                ),
              ),
            ),
          ),
          // Profile Stats
          MyProfileStats(
            postCount: allUserPost.length,
            followerCount: followerCount,
            followingCount: followingCount,
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FollowListPage(
                    uid: widget.uid,
                  ),
                )),
          ),

          // Follow/Unfollow Button
          if (user != null && user!.uid != currentUserId)
            MyFollowButton(onPressed: toggleFollow, isFollowing: _isFollowing),

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
                    color: AppColors.text,
                  ),
                ),
                if (user != null && user!.uid == currentUserId)
                  GestureDetector(
                      onTap: _showEditBioBox,
                      child: Icon(
                        Icons.edit,
                        color: AppColors.text,
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
              style: TextStyle(color: Colors.black),
            ),
          ),
          // List postingan user
          allUserPost.isEmpty
              ?
              // Postingan user kosong
              Center(
                  child: Text(
                    "Belum ada postingan",
                    style: TextStyle(color: Colors.black),
                  ),
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
