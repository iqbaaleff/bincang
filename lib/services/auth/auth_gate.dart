import 'package:bincang/screens/home_page.dart';
import 'package:bincang/services/auth/login_register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // user login
          if (snapshot.hasData) {
            return Homepage();
          }
          // user not login
          else {
            return const LoginRegister();
          }
        },
      ),
    );
  }
}
