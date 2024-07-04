import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:gp/ScreenChat/ChoseTarget.dart';
import 'package:gp/signupPage.dart';
import 'package:gp/welcome.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:gp/ScreenChat/chatScreen.dart';
import 'package:gp/ScreenChat/homeChat.dart';
import 'home.dart'; // Import for jsonEncode
import 'package:firebase_auth/firebase_auth.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:gp/globals.dart' as globals;

String? userNameForchat;



class LoginPage extends StatefulWidget {
  final String baseUrl;
  //const signinPage({super.key});
  const LoginPage({Key? key, required this.baseUrl}) : super(key: key);
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscureText = true; // for toggling password visibility
  final _auth = FirebaseAuth.instance;
  late String email;
  late String password;

  

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> signIn() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

  

    try {
      var url = Uri.parse('${widget.baseUrl}/login');
      var response = await http.post(
        url,
        body: jsonEncode({'email': email, 'password': password}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // Sign in successful
        print('Sign in successful!');
        var responseData = json.decode(response.body);
        String userName = responseData['user_name'];
        userNameForchat = responseData['user_name'];
        try {
          String email = emailController.text.trim();
          String password = passwordController.text.trim();
          print("shouldbe= " + email + password);
     
          globals.LoggedInUSEREmail = email;

          //-------signinhistrocal

            var responseHist = await http.post(
              Uri.parse('${widget.baseUrl}/loginHistorical'),
              body: jsonEncode({
                'email': email,
              }),
              headers: {'Content-Type': 'application/json'},
            );
            if (responseHist.statusCode == 200) {

                  var responseData = json.decode(responseHist.body);

            } else {
              // Some other error happened
              print('Historical day update failed: ${responseHist.statusCode}');
              print('Response body: ${responseHist.body}');
        

            }
          //-------signinhistrocal


          //-------coachsetup

          //-------coachsetup

          final user = await _auth.signInWithEmailAndPassword(
              email: email, password: password);
          if (user != null) {
            // ignore: use_build_context_synchronously
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => WelcomePage(
                          baseUrl: widget.baseUrl,
                          name: userName,
                          email: email,
                          password: password,
                        )));
          }
        } catch (e) {
          print(e);
        }
      } else {
        // Sign in failed

        print('Sign in failed with status code: ${response.statusCode}');
        print('Response body: ${response.body}');

        // showDialog(
        //   context: context,
        //   builder: (BuildContext context) {
        //     return AlertDialog(
        //       title: Text("Error"),
        //       content: Text("Incorrect Username or Password."),
        //       actions: <Widget>[
        //         TextButton(
        //           onPressed: () {
        //             Navigator.of(context).pop();
        //           },
        //           child: Text("OK"),
        //         ),
        //       ],
        //     );
        //   },
        // );

        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.rightSlide,
          title: 'Error',
          desc: 'Incorrect Username or Password.',
          btnOkOnPress: () {},
        )..show();
      }
    } catch (error) {
      // Handle error
      print('Error: $error');
    }
  }





//
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromARGB(255, 255, 255, 255),
            Color.fromARGB(255, 202, 248, 202)
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipPath(
                clipper: WaveClipper(),
                child: Image.asset(
                  'images/img1.jpg', // Replace 'images/img1.jpg' with your image path
                  fit: BoxFit.fill,
                ),
              ),
              SizedBox(height: 5),
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
              Text(
                'Login To Your Account',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: passwordController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureText
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(height: 20),
                    // InkWell(
                    //   onTap: () async {
                    //     // Add forgot password functionality here
                    //     try {
                    //       String email = emailController.text.trim();
                    //       String password = passwordController.text.trim();
                    //       print("shouldbe= " + email + password);

                    //       final user = await _auth.signInWithEmailAndPassword(
                    //           email: email, password: password);
                    //       if (user != null) {
                    //         // ignore: use_build_context_synchronously
                    //         Navigator.pushReplacement(
                    //           context,
                    //           //MaterialPageRoute(builder: (context) => chatScreen(baseUrl: widget.baseUrl)),
                    //           MaterialPageRoute(
                    //               builder: (context) => homeChat(
                    //                   username: userNameForchat!,
                    //                   baseUrl: widget.baseUrl)),
                    //         );
                    //       }
                    //     } catch (e) {
                    //       print(e);
                    //     }
                    //   },
                    //   child: Text(
                    //     'Forgot Password?-Chat Test',
                    //     textAlign: TextAlign.center,
                    //     style: TextStyle(
                    //       color: Color.fromARGB(
                    //           255, 235, 64, 21), // Change to your desired color
                    //       fontWeight: FontWeight.bold,
                    //     ),
                    //   ),
                    // ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Add login functionality here

                        signIn();
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Color.fromARGB(
                                255, 190, 235, 68)), // background color
                        elevation: MaterialStateProperty.all<double>(
                            5), // shadow elevation
                        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                          EdgeInsets.symmetric(
                              horizontal: 45, vertical: 15), // button padding
                        ),
                        shape: MaterialStateProperty.all<OutlinedBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                30), // button border radius
                          ),
                        ),
                      ),
                      child: Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // text color
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors
                                .blue, // Color for the first part of the text
                          ),
                        ),
                        SizedBox(width: 7),
                        InkWell(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      SignupPage(baseUrl: widget.baseUrl)),
                            );
                          },
                          child: Text(
                            'SignUp',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  Colors.red, // Color for the word "SignUp!!"
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height * 0.8);

    var firstControlPoint = Offset(size.width * 0.25, size.height);
    var firstEndPoint = Offset(size.width * 0.5, size.height * 0.8);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint = Offset(size.width * 0.75, size.height * 0.6);
    var secondEndPoint = Offset(size.width, size.height * 0.8);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, size.height * 0.8);
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
