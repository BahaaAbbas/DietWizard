import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
// import 'package:gp/addproduct.dart';
// import 'package:gp/market.dart';
// import 'CategoryPage.dart';
// import 'FoodRecipesPage.dart';
// import 'exerciseslist.dart';
import 'loginPage.dart';
// import 'signupPage.dart';
// import 'market.dart';
// import 'product.dart';
// import 'ProductListScreen.dart';
// import 'addProduct.dart';
// import 'bmi.dart';
// import 'home.dart';
// import 'product.dart';
// import 'showposts.dart';
// import 'welcome.dart';
// import 'bfp.dart';
// import 'profile.dart';
// import 'signupcoach.dart';


import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
  );



 

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  //  static const String baseUrl = 'http://192.168.10.122:3000';//office_orienteedGuest
  // static const String baseUrl = 'http://192.168.1.126:3000'; //office_orienteed2
 
static const String baseUrl = 'http://192.168.68.55:3000';//Home
 
 
 
 
  // static const String baseUrl = 'http://127.0.0.1:61977';//Homeweb
 

  //static const String baseUrl = 'http://192.168.1.6:3000';//Home

  // static const String baseUrl = 'http://192.168.1.2:3000';//Home

 
    //  static const String baseUrl = 'http://192.168.1.9:3000';//Home
 
 
 
 
 
  //  static const String baseUrl = 'http://192.168.1.2:3000';//Home
 
 
  //  static const String baseUrl = 'http://192.168.1.5:3000';//Home
 
 
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diet Wizard',
      debugShowCheckedModeBanner: false,
      home: LoginPage(baseUrl: baseUrl),
      
      
    );
  }
}
