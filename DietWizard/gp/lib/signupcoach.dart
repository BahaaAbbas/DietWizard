import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:gp/loginPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Import for jsonEncode
import 'package:gp/ScreenChat/ChoseTarget.dart';
import 'package:image_picker/image_picker.dart';

import 'package:awesome_notifications/awesome_notifications.dart';

class SignupCoachPage extends StatefulWidget {
  final String baseUrl;
  final String email;
  const SignupCoachPage({Key? key, required this.baseUrl,required this.email}) : super(key: key);
  @override
  State<SignupCoachPage> createState() => _SignupCoachPageState();
}

class _SignupCoachPageState extends State<SignupCoachPage> {
  bool _obscureText = true; // for toggling password visibility
  File? _image;
  // TextEditingController _usernameController = TextEditingController();
  // TextEditingController _emailController = TextEditingController();
    late TextEditingController _emailController; // return bahaa
  // TextEditingController _passwordController = TextEditingController();
  // TextEditingController _firstNameController = TextEditingController();
  // TextEditingController _lastNameController = TextEditingController();
  // TextEditingController _ageController = TextEditingController();
  // TextEditingController _genderController = TextEditingController();
  // TextEditingController _WeightController = TextEditingController();
  // TextEditingController _heightController = TextEditingController();

  TextEditingController _yearsexperiencesController = TextEditingController();
  TextEditingController _qualificationsController = TextEditingController();
  TextEditingController _NumberoftraineesController = TextEditingController();


  @override
      void initState() {
        super.initState();
        _emailController = TextEditingController(text: widget.email);
      }

   Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  final _auth = FirebaseAuth.instance;
  late String emailFire;
  late String passwordFire;

  Future<void> _signup(BuildContext context) async {
    // String username = _usernameController.text.trim();
    String email = _emailController.text.trim();
    // String password = _passwordController.text.trim();
    // String firstName = _firstNameController.text.trim();
    // String lastName = _lastNameController.text.trim();
    // String age = _ageController.text.trim();
    // String gender = _genderController.text.trim();
    String yearsexperiences = _yearsexperiencesController.text.trim();
    String qualifications = _qualificationsController.text.trim();
    // String Weight = _WeightController.text.trim();
    // String height = _heightController.text.trim();
    String Numberoftrainees = _NumberoftraineesController.text.trim();

    // Check if any of the text fields are empty
    if (
    // username.isEmpty ||
        email.isEmpty ||
        // password.isEmpty ||
    //     firstName.isEmpty ||
    //     lastName.isEmpty ||
    //     age.isEmpty ||
    //     gender.isEmpty ||
        yearsexperiences.isEmpty ||
        qualifications.isEmpty ||
        // Weight.isEmpty ||
        // height.isEmpty ||
        Numberoftrainees.isEmpty) {
      

      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        title: 'Error',
        desc: 'Fill all text fields!',
        btnOkOnPress: () {},
      )..show();

      

      return;
    }

     if (_image != null) {
      final url = Uri.parse('${widget.baseUrl}/signupcoach');
      final request = http.MultipartRequest('POST', url);
      request.files
          .add(await http.MultipartFile.fromPath('image', _image!.path));


      // request.fields['username'] = username;
      request.fields['email'] = email;
      // request.fields['password'] = password;
      // request.fields['firstName'] = firstName;
      // request.fields['lastName'] = lastName;
      // request.fields['age'] = age;
      // request.fields['gender'] = gender;
      request.fields['yearsexperiences'] = yearsexperiences;
      request.fields['qualifications'] = qualifications;
      // request.fields['Weight'] = Weight;
      // request.fields['height'] = height;
      request.fields['Numberoftrainees'] = Numberoftrainees;


      try {
        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

         if (response.statusCode == 200) {
        // Signup successful
        print('Signup successful!');
        try {
          // final newUser = await _auth.createUserWithEmailAndPassword(
          //   email: email,
          //   password: password,
          // );
        } catch (e) {
          print(e);
        }

        try {
          // String usernameLog = username;
          // String emailLog = email;
          // String passwordLog = password;
          // print("shouldbe= " + emailLog + passwordLog + usernameLog);

          // final user = await _auth.signInWithEmailAndPassword(
          //     email: emailLog, password: passwordLog);
          // if (user != null) {
          //   //to firebase-regusers
          //   await FirebaseFirestore.instance
          //       .collection('coachesinformation')
          //       .add({
          //     'username': usernameLog,
          //     'useremail': emailLog,
          //   });

           
          // }
        } catch (e) {
          print(e);
        }


        // // Navigate to login page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => LoginPage(baseUrl: widget.baseUrl)),
        );
      } else {
        // Some other error happened
        print('Signup failed with status code: ${response.statusCode}');
        print('Response body: ${response.body}');

       
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.rightSlide,
          title: 'Error',
          desc: response.body != null ? response.body : 'Some Error Happened',
          btnOkOnPress: () {},
        )..show();
      }
      } catch (e) {
        print('Error uploading image: $e');
      }
    } else {
      print('No image selected');
    }

    // try {
    //   var url = Uri.parse('${widget.baseUrl}/signupcoach');
    //   var response = await http.post(
    //     url,
    //     body: jsonEncode({
    //       'username': username,
    //       'email': email,
    //       'password': password,
    //       'firstName': firstName,
    //       'lastName': lastName,
    //       'age': age,
    //       'gender': gender,
    //       'yearsexperiences': yearsexperiences,
    //       'qualifications': qualifications,
    //       'Weight': Weight,
    //       'height': height,
    //       'Numberoftrainees': Numberoftrainees
    //     }),
    //     headers: {'Content-Type': 'application/json'},
    //   );
    //   if (response.statusCode == 200) {
    //     // Signup successful
    //     print('Signup successful!');
    //     try {
    //       final newUser = await _auth.createUserWithEmailAndPassword(
    //         email: email,
    //         password: password,
    //       );
    //     } catch (e) {
    //       print(e);
    //     }

    //     try {
    //       String usernameLog = username;
    //       String emailLog = email;
    //       String passwordLog = password;
    //       print("shouldbe= " + emailLog + passwordLog + usernameLog);

    //       final user = await _auth.signInWithEmailAndPassword(
    //           email: emailLog, password: passwordLog);
    //       if (user != null) {
    //         //to firebase-regusers
    //         await FirebaseFirestore.instance
    //             .collection('coachesinformation')
    //             .add({
    //           'username': usernameLog,
    //           'useremail': emailLog,
    //         });

           
    //       }
    //     } catch (e) {
    //       print(e);
    //     }


    //     // // Navigate to login page
    //     Navigator.pushReplacement(
    //       context,
    //       MaterialPageRoute(
    //           builder: (context) => LoginPage(baseUrl: widget.baseUrl)),
    //     );
    //   } else {
    //     // Some other error happened
    //     print('Signup failed with status code: ${response.statusCode}');
    //     print('Response body: ${response.body}');

       
    //     AwesomeDialog(
    //       context: context,
    //       dialogType: DialogType.error,
    //       animType: AnimType.rightSlide,
    //       title: 'Error',
    //       desc: response.body != null ? response.body : 'Some Error Happened',
    //       btnOkOnPress: () {},
    //     )..show();
    //   }
    // } catch (e) {
    //   print(e);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign Up Coach"),
      ),
      body: SingleChildScrollView(
        // padding: EdgeInsets.all(16.0),
        child: Padding(
          padding: EdgeInsets.all(16.0),
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
                              'Coach Information',
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
              // SizedBox(height: 10),
              // TextField(
              //   controller: _usernameController,
              //   decoration: InputDecoration(
              //     labelText: "Username",
              //     border: OutlineInputBorder(),
              //     prefixIcon: Icon(Icons.verified_user_rounded),
              //   ),
              // ),
              SizedBox(height: 10.0),
              TextField(
                controller: _emailController,
                 enabled: false, // return Bahaa
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              SizedBox(height: 10.0),
              // TextField(
              //   controller: _passwordController,
              //   decoration: InputDecoration(
              //     labelText: "Password",
              //     border: OutlineInputBorder(),
              //     prefixIcon: Icon(Icons.password_outlined),
              //     suffixIcon: IconButton(
              //       icon: Icon(
              //           _obscureText ? Icons.visibility : Icons.visibility_off),
              //       onPressed: () {
              //         setState(() {
              //           _obscureText = !_obscureText;
              //         });
              //       },
              //     ),
              //   ),
              // ),
              // SizedBox(height: 10.0),
              // TextField(
              //   controller: _firstNameController,
              //   decoration: InputDecoration(
              //     labelText: "First Name",
              //     border: OutlineInputBorder(),
              //     prefixIcon: Icon(Icons.person),
              //   ),
              // ),
              // SizedBox(height: 10.0),
              // TextField(
              //   controller: _lastNameController,
              //   decoration: InputDecoration(
              //     labelText: "Last Name",
              //     border: OutlineInputBorder(),
              //     prefixIcon: Icon(Icons.person),
              //   ),
              // ),
              // SizedBox(height: 10.0),
              // TextField(
              //   controller: _ageController,
              //   decoration: InputDecoration(
              //     labelText: "Age",
              //     border: OutlineInputBorder(),
              //     prefixIcon: Icon(Icons.date_range),
              //   ),
              //   keyboardType: TextInputType.number,
              // ),
              // SizedBox(height: 10.0),
              // TextField(
              //   controller: _genderController,
              //   decoration: InputDecoration(
              //     labelText: "Gender",
              //     border: OutlineInputBorder(),
              //     prefixIcon: Icon(Icons.boy_rounded),
              //   ),
              //   keyboardType: TextInputType.text,
              // ),
              SizedBox(height: 10.0),
              TextField(
                controller: _yearsexperiencesController,
                decoration: InputDecoration(
                  labelText: "Years of Experience",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.numbers),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10.0),
              TextField(
                controller: _qualificationsController,
                decoration: InputDecoration(
                  labelText: "Qualifications",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.abc),
                ),
                keyboardType: TextInputType.text,
              ),
              // SizedBox(height: 10.0),
              // TextField(
              //   controller: _WeightController,
              //   decoration: InputDecoration(
              //     labelText: "Weight",
              //     border: OutlineInputBorder(),
              //     prefixIcon: Icon(Icons.scale_outlined),
              //   ),
              //   keyboardType: TextInputType.number,
              // ),
              // SizedBox(height: 10.0),
              // TextField(
              //   controller: _heightController,
              //   decoration: InputDecoration(
              //     labelText: "Height",
              //     border: OutlineInputBorder(),
              //     prefixIcon: Icon(Icons.height),
              //   ),
              //   keyboardType: TextInputType.number,
              // ),
              SizedBox(height: 10.0),
              TextField(
                controller: _NumberoftraineesController,
                decoration: InputDecoration(
                  labelText: "Number of Trainees",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.numbers),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16.0),
              // ElevatedButton(
              //   // onPressed: _signup,
              //   onPressed: () {
              //     _signup(context);
              //   },
              //   child: Text("Signup",style: TextStyle(color: Colors.blue[800],fontSize: 25),),
              // ),
              _image == null
                // ? Text('No image selected.')
                ? TextField(
                // controller: _NumberoftraineesController,
                decoration: InputDecoration(
                  labelText: "No image selected.",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.image),
                ),
                keyboardType: TextInputType.none,
                
              )
              : Container(
                    height: 100,
                    child: Image.file(_image!, height: 100),
                  ),
                
            ElevatedButton(
              onPressed: _getImage,
              child: Text('Select Image',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  )),
            ),
              ElevatedButton(
                onPressed: () {
                  _signup(context);
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
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Coach  Registered ?  ",
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
            ],
          ),
        ),
      ),
    );
  }
}
