import 'package:bincang/admin/screens/homepage_admin.dart';
import 'package:bincang/user/screens/home_page.dart';
import 'package:bincang/services/auth/login_register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<String?> getUserRole(String uid) async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('Users').doc(uid).get();

      if (userDoc.exists) {
        String role = userDoc['role'];
        print("User Role: $role"); // Debugging
        return role;
      } else {
        print("User document not found in Firestore.");
      }
    } catch (e) {
      print("Error getting user role: $e"); // Debugging
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // Loading
          }

          if (snapshot.hasData) {
            User? user = snapshot.data;

            if (user != null) {
              print("User logged in: ${user.uid}"); // Debugging
              return FutureBuilder<String?>(
                future: getUserRole(user.uid),
                builder: (context, roleSnapshot) {
                  if (roleSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (roleSnapshot.hasData) {
                    String? role = roleSnapshot.data;
                    if (role == "admin") {
                      print("Navigating to Admin Page");
                      return HomepageAdmin();
                    } else {
                      print("Navigating to User Home Page");
                      return Homepage();
                    }
                  }

                  print("Role not found, returning to Login/Register Page");
                  return const LoginRegister(); // Jika gagal mendapatkan role
                },
              );
            }
          }

          print("User not logged in, showing Login/Register Page");
          return const LoginRegister();
        },
      ),
    );
  }
}
