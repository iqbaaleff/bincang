import 'package:bincang/models/post.dart';
import 'package:bincang/services/database/database_provider.dart';
import 'package:bincang/widget/my_drawer.dart';
import 'package:bincang/widget/my_input_alert_box.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: MyDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Bincang"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openPostMessage,
        child: Icon(Icons.add),
      ),
      body: Consumer<DatabaseProvider>(
        builder: (context, provider, child) {
          return _buildPostList(provider.allPost);
        },
      ),
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

              return Container(
                child: Text(post.message),
              );
            },
          );
  }
}
