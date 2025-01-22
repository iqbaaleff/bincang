import 'package:firebase_auth/firebase_auth.dart';

class AuthServices {
  //get instance
  final _auth = FirebaseAuth.instance;
  //get current user & uid
  User? getCurrentUser() => _auth.currentUser;
  String getCurrentUid() => _auth.currentUser!.uid;

  //Login
  Future<UserCredential> loginEmailPassword(String email, password) async {
    try {
      final UserCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return UserCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  //Register
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

  //Logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}
