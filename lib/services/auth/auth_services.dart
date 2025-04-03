import 'package:bincang/services/database/database_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AuthServices {
  final _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get current user & uid
  User? getCurrentUser() => _auth.currentUser;
  String? getCurrentUid() => _auth.currentUser?.uid;

  // Login dengan pengecekan suspend
  Future<UserCredential> loginEmailPassword(
      String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // String userId = userCredential.user!.uid;

      // // Ambil data pengguna dari Firestore
      // DocumentSnapshot userDoc = await FirebaseFirestore.instance
      //     .collection('Users')
      //     .doc(userId)
      //     .get();

      // if (userDoc.exists) {
      //   bool isSuspended = userDoc['isSuspended'] ?? false;
      //   Timestamp? suspendUntil = userDoc['suspendUntil'];

      //   if (isSuspended && suspendUntil != null) {
      //     DateTime suspendEndDate = suspendUntil.toDate();

      //     if (DateTime.now().isBefore(suspendEndDate)) {
      //       // Jika masih dalam masa suspend, logout user dan tolak login
      //       await _auth.signOut();
      //       throw Exception(
      //           "Akun Anda telah di-suspend hingga ${DateFormat('dd MMM yyyy').format(suspendEndDate)}. Silakan hubungi admin untuk informasi lebih lanjut.");
      //     } else {
      //       // Jika masa suspend sudah habis, hapus status suspend
      //       await FirebaseFirestore.instance
      //           .collection('Users')
      //           .doc(userId)
      //           .update({
      //         'isSuspended': false,
      //         'suspendUntil': null,
      //       });
      //     }
      //   } else if (isSuspended) {
      //     // Jika akun di-suspend tanpa batas waktu
      //     await _auth.signOut();
      //     throw Exception(
      //         "Akun Anda telah di-suspend secara permanen. Silakan hubungi admin untuk informasi lebih lanjut.");
      //   }
      // }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Terjadi kesalahan saat login.");
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
  Future<void> deleteAccount(String password) async {
    User? user = getCurrentUser();
    if (user == null) return;

    try {
      // 1. Re-authenticate user
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      // 2. Hapus semua postingan user dari collection Posts
      await _deleteUserPosts(user.uid);

      // 3. Hapus data user dari Firestore
      await DatabaseServices().deleteUserInfoFromFirebase(user.uid);

      // 4. Hapus akun auth
      await user.delete();
    } catch (e) {
      print('Error deleting account: $e');
      throw e;
    }
  }

  Future<void> _deleteUserPosts(String userId) async {
    try {
      // Dapatkan semua post dari user
      QuerySnapshot postsSnapshot =
          await _db.collection('Post').where('uid', isEqualTo: userId).get();

      // Hapus semua dokumen sekaligus menggunakan batch
      WriteBatch batch = _db.batch();

      for (var doc in postsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      print('Deleted ${postsSnapshot.docs.length} posts by user $userId');
    } catch (e) {
      print('Error deleting user posts: $e');
      throw Exception('Failed to delete user posts');
    }
  }
  

  // Fungsi untuk mengirim email reset password
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }
}
