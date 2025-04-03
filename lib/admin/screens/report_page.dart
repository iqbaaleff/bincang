import 'package:bincang/helper/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';


class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  late Future<List<Map<String, dynamic>>> _reportedUsers;

  @override
  void initState() {
    super.initState();
    _reportedUsers = getReportedUsers();
  }

  // Fungsi untuk mengambil data pengguna berdasarkan userId
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>?;
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
    return null;
  }

  // Fungsi untuk mengambil data laporan dan menggabungkannya dengan data pengguna
  Future<List<Map<String, dynamic>>> getReportedUsers() async {
    try {
      QuerySnapshot reports =
          await FirebaseFirestore.instance.collection('Reports').get();

      // Ambil data pengguna untuk setiap laporan
      List<Map<String, dynamic>> reportedUsersWithData = await Future.wait(
        reports.docs.map((doc) async {
          Map<String, dynamic> reportData = doc.data() as Map<String, dynamic>;
          String userId = reportData['messageOwnerId'];
          String reportedById = reportData['reportedBy'];

          // Ambil data pengguna yang dilaporkan
          Map<String, dynamic>? userData = await getUserData(userId);
          // Ambil data pengguna yang melaporkan
          Map<String, dynamic>? reportedByData =
              await getUserData(reportedById);

          return {
            ...reportData,
            'username': userData?['username'] ?? 'Unknown User',
            'reportedByUsername': reportedByData?['username'] ?? 'Unknown User',
            'reportId': doc.id, // Simpan ID laporan untuk referensi
          };
        }),
      );

      return reportedUsersWithData;
    } catch (e) {
      print("Error fetching reported users: $e");
      return [];
    }
  }

  // Fungsi untuk menolak laporan
  Future<void> rejectReport(String reportId) async {
    try {
      await FirebaseFirestore.instance
          .collection('Reports')
          .doc(reportId)
          .delete();

      setState(() {
        _reportedUsers = getReportedUsers();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Laporan berhasil ditolak"),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menolak laporan: $e")),
      );
    }
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
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _reportedUsers,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text("Tidak ada laporan"));
                  }
                  return ListView(
                    children: snapshot.data!.map((report) {
                      return Card(
                        color: AppColors.third,
                        elevation: 4,
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Text("Username: ${report['username']}",
                              style: TextStyle(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            "Dilaporkan oleh: ${report['reportedByUsername']}",
                            style: TextStyle(color: AppColors.secondary),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Tombol Tolak
                              ElevatedButton(
                                onPressed: () =>
                                    rejectReport(report['reportId']),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                ),
                                child: Text(
                                  "Tolak",
                                  style: TextStyle(
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8), // Jarak antara tombol
                              // Tombol Suspend
                              ElevatedButton(
                                onPressed: () =>
                                    suspendUser(report['messageOwnerId']),
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
