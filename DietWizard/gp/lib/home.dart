import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:gp/BottomNav.dart';
import 'package:gp/CategoryPage.dart';
import 'package:gp/exerciseslist.dart';
import 'package:gp/welcome.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
// import 'package:draggable_expandable_fab/draggable_expandable_fab.dart';
import 'loginPage.dart';
import 'market.dart';
import 'mypost.dart';
import 'profile.dart';
import 'showposts.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class HomePage extends StatefulWidget {
  final String baseUrl;
  final String name;
  final String email;
  final String password;

  const HomePage({
    Key? key,
    required this.baseUrl,
    required this.name,
    required this.email,
    required this.password,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();
  File? _image;
  List<Post> posts = [];
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
            channelKey: 'basic_channel',
            channelName: 'Basic notifications',
            channelDescription: 'Notification channel for basic tests',
            defaultColor: Colors.blue,
            importance: NotificationImportance.High,
            enableVibration: true)
      ],
      debug: true,
    );
    super.initState();
    fetchPosts();
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        // This is just a basic example. For real apps, you must show some
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  Future<void> fetchPosts() async {
    final response = await http.get(Uri.parse('${widget.baseUrl}/posts'));

    if (response.statusCode == 200) {
      final List<dynamic> postsData = jsonDecode(response.body);

      setState(() {
        posts = postsData
            .map((postData) {
              final List<int> bufferData =
                  List<int>.from(postData['data']['data']);
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

              // Check if reportcount is less than 5
              if (postData['reportcount'] < 6) {
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
              } else {
                // Return null if reportcount is not less than 5
                return null;
              }
            })
            .whereType<Post>()
            .toList(); // Filter out null posts and cast to List<Post>
      });
    } else {
      print('Failed to fetch posts. Status code: ${response.statusCode}');
    }
  }

  Future<void> toggleLike(int postId) async {
    final int postIndex = posts.indexWhere((post) => post.idPost == postId);
    if (postIndex != -1) {
      setState(() {
        if (posts[postIndex].likes.contains(widget.name)) {
          posts[postIndex].likes.remove(widget.name);
        } else {
          posts[postIndex].likes.add(widget.name);
        }
      });

      final response = await http.put(
        Uri.parse('${widget.baseUrl}/posts/$postId/likes/${widget.name}'),
        body: jsonEncode({'likes': posts[postIndex].likes , 'UserLike' : widget.name}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        setState(() {
          if (posts[postIndex].likes.contains(widget.name)) {
            posts[postIndex].likes.remove(widget.name);
          } else {
            posts[postIndex].likes.add(widget.name);
          }
        });
      }


      
      



    }
  }

  Future<void> _saveNotification(String comment ,int postId) async {
    final responseNotification = await http.post(
      Uri.parse('${widget.baseUrl}/postnotification/$postId'),
      body: jsonEncode({
        'nameuser': widget.name,
        'descriptionNotification': comment,
        'titleNotification': "New Comment",
        'postId':postId
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<void> submitComment(int postId, String comment) async {

    final response = await http.post(
      Uri.parse('${widget.baseUrl}/posts/$postId/comments'),
      body: jsonEncode({'username': widget.name, 'comment': comment}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      await fetchPosts();

      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 10,
          channelKey: 'basic_channel',
          title: 'New Comment',
          body: comment,
        ),
      );
      await _saveNotification(comment,postId);
    } else {
      print('Failed to submit comment. Status code: ${response.statusCode}');
    }
  }

  Future<void> report(int postId) async {
    final response = await http.post(
      Uri.parse('${widget.baseUrl}/posts/report/$postId'),
      body: jsonEncode({'username': widget.name}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      await fetchPosts();
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.rightSlide,
        title: "Report Post",
        desc: "", // You can leave this empty if you don't need a description
        width: 600,
        body: Text("Reported successfully"),
        btnCancelText: "Close",
        btnCancelOnPress: () {},
      )..show();
    } else {
      print('Failed to submit comment. Status code: ${response.statusCode}');
    }
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

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    } else {
      print('No image selected.');
    }
  }

  Future<void> _addPost() async {
    final url = Uri.parse('${widget.baseUrl}/posts');
    final request = http.MultipartRequest('POST', url);

    // Add image if selected
    if (_image != null) {
      request.files
          .add(await http.MultipartFile.fromPath('image', _image!.path));
    }

    // Add title and content
    request.fields['title'] = _titleController.text;
    request.fields['content'] = _contentController.text;
    request.fields['name'] = widget.name;

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
         AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 10,
          channelKey: 'basic_channel',
          title: 'New Post Added',
          body: "Added by ${widget.name}",
        ),
      );

        print('Post added successfully');
        _showSuccessDialog();
        fetchPosts();
      } else {
        print('Failed to add post. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error adding post: $e');
    }
  }

  void _showSuccessDialog() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.rightSlide,
      title: 'Post Added Successfully',
      desc: 'Your post has been added successfully.',
      btnOkOnPress: () {
        setState(() {
          _image = null;
          _titleController.clear();
          _contentController.clear();
        });
      },
    )..show();
  }

  Widget buildPost(Post post) {
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
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   children: [
            //         UserAccountsDrawerHeader(
            //   accountName: Text(widget.name),
            //   accountEmail: Text(widget.email),
            //   currentAccountPicture: CircleAvatar(
            //     backgroundColor: Colors.lightBlue,
            //     child: Text(
            //       widget.name.isNotEmpty ? widget.name[0].toUpperCase() : '',
            //       style: TextStyle(fontSize: 25.0, color: Colors.white),
            //     ),
            //   ),
            //   decoration: BoxDecoration(
            //     color: Colors.blue,
            //   ),
            // ),

            //   ],
            //   // child: Text(
            //   //   // "UserName : "+
            //   //   "  "+
            //   //   post.author,
            //   //   style: TextStyle(
            //   //         fontSize: 20,
            //   //         fontWeight: FontWeight.bold,
            //   //       ),
            //   // ),
            // ),
            // Padding(
            // padding: const EdgeInsets.all(8.0),
            UserAccountsDrawerHeader(
              accountName: Text(
                " " + post.author,
                style: TextStyle(fontSize: 20),
              ),
              accountEmail: Text(""),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.lightBlue,
                child: Text(
                  post.author.isNotEmpty ? post.author[0].toUpperCase() : '',
                  style: TextStyle(fontSize: 28.0, color: Colors.white),
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),

            // ),

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
                  // Text("Posted By : "+
                  //   post.author,
                  //   style: TextStyle(
                  //     fontSize: 20,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                  SizedBox(height: 4),
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
                  // Text(
                  //   post.author,
                  //   style: TextStyle(fontSize: 16),
                  // ),
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
                          post.likes.contains(widget.name)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: post.likes.contains(widget.name)
                              ? Colors.red
                              : null,
                        ),
                        onPressed: () => toggleLike(post.idPost),
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
                          String commentText = _commentController.text.trim();
                          if (commentText.isNotEmpty) {
                            submitComment(post.idPost, commentText);
                            _commentController.clear();
                          } else {
                            // Show a snackbar or any other feedback to indicate that the comment is empty
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please enter a comment.'),
                              ),
                            );
                          }
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
                          report(post.idPost);
                        },
                        child: Text(
                          'Report',
                          style: TextStyle(
                              color: Colors.blue[800],
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                        ),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 4),
                              post.comments.length > 2
                                  ? ExpansionTile(
                                      title: Text(
                                        'Show comments',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: post.comments
                                              .map((comment) => Text(
                                                    '${comment.username}: ${comment.text}',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                    ),
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
                                                  fontSize: 16,
                                                ),
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
  }

  bool isDialogOpen = false; // Track if the dialog is already open

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Community",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[
          // IconButton(
          //   icon: const Icon(Icons.comment),
          //   tooltip: 'Comment Icon',
          //   onPressed: () {},
          // ),
          // IconButton(
          //   icon: const Icon(Icons.settings),
          //   tooltip: 'Setting Icon',
          //   onPressed: () {},
          // ),
        ],
        backgroundColor: Colors.blue,
        elevation: 50.0,
      ),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return buildPost(posts[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.info,
            animType: AnimType.leftSlide,
            title: 'Add Post',
            body: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      _image != null
                          ? Image.file(_image!, width: 100, height: 100)
                          : Container(),
                      SizedBox(height: 10),
                      TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Title',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _contentController,
                        decoration: InputDecoration(
                          labelText: 'Content',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () async {
                          await _pickImageFromGallery();
                          setState(
                              () {}); // Update the state to rebuild the dialog with the selected image
                        },
                        child: Text(
                          'Select Image',
                          style: TextStyle(
                              color: Colors.blue[800],
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            btnCancelOnPress: () {
              // Navigator.of(context).pop();
            },
            btnOkOnPress: () {
              _addPost();
              // Navigator.of(context).pop();
            },
          )..show();
        },
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNav(
        indexbottom: '2',
        baseUrl: widget.baseUrl,
        name: widget.name,
        email: widget.email,
        password: widget.password ?? 'default_password',
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(widget.name),
              accountEmail: Text(widget.email),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.lightBlue,
                child: Text(
                  widget.name.isNotEmpty ? widget.name[0].toUpperCase() : '',
                  style: TextStyle(fontSize: 25.0, color: Colors.white),
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.sports_gymnastics),
              title: const Text(' My Exercises '),
              onTap: () {
                // Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ExercisesListPage(
                            baseUrl: widget.baseUrl,
                          )),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.restaurant),
              title: const Text(' Foods'),
              onTap: () {
                // Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CategoryPage(
                            baseUrl: widget.baseUrl,
                            nameuser: widget.name,
                          )),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.post_add),
              title: const Text(' My Posts'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => myPosts(
                      baseUrl: widget.baseUrl,
                      username: widget.name,
                    ),
                  ),
                );
              },
            ),
            
          ],
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
