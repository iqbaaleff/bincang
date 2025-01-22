import 'package:bincang/widget/my_circle.dart';
import 'package:bincang/screens/register_page.dart';
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

  //login method
  void login() async {
    showLoadingCircle(context);

    try {
      await _auth.loginEmailPassword(emailController.text, pwController.text);

      if (mounted) {
        hideLoadingCircle(context);
      }
    } catch (e) {
      if (mounted) {
        hideLoadingCircle(context);
      }
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned(
            bottom: 0,
            child: Container(
              height: size.height * 0.65,
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
                            child: const Text(
                              "Login",
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
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
                                prefixIcon: Icon(Icons.email),
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
                                prefixIcon: Icon(Icons.lock),
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
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                "Lupa Password?",
                                style: TextStyle(
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: size.height * 0.01),
                            child: SizedBox(
                              width: size.width * 0.5,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors
                                      .amber, // Warna latar belakang tombol
                                  foregroundColor:
                                      Colors.black, // Warna teks tombol
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      bottomRight: Radius.circular(12),
                                    ), // Border radius
                                  ),
                                ),
                                onPressed: login,
                                child: const Text(
                                  "Masuk",
                                ),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircleAvatar(
                                  maxRadius: 25,
                                  backgroundColor: Colors.white,
                                  backgroundImage: AssetImage(
                                      "assets/images/googleLogo.png")),
                              SizedBox(
                                width: size.width * 0.03,
                              ),
                              const CircleAvatar(
                                maxRadius: 16,
                                backgroundColor: Colors.white,
                                backgroundImage: AssetImage(
                                    "assets/images/facebookLogo.png"),
                              ),
                            ],
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
                          const Text("Belum Punya Akun?"),
                          GestureDetector(
                            onTap: widget.onTap,
                            child: const Text("Daftar disini!",
                                style: TextStyle(
                                  color: Colors.amber,
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
