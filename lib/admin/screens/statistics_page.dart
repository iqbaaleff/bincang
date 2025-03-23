import 'package:bincang/helper/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StatisticsPage extends StatelessWidget {
  Future<int> _getCount(String collection, {String? field}) async {
    Query query = FirebaseFirestore.instance.collection(collection);
    if (field != null) {
      DateTime oneWeekAgo = DateTime.now().subtract(Duration(days: 7));
      query = query.where(field, isGreaterThan: oneWeekAgo);
    }
    return (await query.get()).size;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            _buildStatItem("Total Pengguna", _getCount("Users")),
            _buildStatItem("Total Postingan", _getCount("Post")),
            _buildStatItem("Pengguna Baru Minggu Ini",
                _getCount("Users", field: "createdAt")),
            _buildStatItem(
                "Postingan Minggu Ini", _getCount("Post", field: "timestamp")),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, Future<int> future) {
    return FutureBuilder<int>(
      future: future,
      builder: (context, snapshot) {
        return Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: AppColors.third,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label,
                    style: TextStyle(fontSize: 16, color: Colors.white)),
                snapshot.connectionState == ConnectionState.waiting
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        "${snapshot.data}",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
              ],
            ),
          ),
        );
      },
    );
  }
}
