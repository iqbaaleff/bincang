import 'package:bincang/user/screens/home_page.dart';
import 'package:bincang/services/auth/login_register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Jika masih memeriksa status login, tampilkan loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Jika terjadi error pada stream
          if (snapshot.hasError) {
            return const Center(
              child: Text("Terjadi kesalahan. Silakan coba lagi."),
            );
          }

          // Jika user sudah login, arahkan ke Homepage
          if (snapshot.hasData) {
            return Homepage();
          }

          // Jika user belum login, arahkan ke LoginRegister
          return const LoginRegister();
        },
      ),
    );
  }
}
