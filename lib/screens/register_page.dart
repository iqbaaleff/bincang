import 'package:bincang/helper/app_colors.dart';
import 'package:bincang/services/database/database_services.dart';
import 'package:bincang/widget/my_circle.dart';
import 'package:bincang/screens/login_page.dart';
import 'package:bincang/services/auth/auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;
  const RegisterPage({super.key, this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _auth = AuthServices();
  final _db = DatabaseServices();

  final TextEditingController namaController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController noHpController = TextEditingController();
  final TextEditingController pwController = TextEditingController();
  final TextEditingController pwConController = TextEditingController();

  void register() async {
    showLoadingCircle(context);
    if (pwController.text != pwConController.text) {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          elevation: 10,
          title: Center(
            child: Text("Password tidak cocok",
                style: TextStyle(
                  fontSize: 15,
                )),
          ),
        ),
      );
    } else {
      try {
        // Tunggu hingga proses registrasi selesai
        UserCredential userCredential = await _auth.registerEmailPassword(
            emailController.text, pwController.text);

        // Pastikan user terautentikasi sebelum menyimpan data
        if (userCredential.user != null) {
          await _db.saveUserInfoInFirebase(
              name: namaController.text,
              email: emailController.text,
              noTel: noHpController.text);

          print("Registrasi berhasil dan data disimpan di Firestore!");

          if (mounted) {
            hideLoadingCircle(context);
          }
        } else {
          print("Error: User tidak berhasil dibuat");
          if (mounted) {
            hideLoadingCircle(context);
          }
        }
      } catch (e) {
        print("Error saat registrasi: $e");
        if (mounted) {
          hideLoadingCircle(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          Positioned(
            bottom: 0,
            child: Container(
              height: size.height * 0.8,
              width: size.width,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(100)),
                color: Colors.white,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.1, vertical: size.height * 0.01),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //
                    Container(
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: size.height * 0.03),
                            child: Text(
                              "Register",
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: AppColors.third,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: size.height * 0.01),
                            child: TextFormField(
                              controller: namaController,
                              decoration: const InputDecoration(
                                label: Text("Nama Lengkap"),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      bottomRight: Radius.circular(12)),
                                  borderSide: BorderSide(
                                    width: 2.0,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      bottomRight: Radius.circular(12)),
                                  borderSide: BorderSide(
                                    width: 2.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: size.height * 0.01),
                            child: TextFormField(
                              controller: emailController,
                              decoration: const InputDecoration(
                                label: Text("Email"),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      bottomRight: Radius.circular(12)),
                                  borderSide: BorderSide(
                                    width: 2.0,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      bottomRight: Radius.circular(12)),
                                  borderSide: BorderSide(
                                    width: 2.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: size.height * 0.01),
                            child: TextFormField(
                              controller: noHpController,
                              decoration: const InputDecoration(
                                label: Text("No Telepon"),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      bottomRight: Radius.circular(12)),
                                  borderSide: BorderSide(
                                    width: 2.0,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      bottomRight: Radius.circular(12)),
                                  borderSide: BorderSide(
                                    width: 2.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: size.height * 0.01),
                            child: TextFormField(
                              controller: pwController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                label: Text("Password"),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      bottomRight: Radius.circular(12)),
                                  borderSide: BorderSide(
                                    width: 2.0,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      bottomRight: Radius.circular(12)),
                                  borderSide: BorderSide(
                                    width: 2.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: size.height * 0.01),
                            child: TextFormField(
                              controller: pwConController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                label: Text("Konfirmasi Password"),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      bottomRight: Radius.circular(12)),
                                  borderSide: BorderSide(
                                    width: 2.0,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      bottomRight: Radius.circular(12)),
                                  borderSide: BorderSide(
                                    width: 2.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: size.height * 0.01),
                            child: SizedBox(
                              width: size.width * 0.5,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.third,
                                  foregroundColor:
                                      Colors.black, // Warna teks tombol
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      bottomRight: Radius.circular(12),
                                    ), // Border radius
                                  ),
                                ),
                                onPressed: register,
                                child: Text(
                                  "Daftar",
                                  style: TextStyle(
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    //

                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: size.height * 0.03),
                      child: Column(
                        children: [
                          const Text("Sudah Punya Akun?"),
                          GestureDetector(
                            onTap: widget.onTap,
                            child: Text("Login sekarang!",
                                style: TextStyle(
                                  color: AppColors.third,
                                )),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
