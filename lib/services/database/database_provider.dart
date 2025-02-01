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

    // Initialize data local like
    initializeLikeMap();

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

  /*
  LIKES
  */
  Map<String, int> _likeCounts = {};
  List<String> _likedPost = [];

  // Apakah current user like postingan ini?
  bool isPostLikedByCurrentUser(String postId) => _likedPost.contains(postId);
  // Get like count dari post
  int getLikeCount(String postId) => _likeCounts[postId] ?? 0;
  void initializeLikeMap() {
    final currentUserID = _auth.getCurrentUid();
    _likedPost.clear();
    for (var post in _allPosts) {
      // Update like
      _likeCounts[post.id] = post.likeCount;
      // If current user sudah like post
      if (post.likedBy.contains(currentUserID)) {
        // Tambah ke local list liked post
        _likedPost.add(post.id);
      }
    }
  }

  // Toggle like
  Future<void> toggleLike(String postId) async {
    // Menyimpan nilai original jika fail
    final likePostOriginal = _likedPost;
    final likeCountOriginal = _likeCounts;

    // Perform Like / Unlike
    if (_likedPost.contains(postId)) {
      _likedPost.remove(postId);
      _likeCounts[postId] = (_likeCounts[postId] ?? 0) - 1;
    } else {
      _likedPost.add(postId);
      _likeCounts[postId] = (_likeCounts[postId] ?? 0) + 1;
    }
    notifyListeners();

    // Update ke database
    try {
      await _db.toggleLikeInFirebase(postId);
    } catch (e) {
      _likedPost = likePostOriginal;
      _likeCounts = likeCountOriginal;
      notifyListeners();
    }
  }
}
