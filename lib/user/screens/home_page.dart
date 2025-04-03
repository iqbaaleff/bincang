import 'package:bincang/user/screens/notif_page.dart';
import 'package:flutter/material.dart';
import 'package:bincang/user/screens/profile_page.dart';
import 'package:bincang/user/screens/search_page.dart';
import 'package:bincang/user/screens/setting_page.dart';
import 'package:bincang/services/auth/auth_services.dart';
import 'package:bincang/helper/app_colors.dart';
import 'package:bincang/helper/navigate_pages.dart';
import 'package:bincang/models/post.dart';
import 'package:bincang/services/database/database_provider.dart';
import 'package:bincang/widget/my_drawer.dart';
import 'package:bincang/widget/my_input_alert_box.dart';
import 'package:bincang/widget/my_posts_tile.dart';
import 'package:provider/provider.dart';

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final _auth = AuthServices();
  int _selectedIndex = 0;
  late final listeningProvider = Provider.of<DatabaseProvider>(context);
  late final databaseProvider =
      Provider.of<DatabaseProvider>(context, listen: false);
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadAllPost();
  }

  Future<void> loadAllPost() async {
    await databaseProvider.loadAllPost();
  }

  void _openPostMessage() {
    showDialog(
      context: context,
      builder: (context) => MyInputAlertBox(
          textController: _messageController,
          hintText: "Apa yang anda pikirkan?",
          onPressed: () async {
            await postMessage(_messageController.text);
          },
          onPressedText: "Post"),
    );
  }

  Future<void> postMessage(String message) async {
    await databaseProvider.postMessage(message);
    await loadAllPost();
    setState(() {});
  }

  static List<Widget> _pages(BuildContext context) => <Widget>[
        DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: AppColors.primary,
              surfaceTintColor: AppColors.third,
              
              title: Text(
                "Bincang",
                style: TextStyle(
                  color: AppColors.third,
                ),
              ),
              centerTitle: true,
              bottom: TabBar(
                  dividerColor: Colors.transparent,
                  labelColor: AppColors.secondary,
                  unselectedLabelColor: AppColors.secondary,
                  indicatorColor: AppColors.secondary,
                  tabs: [
                    Tab(
                      text: "Untuk anda",
                    ),
                    Tab(
                      text: "Mengikuti",
                    ),
                  ]),
            ),
            body: Consumer<DatabaseProvider>(
              builder: (context, provider, child) {
                return TabBarView(
                  children: [
                    _buildPostList(provider.allPost, context),
                    _buildPostList(provider.followingPosts, context),
                  ],
                );
              },
            ),
          ),
        ),
        SearchPage(),
        NotifPage(),
        ProfilePage(uid: AuthServices().getCurrentUid()!),
      ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _pages(context)[_selectedIndex],
      bottomNavigationBar: BottomAppBar(
        color: AppColors.primary,
        shape: CircularNotchedRectangle(),
        notchMargin: 15.0,
        surfaceTintColor: AppColors.third,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.home),
              color:
                  _selectedIndex == 0 ? AppColors.third : AppColors.secondary,
              onPressed: () => _onItemTapped(0),
            ),
            IconButton(
              icon: Icon(Icons.search),
              color:
                  _selectedIndex == 1 ? AppColors.third : AppColors.secondary,
              onPressed: () => _onItemTapped(1),
            ),
            SizedBox(width: 40), // Untuk memberi ruang bagi FAB
            IconButton(
              icon: Icon(Icons.notifications),
              color:
                  _selectedIndex == 2 ? AppColors.third : AppColors.secondary,
              onPressed: () => _onItemTapped(2),
            ),
            IconButton(
              icon: Icon(Icons.person),
              color:
                  _selectedIndex == 3 ? AppColors.third : AppColors.secondary,
              onPressed: () => _onItemTapped(3),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: CircleBorder(),
        onPressed: () =>
            goAddPostPage(context, AuthServices().getCurrentUid()!),
        backgroundColor: AppColors.third,
        child: Icon(Icons.add, color: AppColors.secondary),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  static Widget _buildPostList(List<Post> posts, BuildContext context) {
    return posts.isEmpty
        ? Center(
            child: Text(
              "Tidak ada apapun...",
              style: TextStyle(
                color: Colors.black87,
              ),
            ),
          )
        : RefreshIndicator(
            onRefresh: () async {
              // Panggil fungsi untuk memperbarui data
              final databaseProvider =
                  Provider.of<DatabaseProvider>(context, listen: false);
              await databaseProvider.loadAllPost();
            },
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return MyPostsTile(
                  post: post,
                  onUserTap: () => goUserPage(context, post.uid),
                  onPostTap: () => goPostPage(context, post),
                );
              },
            ),
          );
  }
}
