import 'package:bincang/models/comment.dart';
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
  List<Post> _followingPosts = [];
  // Get post
  List<Post> get allPost => _allPosts;
  List<Post> get followingPosts => _followingPosts;
  // Post
  Future<void> postMessage(String message) async {
    await _db.postMessageInFirebase(message);

    await loadAllPost();
  }

  // Fetch all post
  Future<void> loadAllPost() async {
    final allPost = await _db.getAllPostsFromFirebase();
    // Get blocked user ids
    final blockedUserIds = await _db.getBlockedUidFromFirebase();
    // Filter out blocked users posts
    _allPosts =
        allPost.where((post) => !blockedUserIds.contains(post.uid)).toList();

    loadFollowingPosts();
    // Initialize data local like
    initializeLikeMap();

    // Update UI
    notifyListeners();
  }

  // Filter and return post given uid
  List<Post> filterUserPosts(String uid) {
    return _allPosts.where((post) => post.uid == uid).toList();
  }

  // Load following posts
  Future<void> loadFollowingPosts() async {
    String currentUid = _auth.getCurrentUid()!;
    final followingUserIds = await _db.getFollowingUidsFromFirebase(currentUid);
    _followingPosts =
        _allPosts.where((post) => followingUserIds.contains(post.uid)).toList();
    notifyListeners();
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

  /*
  COMMENT
  */
  final Map<String, List<Comment>> _comments = {};
  List<Comment> getComments(String postId) => _comments[postId] ?? [];

  // Ambil komentar dari Firestore
  Future<void> loadComments(String postId) async {
    try {
      final allComments = await _db.getCommentFromFirebase(postId);
      _comments[postId] = allComments;
      notifyListeners(); // ⚠️ WAJIB agar UI diperbarui
    } catch (e) {
      print("Error loading comments: $e");
    }
  }

  // Tambahkan komentar
  Future<void> addComments(String postId, String message, {String? parentId}) async {
  await _db.addCommentInFirebase(postId, message, parentId: parentId);
  await loadComments(postId); // Refresh komentar setelah menambah
}


  // Hapus komentar
  Future<void> deleteComments(String commentId, String postId) async {
    try {
      await _db.deleteCommentInFirebase(commentId);
      await loadComments(postId); // Muat ulang setelah menghapus
    } catch (e) {
      print("Error deleting comment: $e");
    }
  }

  /* 
  REPORT, BLOCK, DELETE
  */
  List<UserProfile> _blockedUsers = [];
  List<UserProfile> get blockedUsers => _blockedUsers;

  // Fetch blocked user
  Future<void> loadBlockedUser() async {
    final blockedUserIds = await _db.getBlockedUidFromFirebase();
    final blockedUserData = await Future.wait(
        blockedUserIds.map((id) => _db.getUserFromFirebase(id)));

    // Return sebagai list
    _blockedUsers = blockedUserData.whereType<UserProfile>().toList();
    notifyListeners();
  }

  // Block user
  Future<void> blockUser(String userId) async {
    await _db.blockUserInFirebase(userId);
    await loadBlockedUser();
    await loadAllPost();
    notifyListeners();
  }

  // Unblock user
  Future<void> unblockUser(String blockedUserId) async {
    await _db.unblockUserInFirebase(blockedUserId);
    await loadBlockedUser();
    await loadAllPost();
    notifyListeners();
  }

  // Report user dan post
  Future<void> reportUser(String postId, userId) async {
    await _db.reportUserInFirebase(postId, userId);
  }

  /*
  FOLLOW
  */

  final Map<String, List<String>> _followers = {};
  final Map<String, List<String>> _following = {};
  final Map<String, int> _followerCount = {};
  final Map<String, int> _followingCount = {};

  // Get count untuk follower dan following
  int getFollowerCount(String uid) => _followerCount[uid] ?? 0;
  int getFollowingCount(String uid) => _followingCount[uid] ?? 0;

  // Load followers
  Future<void> loadUserFollower(String uid) async {
    final listOfFollowerUids = await _db.getFollowerUidsFromFirebase(uid);
    _followers[uid] = listOfFollowerUids;
    _followerCount[uid] = listOfFollowerUids.length;
    notifyListeners();
  }

  // load following
  Future<void> loadUserFollowing(String uid) async {
    final listOfFollowingUids = await _db.getFollowingUidsFromFirebase(uid);
    _following[uid] = listOfFollowingUids;
    _followingCount[uid] = listOfFollowingUids.length;
    notifyListeners();
  }

  // follow user
  Future<void> followUser(String targetUserId) async {
    final currentUserId = _auth.getCurrentUid();

    // Inisialisasi dengan list kosong jika null
    _followers.putIfAbsent(targetUserId, () => []);
    _following.putIfAbsent(currentUserId!, () => []);

    // Follow jika current user bukan follower target user
    if (!_followers[targetUserId]!.contains(currentUserId)) {
      // Tambah current user ke target user follower list
      _followers[targetUserId]?.add(currentUserId!);
      _followerCount[targetUserId] = (_followerCount[targetUserId] ?? 0) + 1;

      // Tambah target user ke current user following
      _following[currentUserId]?.add(targetUserId);
      _followingCount[currentUserId!] =
          (_followingCount[currentUserId] ?? 0) + 1;

      // Notifikasi perubahan data
      notifyListeners();

      try {
        // Kirim ke Firebase
        await _db.followUserInFirebase(targetUserId);
        await loadUserFollower(currentUserId!);
        await loadUserFollowing(currentUserId!);
      } catch (e) {
        // Rollback data jika gagal
        _followers[targetUserId]?.remove(currentUserId);
        _followerCount[targetUserId] = (_followerCount[targetUserId] ?? 1) - 1;

        _following[currentUserId]?.remove(targetUserId);
        _followingCount[currentUserId!] =
            (_followingCount[currentUserId] ?? 1) - 1;

        // Notifikasi perubahan data
        notifyListeners();

        print("Error saat mengikuti: $e");
      }
    }
  }

// unfollow user
  Future<void> unfollowUser(String targetUserId) async {
    final currentUserId = _auth.getCurrentUid();

    // Inisialisasi dengan list kosong jika null
    _followers.putIfAbsent(targetUserId, () => []);
    _following.putIfAbsent(currentUserId!, () => []);

    // Unfollow jika current user adalah follower target user
    if (_followers[targetUserId]!.contains(currentUserId)) {
      // Hapus current user dari target user follower list
      _followers[targetUserId]?.remove(currentUserId);
      _followerCount[targetUserId] = (_followerCount[targetUserId] ?? 1) - 1;

      // Hapus target user dari current user following list
      _following[currentUserId]?.remove(targetUserId);
      _followingCount[currentUserId!] =
          (_followingCount[currentUserId] ?? 1) - 1;

      // Notifikasi perubahan data
      notifyListeners();

      try {
        // Kirim ke Firebase
        await _db.unfollowUserInFirebase(targetUserId);
        await loadUserFollower(currentUserId!);
        await loadUserFollowing(currentUserId!);
      } catch (e) {
        // Rollback data jika gagal
        _followers[targetUserId]?.add(currentUserId!);
        _followerCount[targetUserId] = (_followerCount[targetUserId] ?? 0) + 1;

        _following[currentUserId]?.add(targetUserId);
        _followingCount[currentUserId!] =
            (_followingCount[currentUserId] ?? 0) + 1;

        // Notifikasi perubahan data
        notifyListeners();

        print("Error saat unfollow: $e");
      }
    }
  }

  // is current user following target user?
  bool isFollowing(String uid) {
    final currentUserId = _auth.getCurrentUid();
    return _followers[uid]?.contains(currentUserId) ?? false;
  }

  Map<String, List<UserProfile>> _followersProfile = {};
  Map<String, List<UserProfile>> _followingProfile = {};
  List<UserProfile> getListOfFollowersProfile(String uid) =>
      _followersProfile[uid] ?? [];
  List<UserProfile> getListOfFollowingProfile(String uid) =>
      _followingProfile[uid] ?? [];

  Future<void> loadUserFollowerProfiles(String uid) async {
    try {
      final followerIds = await _db.getFollowerUidsFromFirebase(uid);
      List<UserProfile> followerProfiles = [];
      for (String followerId in followerIds) {
        UserProfile? followerProfile =
            await _db.getUserFromFirebase(followerId);

        if (followerProfile != null) {
          followerProfiles.add(followerProfile);
        }
      }

      _followersProfile[uid] = followerProfiles;
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> loadUserFollowingProfiles(String uid) async {
    try {
      final followingIds = await _db.getFollowingUidsFromFirebase(uid);
      List<UserProfile> followingProfiles = [];
      for (String followingId in followingIds) {
        UserProfile? followingProfile =
            await _db.getUserFromFirebase(followingId);

        if (followingProfile != null) {
          followingProfiles.add(followingProfile);
        }
      }

      _followingProfile[uid] = followingProfiles;
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  // Search

  List<UserProfile> _searchResult = [];
  List<UserProfile> get searchResult => _searchResult;

  Future<void> searchUsers(String searchTerm) async {
    try {
      final result = await _db.searchUserInFirebase(searchTerm);
      _searchResult = result;
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }
}
