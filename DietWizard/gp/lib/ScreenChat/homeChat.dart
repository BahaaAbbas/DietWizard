import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:async/async.dart'; // Importing the async package
import 'package:gp/ScreenChat/chatScreen.dart';
import 'package:gp/ScreenChat/testfortest.dart';
import 'package:gp/loginPage.dart';
import 'package:gp/home.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:gp/welcome.dart';
import 'package:flutter/cupertino.dart';

final FirebaseFirestore fireStoreinst = FirebaseFirestore.instance;
final FirebaseAuth _auth = FirebaseAuth.instance;
late String signedInUserEmail;
String? outerbaseURL;
String? GlobalPartnerName;

class homeChat extends StatefulWidget {
  final String baseUrl;
  final String username;

  final String? email;
  const homeChat(
      {Key? key,
      this.email,
    
      required this.username,
      required this.baseUrl})
      : super(key: key);

  @override
  State<homeChat> createState() => _homeChatState();
}

class _homeChatState extends State<homeChat> {
  late User signedInUser;
  bool _isSearchingHas = false;
  TextEditingController _searchController = TextEditingController();
  String nameSearch = "";

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        setState(() {
          signedInUser = user;
          signedInUserEmail = signedInUser.email!;
        });
        print("signed email = ${signedInUser.email}");
      }
    } catch (e) {
      print(e);
    }
  }

 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 80, 236, 236),
        title: Row(
          children: [
            IconButton(
              onPressed: () {
                              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificationMessages(
                      username: widget.username,
                      baseUrl: widget.baseUrl,
                      email: signedInUserEmail,
                      //password: widget.password!,
                      

                    ),
                  ),
                );
              },
              icon: Icon(
                Icons.arrow_back,
                color: Color.fromARGB(255, 104, 159, 221),
                size: 35,
              ),
            ),
                SizedBox(width: 10), 
               Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20), 
                  ),
                  child: TextField(
                    controller: _searchController,
                       onChanged: (value) {
                        setState(() {
                            nameSearch = value;
                            _isSearchingHas = value.isNotEmpty; // Update the flag based on text field content
                        });
                      
                    },
                    decoration: InputDecoration(
                      hintText: 'Search',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none, 
                      icon: Icon(Icons.search, color: Colors.grey), 
                    ),
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
            
               Navigator.pushReplacement(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => WelcomePage(
                              baseUrl: widget.baseUrl,
                              name: widget.username,
                              email: signedInUserEmail,
                             
                            ),
                          ),
                        );
            },
            icon: Icon(Icons.home),
          ),
        ],
      ),
      body: _isSearchingHas? 
      SearchResults(
      onCardPressed: (index, myEmail, chatWith, baseUrl) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => chatScreen(
                username: widget.username,
                baseUrl: baseUrl,
                signInConstructorEmail: signedInUserEmail,
                chatwithConstructorEmail:
                    (chatWith == signedInUserEmail) ? myEmail : chatWith,
              ),
            ),
          );
        },
        baseUrl: widget.baseUrl,
        username: widget.username,
        searchUser: nameSearch,


      )
      :
      cardChat(
        onCardPressed: (index, myEmail, chatWith, baseUrl) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => chatScreen(
                username: widget.username,
                baseUrl: baseUrl,
                signInConstructorEmail: signedInUserEmail,
                chatwithConstructorEmail:
                    (chatWith == signedInUserEmail) ? myEmail : chatWith,
              ),
            ),
          );
        },
        baseUrl: widget.baseUrl,
        username: widget.username,
      ),
    );
  }
}

class cardChat extends StatelessWidget {
  final Function(int, String, String, String) onCardPressed;
  final String baseUrl;
  final String username;
  const cardChat(
      {Key? key,
      required this.username,
      required this.onCardPressed,
      required this.baseUrl})
      : super(key: key);


Future<String> getPartnerName(String partnerEmail) async {
    try {
      var url = Uri.parse('$baseUrl/getchatname');
      var response = await http.post(
        url,
        body: jsonEncode({'email': partnerEmail}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // Sign in successful
        print('Response successful!');
        var responseData = json.decode(response.body);
        String partnerName = responseData['username'];
        print('PartnerName = $partnerName');
        return partnerName;
      } else {
        // Sign in failed
        print('Failed with status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return '';
      }
    } catch (error) {
      // Handle error
      print('Error: $error');
      return '';
    }
  }


  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: getUsersStream(),
      builder: (BuildContext context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: CircularProgressIndicator(backgroundColor: Colors.blue),
            ),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }
        final List<DocumentSnapshot> documents = snapshot.data ?? [];
        if (documents.isEmpty) {
          return Center(
            child: Text('No chats found yet.'),
          );
        }

        return ListView.builder(
          itemCount: documents.length,
          itemBuilder: (context, index) {
            final document = documents[index];
            String chatWith = document['chatwith'];
            String myEmail = document['myemail'];
            String myUserId = document['myuserid'];
            Timestamp lastMsgTime = document['lastmsgtime'];

            // Determine the chat partner's email
            String partnerEmail = (chatWith == signedInUserEmail) ? myEmail : chatWith;

            return FutureBuilder<String>(
              future: getPartnerName(partnerEmail),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Placeholder widget while waiting for data
                  return SizedBox(
                    width: 24,
                    height: 24,
                    child: Text(' '),
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  // Partner name fetched successfully, build the chat card
                  String partnerName = snapshot.data ?? '';
                  return Padding(
                    padding: const EdgeInsets.only(
                      top: 12,
                      right: 8,
                      left: 8,
                      bottom: 8,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200], // Background color for the rounded container
                        borderRadius: BorderRadius.circular(25.0), // Rounded corners
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(8.0), // Padding for the list tile content
                        leading: CircleAvatar(
                          // Using Icons.person as a placeholder for profile icons
                          child: Text(
                            partnerEmail.isNotEmpty
                                ? partnerEmail[0].toUpperCase()
                                : '',
                            style: TextStyle(fontSize: 30.0, color: Colors.blue),
                          ),
                        ),
                        title: Text(
                          partnerName.isNotEmpty ? partnerName : partnerEmail,
                          style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),
                        ),
                        subtitle: Text(
                            'Last chatted: ${DateFormat('yyyy-MM-dd HH:mm').format(lastMsgTime.toDate())}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        onTap: () {
                          // myEmail
                          // chatWith
                          // Navigate to chat screen for this user
                          String myEmail = document['myemail'];
                          String chatWith = document['chatwith'];
                          onCardPressed(index, myEmail, chatWith, baseUrl);
                        }, // onTap
                      ),
                    ),
                  );
                }
              },
            );
          },
        );
      },
    );
  }

Stream<List<DocumentSnapshot>> getUsersStream() async* {
  var myEmailQuery = fireStoreinst
      .collection('userchated')
      .where('myemail', isEqualTo: signedInUserEmail)
      .snapshots();

  var chatWithEmailQuery = fireStoreinst
      .collection('userchated')
      .where('chatwith', isEqualTo: signedInUserEmail)
      .snapshots();

  await for (var myEmailSnapshot in myEmailQuery) {
    await for (var chatWithEmailSnapshot in chatWithEmailQuery) {
      var documents = <DocumentSnapshot>[];

      // Add documents from myEmailSnapshot to the list
      documents.addAll(myEmailSnapshot.docs);

      // Add documents from chatWithEmailSnapshot to the list
      documents.addAll(chatWithEmailSnapshot.docs);

      // Filter out documents with null lastmsgtime and sort by lastmsgtime
      documents = documents.where((doc) => doc['lastmsgtime'] != null)
          .toList()
          ..sort((a, b) => (b['lastmsgtime'] as Timestamp).compareTo(a['lastmsgtime'] as Timestamp));

      yield documents;
    }
  }
}


}


class SearchResults extends StatelessWidget {
  final Function(int, String, String, String) onCardPressed;
  final String baseUrl;
  final String username;
  final String searchUser;
  const SearchResults(
      {Key? key,
      required this.searchUser,
      required this.username,
      required this.onCardPressed,
      required this.baseUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
 return StreamBuilder(
  stream: getSearchUsers(searchUser),
  builder:(BuildContext context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: CircularProgressIndicator(backgroundColor: Colors.blue),
            ),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        final List<DocumentSnapshot> documents = snapshot.data ?? [];
        if (documents.isEmpty) {
          return Center(
            child: Text('No users found.'),
          );
        }

        return ListView.builder(
          itemCount: documents.length,
          itemBuilder: (context, index) {
            final document = documents[index];
            String getregUsername = document['username'];
            String getregUseremail = document['useremail'];
              print(getregUsername + getregUseremail);
            if (getregUsername.toLowerCase().startsWith(searchUser.toLowerCase())) {

              return Padding(
                padding: const EdgeInsets.only(
                  top: 12,
                  right: 8,
                  left: 8,
                  bottom: 8,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200], // Background color for the rounded container
                    borderRadius: BorderRadius.circular(25.0), // Rounded corners
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(8.0), // Padding for the list tile content
                    leading: CircleAvatar(
                      child: Text(
                        getregUsername.isNotEmpty ? getregUsername[0].toUpperCase() : '',
                        style: TextStyle(fontSize: 30.0, color: Colors.blue),
                      ),
                    ),
                    title: Text(
                      getregUsername,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      // myEmail
                      // chatWith
                      // Navigate to chat screen for this user

                       String myEmail = signedInUserEmail;
                       String chatWith = document['useremail'];
                       onCardPressed(index, myEmail, chatWith, baseUrl);
                    }, //ontap
                  ),
                ),
              );
            } else {
              return SizedBox.shrink();
            }
            
          },
        );

  } ,
  );
 

}



Stream<List<DocumentSnapshot>> getSearchUsers(String searchText) async* {

   final QuerySnapshot<Map<String, dynamic>> querySnapshot = await fireStoreinst
    .collection('regusers')
    .where('username', isGreaterThanOrEqualTo: searchText)
    .where('username', isLessThanOrEqualTo: '$searchText\uf8ff')
    .get();

  yield querySnapshot.docs;

}

}
