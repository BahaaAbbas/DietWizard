import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Post {
  final int idPost;
  final String title;
  final String content;
  final String author;
  final Uint8List imageData;
  List<String> likes;
  List<Comment> comments;
  final int reportcount;

  Post({
    required this.idPost,
    required this.title,
    required this.content,
    required this.author,
    required this.imageData,
    this.likes = const [],
    this.comments = const [],
    required this.reportcount,
  });
}

class Comment {
  final String username;
  final String text;

  Comment({required this.username, required this.text});
}

class PostShow extends StatefulWidget {
  final String baseUrl;
  final String username;
  const PostShow({Key? key, required this.baseUrl, required this.username})
      : super(key: key);
  @override
  _PostShowState createState() => _PostShowState();
}

class _PostShowState extends State<PostShow> {
  List<Post> posts = [];
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchPost();
  }

  Future<void> fetchPost() async {
    final response = await http.get(Uri.parse('${widget.baseUrl}/posts'));

    if (response.statusCode == 200) {
      final List<dynamic> postsData = jsonDecode(response.body);

      setState(() {
        posts = postsData.map((postData) {
          final List<int> bufferData = List<int>.from(postData['data']['data']);
          final Uint8List imageData = Uint8List.fromList(bufferData);

          List<Comment> comments = [];
          if (postData['comments'] != null) {
            comments =
                (postData['comments'] as List<dynamic>).map((commentData) {
              return Comment(
                username: commentData['username'],
                text: commentData['text'],
              );
            }).toList();
          }

          return Post(
            idPost: postData['idPost'],
            title: postData['title'],
            content: postData['content'],
            author: postData['author'],
            imageData: imageData,
            likes: List<String>.from(postData['likes']),
            comments: comments,
            reportcount: postData['reportcount'],
          );
        }).toList();
      });
    } else {
      print('Failed to fetch products. Status code: ${response.statusCode}');
    }
  }

  Future<void> toggleLike(int index) async {
    setState(() {
      if (posts[index].likes.contains(widget.username)) {
        posts[index].likes.remove(widget.username);
      } else {
        posts[index].likes.add(widget.username);
      }
    });

    final response = await http.put(
      Uri.parse('${widget.baseUrl}/posts/${posts[index].idPost}/likes'),
      body: jsonEncode({'likes': posts[index].likes}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      setState(() {
        if (posts[index].likes.contains(widget.username)) {
          posts[index].likes.remove(widget.username);
        } else {
          posts[index].likes.add(widget.username);
        }
      });
    }
  }

  Future<void> submitComment(int postId, String comment) async {
    final response = await http.post(
      Uri.parse('${widget.baseUrl}/posts/$postId/comments'),
      body: jsonEncode({'username': widget.username, 'comment': comment}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      await fetchPost();
    } else {
      print('Failed to submit comment. Status code: ${response.statusCode}');
    }
  }

  void showLikesDialog(List<String> likes) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Likes"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: likes.map((user) => Text(user)).toList(),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Posts',
          style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800]),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          iconSize: 40,
          color: Colors.blue[800],
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(posts.length, (index) {
            final post = posts[index];
            return SizedBox(
              width: double.infinity,
              child: Card(
                elevation: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 200,
                      child: Image.memory(
                        post.imageData,
                        fit: BoxFit.fitHeight,
                        width: double.infinity,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            post.content,
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 4),
                          Text(
                            post.author,
                            style: TextStyle(fontSize: 16),
                          ),
                          
                          SizedBox(height: 8),
                          TextField(
                            controller: _commentController,
                            decoration: InputDecoration(
                              hintText: 'Add a comment...',
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  post.likes.contains(widget.username)
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: post.likes.contains(widget.username)
                                      ? Colors.red
                                      : null,
                                ),
                                onPressed: () => toggleLike(index),
                              ),
                              SizedBox(width: 8),
                              InkWell(
                                onTap: () => showLikesDialog(post.likes),
                                child: Text(
                                  "Likes (${post.likes.length})",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  submitComment(
                                      post.idPost, _commentController.text);
                                  _commentController.clear();
                                },
                                child: Text('Comment'),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          // Display comments
                          if (post.comments.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 4),
                                if (post.comments.isNotEmpty)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 4),
                                      post.comments.length > 2
                                          ? ExpansionTile(
                                              title: Text('Show comments'),
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: post.comments
                                                      .map((comment) => Text(
                                                            '${comment.username}: ${comment.text}',
                                                            style: TextStyle(
                                                                fontSize: 16),
                                                          ))
                                                      .toList(),
                                                ),
                                              ],
                                            )
                                          : Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: post.comments
                                                  .map((comment) => Text(
                                                        '${comment.username}: ${comment.text}',
                                                        style: TextStyle(
                                                            fontSize: 16),
                                                      ))
                                                  .toList(),
                                            ),
                                    ],
                                  ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
