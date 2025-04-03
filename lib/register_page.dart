import 'package:bincang/helper/app_colors.dart';
import 'package:bincang/services/database/database_services.dart';
import 'package:bincang/services/auth/auth_services.dart';
import 'package:bincang/widget/my_circle.dart';
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
  final _formKey = GlobalKey<FormState>();

  final TextEditingController namaController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController noHpController = TextEditingController();
  final TextEditingController pwController = TextEditingController();
  final TextEditingController pwConController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Validator for full name (no numbers or emojis)
  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Wajib diisi';
    }
    if (RegExp(r'[0-9]').hasMatch(value)) {
      return 'Nama tidak boleh mengandung angka';
    }
    if (RegExp(
      r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])',
    ).hasMatch(value)) {
      return 'Nama tidak boleh mengandung emoji';
    }
    return null;
  }

  // Validator for phone number (only numbers, no letters or emojis)
  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Wajib diisi';
    }
    if (RegExp(r'[a-zA-Z]').hasMatch(value)) {
      return 'Nomor telepon hanya boleh mengandung angka';
    }
    if (RegExp(
      r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])',
    ).hasMatch(value)) {
      return 'Nomor telepon tidak boleh mengandung emoji';
    }
    return null;
  }

  // Validator for password (no emojis)
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Wajib diisi';
    }
    if (value.length < 6) {
      return 'Minimal 6 karakter';
    }
    if (RegExp(
      r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])',
    ).hasMatch(value)) {
      return 'Password tidak boleh mengandung emoji';
    }
    return null;
  }

  void register() async {
    if (!_formKey.currentState!.validate()) return;
    showLoadingCircle(context);
    try {
      UserCredential userCredential = await _auth.registerEmailPassword(
          emailController.text.trim(), pwController.text.trim());
      if (userCredential.user != null) {
        await _db.saveUserInfoInFirebase(
          name: namaController.text.trim(),
          email: emailController.text.trim(),
          noTel: noHpController.text.trim(),
        );
        print("Registrasi berhasil dan data disimpan di Firestore!");
      }
    } catch (e) {
      print("Error saat registrasi: $e");
    } finally {
      if (mounted) hideLoadingCircle(context);
    }
  }

  Widget buildTextField(
    String label,
    TextEditingController controller, {
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? _obscurePassword : false,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                )
              : null,
        ),
        validator: validator,
      ),
    );
  }

  Widget buildConfirmPasswordField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: pwConController,
        obscureText: _obscureConfirmPassword,
        decoration: InputDecoration(
          labelText: "Konfirmasi Password",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
            ),
            onPressed: () {
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              });
            },
          ),
        ),
        validator: (val) {
          if (val == null || val.isEmpty) {
            return 'Wajib diisi';
          }
          if (val != pwController.text) {
            return 'Password tidak cocok';
          }
          if (RegExp(
            r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])',
          ).hasMatch(val)) {
            return 'Password tidak boleh mengandung emoji';
          }
          return null;
        },
      ),
    );
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
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          const SizedBox(height: 20),
                          Text("Register",
                              style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.third)),
                          buildTextField("Nama Lengkap", namaController,
                              validator: validateName),
                          buildTextField("Gunakan Email Aktif", emailController,
                              validator: (val) => val!.contains('@')
                                  ? null
                                  : "Email tidak valid"),
                          buildTextField("No Telepon", noHpController,
                              validator: validatePhone),
                          buildTextField("Password", pwController,
                              isPassword: true, validator: validatePassword),
                          buildConfirmPasswordField(),
                          SizedBox(
                            width: size.width * 0.5,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.third,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: register,
                              child: Text("Daftar",
                                  style: TextStyle(color: AppColors.secondary)),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Column(
                          children: [
                            const Text("Sudah Punya Akun?"),
                            GestureDetector(
                              onTap: widget.onTap,
                              child: Text("Login sekarang!",
                                  style: TextStyle(color: AppColors.third)),
                            ),
                          ],
                        ),
                      ),
                    ],
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
