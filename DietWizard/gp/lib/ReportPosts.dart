import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:collection/collection.dart';

class ReportedPost {
  final int idPost; // Added idPost property
  final Uint8List imageData;
  final List<Comments> comments;
  String? returnReport;

  ReportedPost({
    required this.idPost,
    required this.imageData,
    required this.comments,
    this.returnReport,
  });
}

class Comments {
  final String username;
  final String text;

  Comments({required this.username, required this.text});
}

class ReportPosts extends StatefulWidget {
  final String baseUrl;

  const ReportPosts({Key? key, required this.baseUrl}) : super(key: key);

  @override
  _ReportPostsState createState() => _ReportPostsState();
}

class _ReportPostsState extends State<ReportPosts> {
  List<Map<String, dynamic>>? _reportInfoList;
  List<ReportedPost> postsReported = [];
  List<int> deletedPostIds = []; // Maintain a list of deleted post IDs

  Future<void> fetchPostInformation(BuildContext context) async {
    final url = Uri.parse('${widget.baseUrl}/posts/getreport');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final reportInfoList = json.decode(response.body);
        setState(() {
          _reportInfoList = List<Map<String, dynamic>>.from(reportInfoList);
          postsReported = _reportInfoList!
              .where((reportedPost) => reportedPost['reportcount'] > 5)
              .map((reportedPost) {
            final List<int> bufferData =
                List<int>.from(reportedPost['data']['data']);
            final Uint8List imageData = Uint8List.fromList(bufferData);

            List<Comments> comments = [];
            if (reportedPost['comments'] != null) {
              comments = (reportedPost['comments'] as List<dynamic>)
                  .map((commentData) {
                return Comments(
                  username: commentData['username'],
                  text: commentData['text'],
                );
              }).toList();
            }

            return ReportedPost(
              idPost: reportedPost['idPost'], // Added idPost initialization
              imageData: imageData,
              comments: comments,
              // ReturnReport: reportedPost['reportcount'],
            );
          }).toList();
        });
      } else if (response.statusCode == 404) {
        _showErrorDialog('Posts not found.');
      } else {
        _showErrorDialog('Failed to fetch post information.');
      }
    } catch (error) {
      _showErrorDialog('Failed to fetch post information: $error');
    }
  }

  Future<void> _deletePost(int postId) async {
    final response = await http.delete(
      Uri.parse('${widget.baseUrl}/deleteposts/$postId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      setState(() {
        // Add the deleted post ID to the list
        deletedPostIds.add(postId);
        // Remove the deleted post from the list
        postsReported.removeWhere((report) => report.idPost == postId);
        // AwesomeDialog(...)
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
        postsReported
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

  Future<void> _editPost(ReportedPost post) async {
    TextEditingController numberreportController =
        TextEditingController(text: post.returnReport);

    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.rightSlide,
      title: 'Edit Post',
      desc: 'Are You Sure To Return The Post ?',
      body: Column(
        children: [
          Text(
            "Are You Sure To Return This Post ",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          )
          // TextField(
          //   controller: numberreportController,
          //   decoration: InputDecoration(labelText: 'Number of reports'),
          // ),
        ],
      ),
      btnCancelOnPress: () {},
      btnOkOnPress: () async {
        if (mounted) {
          // post.returnReport = numberreportController.text;
          post.returnReport = "1";

          await _updatePost(post);
        }
      },
    )..show();
  }

  // Function to update post on server
  Future<void> _updatePost(ReportedPost post) async {
    final response = await http.put(
      Uri.parse('${widget.baseUrl}/editreportposts/${post.idPost}'),
      body: jsonEncode({
        'idPost': post.idPost,
        'reportcount': post.returnReport,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Post updated successfully
      fetchPostInformation(context); // Refresh the posts list
    } else {
      // Failed to update post
      print('Failed to update post. Status code: ${response.statusCode}');
    }
  }

  void _showErrorDialog(String errorMessage) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      title: 'Error',
      desc: errorMessage,
      btnOkText: 'Close',
      btnOkOnPress: () {},
    )..show();
  }

  Widget _buildCoachCards(List<Map<String, dynamic>> reportInfoList) {
    return Column(
      children: reportInfoList.map((infoListPost) {
        if (deletedPostIds.contains(infoListPost['idPost'])) {
          // Skip rendering deleted posts
          return SizedBox.shrink();
        }
        return Card(
          child: Stack(
            children: [
                 UserAccountsDrawerHeader(
                        accountName: Text(
                          " ${infoListPost['author']}",
                          style: TextStyle(fontSize: 20),
                        ),
                        accountEmail: Text(""),
                        currentAccountPicture: CircleAvatar(
                          backgroundColor: Colors.lightBlue,
                          child: Text(
                            infoListPost['author'].isNotEmpty
                                ? infoListPost['author'][0].toUpperCase()
                                : '',
                            style:
                                TextStyle(fontSize: 28.0, color: Colors.white),
                          ),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                        ),
                      ),
                       
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                   
                    SizedBox(height: 150),
                    Text(
                      'Title : ${infoListPost['title']}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 8),
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.memory(
                          postsReported
                              .firstWhere(
                                (post) => post.idPost == infoListPost['idPost'],
                                orElse: () => ReportedPost(
                                    idPost: infoListPost['idPost'],
                                    imageData: Uint8List(0),
                                    comments: []),
                              )
                              .imageData,
                          width: 230,
                          height: 300,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                      'Content : ${infoListPost['content']}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 15),
                    Text(
                      'The Number Of Report is :  ${infoListPost['reportcount']}',
                      style: TextStyle(fontSize: 16),
                    ),
                    // Comments section...
                    if (postsReported[reportInfoList.indexOf(infoListPost)]
                        .comments
                        .isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 4),
                          if (postsReported[
                                      reportInfoList.indexOf(infoListPost)]
                                  .comments
                                  .length >
                              0)
                            ExpansionTile(
                              title: Text('Show comments'),
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: List.generate(
                                    postsReported[reportInfoList
                                            .indexOf(infoListPost)]
                                        .comments
                                        .length,
                                    (commentIndex) {
                                      final comment = postsReported[
                                              reportInfoList
                                                  .indexOf(infoListPost)]
                                          .comments[commentIndex];
                                      return Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '${comment.username}: ${comment.text}',
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.close),
                                            onPressed: () {
                                              _onDeleteCommentPressed(
                                                  infoListPost[
                                                      'idPost'], // Assuming postId is the key for post id
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
                          else
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: List.generate(
                                postsReported[
                                        reportInfoList.indexOf(infoListPost)]
                                    .comments
                                    .length,
                                (commentIndex) {
                                  final comment = postsReported[
                                          reportInfoList.indexOf(infoListPost)]
                                      .comments[commentIndex];
                                  return Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${comment.username}: ${comment.text}',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.close),
                                        onPressed: () {
                                          _onDeleteCommentPressed(
                                              infoListPost[
                                                  'idPost'], // Assuming postId is the key for post id
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
              ),
              Positioned(
                top: 160,
                right: 10,
                child: IconButton(
                  icon: Icon(Icons.delete),
                  color: Colors.red,
                  onPressed: () {
                    AwesomeDialog(
                      context: context,
                      dialogType: DialogType.warning,
                      animType: AnimType.scale,
                      title: 'Confirm Delete',
                      desc: 'Are you sure you want to delete this coach',
                      btnCancelText: 'Cancel',
                      btnCancelOnPress: () {},
                      btnOkText: 'Delete',
                      btnOkOnPress: () {
                        // Call your delete function here passing the coach's id
                        _deletePost(infoListPost['idPost']);
                        // Show success dialog
                        AwesomeDialog(
                          context: context,
                          dialogType: DialogType.success,
                          animType: AnimType.rightSlide,
                          title: 'Delete Post',
                          desc: 'Deleted successfully',
                          width: 600,
                          btnOkText: 'Close',
                          btnOkOnPress: () {},
                        )..show();
                      },
                    )..show();
                  },
                ),
              ),
              Positioned(
                top: 160,
                right: 40,
                child: IconButton(
                  icon: Icon(Icons.edit),
                  color: Colors.green,
                  onPressed: () {
                    // Add edit functionality here

                    _editPost(
                        postsReported[reportInfoList.indexOf(infoListPost)]);
                  },
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Information About Posts',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.blue[800],
          ),
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
        child: Padding(
          padding: EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.network(
                'https://qbm.com.au/wp-content/uploads/2023/03/The-Benefits-of-Dilapidation-Reports-For-Pre-and-Post-Construction-1140x580.jpg',
                width: 400,
                height: 200,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  fetchPostInformation(context);
                },
                child: Text(
                  'Show Posts Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Show the coach information widgets if available
              if (_reportInfoList != null) _buildCoachCards(_reportInfoList!),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
