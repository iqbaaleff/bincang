import 'package:bincang/admin/screens/manage_post_page.dart';
import 'package:bincang/admin/screens/report_page.dart';
import 'package:bincang/admin/screens/statistics_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:bincang/services/auth/auth_services.dart';
import '../../widget/my_setting_tile.dart';

class ReportPage extends StatefulWidget {
  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  late Future<List<DocumentSnapshot>> _reportedUsers;

  @override
  void initState() {
    super.initState();
    _reportedUsers = getReportedUsers();
  }

  Future<List<DocumentSnapshot>> getReportedUsers() async {
    QuerySnapshot reports =
        await FirebaseFirestore.instance.collection('Reports').get();
    return reports.docs;
  }

  Future<void> suspendUser(String userId) async {
    try {
      DateTime suspendEndDate = DateTime.now().add(Duration(days: 90));
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      WriteBatch batch = firestore.batch();

      DocumentReference userRef = firestore.collection('Users').doc(userId);
      batch.update(userRef, {
        'isSuspended': true,
        'suspendUntil': suspendEndDate,
      });

      QuerySnapshot posts = await firestore
          .collection('Post')
          .where('ownerId', isEqualTo: userId)
          .get();

      for (var doc in posts.docs) {
        batch.delete(doc.reference);
      }

      QuerySnapshot reports = await firestore
          .collection('Reports')
          .where('messageOwnerId', isEqualTo: userId)
          .get();

      for (var doc in reports.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      setState(() {
        _reportedUsers = getReportedUsers();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Akun berhasil disuspend hingga ${DateFormat('dd MMM yyyy').format(suspendEndDate)}",
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal mensuspend akun: $e")),
      );
    }
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
            Text("Akun yang Dilaporkan",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<DocumentSnapshot>>(
                future: _reportedUsers,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text("Tidak ada laporan"));
                  }
                  return ListView(
                    children: snapshot.data!.map((doc) {
                      return Card(
                        color: AppColors.third,
                        elevation: 4,
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Text("User ID: ${doc['messageOwnerId']}",
                              style: TextStyle(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            "Dilaporkan oleh: ${doc['reportedBy']}",
                            style: TextStyle(color: AppColors.secondary),
                          ),
                          trailing: Column(
                            children: [
                              ElevatedButton(
                                onPressed: () =>
                                    suspendUser(doc['messageOwnerId']),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: Text(
                                  "Suspend",
                                  style: TextStyle(
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
