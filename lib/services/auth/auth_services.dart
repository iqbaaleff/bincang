import 'package:bincang/services/database/database_services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthServices {
  // Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user & UID
  User? getCurrentUser() => _auth.currentUser;
  String? getCurrentUid() => _auth.currentUser?.uid;

  // Login dengan email dan password
  Future<UserCredential> loginEmailPassword(
      String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e));
    }
  }

  // Register dengan email dan password
  Future<UserCredential> registerEmailPassword(
      String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e));
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Delete Account
  Future<void> deleteAccount() async {
    try {
      User? user = getCurrentUser();
      if (user != null) {
        // Hapus data dari database
        await DatabaseServices().deleteUserInfoFromFirebase(user.uid);

        // Hapus akun dari Firebase Authentication
        await user.delete();
      }
    } on FirebaseAuthException catch (e) {
      throw Exception("Gagal menghapus akun: ${_handleAuthError(e)}");
    }
  }

  // Handle Firebase Auth Errors
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case "invalid-email":
        return "Format email tidak valid.";
      case "user-disabled":
        return "Akun telah dinonaktifkan.";
      case "user-not-found":
        return "Akun tidak ditemukan.";
      case "wrong-password":
        return "Password salah.";
      case "email-already-in-use":
        return "Email sudah terdaftar.";
      case "weak-password":
        return "Password terlalu lemah.";
      case "requires-recent-login":
        return "Silakan login kembali sebelum menghapus akun.";
      default:
        return "Terjadi kesalahan, silakan coba lagi.";
    }
  }
}
