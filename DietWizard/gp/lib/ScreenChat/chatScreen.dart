import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:gp/loginPage.dart';
import 'package:gp/ScreenChat/homeChat.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final FirebaseFirestore fireStoreinst = FirebaseFirestore.instance;
final List<String> Recemails = [
  'bahaa@gmail.com',
  'yazan@gmail.com',
  'ahmad@gmail.com',
  'ibrahim@gmail.com',
  
];
String? signedInUserEmail;
String? signedInUserID;
String? signedInUserRecievd;
String? RecChatemail;
String? chatPartnerName;
String? chatOriginName;

class chatScreen extends StatefulWidget {
  final String baseUrl;
  final String username;
  final String? signInConstructorEmail;
  final String? chatwithConstructorEmail;
  // const chatScreen({Key? key, required this.baseUrl}) : super(key: key);
  const chatScreen({
    Key? key,
    required this.username,
    required this.baseUrl,
    this.signInConstructorEmail,
    this.chatwithConstructorEmail,
  }) : super(key: key);

  @override
  State<chatScreen> createState() => _chatScreenState();
}

class _chatScreenState extends State<chatScreen> {
  final msgTextcontroller = TextEditingController();

  String? messageText;

  final _auth = FirebaseAuth.instance;
  late User signedInUser;

  @override
  void initState() {
    RecChatemail = widget.chatwithConstructorEmail ?? Recemails[0];
    chatOriginName = widget.username;
    getPartnerName(RecChatemail!);
    print(
        "chatwithConstructorEmail = ${widget.chatwithConstructorEmail}        ------------------  ");
    print("RecChatemail = ${RecChatemail}        --------------------");
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        signedInUser = user;
        signedInUserEmail = signedInUser.email;
        signedInUserID = signedInUser.uid;
        print(
            "signed email = ${signedInUser.email} --- signed ID = ${signedInUser.uid}");
      }
    } catch (e) {
      print(e);
    }
  }

  void getMessageStrema() async {
    await for (var snapshot
        in fireStoreinst.collection('messages').snapshots()) {
      for (var message in snapshot.docs) {
        print(message.data());
      }
    }
  }

// Function to handle sending a message
  Future<void> sendMessage() async {
    msgTextcontroller.clear();
    final receiverEmail = RecChatemail;
    final userPair = [signedInUserEmail, receiverEmail];
    userPair.sort(); // Sort it alphabetically to create  document ID to pair
    final chatRef = fireStoreinst
        .collection('userchated')
        .doc('${userPair[0]}-${userPair[1]}');
    final chatDoc = await chatRef.get();
    if (chatDoc.exists) {
      // If chat document exists, update lastmsgtime and do not create a new document
      await chatRef.update({
        'lastmsgtime': FieldValue.serverTimestamp(),
      });
    } else {
      // If chat document doesn't exist, create a new document and set lastmsgtime
      await chatRef.set({
        'chatwith': receiverEmail,
        'lastmsgtime': FieldValue.serverTimestamp(),
        'myemail': signedInUserEmail,
        'myuserid': signedInUserID,
      });
    }
    // Add the message to the messages collection
    await fireStoreinst.collection('messages').add({
      'text': messageText,
      'email': signedInUserEmail,
      'senderid': signedInUserID,
      'recevieremail': receiverEmail,
      'time': FieldValue.serverTimestamp(),
    });
  }


    Future<void> getPartnerName(String PartnerEmail) async {
      print("PartnerEmail = ${PartnerEmail}");
      print("PartnerEmail = ${widget.baseUrl}");
    try {
      var url = Uri.parse('${widget.baseUrl}/getchatname');
      var response = await http.post(
        url,
        body: jsonEncode({'email': PartnerEmail,}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // Sign in successful
        print('response successful!');
        var responseData = json.decode(response.body);
        String username = responseData['username'];
      chatPartnerName = responseData['username'];
     
      } else {
        // Sign in failed

        print('failed with status code: ${response.statusCode}');
        print('Response body: ${response.body}');

      }
    } catch (error) {
      // Handle error
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 80, 236, 236),
        title: Row(
          children: [
            Image.asset(
              'images/img6.png',
              height: 87,
              width: 75,
            ),
            SizedBox(width: 55),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              
              child: Text(
                'DietWizard Chat',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(left: 10, top: 8.0),
            child: IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => homeChat(
                        username: widget.username, baseUrl: widget.baseUrl),
                  ),
                );
              },
              icon: Icon(Icons.chat),
            ),
          ),
      
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MsgstrmBuldr(),
            Container(
              height: 60, // Define the height of the container
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Color.fromARGB(255, 223, 186, 119),
                    width: 2,
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Color.fromARGB(255, 236, 189, 189),
                      ),
                      child: TextField(
                        controller: msgTextcontroller,
                        onChanged: (value) {
                          messageText = value;
                        },
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 20,
                          ),
                          hintText: 'Write your message here...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: const Color.fromARGB(255, 133, 171, 214),
                    ),
                    child: IconButton(
                      onPressed: () async {
                        await sendMessage();
                      }, //end on pressed
                      icon: Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MsgstrmBuldr extends StatelessWidget {
  const MsgstrmBuldr({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      //stream: fireStoreinst.collection('messages').orderBy('time').snapshots(),
      stream: fireStoreinst
          .collection('messages')
          .where('email', whereIn: [signedInUserEmail, RecChatemail])
          .orderBy('time')
          .snapshots(),
      builder: (context, snapshot) {
        List<msgline> messagewidgetList = [];

        if (!snapshot.hasData) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: CircularProgressIndicator(
                backgroundColor: Colors.blue,
              ),
            ),
          );
        }

        // final messagesD = snapshot.data!.docs.toList().reversed;
        /*
                          in future remember to change the way,, but for now you have to change recemails list everytime
                          --fn sendMessage() is for userchated to store to/with chat user and last time msg
                 */
        final messagesD = snapshot.data!.docs
            .where((doc) =>
                doc['recevieremail'] == signedInUserEmail ||
                doc['recevieremail'] == RecChatemail)
            .toList()
            .reversed;
        for (var msg in messagesD) {
          // if(msg.get('email') == signedInUserEmail && msg.get('recevieremail') ){

          // }
          final messagesDText = msg.get('text');
          final messagesDemail = msg.get('email');
          final messagesDsenderID = msg.get('senderid');
          final messagesDtime = msg.get('time');
          final messagesDRecMsg = msg.get('recevieremail');
          final currentuser = signedInUserEmail;
          final messagesPname;
          if(messagesDemail==signedInUserEmail){
            print("okEMAILLLLLLLLLLLLL");
              messagesPname = chatOriginName;
          }
          else {
            messagesPname = chatPartnerName;
          }


          final singlemsgWidg = msgline(
           // Msgemail: messagesDemail,
            Msgemail: messagesPname,
            text: messagesDText,
            isMe: currentuser == messagesDemail,
          );

          messagewidgetList.add(singlemsgWidg);
        }
        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            children: messagewidgetList,
          ),
        );
      },
    );
  }
}

class msgline extends StatelessWidget {
  const msgline({this.text, this.Msgemail, required this.isMe, Key? key})
      : super(key: key);

  final String? text;
  final String? Msgemail;
  //final String? RecMsg;
  final bool isMe;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            '$Msgemail',
            style: TextStyle(
                fontSize: 14, color: const Color.fromARGB(255, 34, 32, 30)),
          ),
              Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              isMe ? SizedBox() :  Padding(
               padding: const EdgeInsets.only(bottom: 10.0),
                child: CircleAvatar(
                 // child: Icon(Icons.coffee),
                   child: Text(
                       RecChatemail!.isNotEmpty
                            ? RecChatemail![0].toUpperCase()
                           
                            : '',
                        style: TextStyle(fontSize: 30.0, color: Colors.red[300]),
                      ),
                ),
              ),
              SizedBox(width: 5), // Add space between avatar and message text
              Material(
                elevation: 6,
                borderRadius: isMe
                    ? BorderRadius.only(
                        topLeft: Radius.circular(30),
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      )
                    : BorderRadius.only(
                        topRight: Radius.circular(30),
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                color: isMe ? Color.fromARGB(255, 73, 164, 238) : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 20.0),
                  child: Text(
                    '$text',
                    style: TextStyle(
                      fontSize: 15,
                      color: isMe ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
               SizedBox(width: 5), // Add space between message text and avatar
              isMe ? Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: CircleAvatar(
                //  child: Icon(Icons.coffee),
                  child: Text(
                       signedInUserEmail!.isNotEmpty
                            ? signedInUserEmail![0].toUpperCase()
                            : '',
                        style: TextStyle(fontSize: 30.0, color: Colors.blue),
                      ),
                  
                ),
              ) : SizedBox(),
              
            ],
          ),
        ],
      ),
    );
  }
}