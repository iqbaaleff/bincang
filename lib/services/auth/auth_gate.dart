import 'package:bincang/admin/screens/homepage_admin.dart';
import 'package:bincang/helper/app_colors.dart';
import 'package:bincang/user/screens/home_page.dart';
import 'package:bincang/services/auth/login_register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<Map<String, dynamic>> getUserData(String uid) async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('Users').doc(uid).get();

      if (userDoc.exists && userDoc.data() != null) {
        final userData = userDoc.data() as Map<String, dynamic>;
        return {
          'role': userData['role'] ?? 'user', // Default role jika tidak ada
          'isSuspended': userData['isSuspended'] ?? false,
        };
      }
      throw Exception('User document not found or empty');
    } catch (e) {
      print("Error getting user data: $e");
      // Return default values if there's any error
      return {
        'role': 'user',
        'isSuspended': false,
      };
    }
  }

  void _showSuspendedDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Akun dibatasi'),
          content: const Text(
              'Akun anda telah dibatasi. Hubungi admin untuk informasi lebih lanjut'),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: AppColors.third,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              child: Text('OK',
                  style: TextStyle(
                    color: AppColors.secondary,
                  )),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showErrorDialog(context, 'An authentication error occurred');
            });
            return const LoginRegister();
          }

          if (snapshot.hasData && snapshot.data != null) {
            final user = snapshot.data!;
            print("User logged in: ${user.uid}");

            return FutureBuilder<Map<String, dynamic>>(
              future: getUserData(user.uid),
              builder: (context, userDataSnapshot) {
                if (userDataSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (userDataSnapshot.hasError) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _showErrorDialog(context, 'Failed to load user data');
                  });
                  return const LoginRegister();
                }

                final userData = userDataSnapshot.data!;
                final role = userData['role'];
                final isSuspended = userData['isSuspended'];

                // Check if user is suspended
                if (isSuspended == true) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _showSuspendedDialog(context);
                  });
                  return const LoginRegister();
                }

                // Navigate based on role
                switch (role) {
                  case 'admin':
                    print("Navigating to Admin Page");
                    return HomepageAdmin();
                  default:
                    print("Navigating to User Home Page");
                    return Homepage();
                }
              },
            );
          }

          print("User not logged in, showing Login/Register Page");
          return const LoginRegister();
        },
      ),
    );
  }
}
