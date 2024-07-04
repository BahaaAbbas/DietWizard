import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:gp/BottomNav.dart';
import 'package:gp/ScreenChat/testfortest.dart';
import 'package:gp/dailyintake.dart/dailySummary.dart';
import 'package:gp/main.dart';
import 'package:line_icons/line_icons.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:flutter/services.dart';
import 'package:gp/loginPage.dart';
import 'package:gp/market.dart';
import 'package:gp/profile.dart';
import 'package:gp/showexercises.dart';
import 'dart:math';
 
// import 'dart:ffi';
import 'package:gp/welcome.dart';

 
 
import 'package:fl_chart/fl_chart.dart';
import 'package:gp/WaterIntake/BarchartThing.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Import for jsonEncode
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart'; // Add this line to import the intl package
import 'package:gp/Cart.dart';
import 'package:gp/FoodRecipesPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
// import 'package:dash_chat_2/dash_chat_2.dart';





class ChatPage extends StatefulWidget {
  final String baseUrl;
  final String name;
  final String email;

  const ChatPage({
    Key? key,
    required this.baseUrl,
    required this.name,
    required this.email,
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController prompController = TextEditingController();
  static const GEMINI_API_KEY = "AIzaSyCDZHhq9Iso5HgCo4Ro_em53CJcHKiO7UY";
  final model = GenerativeModel(model: "gemini-pro", apiKey: GEMINI_API_KEY);
  final List<ModelMessage> prompt = [];
  bool isBotTyping = false;

  // final List<String> presetMessages = [
  //   "Make a breakfast Food has 500 calories",
  //   "Give me a lunch idea",
  //   "Suggest a dinner recipe",
  //   "Provide a healthy snack option"
  // ];
  String? selectedMessage;
List<String> presetMessages = [];


  Future<void> fetchUserData() async {
    final response = await http.get(
      
        Uri.parse('${widget.baseUrl}/FetchforPreset?email=${widget.email}'),

    
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final goalWeight = double.parse(data['goalWeight']);
      final goalweeklyPer = double.parse(data['goalweeklyPer']);
      final currentWeight = double.parse(data['currentWeight']);
      final goalProtein = double.parse(data['goalProtein']);
      final afterTDEE = double.parse(data['afterTDEE']);

      setState(() {
        presetMessages = [
          'How many days until reach $goalWeight kg if $goalweeklyPer kg weight per week and my current weight is $currentWeight kg',
          'Provide Breakfast plan that has 25% of $goalProtein gm protein',
          'Provide Dinner that has 25% of $afterTDEE calories',
          'Make a breakfast Food has 500 calories',
          'Provide a healthy snack option',
        ];
      });
    } else {
      // Handle error
      print('Failed to fetch user data');
    }
  }


  Future<void> sendMessage(String message) async {
    setState(() {
      prompController.clear();
      prompt.add(ModelMessage(
        isPrompt: true,
        message: message,
        time: DateTime.now(),
      ));
      isBotTyping = true; // Show typing indicator
    });

    // For response
    final content = [Content.text(message)];
    final response = await model.generateContent(content);

    setState(() {
      prompt.add(ModelMessage(
        isPrompt: false,
        message: response.text ?? "",
        time: DateTime.now(),
      ));
      isBotTyping = false; // Hide typing indicator
    });
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
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
            SizedBox(width: 75),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Bot Chat',
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
                  CupertinoPageRoute(
                    builder: (context) => WelcomePage(
                      baseUrl: widget.baseUrl,
                      name: widget.name,
                      email: widget.email,
                    ),
                  ),
                );
              },
              icon: Icon(Icons.home),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: prompt.length + (isBotTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == prompt.length) {
                  return TypingIndicator(); // Typing indicator widget
                }
                final message = prompt[index];
                return UserPrompt(
                  isPrompt: message.isPrompt,
                  message: message.message,
                  date: DateFormat('hh:mm a').format(message.time),
                );
              },
            ),
          ),

Padding(
  padding: EdgeInsets.all(10),
  child: Container(
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey), // Border color
      borderRadius: BorderRadius.circular(10), // Border radius
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        isExpanded: true, // Ensures the dropdown button takes full width
        value: selectedMessage,
        hint: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10), // Adjust hint padding
          child: Text(selectedMessage ?? "Select a preset message"),
        ),
        items: presetMessages.map((String value) {
          return DropdownMenuItem<String>(
  value: value,
  child: Padding(
    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20), // Adjust item padding
    child: Row(
      children: [
        Expanded( // Use Expanded to allow the text to expand
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                    fontSize: 13
                  ),
          ),
        ),
      ],
    ),
  ),
);
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            selectedMessage = newValue;
          });
          if (newValue != null) {
            sendMessage(newValue);
          }
              // Reset selectedMessage to null or empty string to show the hint again
          setState(() {
            selectedMessage = null; // or selectedMessage = '';
          });
        },
        selectedItemBuilder: (context) {
          return presetMessages.map<Widget>((String item) {
            return Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey)),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16), // Adjust item padding
                child: Text(
                  item,
                  overflow: TextOverflow.ellipsis,
                 
                ),
              ),
            );
          }).toList();
        },
      ),
    ),
  ),
),

          Padding(
            padding: EdgeInsets.all(25),
            child: Row(
              children: [
                Expanded(
                  flex: 20,
                  child: TextField(
                    controller: prompController,
                    style: TextStyle(color: Colors.black, fontSize: 14),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      hintText: "Enter Your message...",
                    ),
                  ),
                ),
                Spacer(),
                GestureDetector(
                  onTap: () => sendMessage(prompController.text),
                  child: CircleAvatar(
                    radius: 29,
                    backgroundColor: Colors.greenAccent,
                    child: Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Container UserPrompt({
    required final bool isPrompt,
    required String message,
    required String date,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.symmetric(vertical: 15).copyWith(
        left: isPrompt ? 80 : 15,
        right: isPrompt ? 15 : 80,
      ),
      decoration: BoxDecoration(
        color: isPrompt ? Colors.green : Colors.grey,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomLeft: isPrompt ? Radius.circular(20) : Radius.zero,
          bottomRight: isPrompt ? Radius.zero : Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: TextStyle(
              fontWeight: isPrompt ? FontWeight.bold : FontWeight.normal,
              fontSize: 16,
              color: isPrompt ? Colors.white : Colors.black,
            ),
          ),
          Text(
            date,
            style: TextStyle(
              fontSize: 14,
              color: isPrompt ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class TypingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.symmetric(vertical: 15).copyWith(left: 15, right: 80),
      child: Row(
        children: [
          //CircularProgressIndicator(),
          SizedBox(width: 10),
          Text(
            "Bot is typing...",
            style: TextStyle(fontSize: 18, color: const Color.fromARGB(255, 27, 27, 27)),
          ),
        ],
      ),
    );
  }
}

class ModelMessage {
  final bool isPrompt;
  final String message;
  final DateTime time;

  ModelMessage({
    required this.isPrompt,
    required this.message,
    required this.time,
  });
}


// class _ChatPageState extends State<ChatPage> {
 
//   TextEditingController  prompController = TextEditingController();

//  static  const GEMINI_API_KEY = "AIzaSyCDZHhq9Iso5HgCo4Ro_em53CJcHKiO7UY";  //  Gemini API key 
//   final model  = GenerativeModel(model: "gemini-pro", apiKey: GEMINI_API_KEY);
//   final List<ModelMessage> prompt = [];
//   bool isBotTyping = false;

//   Future<void> sendMessage() async{

//       final message = prompController.text;
//       // for prompt 
//       setState(() {
//         prompController.clear();
//         prompt.add(ModelMessage(
//           isPrompt: true,
//            message: message,
//          time: DateTime.now(),

//          ),
//          );
//           isBotTyping = true; // Show typing indicator
//       });

//       // for response 
//       final content = [Content.text(message)];
//       final response = await model.generateContent(content);
//       setState(() {
//         prompt.add(ModelMessage(
//           isPrompt: false,
//            message: response.text ?? "",
//          time: DateTime.now(),

//          ),
//          );
//          isBotTyping = false; // Hide typing indicator
//       });
  
//   }



//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//            appBar: AppBar(
//         backgroundColor: Color.fromARGB(255, 80, 236, 236),
//         title: Row(
//           children: [
//             Image.asset(
//               'images/img6.png',
//               height: 87,
//               width: 75,
//             ),
//             SizedBox(width: 75),
//             Padding(
//               padding: const EdgeInsets.only(top: 8.0),
              
//               child: Text(
//                 'Bot Chat',
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//             )
//           ],
//         ),
//         actions: [
//           Padding(
//             padding: EdgeInsets.only(left: 10, top: 8.0),
//             child: IconButton(
//               onPressed: () {
//                Navigator.pushReplacement(
//                   context,
//                   CupertinoPageRoute(
//                     builder: (context) => WelcomePage(
//                       baseUrl: widget.baseUrl,
//                       name: widget.name,
//                       email: widget.email,
//                     ),
//                   ),
//                 );
//               },
//               icon: Icon(Icons.home),
//             ),
//           ),
      
//         ],
//       ),

         
//      body: Column(
//       children: [
//         Expanded(child:  ListView.builder(
//               itemCount: prompt.length + (isBotTyping ? 1 : 0),
//               itemBuilder: (context, index) {
//                 if (index == prompt.length) {
//                   return TypingIndicator(); // Typing indicator widget
//                 }
//                 final message = prompt[index];
//                 return UserPrompt(
//                   isPrompt: message.isPrompt,
//                   message: message.message,
//                   date: DateFormat('hh:mm a').format(message.time),
//                 );
//               },
//             ),
//         ),
//       Padding(
//         padding: EdgeInsets.all(25),
//         child: Row(
//           children: [
//             Expanded(
//               flex: 20,
//               child: TextField(
//                 controller: prompController,
//                 style: 
//             TextStyle(color: Colors.black,fontSize: 14),
//             decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(20),),
//             hintText: "Enter Your message..."),
            
//             ),

//             ),
//             Spacer(),
//             GestureDetector(onTap: () {

//               sendMessage();

//             },
//             child: CircleAvatar(radius: 29,backgroundColor: Colors.greenAccent,
//             child: Icon(Icons.send,color: 
//             Colors.white,
//             size: 32,),
//             ),
//             ),

//         ],),
//         ),
       
     
     
     
//      ],
//      ),
//     );
//   }


//   Container UserPrompt ( {required final bool isPrompt , required String message, required String date} ){
//       return Container(
//             width: double.infinity,
//             padding: EdgeInsets.all(15),
//             margin: EdgeInsets.symmetric(vertical: 15).copyWith(left: isPrompt ? 80 : 15 , right: isPrompt ? 15 : 80 ),
//             decoration: BoxDecoration(
//           color: isPrompt  ? Colors.green : Colors.grey ,
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(20), 
//           topRight:  Radius.circular(20),
//                bottomLeft:isPrompt? Radius.circular(20): Radius.zero, 
//           bottomRight: isPrompt? Radius.zero : Radius.circular(20),


//           ),
                

//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start ,
//               children: [
//                 //for promt and respond
//                 Text(message , style: TextStyle(fontWeight: isPrompt ? FontWeight.bold : FontWeight.normal,
//                  fontSize: 16,
//                  color: isPrompt ? Colors.white : Colors.black ,
//                  ),),
//                  //for prompt and respond time 
//                 Text( 
//                   date,
//                   style: TextStyle(
//                  fontSize: 14,
//                  color: isPrompt ? Colors.white : Colors.black ,
//                  ),),
//             ],),
//           );
//   }

// }


// class ModelMessage {

//     final bool isPrompt;
//     final String message;
//     final DateTime time;

//   ModelMessage({
//     required this.isPrompt,
//      required this.message,
//       required this.time
      
//       });

  

// }

// class TypingIndicator extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(15),
//       margin: EdgeInsets.symmetric(vertical: 15).copyWith(left: 15, right: 80),
//       child: Row(
//         children: [
//           //CircularProgressIndicator(),
//           SizedBox(width: 10),
//           Text(
//             "Bot is typing...",
//             style: TextStyle(fontSize: 18, color: Colors.grey),
//           ),
//         ],
//       ),
//     );
//   }
// }
