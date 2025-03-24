import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bincang/helper/app_colors.dart';
import 'package:bincang/helper/navigate_pages.dart';
import 'package:bincang/services/database/database_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Impor package intl

class NotifPage extends StatelessWidget {
  // Fungsi untuk memformat timestamp
  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('dd-MM-yyyy HH.mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final databaseProvider = Provider.of<DatabaseProvider>(context);

    // Muat notifikasi saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      databaseProvider.loadNotifications();
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          'Notifikasi',
          style: TextStyle(
            color: AppColors.third,
          ),
        ),
      ),
      body: databaseProvider.notifications.isEmpty
          ? Center(
              child: Text(
                'Tidak ada notifikasi',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            )
          : ListView.builder(
              itemCount: databaseProvider.notifications.length,
              itemBuilder: (context, index) {
                final notification = databaseProvider.notifications[index];
                return Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.all(10),
                      leading: Icon(
                        notification.type == 'like'
                            ? Icons.favorite
                            : Icons.comment,
                        color: AppColors.third,
                      ),
                      title: Text(
                        notification.type == 'like'
                            ? '${notification.senderName} (@${notification.senderUsername}) menyukai postingan Anda'
                            : '${notification.senderName} (@${notification.senderUsername}) ${notification.message}',
                      ),
                      subtitle: Text(
                        'Pada: ${formatTimestamp(notification.timestamp)}', // Format timestamp
                        style: TextStyle(
                          color: AppColors.third,
                          fontSize: 12,
                        ),
                      ),
                      trailing: notification.isRead
                          ? null
                          : Icon(Icons.circle, color: Colors.red, size: 10),
                      onTap: () async {
                        // Tandai notifikasi sebagai sudah dibaca
                        await databaseProvider
                            .markNotificationAsRead(notification.id);

                        // Ambil data postingan berdasarkan postId
                        final post = await databaseProvider
                            .getPostById(notification.postId);
                        if (post != null) {
                          // Navigasi ke halaman postingan
                          goPostPage(context, post);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Postingan tidak ditemukan')),
                          );
                        }
                      },
                    ),
                    Divider(
                      color: Colors.black12,
                    )
                  ],
                );
              },
            ),
    );
  }
}
