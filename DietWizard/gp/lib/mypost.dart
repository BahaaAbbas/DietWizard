// import 'dart:convert';awesome_dialog
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:awesome_dialog/awesome_dialog.dart';

// class Posts {
//   final int idPost;
//   final String title;
//   final String content;
//   final String author;
//   final Uint8List imageData;
//   List<String> likes;
//   List<Comments> comments;

//   Posts({
//     required this.idPost,
//     required this.title,
//     required this.content,
//     required this.author,
//     required this.imageData,
//     this.likes = const [],
//     this.comments = const [],
//   });
// }

// class Comments {
//   final String username;
//   final String text;

//   Comments({required this.username, required this.text});
// }

// class myPosts extends StatefulWidget {
//   final String baseUrl;
//   final String username;
//   const myPosts({Key? key, required this.baseUrl, required this.username})
//       : super(key: key);
//   @override
//   _myPostsState createState() => _myPostsState();
// }

// class _myPostsState extends State<myPosts> {
//   List<Posts> posts = [];
//   final TextEditingController _commentController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     fetchPost();
//   }

//   Future<void> fetchPost() async {
//     final response = await http.get(Uri.parse('${widget.baseUrl}/posts'));

//     if (response.statusCode == 200) {
//       final List<dynamic> postsData = jsonDecode(response.body);

//       setState(() {
//         posts = postsData.map((postData) {
//           final List<int> bufferData = List<int>.from(postData['data']['data']);
//           final Uint8List imageData = Uint8List.fromList(bufferData);

//           List<Comments> comments = [];
//           if (postData['comments'] != null) {
//             comments =
//                 (postData['comments'] as List<dynamic>).map((commentData) {
//               return Comments(
//                 username: commentData['username'],
//                 text: commentData['text'],
//               );
//             }).toList();
//           }

//           return Posts(
//             idPost: postData['idPost'],
//             title: postData['title'],
//             content: postData['content'],
//             author: postData['author'],
//             imageData: imageData,
//             likes: List<String>.from(postData['likes']),
//             comments: comments,
//           );
//         }).toList();
//       });
//     } else {
//       print('Failed to fetch products. Status code: ${response.statusCode}');
//     }
//   }

//   Future<void> toggleLike(int index) async {
//     setState(() {
//       if (posts[index].likes.contains(widget.username)) {
//         posts[index].likes.remove(widget.username);
//       } else {
//         posts[index].likes.add(widget.username);
//       }
//     });

//     final response = await http.put(
//       Uri.parse('${widget.baseUrl}/posts/${posts[index].idPost}/likes'),
//       body: jsonEncode({'likes': posts[index].likes}),
//       headers: {'Content-Type': 'application/json'},
//     );

//     if (response.statusCode != 200) {
//       setState(() {
//         if (posts[index].likes.contains(widget.username)) {
//           posts[index].likes.remove(widget.username);
//         } else {
//           posts[index].likes.add(widget.username);
//         }
//       });
//     }
//   }

//   Future<void> submitComment(int postId, String comment) async {
//     final response = await http.post(
//       Uri.parse('${widget.baseUrl}/posts/$postId/comments'),
//       body: jsonEncode({'username': widget.username, 'comment': comment}),
//       headers: {'Content-Type': 'application/json'},
//     );

//     if (response.statusCode == 200) {
//       await fetchPost();
//     } else {
//       print('Failed to submit comment. Status code: ${response.statusCode}');
//     }
//   }

//   Future<void> _deletePost(int postId) async {
//     final response = await http.delete(
//       Uri.parse('${widget.baseUrl}/deleteposts/$postId'),
//       headers: {'Content-Type': 'application/json'},
//     );

//     if (response.statusCode == 200) {
//       setState(() {
//         // Remove the deleted post from the list
//         posts.removeWhere((post) => post.idPost == postId);
//         AwesomeDialog(
//           context: context,
//           dialogType: DialogType.success,
//           animType: AnimType.rightSlide,
//           title: "Delete Post",
//           desc: "", // You can leave this empty if you don't need a description
//           width: 600,
//           body: Text("Deleted successfully"),
//           btnCancelText: "Close",
//           btnCancelOnPress: () {},
//         )..show();
//       });
//     } else {
//       print('Failed to delete post. Status code: ${response.statusCode}');
//     }
//   }

//   Future<void> _deleteComment(int postId, int commentIndex) async {
//     final response = await http.delete(
//       Uri.parse('${widget.baseUrl}/posts/$postId/comments/$commentIndex'),
//       headers: {'Content-Type': 'application/json'},
//     );

//     if (response.statusCode == 200) {
//       setState(() {
//         // Remove the comment from the corresponding post
//         posts
//             .firstWhere((post) => post.idPost == postId)
//             .comments
//             .removeAt(commentIndex);
//         AwesomeDialog(
//           context: context,
//           dialogType: DialogType.success,
//           animType: AnimType.rightSlide,
//           title: "Delete Comment",
//           desc: "", // You can leave this empty if you don't need a description
//           width: 600,
//           body: Text("Comment deleted successfully"),
//           btnCancelText: "Close",
//           btnCancelOnPress: () {},
//         )..show();
//       });
//     } else {
//       print('Failed to delete comment. Status code: ${response.statusCode}');
//     }
//   }

//   void _onDeleteCommentPressed(int postId, int commentIndex) {
//     _deleteComment(postId, commentIndex);
//   }

//   void showLikesDialog(List<String> likes) {
//     AwesomeDialog(
//       context: context,
//       dialogType: DialogType.noHeader,
//       animType: AnimType.rightSlide,
//       title: "Likes",
//       desc: "", // You can leave this empty if you don't need a description
//       width: 600,
//       body: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: likes
//             .map((user) => Text(
//                   user,
//                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                 ))
//             .toList(),
//       ),
//       btnCancelText: "Close",
//       btnCancelOnPress: () {},
//     )..show();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'My Posts',
//           style: TextStyle(
//               fontSize: 25,
//               fontWeight: FontWeight.bold,
//               color: Colors.blue[800]),
//         ),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           iconSize: 40,
//           color: Colors.blue[800],
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,

//           // Inside the build method of your _myPostsState class
//           children: List.generate(posts.length, (index) {
//             final post = posts[index];
//             // Check if the post's author matches the current user
//             if (post.author == widget.username) {
//               return SizedBox(
//                 width: double.infinity,
//                 child: Card(
//                   elevation: 4,
//                   margin: EdgeInsets.all(8),
//                   clipBehavior: Clip.antiAlias,
//                   color: Color.fromARGB(255, 255, 255, 255),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       UserAccountsDrawerHeader(
//                         accountName: Text(
//                           " " + post.author,
//                           style: TextStyle(fontSize: 20),
//                         ),
//                         accountEmail: Text(""),
//                         currentAccountPicture: CircleAvatar(
//                           backgroundColor: Colors.lightBlue,
//                           child: Text(
//                             post.author.isNotEmpty
//                                 ? post.author[0].toUpperCase()
//                                 : '',
//                             style:
//                                 TextStyle(fontSize: 28.0, color: Colors.white),
//                           ),
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.blue,
//                         ),
//                       ),
//                       SizedBox(
//                         height: 200,
//                         child: Image.memory(
//                           post.imageData,
//                           fit: BoxFit.fitHeight,
//                           width: double.infinity,
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               "Title : " + post.title,
//                               style: TextStyle(
//                                 fontSize: 17,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             SizedBox(height: 4),
//                             Text(
//                               post.content,
//                               style: TextStyle(fontSize: 16),
//                             ),
//                             SizedBox(height: 8),
//                             TextField(
//                               controller: _commentController,
//                               decoration: InputDecoration(
//                                 hintText: 'Add a comment...',
//                               ),
//                             ),
//                             SizedBox(height: 8),
//                             Row(
//                               children: [
//                                 IconButton(
//                                   icon: Icon(
//                                     post.likes.contains(widget.username)
//                                         ? Icons.favorite
//                                         : Icons.favorite_border,
//                                     color: post.likes.contains(widget.username)
//                                         ? Colors.red
//                                         : null,
//                                   ),
//                                   onPressed: () => toggleLike(index),
//                                 ),
//                                 SizedBox(width: 8),
//                                 InkWell(
//                                   onTap: () => showLikesDialog(post.likes),
//                                   child: Text(
//                                     "Likes (${post.likes.length})",
//                                     style: TextStyle(
//                                       color: Colors.blue,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ),
//                                 SizedBox(width: 8),
//                                 ElevatedButton(
//                                   onPressed: () {
//                                     submitComment(
//                                         post.idPost, _commentController.text);
//                                     _commentController.clear();
//                                   },
//                                   child: Text(
//                                     'Comment',
//                                     style: TextStyle(
//                                         color: Colors.blue[800],
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 15),
//                                   ),
//                                 ),
//                                 SizedBox(width: 8),
//                                 ElevatedButton(
//                                   onPressed: () {
//                                     _deletePost(post.idPost);
//                                   },
//                                   child: Text(
//                                     'Delete Post',
//                                     style: TextStyle(
//                                         color: Colors.red,
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 15),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             SizedBox(height: 8),
//                             // Display comments
//                             if (post.comments.isNotEmpty)
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   SizedBox(height: 4),
//                                   if (post.comments.isNotEmpty)
//                                     Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         SizedBox(height: 4),
//                                         post.comments.length > 2
//                                             ? ExpansionTile(
//                                                 title: Text('Show comments'),
//                                                 children: [
//                                                   Column(
//                                                     crossAxisAlignment:
//                                                         CrossAxisAlignment
//                                                             .start,
//                                                     children: List.generate(
//                                                       post.comments.length,
//                                                       (commentIndex) {
//                                                         final comment =
//                                                             post.comments[
//                                                                 commentIndex];
//                                                         return Row(
//                                                           children: [
//                                                             Expanded(
//                                                               child: Text(
//                                                                 '${comment.username}: ${comment.text}',
//                                                                 style: TextStyle(
//                                                                     fontSize:
//                                                                         16),
//                                                               ),
//                                                             ),
//                                                             IconButton(
//                                                               icon: Icon(
//                                                                   Icons.close),
//                                                               onPressed: () {
//                                                                 _onDeleteCommentPressed(
//                                                                     post.idPost,
//                                                                     commentIndex);
//                                                               },
//                                                             ),
//                                                           ],
//                                                         );
//                                                       },
//                                                     ),
//                                                   ),
//                                                 ],
//                                               )
//                                             : Column(
//                                                 crossAxisAlignment:
//                                                     CrossAxisAlignment.start,
//                                                 children: List.generate(
//                                                   post.comments.length,
//                                                   (commentIndex) {
//                                                     final comment = post
//                                                         .comments[commentIndex];
//                                                     return Row(
//                                                       children: [
//                                                         Expanded(
//                                                           child: Text(
//                                                             '${comment.username}: ${comment.text}',
//                                                             style: TextStyle(
//                                                                 fontSize: 16),
//                                                           ),
//                                                         ),
//                                                         IconButton(
//                                                           icon:
//                                                               Icon(Icons.close),
//                                                           onPressed: () {
//                                                             _onDeleteCommentPressed(
//                                                                 post.idPost,
//                                                                 commentIndex);
//                                                           },
//                                                         ),
//                                                       ],
//                                                     );
//                                                   },
//                                                 ),
//                                               ),
//                                       ],
//                                     ),
//                                 ],
//                               ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             } else {
//               return SizedBox
//                   .shrink(); // Return empty container for posts by other users
//             }
//           }),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _commentController.dispose();
//     super.dispose();
//   }
// }

//////////////////////

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_dialog/awesome_dialog.dart';

class Posts {
  final int idPost;
  String title;
  String content;
  final String author;
  final Uint8List imageData;
  List<String> likes;
  List<Comments> comments;
  final int reportcount;

  Posts(
      {required this.idPost,
      required this.title,
      required this.content,
      required this.author,
      required this.imageData,
      this.likes = const [],
      this.comments = const [],
      required this.reportcount});
}

class Comments {
  final String username;
  final String text;

  Comments({required this.username, required this.text});
}

class myPosts extends StatefulWidget {
  final String baseUrl;
  final String username;
  const myPosts({Key? key, required this.baseUrl, required this.username})
      : super(key: key);
  @override
  _myPostsState createState() => _myPostsState();
}

class _myPostsState extends State<myPosts> {
  List<Posts> posts = [];
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

          List<Comments> comments = [];
          if (postData['comments'] != null) {
            comments =
                (postData['comments'] as List<dynamic>).map((commentData) {
              return Comments(
                username: commentData['username'],
                text: commentData['text'],
              );
            }).toList();
          }

          return Posts(
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

  Future<void> _deletePost(int postId) async {
    final response = await http.delete(
      Uri.parse('${widget.baseUrl}/deleteposts/$postId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      setState(() {
        // Remove the deleted post from the list
        posts.removeWhere((post) => post.idPost == postId);
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.rightSlide,
          title: "Delete Post",
          desc: "", // You can leave this empty if you don't need a description
          width: 600,
          body: Text("Deleted successfully"),
          btnCancelText: "Close",
          btnCancelOnPress: () {},
        )..show();
      });
    } else {
      print('Failed to delete post. Status code: ${response.statusCode}');
    }
  }

  Future<void> _deleteComment(int postId, int commentIndex) async {
    final response = await http.delete(
      Uri.parse('${widget.baseUrl}/posts/$postId/comments/$commentIndex'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      setState(() {
        // Remove the comment from the corresponding post
        posts
            .firstWhere((post) => post.idPost == postId)
            .comments
            .removeAt(commentIndex);
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.rightSlide,
          title: "Delete Comment",
          desc: "", // You can leave this empty if you don't need a description
          width: 600,
          body: Text("Comment deleted successfully"),
          btnCancelText: "Close",
          btnCancelOnPress: () {},
        )..show();
      });
    } else {
      print('Failed to delete comment. Status code: ${response.statusCode}');
    }
  }

  void _onDeleteCommentPressed(int postId, int commentIndex) {
    _deleteComment(postId, commentIndex);
  }

  void showLikesDialog(List<String> likes) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      animType: AnimType.rightSlide,
      title: "Likes",
      desc: "", // You can leave this empty if you don't need a description
      width: 600,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: likes
            .map((user) => Text(
                  user,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ))
            .toList(),
      ),
      btnCancelText: "Close",
      btnCancelOnPress: () {},
    )..show();
  }

  Future<void> _editPost(Posts post) async {
    TextEditingController titleController =
        TextEditingController(text: post.title);
    TextEditingController contentController =
        TextEditingController(text: post.content);

    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.rightSlide,
      title: 'Edit Post',
      body: Column(
        children: [
          TextField(
            controller: titleController,
            decoration: InputDecoration(labelText: 'Title'),
          ),
          TextField(
            controller: contentController,
            decoration: InputDecoration(labelText: 'Content'),
          ),
        ],
      ),
      btnCancelOnPress: () {
        // if (mounted) {

        // }
      },
      btnOkOnPress: () async {
        if (mounted) {
          post.title = titleController.text;
          post.content = contentController.text;
          await _updatePost(post);
        }
      },
    )..show();
  }

  // Function to update post on server
  Future<void> _updatePost(Posts post) async {
    final response = await http.put(
      Uri.parse('${widget.baseUrl}/editposts/${post.idPost}'),
      body: jsonEncode({
        'title': post.title,
        'content': post.content,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Post updated successfully
      fetchPost(); // Refresh the posts list
    } else {
      // Failed to update post
      print('Failed to update post. Status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Posts',
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
            // Check if the post's author matches the current user
            if (post.author == widget.username) {
              return SizedBox(
                width: double.infinity,
                child: Card(
                  elevation: 4,
                  margin: EdgeInsets.all(8),
                  clipBehavior: Clip.antiAlias,
                  color: Color.fromARGB(255, 255, 255, 255),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      UserAccountsDrawerHeader(
                        accountName: Text(
                          " " + post.author,
                          style: TextStyle(fontSize: 20),
                        ),
                        accountEmail: Text(""),
                        currentAccountPicture: CircleAvatar(
                          backgroundColor: Colors.lightBlue,
                          child: Text(
                            post.author.isNotEmpty
                                ? post.author[0].toUpperCase()
                                : '',
                            style:
                                TextStyle(fontSize: 28.0, color: Colors.white),
                          ),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                        ),
                      ),
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
                              "Title : " + post.title,
                              style: TextStyle(
                                fontSize: 17,
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
                              "The Number Of Report is : " +
                                  post.reportcount.toString(),
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
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      post.likes.contains(widget.username)
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color:
                                          post.likes.contains(widget.username)
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
                                    child: Text(
                                      'Comment',
                                      style: TextStyle(
                                          color: Colors.blue[800],
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      _deletePost(post.idPost);
                                    },
                                    child: Text(
                                      'Delete Post',
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      _editPost(post);
                                    },
                                    child: Text(
                                      'Edit Post',
                                      style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15),
                                    ),
                                  ),
                                ],
                              ),
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
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: List.generate(
                                                      post.comments.length,
                                                      (commentIndex) {
                                                        final comment =
                                                            post.comments[
                                                                commentIndex];
                                                        return Row(
                                                          children: [
                                                            Expanded(
                                                              child: Text(
                                                                '${comment.username}: ${comment.text}',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        16),
                                                              ),
                                                            ),
                                                            IconButton(
                                                              icon: Icon(
                                                                  Icons.close),
                                                              onPressed: () {
                                                                _onDeleteCommentPressed(
                                                                    post.idPost,
                                                                    commentIndex);
                                                              },
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: List.generate(
                                                  post.comments.length,
                                                  (commentIndex) {
                                                    final comment = post
                                                        .comments[commentIndex];
                                                    return Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            '${comment.username}: ${comment.text}',
                                                            style: TextStyle(
                                                                fontSize: 16),
                                                          ),
                                                        ),
                                                        IconButton(
                                                          icon:
                                                              Icon(Icons.close),
                                                          onPressed: () {
                                                            _onDeleteCommentPressed(
                                                                post.idPost,
                                                                commentIndex);
                                                          },
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                ),
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
            } else {
              return SizedBox
                  .shrink(); // Return empty container for posts by other users
            }
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
