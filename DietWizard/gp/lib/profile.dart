import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// import 'loginPage.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'welcome.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class ProfilePage extends StatefulWidget {
  final String baseUrl;
  final String name;
  final String email;


  const ProfilePage({
    Key? key,
    required this.baseUrl,
    required this.name,
    required this.email,
   
  }) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  String oldPassword = '';
  String newPassword = '';

  final _auth = FirebaseAuth.instance;

  void changePassword() async {
    String changePasswordUrl = widget.baseUrl + '/changepassword';

    try {
      var response = await http.post(
        Uri.parse(changePasswordUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': widget.email,
          'oldpassword': oldPassword,
          'newpassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
       
        final currentUser = _auth.currentUser;
        print( currentUser);
        if (currentUser != null) {
          // Create a credential with the user's current email and their current password
          final credential = EmailAuthProvider.credential(
              email: widget.email, password: oldPassword);

          // Reauthenticate the user using the credential
          await currentUser.reauthenticateWithCredential(credential);

          // Update the password
          await currentUser.updatePassword(newPassword);
        } else {
          // Handle the case where the current user is null
          print('Current user is null');
        }

        print('Password changed successfully');
        // Clear text fields
        oldPasswordController.clear();
        newPasswordController.clear();

        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.rightSlide,
          title: 'Success',
          desc: 'Password changed successfully.',
          // btnCancelOnPress: () {},
          btnOkOnPress: () {},
        )..show();

        // Show success message or perform any additional actions
      } else {
        print('Password change failed: ${response.body}');
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.rightSlide,
          title: 'Error',
          desc: 'Password change failed ',
          // btnCancelOnPress: () {},
          btnOkOnPress: () {},
        )..show();

        // Show error message or handle error scenarios
      }
    } catch (e) {
      print('Error occurred while changing password: $e');
      // Handle error scenarios
    }
  }

  @override
  void initState() {
   super.initState();
  

 

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
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
            // Navigator.of(context).pop();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => WelcomePage(baseUrl: widget.baseUrl,name: widget.name, email: widget.email,)),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(1.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
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
                color: Color.fromARGB(255, 102, 177, 238),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.blue[200],
                borderRadius: BorderRadius.circular(10),
              ),
              // child: Text(
              //   "The Old Password Is : " + widget.password,
              //   style: TextStyle(fontSize: 25),
              // ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: oldPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Old Password',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  oldPassword = value;
                });
              },
            ),
            SizedBox(height: 20),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  newPassword = value;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Call the method to change password
                changePassword();
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  'Change Password',
                  style: TextStyle(
                      color: Colors.blue[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
