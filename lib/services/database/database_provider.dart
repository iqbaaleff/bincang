import 'package:bincang/models/post.dart';
import 'package:bincang/models/user.dart';
import 'package:bincang/services/auth/auth_services.dart';
import 'package:bincang/services/database/database_services.dart';
import 'package:flutter/foundation.dart';

class DatabaseProvider extends ChangeNotifier {
  final _auth = AuthServices();
  final _db = DatabaseServices();

  /*
    SERVICES
  */
  // Get user profil
  Future<UserProfile?> userProfile(String uid) => _db.getUserFromFirebase(uid);
  // Update user bio
  Future<void> updateBio(String bio) => _db.updateUserBioInFirebase(bio);

  /* 
    POST
  */
  // List post
  List<Post> _allPosts = [];
  // Get post
  List<Post> get allPost => _allPosts;
  // Post
  Future<void> postMessage(String message) async {
    await _db.postMessageInFirebase(message);

    await loadAllPost();
  }

  // Fetch all post
  Future<void> loadAllPost() async {
    final allPost = await _db.getAllPostsFromFirebase();

    // Update local data
    _allPosts = allPost;

    // Update UI
    notifyListeners();
  }

  // Filter and return post given uid
  List<Post> filterUserPosts(String uid) {
    return _allPosts.where((post) => post.uid == uid).toList();
  }

  // Hapus post
  Future<void> deletePost(String postId) async {
    // hapus dari firebase
    await _db.deletePostFromFirebase(postId);
    // reload data
    loadAllPost();
  }
}
