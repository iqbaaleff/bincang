import 'package:bincang/helper/app_colors.dart';
import 'package:bincang/register_page.dart';
import 'package:bincang/services/auth/auth_services.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;
  const LoginPage({super.key, this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _auth = AuthServices();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController pwController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    pwController.dispose();
    super.dispose();
  }

  void login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.loginEmailPassword(
          emailController.text.trim(), pwController.text.trim());
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showForgotPasswordDialog() {
    final size = MediaQuery.of(context).size;
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Lupa Password"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Masukkan email Anda untuk mereset password."),
              const SizedBox(height: 20),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Email tidak boleh kosong";
                  } else if (!RegExp(
                          r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                      .hasMatch(value)) {
                    return "Masukkan email yang valid";
                  }
                  return null;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: AppColors.third),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "Batal",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: AppColors.third),
              onPressed: () async {
                if (emailController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Email tidak boleh kosong")),
                  );
                  return;
                }

                try {
                  await _auth
                      .sendPasswordResetEmail(emailController.text.trim());
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Email reset password telah dikirim")),
                  );
                  Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              },
              child: const Text(
                "Kirim",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
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
              height: size.height * 0.65,
              width: size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(100)),
                color: Colors.white,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.1, vertical: size.height * 0.01),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: size.height * 0.03),
                            child: Text(
                              "Login",
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
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: "Email",
                                prefixIcon: Icon(Icons.email),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      bottomRight: Radius.circular(12)),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Email tidak boleh kosong";
                                } else if (!RegExp(
                                        r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                                    .hasMatch(value)) {
                                  return "Masukkan email yang valid";
                                }
                                return null;
                              },
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: size.height * 0.01),
                            child: TextFormField(
                              controller: pwController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: "Password",
                                prefixIcon: Icon(Icons.lock),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      bottomRight: Radius.circular(12)),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Password tidak boleh kosong";
                                } else if (value.length < 6) {
                                  return "Password minimal 6 karakter";
                                }
                                return null;
                              },
                            ),
                          ),
                          GestureDetector(
                            onTap: _showForgotPasswordDialog,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  "Lupa Password?",
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ],
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
                                  foregroundColor: Colors.black,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      bottomRight: Radius.circular(12),
                                    ),
                                  ),
                                ),
                                onPressed: _isLoading ? null : login,
                                child: _isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white)
                                    : Text(
                                        "Masuk",
                                        style: TextStyle(
                                          color: AppColors.secondary,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: size.height * 0.03),
                        child: Column(
                          children: [
                            const Text("Belum Punya Akun?"),
                            GestureDetector(
                              onTap: widget.onTap,
                              child: Text(
                                "Daftar disini!",
                                style: TextStyle(color: AppColors.third),
                              ),
                            )
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
