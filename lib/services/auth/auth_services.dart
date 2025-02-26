import 'package:bincang/services/database/database_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AuthServices {
  final _auth = FirebaseAuth.instance;

  // Get current user & uid
  User? getCurrentUser() => _auth.currentUser;
  String getCurrentUid() => _auth.currentUser!.uid;

  // Login dengan pengecekan suspend
  Future<UserCredential> loginEmailPassword(
      String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String userId = userCredential.user!.uid;

      // Ambil data pengguna dari Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        bool isSuspended = userDoc['isSuspended'] ?? false;
        Timestamp? suspendUntil = userDoc['suspendUntil'];

        if (isSuspended && suspendUntil != null) {
          DateTime suspendEndDate = suspendUntil.toDate();

          if (DateTime.now().isBefore(suspendEndDate)) {
            // Jika masih dalam masa suspend, logout user dan tolak login
            await _auth.signOut();
            throw Exception(
                "Akun Anda disuspend hingga ${DateFormat('dd MMM yyyy').format(suspendEndDate)}");
          } else {
            // Jika masa suspend sudah habis, hapus status suspend
            await FirebaseFirestore.instance
                .collection('Users')
                .doc(userId)
                .update({
              'isSuspended': false,
              'suspendUntil': null,
            });
          }
        }
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // Register
  Future<UserCredential> registerEmailPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Delete account
  Future<void> deleteAccount() async {
    User? user = getCurrentUser();
    if (user != null) {
      // Delete from Firestore
      await DatabaseServices().deleteUserInfoFromFirebase(user.uid);
      // Delete user auth record
      await user.delete();
    }
  }
}
