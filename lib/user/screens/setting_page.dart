import 'package:bincang/helper/app_colors.dart';
import 'package:bincang/helper/navigate_pages.dart';
import 'package:bincang/services/auth/auth_services.dart';
import 'package:bincang/widget/my_setting_tile.dart';
import 'package:flutter/material.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final _auth = AuthServices();

  void logout() {
    _auth.logout();
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  void confirmDelete(BuildContext conntext) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Hapus akun?"),
        content: Text("Apakah kamu yakin?"),
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
          // Block
          TextButton(
            style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: AppColors.third),
            onPressed: () async {
              // Tampilkan dialog konfirmasi
              bool confirmDelete = await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("Konfirmasi Penghapusan"),
                  content: Text(
                      "Apakah Anda yakin ingin menghapus akun beserta semua postingan Anda? Tindakan ini tidak dapat dibatalkan."),
                  actions: [
                    TextButton(
                      style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: AppColors.third),
                      onPressed: () => Navigator.pop(context, false),
                      child:
                          Text("Batal", style: TextStyle(color: Colors.white)),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: AppColors.third),
                      onPressed: () => Navigator.pop(context, true),
                      child:
                          Text("Hapus", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );

              if (confirmDelete == true) {
                // Tampilkan loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) =>
                      Center(child: CircularProgressIndicator()),
                );

                try {
                  // Minta password untuk re-autentikasi
                  String? password = await showDialog(
                    context: context,
                    builder: (context) {
                      final passwordController = TextEditingController();
                      return AlertDialog(
                        title: Text("Verifikasi Password"),
                        content: TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                              labelText: 'Masukkan password Anda'),
                        ),
                        actions: [
                          TextButton(
                            style: TextButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                backgroundColor: AppColors.third),
                            onPressed: () => Navigator.pop(context),
                            child: Text("Batal",
                                style: TextStyle(color: Colors.white)),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                backgroundColor: AppColors.third),
                            onPressed: () =>
                                Navigator.pop(context, passwordController.text),
                            child: Text("Lanjutkan",
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      );
                    },
                  );

                  if (password != null && password.isNotEmpty) {
                    await AuthServices().deleteAccount(password);

                    // Tutup loading indicator
                    Navigator.pop(context);

                    // Navigasi ke halaman awal
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/', (route) => false);

                    // Tampilkan pesan sukses
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Akun berhasil dihapus")),
                    );
                  }
                } catch (e) {
                  // Tutup loading indicator
                  Navigator.pop(context);

                  // Tampilkan pesan error
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text("Gagal menghapus akun: ${e.toString()}")),
                  );
                }
              }
            },
            child: Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          "Pengaturan",
          style: TextStyle(
            color: AppColors.third,
          ),
        ),
      ),
      body: Column(
        children: [
          MySettingTile(
            title: "Blocked Users",
            action: IconButton(
              onPressed: () => goBlockedUsersPage(context),
              icon: Icon(Icons.arrow_forward_ios),
            ),
          ),
          MySettingTile(
            title: "Hapus akun",
            action: IconButton(
              onPressed: () => confirmDelete(context),
              icon: Icon(Icons.delete),
            ),
          ),
          MySettingTile(
            title: "Keluar",
            action: IconButton(
              onPressed: logout,
              icon: Icon(Icons.logout_outlined),
            ),
          ),
        ],
      ),
    );
  }
}
