// import 'package:flutter/material.dart';
// import 'package:animated_text_kit/animated_text_kit.dart';
// import 'package:gp/loginPage.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert'; // Import for jsonEncode
// import 'package:awesome_dialog/awesome_dialog.dart';

// class SignupPage extends StatefulWidget {
//   final String baseUrl;

//   const SignupPage({Key? key, required this.baseUrl}) : super(key: key);
//   @override
//   State<SignupPage> createState() => _SignupPageState();
// }

// class _SignupPageState extends State<SignupPage> {
//   bool _obscureText = true; // for toggling password visibility

//   TextEditingController _usernameController = TextEditingController();
//   TextEditingController _emailController = TextEditingController();
//   TextEditingController _passwordController = TextEditingController();
//   TextEditingController _firstnameController = TextEditingController();
//   TextEditingController _lastnameController = TextEditingController();

//   Future<void> _signup() async {
//     String username = _usernameController.text.trim();
//     String email = _emailController.text.trim();
//     String password = _passwordController.text.trim();
//     String firstname = _firstnameController.text.trim();
//     String lastname = _lastnameController.text.trim();

//     // Check if any of the text fields are empty
//     if (username.isEmpty ||
//         email.isEmpty ||
//         password.isEmpty ||
//         firstname.isEmpty ||
//         lastname.isEmpty) {
//       // showDialog(
//       //   context: context,
//       //   builder: (BuildContext context) {
//       //     return AlertDialog(
//       //       title: Text("Error", style: TextStyle(color: Colors.red)),
//       //       content: Text("Fill all text fields!",
//       //           style: TextStyle(
//       //               color: Colors.black,
//       //               fontSize: 18,
//       //               fontWeight: FontWeight.bold)),
//       //       actions: <Widget>[
//       //         TextButton(
//       //           onPressed: () {
//       //             Navigator.of(context).pop();
//       //           },
//       //           child: Text("OK"),
//       //         ),
//       //       ],
//       //     );
//       //   },
//       // );

//       AwesomeDialog(
//         context: context,
//         dialogType: DialogType.warning,
//         animType: AnimType.topSlide,
//         title: 'Error',
//         desc: 'Fill all text fields!',
//         btnOkText: 'OK',
//         btnOkOnPress: () {
//           // Navigator.of(context).pop();
//         },
//       )..show();

//       return; // Return to exit the function if any field is empty
//     }

//     try {
//       var url = Uri.parse('${widget.baseUrl}/signup');
//       var response = await http.post(
//         url,
//         body: jsonEncode({
//           'username': username,
//           'email': email,
//           'password': password,
//           'firstname': firstname,
//           'lastname': lastname
//         }),
//         headers: {'Content-Type': 'application/json'},
//       );
//       if (response.statusCode == 200) {
//         // Signup successful
//         print('Signup successful!');
//         AwesomeDialog(
//           context: context,
//           dialogType: DialogType.success,
//           animType: AnimType.rightSlide,
//           title: 'Done',
//           desc: 'Registration Successful',
//           // btnCancelOnPress: () {},
//           btnOkOnPress: () {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                   builder: (context) => LoginPage(baseUrl: widget.baseUrl)),
//             );
//           },
//         )..show();
//         // Navigate to login page
//       } else {
//         // Some other error happened
//         print('Signup failed with status code: ${response.statusCode}');
//         print('Response body: ${response.body}');

//         // ignore: use_build_context_synchronously
//         // showDialog(
//         //   context: context,
//         //   builder: (BuildContext context) {
//         //     return AlertDialog(
//         //       title: Text(
//         //         "Error",
//         //         style: TextStyle(color: Colors.red),
//         //       ),
//         //       content: Text(
//         //         // ignore: unnecessary_null_comparison
//         //         response.body != null ? response.body : "Some Error Happened",
//         //         style: TextStyle(
//         //             color: Colors.black,
//         //             fontSize: 18,
//         //             fontWeight: FontWeight.bold),
//         //       ),
//         //       actions: <Widget>[
//         //         TextButton(
//         //           onPressed: () {
//         //             Navigator.of(context).pop();
//         //           },
//         //           child: Text("OK"),
//         //         ),
//         //       ],
//         //     );
//         //   },
//         // );

//         AwesomeDialog(
//           context: context,
//           dialogType: DialogType.error,
//           animType: AnimType.leftSlide,
//           title: 'Error',
//           desc: response.body != null ? response.body : 'Some Error Happened',
//           // btnCancelOnPress: () {},
//           btnOkOnPress: () {
//             // Navigator.of(context).pop();
//           },
//         )..show();
//       }
//     } catch (error) {
//       // Handle error
//       print('Error: $error');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Signup',
//           style: TextStyle(
//             fontSize: 25,
//             fontWeight: FontWeight.bold,
//             color: Colors.blue[800],
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: EdgeInsets.all(20.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Column(
//                 children: [
//                   Container(
//                     width: 280,
//                     height: 150,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.all(Radius.circular(20.0)),
//                       image: DecorationImage(
//                         image:
//                             AssetImage('images/img5.png'), // Adjust image path
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 10),
//                   SizedBox(
//                     width: double.infinity,
//                     child: Center(
//                       child: DefaultTextStyle(
//                         style: const TextStyle(
//                           fontSize: 40.0,
//                           fontWeight: FontWeight.bold,
//                           color: Color.fromARGB(255, 91, 169, 233),
//                         ),
//                         child: AnimatedTextKit(
//                           totalRepeatCount: 10,
//                           animatedTexts: [
//                             TypewriterAnimatedText(
//                               'Diet Wizard',
//                               speed: Duration(
//                                   milliseconds:
//                                       500), // Adjust speed to 5 seconds
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 10),
//               TextField(
//                 controller: _usernameController,
//                 decoration: InputDecoration(
//                   labelText: 'User Name',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.verified_user_rounded),
//                 ),
//               ),
//               SizedBox(height: 10.0),
//               TextField(
//                 controller: _firstnameController,
//                 decoration: InputDecoration(
//                   labelText: 'First Name',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.person),
//                 ),
//               ),
//               SizedBox(height: 10.0),
//               TextField(
//                 controller: _lastnameController,
//                 decoration: InputDecoration(
//                   labelText: 'Second Name',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.person),
//                 ),
//               ),
//               SizedBox(height: 10.0),
//               TextField(
//                 controller: _emailController,
//                 decoration: InputDecoration(
//                   labelText: 'Email',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.email),
//                 ),
//                 keyboardType: TextInputType.emailAddress,
//               ),
//               SizedBox(height: 10.0),
//               TextField(
//                 controller: _passwordController,
//                 obscureText: _obscureText,
//                 decoration: InputDecoration(
//                   labelText: 'Password',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.lock),
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                         _obscureText ? Icons.visibility : Icons.visibility_off),
//                     onPressed: () {
//                       setState(() {
//                         _obscureText = !_obscureText;
//                       });
//                     },
//                   ),
//                 ),
//               ),
//               SizedBox(height: 20.0),
//               ElevatedButton(
//                 onPressed: () {
//                   _signup();
//                 },
//                 style: ButtonStyle(
//                   backgroundColor: MaterialStateProperty.all<Color>(
//                       Color.fromARGB(255, 43, 148, 235)), // background color
//                   elevation:
//                       MaterialStateProperty.all<double>(5), // shadow elevation
//                   padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
//                     EdgeInsets.symmetric(
//                         horizontal: 45, vertical: 15), // button padding
//                   ),
//                   shape: MaterialStateProperty.all<OutlinedBorder>(
//                     RoundedRectangleBorder(
//                       borderRadius:
//                           BorderRadius.circular(30), // button border radius
//                     ),
//                   ),
//                 ),
//                 child: Text(
//                   'Sign Up',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white, // text color
//                   ),
//                 ),
//               ),
//               SizedBox(height: 20),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     "Already Registered?  ",
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color:
//                           Colors.blue, // Color for the first part of the text
//                     ),
//                   ),
//                   SizedBox(width: 7),
//                   InkWell(
//                     onTap: () {
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) =>
//                                 LoginPage(baseUrl: widget.baseUrl)),
//                       );
//                     },
//                     child: Text(
//                       'Login ',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 19,
//                         color: Colors.red, // Color for the word "SignUp!!"
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

////////////////////////////////////

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:animated_text_kit/animated_text_kit.dart';
// import 'package:gp/loginPage.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert'; // Import for jsonEncode
// import 'package:gp/ScreenChat/ChoseTarget.dart';

// class SignupPage extends StatefulWidget {
//   final String baseUrl;
//   //const signupPage({super.key});
//   const SignupPage({Key? key, required this.baseUrl}) : super(key: key);
//   @override
//   State<SignupPage> createState() => _SignupPageState();
// }

// class _SignupPageState extends State<SignupPage> {
//   bool _obscureText = true; // for toggling password visibility

//   TextEditingController _usernameController = TextEditingController();
//   TextEditingController _emailController = TextEditingController();
//   TextEditingController _passwordController = TextEditingController();
//   TextEditingController _firstnameController = TextEditingController();
//   TextEditingController _lastnameController = TextEditingController();

//   final _auth = FirebaseAuth.instance;
//   late String emailFire;
//   late String passwordFire;

//   Future<void> _signup() async {
//     String username = _usernameController.text.trim();
//     String email = _emailController.text.trim();
//     String password = _passwordController.text.trim();
//     String firstname = _firstnameController.text.trim();
//     String lastname = _lastnameController.text.trim();

//     // Check if any of the text fields are empty
//     if (username.isEmpty ||
//         email.isEmpty ||
//         password.isEmpty ||
//         firstname.isEmpty ||
//         lastname.isEmpty) {
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text("Error", style: TextStyle(color: Colors.red)),
//             content: Text("Fill all text fields!",
//                 style: TextStyle(
//                     color: Colors.black,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold)),
//             actions: <Widget>[
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: Text("OK"),
//               ),
//             ],
//           );
//         },
//       );
//       return;
//     }

//     try {
//       var url = Uri.parse('${widget.baseUrl}/signup');
//       var response = await http.post(
//         url,
//         body: jsonEncode({
//           'username': username,
//           'email': email,
//           'password': password,
//           'firstname': firstname,
//           'lastname': lastname
//         }),
//         headers: {'Content-Type': 'application/json'},
//       );
//       if (response.statusCode == 200) {
//         // Signup successful
//         print('Signup successful!');
//         try {
//           final newUser = await _auth.createUserWithEmailAndPassword(
//             email: email,
//             password: password,
//           );
//         } catch (e) {
//           print(e);
//         }

//         try {
//           String emailLog = email;
//           String passwordLog = password;
//           print("shouldbe= " + emailLog + passwordLog);

//           final user = await _auth.signInWithEmailAndPassword(
//               email: emailLog, password: passwordLog);
//           if (user != null) {
//             Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) =>
//                       choseTarget(display: 1, baseUrl: widget.baseUrl),
//                 ));
//           }
//         } catch (e) {
//           print(e);
//         }

//         // // Navigate to login page

//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//               builder: (context) => LoginPage(baseUrl: widget.baseUrl)),
//         );
//       } else {
//         // Some other error happened
//         print('Signup failed with status code: ${response.statusCode}');
//         print('Response body: ${response.body}');

//         showDialog(
//           context: context,
//           builder: (BuildContext context) {
//             return AlertDialog(
//               title: Text(
//                 "Error",
//                 style: TextStyle(color: Colors.red),
//               ),
//               content: Text(
//                 response.body != null ? response.body : "Some Error Happened",
//                 style: TextStyle(
//                     color: Colors.black,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold),
//               ),
//               actions: <Widget>[
//                 TextButton(
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                   child: Text("OK"),
//                 ),
//               ],
//             );
//           },
//         );
//       }
//     } catch (error) {
//       // Handle error
//       print('Error: $error');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Signup'),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: EdgeInsets.all(20.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Column(
//                 children: [
//                   Container(
//                     width: 280,
//                     height: 150,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.all(Radius.circular(20.0)),
//                       image: DecorationImage(
//                         image:
//                             AssetImage('images/img5.png'), // Adjust image path
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 10),
//                   SizedBox(
//                     width: double.infinity,
//                     child: Center(
//                       child: DefaultTextStyle(
//                         style: const TextStyle(
//                           fontSize: 40.0,
//                           fontWeight: FontWeight.bold,
//                           color: Color.fromARGB(255, 91, 169, 233),
//                         ),
//                         child: AnimatedTextKit(
//                           totalRepeatCount: 10,
//                           animatedTexts: [
//                             TypewriterAnimatedText(
//                               'Diet Wizard',
//                               speed: Duration(
//                                   milliseconds:
//                                       500), // Adjust speed to 5 seconds
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 10),
//               TextField(
//                 controller: _usernameController,
//                 decoration: InputDecoration(
//                   labelText: 'User Name',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.verified_user_rounded),
//                 ),
//               ),
//               SizedBox(height: 10.0),
//               TextField(
//                 controller: _firstnameController,
//                 decoration: InputDecoration(
//                   labelText: 'First Name',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.person),
//                 ),
//               ),
//               SizedBox(height: 10.0),
//               TextField(
//                 controller: _lastnameController,
//                 decoration: InputDecoration(
//                   labelText: 'Second Name',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.person),
//                 ),
//               ),
//               SizedBox(height: 10.0),
//               TextField(
//                 controller: _emailController,
//                 decoration: InputDecoration(
//                   labelText: 'Email',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.email),
//                 ),
//                 keyboardType: TextInputType.emailAddress,
//               ),
//               SizedBox(height: 10.0),
//               TextField(
//                 controller: _passwordController,
//                 obscureText: _obscureText,
//                 decoration: InputDecoration(
//                   labelText: 'Password',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.lock),
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                         _obscureText ? Icons.visibility : Icons.visibility_off),
//                     onPressed: () {
//                       setState(() {
//                         _obscureText = !_obscureText;
//                       });
//                     },
//                   ),
//                 ),
//               ),
//               SizedBox(height: 20.0),
//               ElevatedButton(
//                 onPressed: () {
//                   _signup();
//                   //signuptoFireBase();
//                 },
//                 style: ButtonStyle(
//                   backgroundColor: MaterialStateProperty.all<Color>(
//                       Color.fromARGB(255, 43, 148, 235)), // background color
//                   elevation:
//                       MaterialStateProperty.all<double>(5), // shadow elevation
//                   padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
//                     EdgeInsets.symmetric(
//                         horizontal: 45, vertical: 15), // button padding
//                   ),
//                   shape: MaterialStateProperty.all<OutlinedBorder>(
//                     RoundedRectangleBorder(
//                       borderRadius:
//                           BorderRadius.circular(30), // button border radius
//                     ),
//                   ),
//                 ),
//                 child: Text(
//                   'Sign Up',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white, // text color
//                   ),
//                 ),
//               ),
//               SizedBox(height: 20),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     "Already Registered?  ",
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color:
//                           Colors.blue, // Color for the first part of the text
//                     ),
//                   ),
//                   SizedBox(width: 7),
//                   InkWell(
//                     onTap: () {
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) =>
//                                 LoginPage(baseUrl: widget.baseUrl)),
//                       );
//                     },
//                     child: Text(
//                       'Login ',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 19,
//                         color: Colors.red, // Color for the word "SignUp!!"
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

/////////////////////////////////////////////////////

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:gp/loginPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Import for jsonEncode
import 'package:gp/ScreenChat/ChoseTarget.dart';
import 'signupcoach.dart';


class SignupPage extends StatefulWidget {
  final String baseUrl;
  //const signupPage({super.key});
  const SignupPage({Key? key, required this.baseUrl}) : super(key: key);
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool _obscureText = true; // for toggling password visibility

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _firstnameController = TextEditingController();
  TextEditingController _lastnameController = TextEditingController();

  final _auth = FirebaseAuth.instance;
  late String emailFire;
  late String passwordFire;

  Future<void> _signup() async {
    String username = _usernameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String firstname = _firstnameController.text.trim();
    String lastname = _lastnameController.text.trim();

    // Check if any of the text fields are empty
    if (username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        firstname.isEmpty ||
        lastname.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error", style: TextStyle(color: Colors.red)),
            content: Text("Fill all text fields!",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
      return;
    }

    try {
      var url = Uri.parse('${widget.baseUrl}/signup');
      var response = await http.post(
        url,
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'firstname': firstname,
          'lastname': lastname
        }),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        // Signup successful
        print('Signup successful!');
        try {
          final newUser = await _auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
        } catch (e) {
          print(e);
        }

        try {
          String usernameLog = username;
          String emailLog = email;
          String passwordLog = password;
             print("shouldbe= " + emailLog + passwordLog + usernameLog );

          final user = await _auth.signInWithEmailAndPassword(
              email: emailLog, password: passwordLog);
          if (user != null) {

              //to firebase-regusers
            await FirebaseFirestore.instance.collection('regusers').add({
              'username': usernameLog,
              'useremail': emailLog,      
            });

            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      choseTarget(display: 1, baseUrl: widget.baseUrl),
                ));
          }
        } catch (e) {
          print(e);
        }

        // // Navigate to login page
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(
        //       builder: (context) => LoginPage(baseUrl: widget.baseUrl)),
        // );
      } else {
        // Some other error happened
        print('Signup failed with status code: ${response.statusCode}');
        print('Response body: ${response.body}');

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                "Error",
                style: TextStyle(color: Colors.red),
              ),
              content: Text(
                response.body != null ? response.body : "Some Error Happened",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
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
        title: Text('Signup'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Container(
                    width: 280,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      image: DecorationImage(
                        image:
                            AssetImage('images/img5.png'), // Adjust image path
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: Center(
                      child: DefaultTextStyle(
                        style: const TextStyle(
                          fontSize: 40.0,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 91, 169, 233),
                        ),
                        child: AnimatedTextKit(
                          totalRepeatCount: 10,
                          animatedTexts: [
                            TypewriterAnimatedText(
                              'Diet Wizard',
                              speed: Duration(
                                  milliseconds:
                                      500), // Adjust speed to 5 seconds
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'User Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.verified_user_rounded),
                ),
              ),
              SizedBox(height: 10.0),
              TextField(
                controller: _firstnameController,
                decoration: InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              SizedBox(height: 10.0),
              TextField(
                controller: _lastnameController,
                decoration: InputDecoration(
                  labelText: 'Second Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              SizedBox(height: 10.0),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 10.0),
              TextField(
                controller: _passwordController,
                obscureText: _obscureText,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  _signup();
                  //signuptoFireBase();
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Color.fromARGB(255, 43, 148, 235)), // background color
                  elevation:
                      MaterialStateProperty.all<double>(5), // shadow elevation
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    EdgeInsets.symmetric(
                        horizontal: 45, vertical: 15), // button padding
                  ),
                  shape: MaterialStateProperty.all<OutlinedBorder>(
                    RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(30), // button border radius
                    ),
                  ),
                ),
                child: Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // text color
                  ),
                ),
              ),
              SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already Registered?  ",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color:
                          Colors.blue, // Color for the first part of the text
                    ),
                  ),
                  SizedBox(width: 7),
                  InkWell(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                LoginPage(baseUrl: widget.baseUrl)),
                      );
                    },
                    child: Text(
                      'Login ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 19,
                        color: Colors.red, // Color for the word "SignUp!!"
                      ),
                    ),
                  ),
                   
                ],
              ),
              SizedBox(height: 2),
              //  Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Text(
              //       "Coach Not Registered?  ",
              //       style: TextStyle(
              //         fontWeight: FontWeight.bold,
              //         color:
              //             Colors.blue, // Color for the first part of the text
              //       ),
              //     ),
              //     SizedBox(width: 7),
              //     InkWell(
              //       onTap: () {
              //         Navigator.pushReplacement(
              //           context,
              //           MaterialPageRoute(
              //               builder: (context) =>
              //                   SignupCoachPage(baseUrl: widget.baseUrl)
              //                   ),
              //         );
              //       },
              //       child: Text(
              //         'Sign Up ', 
              //         style: TextStyle(
              //           fontWeight: FontWeight.bold,
              //           fontSize: 19,
              //           color: Colors.red, // Color for the word "SignUp!!"
              //         ),
              //       ),
              //     ),
                   
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
