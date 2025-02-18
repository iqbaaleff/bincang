import 'package:bincang/helper/app_colors.dart';
import 'package:bincang/services/database/database_provider.dart';
import 'package:bincang/widget/my_user_tile.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    late final listeningProvider = Provider.of<DatabaseProvider>(context);
    late final databaseProvider =
        Provider.of<DatabaseProvider>(context, listen: false);
    return Scaffold(
        backgroundColor: AppColors.primary,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          title: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Cari disini..",
              hintStyle: TextStyle(
                color: AppColors.secondary,
              ),
              border: InputBorder.none,
              suffixIcon: Icon(
                Icons.search,
                color: AppColors.secondary,
              ),
            ),
            style: TextStyle(
              color: AppColors.secondary,
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                databaseProvider.searchUsers(value);
              } else {
                databaseProvider.searchUsers("");
              }
            },
          ),
        ),
        body: listeningProvider.searchResult.isEmpty
            ? Center(
                child: Text(
                  "Pengguna tidak ditemukan..",
                  style: TextStyle(color: AppColors.secondary),
                ),
              )
            : ListView.builder(
                itemCount: listeningProvider.searchResult.length,
                itemBuilder: (context, index) {
                  final user = listeningProvider.searchResult[index];

                  return MyUserTile(user: user);
                },
              ));
  }
}
