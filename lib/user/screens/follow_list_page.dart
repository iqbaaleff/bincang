import 'package:bincang/models/user.dart';
import 'package:bincang/services/database/database_provider.dart';
import 'package:bincang/widget/my_user_tile.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FollowListPage extends StatefulWidget {
  final String uid;
  const FollowListPage({super.key, required this.uid});

  @override
  State<FollowListPage> createState() => _FollowListPageState();
}

class _FollowListPageState extends State<FollowListPage> {
  late final listeningProvider = Provider.of<DatabaseProvider>(context);
  late final databaseProvider =
      Provider.of<DatabaseProvider>(context, listen: false);
  @override
  void initState() {
    super.initState();
    loadFollowerList();
    loadFollowingList();
  }

  Future<void> loadFollowerList() async {
    await databaseProvider.loadUserFollower(widget.uid);
  }

  Future<void> loadFollowingList() async {
    await databaseProvider.loadUserFollowing(widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    final followers = listeningProvider.getListOfFollowersProfile(widget.uid);
    final following = listeningProvider.getListOfFollowingProfile(widget.uid);
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.amber,
            bottom: TabBar(
                dividerColor: Colors.transparent,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.black54,
                indicatorColor: Colors.grey,
                tabs: [
                  Tab(
                    text: "Pengikut",
                  ),
                  Tab(
                    text: "Mengikuti",
                  ),
                ]),
          ),
          body: TabBarView(
            children: [
              _buildUserList(followers, "Tidak ada pengikut.."),
              _buildUserList(following, "Tidak ada yang diikuti.."),
            ],
          ),
        ));
  }

  Widget _buildUserList(List<UserProfile> userList, String emptyMessage) {
    return userList.isEmpty
        ? Center(
            child: Text(emptyMessage),
          )
        : ListView.builder(
            itemCount: userList.length,
            itemBuilder: (context, index) {
              final user = userList[index];

              return MyUserTile(user: user);
            },
          );
  }
}
