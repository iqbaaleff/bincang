import 'package:bincang/models/post.dart';
import 'package:bincang/services/database/database_provider.dart';
import 'package:bincang/widget/my_drawer.dart';
import 'package:bincang/widget/my_input_alert_box.dart';
import 'package:bincang/widget/my_posts_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  late final listeningProvider = Provider.of<DatabaseProvider>(context);
  late final databaseProvider =
      Provider.of<DatabaseProvider>(context, listen: false);
  final _messageController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadAllPost();
  }

  // Load all post
  Future<void> loadAllPost() async {
    await databaseProvider.loadAllPost();
  }

  void _openPostMessage() {
    showDialog(
      context: context,
      builder: (context) => MyInputAlertBox(
          textController: _messageController,
          hintText: "Apa yang anda pikirkan?",
          onPressed: () async {
            // Post in db
            await postMessage(_messageController.text);
          },
          onPressedText: "Post"),
    );
  }

  // User post message
  Future<void> postMessage(String message) async {
    await databaseProvider.postMessage(message);
    await loadAllPost(); // Tambahkan ini agar daftar post diperbarui
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      drawer: MyDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Bincang"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
        ),
        onPressed: _openPostMessage,
        child: Icon(Icons.add),
      ),
      body: _buildPostList(listeningProvider.allPost),
      
    );
  }

  Widget _buildPostList(List<Post> posts) {
    return posts.isEmpty
        ? Center(
            child: Text("Tidak ada apapun..."),
          )
        : ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];

              return MyPostsTile(post: post);
            },
          );
  }
}
