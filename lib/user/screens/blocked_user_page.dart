import 'package:bincang/helper/app_colors.dart';
import 'package:bincang/services/database/database_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BlockedUsersPage extends StatefulWidget {
  const BlockedUsersPage({super.key});

  @override
  State<BlockedUsersPage> createState() => _BlockedUserPageState();
}

class _BlockedUserPageState extends State<BlockedUsersPage> {
  late final listeningProvider = Provider.of<DatabaseProvider>(context);
  late final databaseProvider =
      Provider.of<DatabaseProvider>(context, listen: false);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadBlockedUsers();
  }

  Future<void> loadBlockedUsers() async {
    await databaseProvider.loadBlockedUser();
  }

  void _showUnblockConfirmBox(String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Buka Blokir"),
        content: Text("Apakah kamu yakin akan membukanya?"),
        actions: [
          // Batal
          TextButton(
            style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: AppColors.third),
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Batal",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          // Buka Block
          TextButton(
            style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: AppColors.third),
            onPressed: () async {
              await databaseProvider.unblockUser(userId);
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Blokir telah dibuka"),
                ),
              );
            },
            child: Text(
              "Buka Blokir",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final blockedUsers = listeningProvider.blockedUsers;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          "Pengguna yang diblokir",
          style: TextStyle(color: AppColors.third),
        ),
      ),
      body: blockedUsers.isEmpty
          ? Center(
              child: Text(
              "Tidak ada yang di blokir..",
              style: TextStyle(color: Colors.black),
            ))
          : ListView.builder(
              itemCount: blockedUsers.length,
              itemBuilder: (context, index) {
                final user = blockedUsers[index];

                return ListTile(
                  title: Text(
                    user.name,
                    style: TextStyle(color: AppColors.primary),
                  ),
                  subtitle: Text(
                    '@${user.username}',
                    style: TextStyle(color: AppColors.text),
                  ),
                  trailing: IconButton(
                      onPressed: () => _showUnblockConfirmBox(user.uid),
                      icon: Icon(Icons.block, color: AppColors.third)),
                );
              },
            ),
    );
  }
}
