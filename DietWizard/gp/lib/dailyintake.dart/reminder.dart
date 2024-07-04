// import 'package:flutter/material.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/widgets.dart';
// import 'package:gp/BottomNav.dart';
// import 'package:gp/main.dart';
// import 'package:line_icons/line_icons.dart';
// import 'package:google_nav_bar/google_nav_bar.dart';
// import 'package:flutter/services.dart';
// import 'package:gp/loginPage.dart';
// import 'package:gp/market.dart';
// import 'package:gp/profile.dart';
// import 'dart:math';
// // import 'dart:ffi';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:gp/WaterIntake/BarchartThing.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert'; // Import for jsonEncode
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'package:gp/welcome.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:awesome_dialog/awesome_dialog.dart';
// import 'package:path/path.dart' as path;
// import 'package:intl/intl.dart'; // Add this line to import the intl package

//   TimeOfDay selectedTimeGlobal = TimeOfDay.now();

//    String selectedReminderTypeGlobal = "#";
//    bool CheckedGlobal = false;

// List<ReminderSet> reminders = [
//   ReminderSet(
//     reminderType: 'Breakfast',
//     reminderTime: TimeOfDay(hour: 8, minute: 0), // Example time
//     isActivated: false,
//   ),
//   //   ReminderSet(
//   //   reminderType: 'Breakfast',
//   //   reminderTime: TimeOfDay(hour: 9, minute: 0), // Example time
//   //   isActivated: false,
//   // ),
//   // ReminderSet(
//   //   reminderType: 'Lunch',
//   //   reminderTime: TimeOfDay(hour: 12, minute: 0), // Example time
//   //   isActivated: true,
//   // ),

// ];

// class reminderpage extends StatefulWidget {
//   final String baseUrl;
//   final String name;
//   final String email;

//   const reminderpage({
//     Key? key,
//     required this.baseUrl,
//     required this.name,
//     required this.email,
//   }) : super(key: key);

//   @override
//   State<reminderpage> createState() => _reminderpageState();
// }

// class _reminderpageState extends State<reminderpage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//  appBar: AppBar(
//         backgroundColor: Colors.redAccent,
//         title: Row(
//           children: [
//             SizedBox(width: 5),
//             Image.asset(
//               'images/img6.png',
//               height: 87,
//               width: 75,
//             ),
//             SizedBox(width: 35),
//             Padding(
//               padding: const EdgeInsets.only(top: 8.0),
//               child: Text(
//                 'Reminders',
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: Color.fromARGB(255, 2, 6, 248),
//                 ),
//               ),
//             )
//           ],
//         ),
//         actions: [
//           Padding(
//             padding: EdgeInsets.only(right: 8, top: 2.0),
//             child: IconButton(
//               onPressed: () {
//                   Navigator.pushReplacement(
//                           context,
//                           CupertinoPageRoute(
//                             builder: (context) => WelcomePage(
//                               baseUrl: widget.baseUrl,
//                               name: widget.name,
//                               email: widget.email,

//                             ),
//                           ),
//                         );
//               },
//               icon: Icon(
//                 Icons.circle_notifications,
//                 color: Color.fromARGB(255, 104, 159, 221),
//                 size: 35,
//               ),
//             ),
//           ),
//         ],
//       ),

//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             SizedBox(height: 10),
//         // if (CheckedGlobal)
//         // //chat gpt come here , make a list to display
//         //   ReminderInfoWidget(
//         //     reminders: reminders,
//         //   ),

//         ReminderInfoWidget(
//             reminders: reminders,
//           ),

//           ],
//         ),
//       ),
//        floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           Navigator.pushReplacement(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => AddReminderPage(
//                                   baseUrl: widget.baseUrl,
//                                   name: widget.name,
//                                   email: widget.email,

//                                 ),
//                               ),
//                             );
//         },
//         backgroundColor: Colors.blueAccent,
//         child: Icon(Icons.add),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
//     );
//   }

// }

// class ReminderSet {
//   final String reminderType;
//   final TimeOfDay reminderTime;
//   bool isActivated;

//   ReminderSet({
//     required this.reminderType,
//     required this.reminderTime,
//     this.isActivated = false,
//   });
// }

// class ReminderInfoWidget extends StatefulWidget {

//   final List<ReminderSet> reminders;

//   const ReminderInfoWidget({
//     Key? key,
//    required this.reminders,
//   }) : super(key: key);

//   @override
//   _ReminderInfoWidgetState createState() => _ReminderInfoWidgetState();
// }

// class _ReminderInfoWidgetState extends State<ReminderInfoWidget> {
//   bool isReminderActivated = false;

//   @override
//   void initState() {
//     super.initState();
//     CheckedGlobal = false;
//      print(widget.reminders.length);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: MediaQuery.of(context).size.height ,
//       decoration: BoxDecoration(
//       //  color: Colors.blue,
//       ),
//        child: widget.reminders.isEmpty
//           ? Center(
//               child: Text(
//                 'Add Reminder Below',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//             )
//           : ListView.builder(
//         itemCount: widget.reminders.length,

//         itemBuilder: (context, index) {
//           print(widget.reminders.length);
//           final reminder = widget.reminders[index];
//           return Container(
//             padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
//             margin: EdgeInsets.symmetric(vertical: 8),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(12),
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.grey.withOpacity(0.5),
//                   spreadRadius: 2,
//                   blurRadius: 5,
//                   offset: Offset(0, 3),
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Daily Reminder for ',
//                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     Text(
//                       '${reminder.reminderType}',
//                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
//                     ),
//                     Text(
//                       ' at ',
//                       style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                     ),
//                     Text(
//                       '${reminder.reminderTime.format(context)}',
//                       style: TextStyle(fontSize: 16, color: Colors.blue),
//                     ),

//                   ],
//                 ),
//                 SizedBox(height: 10),
//                 Row(
//                   children: [
//                     Text(
//                       'Reminder Status:',
//                       style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                     ),
//                     SizedBox(width: 10),
//                     Text(
//                       reminder.isActivated ? 'ON' : 'OFF',
//                       style: TextStyle(fontSize: 16, color: reminder.isActivated ? Colors.green : Colors.red),
//                     ),
//                     SizedBox(width: 10),
//                     Transform.scale(
//                       scale: 1.2,
//                       child: Switch(
//                         value: reminder.isActivated,
//                         onChanged: (value) {
//                           setState(() {
//                             reminder.isActivated = value;
//                           });
//                         },
//                         activeColor: Colors.green,
//                         inactiveThumbColor: Colors.grey,
//                       ),
//                     ),
//                     SizedBox(width: 70),
//                            Container(
//   width: 60, // Adjust width as needed
//   height: 60, // Adjust height as needed
//   child: IconButton(
//     onPressed: () {
//       setState(() {
//         widget.reminders.removeAt(index);
//       });
//     },
//     icon: Icon(Icons.delete),
//     color: Colors.red,
//   ),
// ),

//                   ],
//                 ),

//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// class AddReminderPage extends StatefulWidget {
//     final String baseUrl;
//   final String name;
//   final String email;

//   const AddReminderPage({
//     Key? key,
//     required this.baseUrl,
//     required this.name,
//     required this.email,
//   }) : super(key: key);

//   @override
//   _AddReminderPageState createState() => _AddReminderPageState();
// }

// class _AddReminderPageState extends State<AddReminderPage> {
//   String _selectedMealType = 'Breakfast'; // Default meal type
//   TimeOfDay _selectedTime = TimeOfDay.now(); // Default time

//   Future<void> _selectTime(BuildContext context) async {
//     final TimeOfDay? pickedTime = await showTimePicker(
//       context: context,
//       initialTime: _selectedTime,
//     );
//     if (pickedTime != null && pickedTime != _selectedTime) {
//       setState(() {
//         _selectedTime = pickedTime;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.teal[100],
//           title: Row(
//           children: [
//             SizedBox(width: 5),
//              IconButton(
//               onPressed: () {
//                  Navigator.pushReplacement(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => reminderpage(
//                                   baseUrl: widget.baseUrl,
//                                   name: widget.name,
//                                   email: widget.email,

//                                 ),
//                               ),
//                             );
//               },
//               icon: Icon(
//                 Icons.arrow_back,
//                 color: Color.fromARGB(255, 104, 159, 221),
//                 size: 35,
//               ),
//             ),
//             SizedBox(width: 35),
//             Text('Add Reminder'),

//              ]

//           ),

//       ),
// body: Padding(
//   padding: const EdgeInsets.all(16.0),
//   child: Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       // Select Reminder Type
//       Padding(
//         padding: const EdgeInsets.only(bottom: 20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Select Reminder Type:',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 10),
//             DropdownButton<String>(
//               value: _selectedMealType,
//               onChanged: (String? newValue) {
//                 setState(() {
//                   _selectedMealType = newValue!;
//                 });
//               },
//               items: <String>['Breakfast', 'Lunch', 'Dinner', 'Snack', 'Exercise']
//                   .map<DropdownMenuItem<String>>((String value) {
//                 return DropdownMenuItem<String>(
//                   value: value,
//                   child: Text(value),
//                 );
//               }).toList(),
//             ),
//           ],
//         ),
//       ),

//       // Select Time
//       Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Select Time:',
//             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//           ),
//           SizedBox(height: 10),
//           Row(
//             children: [
//               ElevatedButton(
//                 onPressed: () => _selectTime(context),
//                 child: Text('Select Time'),
//               ),
//               SizedBox(width: 95),
//               // Wrap the Row content in a Column for better styling
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Selected Time',
//                     style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                   ),
//                   Text(
//                     '${_selectedTime.format(context)}',
//                     style: TextStyle(fontSize: 16, color: Colors.blue),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ],
//       ),

//       SizedBox(height: 40), // Added space between "Select Time" and "Save" button

//       // Save button
//       Center(
//         child: ElevatedButton.icon(
//           onPressed: () {
//             // Add functionality for Save button here
//             selectedTimeGlobal = _selectedTime;
//             selectedReminderTypeGlobal = _selectedMealType;
//             CheckedGlobal = true;
//              Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => reminderpage(
//                   baseUrl: widget.baseUrl,
//                   name: widget.name,
//                   email: widget.email,

//                 ),
//               ),
//             );

//           },
//           style: ElevatedButton.styleFrom(
//             side: BorderSide(color: Colors.blue, width: 2),
//             padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//           ),
//           icon: Icon(Icons.save),
//           label: Text(
//             'Save',
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//       ),

//       SizedBox(height: 20), // Added space between "Save" button and note

//       Divider(), // Added a Divider

//       // Note
//       Padding(
//         padding: const EdgeInsets.symmetric(vertical: 10),
//         child: Center(
//           child: Text(
//             'All Reminders are Daily Basis',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey,
//             ),
//           ),
//         ),
//       ),
//     ],
//   ),
// ),

//     );
//   }
// }

////////////////////////////////////////////////////////////////////////////////////////////////

// import 'package:flutter/material.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:gp/welcome.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert'; // Import for jsonEncode

// TimeOfDay selectedTimeGlobal = TimeOfDay.now();
// String selectedReminderTypeGlobal = "#";
// bool CheckedGlobal = false;

// List<ReminderSet> reminders = [];

// class reminderpage extends StatefulWidget {
//   final String baseUrl;
//   final String name;
//   final String email;

//   const reminderpage({
//     Key? key,
//     required this.baseUrl,
//     required this.name,
//     required this.email,
//   }) : super(key: key);

//   @override
//   State<reminderpage> createState() => _reminderpageState();
// }

// class _reminderpageState extends State<reminderpage> {
//   @override
//   void initState() {
//     super.initState();
//     fetchReminders();
//   }

//   Future<void> fetchReminders() async {
//     final url = Uri.parse('${widget.baseUrl}/reminders'); // Adjust the endpoint as needed
//     final response = await http.get(url);

//     if (response.statusCode == 200) {
//       setState(() {
//         reminders = (json.decode(response.body) as List)
//             .map((data) => ReminderSet.fromJson(data))
//             .toList();
//       });
//     } else {
//       // Handle error
//       print('Failed to load reminders');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.redAccent,
//         title: Row(
//           children: [
//             SizedBox(width: 5),
//             Image.asset(
//               'images/img6.png',
//               height: 87,
//               width: 75,
//             ),
//             SizedBox(width: 35),
//             Padding(
//               padding: const EdgeInsets.only(top: 8.0),
//               child: Text(
//                 'Reminders',
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: Color.fromARGB(255, 2, 6, 248),
//                 ),
//               ),
//             )
//           ],
//         ),
//         actions: [
//           Padding(
//             padding: EdgeInsets.only(right: 8, top: 2.0),
//             child: IconButton(
//               onPressed: () {
//                 Navigator.pushReplacement(
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
//               icon: Icon(
//                 Icons.circle_notifications,
//                 color: Color.fromARGB(255, 104, 159, 221),
//                 size: 35,
//               ),
//             ),
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             SizedBox(height: 10),
//             ReminderInfoWidget(
//               reminders: reminders,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (context) => AddReminderPage(
//                 baseUrl: widget.baseUrl,
//                 name: widget.name,
//                 email: widget.email,
//               ),
//             ),
//           );
//         },
//         backgroundColor: Colors.blueAccent,
//         child: Icon(Icons.add),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
//     );
//   }
// }

// class ReminderSet {
//   final String reminderType;
//   final TimeOfDay reminderTime;
//   bool isActivated;

//   ReminderSet({
//     required this.reminderType,
//     required this.reminderTime,
//     this.isActivated = false,
//   });

//   factory ReminderSet.fromJson(Map<String, dynamic> json) {
//     return ReminderSet(
//       reminderType: json['reminderType'],
//       reminderTime: TimeOfDay(
//         hour: json['reminderTime']['hour'],
//         minute: json['reminderTime']['minute'],
//       ),
//       isActivated: json['isActivated'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'reminderType': reminderType,
//       'reminderTime': {
//         'hour': reminderTime.hour,
//         'minute': reminderTime.minute,
//       },
//       'isActivated': isActivated,
//     };
//   }
// }

// class ReminderInfoWidget extends StatefulWidget {
//   final List<ReminderSet> reminders;

//   const ReminderInfoWidget({
//     Key? key,
//     required this.reminders,
//   }) : super(key: key);

//   @override
//   _ReminderInfoWidgetState createState() => _ReminderInfoWidgetState();
// }

// class _ReminderInfoWidgetState extends State<ReminderInfoWidget> {
//   bool isReminderActivated = false;

//   @override
//   void initState() {
//     super.initState();
//     CheckedGlobal = false;
//     print(widget.reminders.length);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: MediaQuery.of(context).size.height,
//       decoration: BoxDecoration(
//         //  color: Colors.blue,
//       ),
//       child: widget.reminders.isEmpty
//           ? Center(
//               child: Text(
//                 'Add Reminder Below',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//             )
//           : ListView.builder(
//               itemCount: widget.reminders.length,
//               itemBuilder: (context, index) {
//                 print(widget.reminders.length);
//                 final reminder = widget.reminders[index];
//                 return Container(
//                   padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
//                   margin: EdgeInsets.symmetric(vertical: 8),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(12),
//                     color: Colors.white,
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withOpacity(0.5),
//                         spreadRadius: 2,
//                         blurRadius: 5,
//                         offset: Offset(0, 3),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             'Daily Reminder for ',
//                             style: TextStyle(
//                                 fontSize: 18, fontWeight: FontWeight.bold),
//                           ),
//                           Text(
//                             '${reminder.reminderType}',
//                             style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.green),
//                           ),
//                           Text(
//                             ' at ',
//                             style: TextStyle(
//                                 fontSize: 16, fontWeight: FontWeight.bold),
//                           ),
//                           Text(
//                             '${reminder.reminderTime.format(context)}',
//                             style: TextStyle(fontSize: 16, color: Colors.blue),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 10),
//                       Row(
//                         children: [
//                           Text(
//                             'Reminder Status:',
//                             style: TextStyle(
//                                 fontSize: 16, fontWeight: FontWeight.bold),
//                           ),
//                           SizedBox(width: 10),
//                           Text(
//                             reminder.isActivated ? 'ON' : 'OFF',
//                             style: TextStyle(
//                                 fontSize: 16,
//                                 color: reminder.isActivated
//                                     ? Colors.green
//                                     : Colors.red),
//                           ),
//                           SizedBox(width: 10),
//                           Transform.scale(
//                             scale: 1.2,
//                             child: Switch(
//                               value: reminder.isActivated,
//                               onChanged: (value) {
//                                 setState(() {
//                                   reminder.isActivated = value;
//                                 });
//                               },
//                               activeColor: Colors.green,
//                               inactiveThumbColor: Colors.grey,
//                             ),
//                           ),
//                           SizedBox(width: 70),
//                           Container(
//                             width: 60, // Adjust width as needed
//                             height: 60, // Adjust height as needed
//                             child: IconButton(
//                               onPressed: () {
//                                 setState(() {
//                                   widget.reminders.removeAt(index);
//                                 });
//                               },
//                               icon: Icon(Icons.delete),
//                               color: Colors.red,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }

// class AddReminderPage extends StatefulWidget {
//   final String baseUrl;
//   final String name;
//   final String email;

//   const AddReminderPage({
//     Key? key,
//     required this.baseUrl,
//     required this.name,
//     required this.email,
//   }) : super(key: key);

//   @override
//   _AddReminderPageState createState() => _AddReminderPageState();
// }

// // class _AddReminderPageState extends State<AddReminderPage> {
// //   String _selectedMealType = 'Breakfast'; // Default meal type
// //   TimeOfDay _selectedTime = TimeOfDay.now(); // Default time

// //   Future<void> _selectTime(BuildContext context) async {
// //     final TimeOfDay? pickedTime = await showTimePicker(
// //       context: context,
// //       initialTime: _selectedTime,
// //     );
// //     if (pickedTime != null && pickedTime != _selectedTime) {
// //       setState(() {
// //         _selectedTime = pickedTime;
// //       });
// //     }
// //   }

// //   Future<void> _saveReminder() async {
// //     final reminder = ReminderSet(
// //       reminderType: _selectedMealType,
// //       reminderTime: _selectedTime,
// //       isActivated: true,
// //     );

// //     final url = Uri.parse('${widget.baseUrl}/reminders'); // Adjust the endpoint as needed
// //     final response = await http.post(
// //       url,
// //       headers: {
// //         'Content-Type': 'application/json',
// //       },
// //       body: jsonEncode(reminder.toJson()),
// //     );

// //     if (response.statusCode == 201) {
// //       // Reminder successfully added
// //       Navigator.pushReplacement(
// //         context,
// //         MaterialPageRoute(
// //           builder: (context) => reminderpage(
// //             baseUrl: widget.baseUrl,
// //             name: widget.name,
// //             email: widget.email,
// //           ),
// //         ),
// //       );
// //     } else {
// //       // Handle error
// //       print('Failed to save reminder');
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         backgroundColor: Colors.teal[100],
// //         title: Row(
// //           children: [
// //             SizedBox(width: 5),
// //             IconButton(
// //               onPressed: () {
// //                 Navigator.pushReplacement(
// //                   context,
// //                   MaterialPageRoute(
// //                     builder: (context) => reminderpage(
// //                       baseUrl: widget.baseUrl,
// //                       name: widget.name,
// //                       email: widget.email,
// //                     ),
// //                   ),
// //                 );
// //               },
// //               icon: Icon(
// //                 Icons.arrow_back,
// //                 color: Color.fromARGB(255, 104, 159, 221),
// //                 size: 35,
// //               ),
// //             ),
// //             SizedBox(width: 35),
// //             Text('Add Reminder'),
// //           ],
// //         ),
// //       ),
// //       body: Padding(
// //         padding: const EdgeInsets.all(16.0),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             // Select Reminder Type
// //             Padding(
// //               padding: const EdgeInsets.only(bottom: 20.0),
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Text(
// //                     'Select Reminder Type:',
// //                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
// //                   ),
// //                   SizedBox(height: 10),
// //                   DropdownButton<String>(
// //                     value: _selectedMealType,
// //                     onChanged: (String? newValue) {
// //                       setState(() {
// //                         _selectedMealType = newValue!;
// //                       });
// //                     },
// //                     items: <String>['Breakfast', 'Lunch', 'Dinner', 'Snack', 'Exercise']
// //                         .map<DropdownMenuItem<String>>((String value) {
// //                       return DropdownMenuItem<String>(
// //                         value: value,
// //                         child: Text(value),
// //                       );
// //                     }).toList(),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //             // Select Time
// //             Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Text(
// //                   'Select Time:',
// //                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
// //                 ),
// //                 SizedBox(height: 10),
// //                 Row(
// //                   children: [
// //                     ElevatedButton(
// //                       onPressed: () => _selectTime(context),
// //                       child: Text('Select Time'),
// //                     ),
// //                     SizedBox(width: 95),
// //                     Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         Text(
// //                           'Selected Time',
// //                           style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
// //                         ),
// //                         Text(
// //                           '${_selectedTime.format(context)}',
// //                           style: TextStyle(fontSize: 16, color: Colors.blue),
// //                         ),
// //                       ],
// //                     ),
// //                   ],
// //                 ),
// //               ],
// //             ),
// //             SizedBox(height: 40), // Added space between "Select Time" and "Save" button
// //             // Save button
// //             Center(
// //               child: ElevatedButton.icon(
// //                 onPressed: _saveReminder,
// //                 style: ElevatedButton.styleFrom(
// //                   side: BorderSide(color: Colors.blue, width: 2),
// //                   padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
// //                 ),
// //                 icon: Icon(Icons.save),
// //                 label: Text(
// //                   'Save',
// //                   style: TextStyle(
// //                     fontSize: 14,
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //                 ),
// //               ),
// //             ),
// //             SizedBox(height: 20), // Added space between "Save" button and note
// //             Divider(), // Added a Divider
// //             // Note
// //             Padding(
// //               padding: const EdgeInsets.symmetric(vertical: 10),
// //               child: Center(
// //                 child: Text(
// //                   'All Reminders are Daily Basis',
// //                   style: TextStyle(
// //                     fontSize: 16,
// //                     fontWeight: FontWeight.bold,
// //                     color: Colors.grey,
// //                   ),
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// class _AddReminderPageState extends State<AddReminderPage> {
//   String _selectedMealType = 'Breakfast'; // Default meal type
//   TimeOfDay _selectedTime = TimeOfDay.now(); // Default time

//   Future<void> _selectTime(BuildContext context) async {
//     final TimeOfDay? pickedTime = await showTimePicker(
//       context: context,
//       initialTime: _selectedTime,
//     );
//     if (pickedTime != null && pickedTime != _selectedTime) {
//       setState(() {
//         _selectedTime = pickedTime;
//       });
//     }
//   }

//   Future<void> _saveReminder() async {
//     final url = Uri.parse('${widget.baseUrl}/reminders');
//     final response = await http.post(
//       url,
//       headers: {
//         'Content-Type': 'application/json',
//       },
//       body: jsonEncode({
//         'reminderType': _selectedMealType,
//         'reminderTime': {
//           'hour': _selectedTime.hour,
//           'minute': _selectedTime.minute,
//         },
//         'isActivated': true,
//       }),
//     );

//     if (response.statusCode == 201) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => reminderpage(
//             baseUrl: widget.baseUrl,
//             name: widget.name,
//             email: widget.email,
//           ),
//         ),
//       );
//     } else {
//       // Handle error
//       print('Failed to save reminder');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.teal[100],
//         title: Row(
//           children: [
//             SizedBox(width: 5),
//             IconButton(
//               onPressed: () {
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => reminderpage(
//                       baseUrl: widget.baseUrl,
//                       name: widget.name,
//                       email: widget.email,
//                     ),
//                   ),
//                 );
//               },
//               icon: Icon(
//                 Icons.arrow_back,
//                 color: Color.fromARGB(255, 104, 159, 221),
//                 size: 35,
//               ),
//             ),
//             SizedBox(width: 35),
//             Text('Add Reminder'),
//           ],
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Select Reminder Type
//             Padding(
//               padding: const EdgeInsets.only(bottom: 20.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Select Reminder Type:',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//                   SizedBox(height: 10),
//                   DropdownButton<String>(
//                     value: _selectedMealType,
//                     onChanged: (String? newValue) {
//                       setState(() {
//                         _selectedMealType = newValue!;
//                       });
//                     },
//                     items: <String>[
//                       'Breakfast',
//                       'Lunch',
//                       'Dinner',
//                       'Snack',
//                       'Exercise'
//                     ].map<DropdownMenuItem<String>>((String value) {
//                       return DropdownMenuItem<String>(
//                         value: value,
//                         child: Text(value),
//                       );
//                     }).toList(),
//                   ),
//                 ],
//               ),
//             ),

//             // Select Time
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Select Time:',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//                 SizedBox(height: 10),
//                 Row(
//                   children: [
//                     ElevatedButton(
//                       onPressed: () => _selectTime(context),
//                       child: Text('Select Time'),
//                     ),
//                     SizedBox(width: 95),
//                     // Wrap the Row content in a Column for better styling
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Selected Time',
//                           style: TextStyle(
//                               fontSize: 14, fontWeight: FontWeight.bold),
//                         ),
//                         Text(
//                           '${_selectedTime.format(context)}',
//                           style:
//                               TextStyle(fontSize: 16, color: Colors.blue),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ],
//             ),

//             SizedBox(
//                 height: 40), // Added space between "Select Time" and "Save" button

//             // Save button
//             Center(
//               child: ElevatedButton.icon(
//                 onPressed: _saveReminder,
//                 style: ElevatedButton.styleFrom(
//                   side: BorderSide(color: Colors.blue, width: 2),
//                   padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                 ),
//                 icon: Icon(Icons.save),
//                 label: Text(
//                   'Save',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),

//             SizedBox(height: 20), // Added space between "Save" button and note

//             Divider(), // Added a Divider

//             // Note
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 10),
//               child: Center(
//                 child: Text(
//                   'All Reminders are Daily Basis',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.grey,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

////////////////////////////////////////////////////////////////////////////////////////////////
 



import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:gp/welcome.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

TimeOfDay selectedTimeGlobal = TimeOfDay.now();
String selectedReminderTypeGlobal = "#";
bool CheckedGlobal = false;

List<ReminderSet> reminders = [];

class ReminderPage extends StatefulWidget {
  final String baseUrl;
  final String name;
  final String email;

  const ReminderPage({
    Key? key,
    required this.baseUrl,
    required this.name,
    required this.email,
  }) : super(key: key);

  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
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
    fetchReminders();


     AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        // This is just a basic example. For real apps, you must show some
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }




  Future<void> fetchReminders() async {
    final url = Uri.parse('${widget.baseUrl}/reminders/${widget.email}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        reminders = (json.decode(response.body) as List)
            .map((data) => ReminderSet.fromJson(data))
            .toList();
      });
      

       

    } else {
      print('Failed to load reminders');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: Row(
          children: [
            SizedBox(width: 5),
            Image.asset(
              'images/img6.png',
              height: 87,
              width: 75,
            ),
            SizedBox(width: 35),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Reminders',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 2, 6, 248),
                ),
              ),
            )
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 8, top: 2.0),
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
              icon: Icon(
                Icons.home,
                color: Color.fromARGB(255, 104, 159, 221),
                size: 35,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 10),
            ReminderInfoWidget(
              reminders: reminders,
              name:widget.name,
              updateReminderStatus: updateReminderStatus,
                baseUrl: widget.baseUrl, // Pass baseUrl here
                email: widget.email,

            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AddReminderPage(
                baseUrl: widget.baseUrl,
                name: widget.name,
                email: widget.email,
                onReminderAdded: _addNewReminder,
              ),
            ),
          );
        },
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _addNewReminder(ReminderSet newReminder) {
    if (mounted) {
      setState(() {
        reminders.add(newReminder);
      });
    }
  }

  // Future<void> updateReminderStatus(String reminderId, bool newStatus) async {
  //   final url = Uri.parse('${widget.baseUrl}/reminders/$reminderId');
  //   final response = await http.put(
  //     url,
  //     headers: {
  //       'Content-Type': 'application/json',
  //     },
  //     body: jsonEncode({
  //       'isActivated': newStatus,
  //     }),
  //   );

  //   if (response.statusCode == 200) {
  //     setState(() {
  //       final reminderToUpdate =
  //           reminders.firstWhere((reminder) => reminder.id == reminderId);
  //       reminderToUpdate.isActivated = newStatus;
    
  //     });
     

  //   } else {
  //     print('Failed to update reminder status');
  //   }
  // }



// Future<void> updateReminderStatus(String reminderId, bool newStatus) async {
//   final url = Uri.parse('${widget.baseUrl}/reminders/$reminderId/${widget.email}');
//   final response = await http.put(
//     url,
//     headers: {
//       'Content-Type': 'application/json',
//     },
//     body: jsonEncode({
//       'isActivated': newStatus,
//     }),
//   );

//   if (response.statusCode == 200) {
//     // Check if the widget's state is still mounted
//     if (mounted) {
//       setState(() {
//         final reminderToUpdate = reminders.firstWhere(
//           (reminder) => reminder.id == reminderId,
//         );
//         reminderToUpdate.isActivated = newStatus;

//             // check if state convert from true to false make notification

            
//       //    AwesomeNotifications().createNotification(
//       //   content: NotificationContent(
//       //     id: 10,
//       //     channelKey: 'basic_channel',
//       //     title: 'Reminder',
//       //     body: 'Reminder',
//       //   ),
//       // );
            
        
//       });
//     }
//   } else {
//     print('Failed to update reminder status');
//   }
// }



Future<void> updateReminderStatus(String reminderId, bool newStatus) async {
  final url = Uri.parse('${widget.baseUrl}/reminders/$reminderId/${widget.email}');
  final response = await http.put(
    url,
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'isActivated': newStatus,
    }),
  );

  if (response.statusCode == 200) {
     
    final responseBody = jsonDecode(response.body);

  
       if (responseBody['status'] == 'done') {
            
            AwesomeNotifications().createNotification(
              content: NotificationContent(
                id: 10,
                channelKey: 'basic_channel',
                title: 'Reminder For Food',
                body: 'Reminder For Meal',
              ),
            );
          }
      if (mounted) {
        setState(() {
          final reminderToUpdate = reminders.firstWhere(
            (reminder) => reminder.id == reminderId,
          );
          reminderToUpdate.isActivated = newStatus;

          
        
 
         
        });
      }
    // }
  } else {
    print('Failed to update reminder status');
  }
}






}

class ReminderSet {
  final String id; // Add an ID field
  final String reminderType;
  final TimeOfDay reminderTime;
   
  bool isActivated;

  ReminderSet({
    required this.id,
    required this.reminderType,
    required this.reminderTime,
    this.isActivated = false,
     
  });

  factory ReminderSet.fromJson(Map<String, dynamic> json) {
    return ReminderSet(
      id: json['_id'],
      reminderType: json['reminderType'],
      reminderTime: TimeOfDay(
        hour: json['reminderTime']['hour'],
        minute: json['reminderTime']['minute'],
      ),
      isActivated: json['isActivated'],
       
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reminderType': reminderType,
      'reminderTime': {
        'hour': reminderTime.hour,
        'minute': reminderTime.minute,
      },
      'isActivated': isActivated,
    };
  }
}

class ReminderInfoWidget extends StatefulWidget {
  final List<ReminderSet> reminders;
  final String email;
  final String name;
  final Function(String, bool) updateReminderStatus;
   final String baseUrl; // Add this line

  const ReminderInfoWidget({
    Key? key,
    required this.reminders,
     required this.name,
    required this.updateReminderStatus,
     required this.baseUrl, // Add this line
    required this.email,
  }) : super(key: key);

  @override
  _ReminderInfoWidgetState createState() => _ReminderInfoWidgetState();
}

class _ReminderInfoWidgetState extends State<ReminderInfoWidget> {


   void reloadPage() {
    setState(() {}); // Trigger state change
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(),
      child: widget.reminders.isEmpty
          ? Center(
              child: Text(
                'Add Reminder Below',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
          : ListView.builder(
              itemCount: widget.reminders.length,
              itemBuilder: (context, index) {
                final reminder = widget.reminders[index];
                return Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  margin: EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Daily Reminder for ',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${reminder.reminderType}',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green),
                          ),
                          Text(
                            ' at ',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${reminder.reminderTime.format(context)}',
                            style: TextStyle(fontSize: 16, color: Colors.blue),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            'Reminder Status:',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 10),
                          Text(
                            reminder.isActivated ? 'ON' : 'OFF',
                            style: TextStyle(
                                fontSize: 16,
                                color: reminder.isActivated
                                    ? Colors.green
                                    : Colors.red),
                          ),
                          SizedBox(width: 10),
                          Transform.scale(
                            scale: 1.2,
                            child: Switch(
                              value: reminder.isActivated,
                              onChanged: (value) {
                             
                                  widget.updateReminderStatus(
                                    reminder.id, value);
                                    
                                
                                Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>ReminderPage(
                                    baseUrl: widget.baseUrl,
                                    name: widget.name,
                                    email: widget.email,
                                  ),
                                ),
                              );
                               
                              },
                              activeColor: Colors.green,
                              inactiveThumbColor: Colors.grey,
                            ),
                          ),
                          SizedBox(width: 70),
                          Container(
                            width: 60,
                            height: 60,
                            child: IconButton(
                              onPressed: () {
                                // setState(() {
                                //   widget.reminders.removeAt(index);
                                // });
                                  _deleteReminder(index);
                              },
                              icon: Icon(Icons.delete),
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

// Future<void> _deleteReminder(int index) async {
//   bool confirmDelete = await showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: Text("Confirm Delete"),
//         content: Text("Are you sure you want to delete this reminder?"),
//         actions: <Widget>[
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop(false);
//             },
//             child: Text("CANCEL"),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop(true);
//             },
//             child: Text("DELETE"),
//           ),
//         ],
//       );
//     },
//   );

//   if (confirmDelete != null && confirmDelete) {
//     // Perform delete operation
//     final url = Uri.parse('${widget.baseUrl}/reminders/${widget.reminders[index].id}'); // Assuming there's an 'id' field in ReminderSet
//     final response = await http.delete(url);

//     if (response.statusCode == 200) {
//       setState(() {
//         widget.reminders.removeAt(index);
//       });
//     } else {
//       // Handle error
//       print('Failed to delete reminder');
//     }
//   }
// }


Future<void> _deleteReminder(int index) async {
  AwesomeDialog(
    context: context,
    dialogType: DialogType.warning,
    animType: AnimType.bottomSlide,
    title: 'Confirm Delete',
    desc: 'Are you sure you want to delete this reminder?',
    btnCancelText: 'CANCEL',
    btnCancelOnPress: () {},
    btnOkText: 'DELETE',
    btnOkOnPress: () async {
      // Perform delete operation
      final url = Uri.parse('${widget.baseUrl}/reminders/${widget.reminders[index].id}/${widget.email}'); // Assuming there's an 'id' field in ReminderSet
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        setState(() {
          widget.reminders.removeAt(index);
        });
      } else {
        // Handle error
        print('Failed to delete reminder');
      }
    },
  ).show();
}


// Future<void> _deleteReminder(int index) async {
//   bool? confirmDelete = await AwesomeDialog(
//     context: context,
//     dialogType: DialogType.warning,
//     animType: AnimType.bottomSlide,
//     title: 'Confirm Delete',
//     desc: 'Are you sure you want to delete this reminder?',
//     btnCancelOnPress: () {},
//     btnOkText: 'DELETE',
//     btnOkOnPress: () {
//       // Perform delete operation
//       // You can call a function to delete the reminder from the backend here
//       setState(() {
//         widget.reminders.removeAt(index);
//       });
//     },
//   ).show();

//   // if (confirmDelete != null && confirmDelete) {
//   //   // Perform delete operation
//   //   // You can call a function to delete the reminder from the backend here
//   //   setState(() {
//   //     widget.reminders.removeAt(index);
//   //   });
//   // }
//     if (confirmDelete != null && confirmDelete) {
//     // Perform delete operation
//     final url = Uri.parse('${widget.baseUrl}/reminders/${widget.reminders[index].id}'); // Assuming there's an 'id' field in ReminderSet
//     final response = await http.delete(url);

//     if (response.statusCode == 200) {
//       setState(() {
//         widget.reminders.removeAt(index);
//       });
//     } else {
//       // Handle error
//       print('Failed to delete reminder');
//     }
//   }
// }










}

class AddReminderPage extends StatefulWidget {
  final String baseUrl;
  final String name;
  final String email;
  final Function(ReminderSet) onReminderAdded;

  const AddReminderPage({
    Key? key,
    required this.baseUrl,
    required this.name,
    required this.email,
    required this.onReminderAdded,
  }) : super(key: key);

  @override
  _AddReminderPageState createState() => _AddReminderPageState();
}

class _AddReminderPageState extends State<AddReminderPage> {
  String _selectedMealType = 'Breakfast'; // Default meal type
  TimeOfDay _selectedTime = TimeOfDay.now(); // Default time

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  Future<void> _saveReminder() async {
    final url = Uri.parse('${widget.baseUrl}/reminders/${widget.email}');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'reminderType': _selectedMealType,
        'reminderTime': {
          'hour': _selectedTime.hour,
          'minute': _selectedTime.minute,
          
        },
        'isActivated': false,
      }),
    );

    if (response.statusCode == 201) {
      final newReminder = ReminderSet.fromJson(jsonDecode(response.body));
      widget.onReminderAdded(newReminder);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ReminderPage(
            baseUrl: widget.baseUrl,
            name: widget.name,
            email: widget.email,
          ),
        ),
      );


       
    } else {
      print('Failed to save reminder');
    }
  }



















  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal[100],
        title: Row(
          children: [
            SizedBox(width: 5),
            IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReminderPage(
                      baseUrl: widget.baseUrl,
                      name: widget.name,
                      email: widget.email,
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
            SizedBox(width: 35),
            Text('Add Reminder'),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Reminder Type:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  DropdownButton<String>(
                    value: _selectedMealType,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedMealType = newValue!;
                      });
                    },
                    items: <String>[
                      'Breakfast',
                      'Lunch',
                      'Dinner',
                      'Snack',
                      'Exercise',
                      'Water',
                      'Logging',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Time:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => _selectTime(context),
                      child: Text('Select Time'),
                    ),
                    SizedBox(width: 95),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selected Time',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${_selectedTime.format(context)}',
                          style: TextStyle(fontSize: 16, color: Colors.blue),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 40),
            Center(
              child: ElevatedButton.icon(
                onPressed: _saveReminder,
                style: ElevatedButton.styleFrom(
                  side: BorderSide(color: Colors.blue, width: 2),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                ),
                icon: Icon(Icons.save),
                label: Text(
                  'Save',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Center(
                child: Text(
                  'All Reminders are Daily Basis',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  @override
void dispose() {
  // Dispose any resources here
  super.dispose();
}
}
