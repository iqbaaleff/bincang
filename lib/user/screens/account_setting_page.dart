import 'package:bincang/helper/app_colors.dart';
import 'package:bincang/services/auth/auth_services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AccountSettingPage extends StatefulWidget {
  const AccountSettingPage({super.key});

  @override
  State<AccountSettingPage> createState() => _AccountSettingPageState();
}

class _AccountSettingPageState extends State<AccountSettingPage> {
  void confirmDelete(BuildContext conntext) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Hapus akun?"),
        content: Text("Apakah kamu yakin?"),
        actions: [
          // Batal
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Batal"),
          ),
          // Hapus
          TextButton(
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
                      onPressed: () => Navigator.pop(context, false),
                      child: Text("Batal"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text("Hapus", style: TextStyle(color: Colors.red)),
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
                            onPressed: () => Navigator.pop(context),
                            child: Text("Batal"),
                          ),
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context, passwordController.text),
                            child: Text("Lanjutkan"),
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
            child: Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          "Pengaturan akun",
          style: TextStyle(color: AppColors.third),
        ),
      ),
      body: Column(
        children: [
          GestureDetector(
            onTap: () => confirmDelete(context),
            child: Container(
              margin: EdgeInsets.symmetric(
                  horizontal: size.width * 0.05, vertical: size.height * 0.004),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15)),
                color: Colors.red,
              ),
              padding: EdgeInsets.all(25),
              child: Center(
                child: Text(
                  "Hapus akun",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
