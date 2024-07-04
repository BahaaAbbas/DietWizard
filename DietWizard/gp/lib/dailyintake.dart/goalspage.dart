import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:gp/BottomNav.dart';
import 'package:gp/main.dart';
import 'package:line_icons/line_icons.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:flutter/services.dart';
import 'package:gp/loginPage.dart';
import 'package:gp/market.dart';
import 'package:gp/profile.dart';
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

List<Map<String, dynamic>> userDataList = [];

class goalspage extends StatefulWidget {
  final String baseUrl;
  final String name;
  final String email;

  const goalspage({
    Key? key,
    required this.baseUrl,
    required this.name,
    required this.email,
  }) : super(key: key);

  @override
  State<goalspage> createState() => _goalspageState();
}

class _goalspageState extends State<goalspage> {

  final TextEditingController _workweekcontroller = TextEditingController();
  final TextEditingController _minWorkcontroller = TextEditingController();
final TextEditingController carbsperController = TextEditingController();
final TextEditingController proteinperController = TextEditingController();
final TextEditingController fatperController = TextEditingController();
final TextEditingController tdeeController = TextEditingController();
final TextEditingController startingWeightController = TextEditingController();
final TextEditingController currentWeightController = TextEditingController();
final TextEditingController goalWeightController = TextEditingController();

late String SelectWEEKLYTARGET;
   String SelectACTIVITYLEVEL = "Lightly Active";


 bool isLoading = true;

   Future<void> getUserGoal() async {
    try {
      var url = Uri.parse('${widget.baseUrl}/getUserGoal');
      var response = await http.post(
        url,
        body: jsonEncode({
          'email': widget.email,
        }),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        
   
         
      Map<String, dynamic> userData = jsonDecode(response.body);
      
        setState(() {
          userDataList.clear();
           isLoading = false; // Update loading state
            userDataList.add(userData);
                userDataList.forEach((userData) {
                  String userEmail = userData['email'];
                  //print('User Email: $userEmail');
                   print('User Email: $userData');
                });
         });



   

   // String firstUserEmail = userDataList[0]['email'];
    //  email:String,
    // TDEE:String,
    // target: String,
    // activity: String,
    // sex: String,
    // age: String,
    // height: String,
    // weight: String,
    // goalWeight: String,
    // date: String,
    // carbs:String,
    // protien:String,
    // fat: String,
    // workWeek:String,
    // minWork:String,
        
      } else {
        // Some other error happened
        print('getting info goal failed: ${response.statusCode}');
        print('Response body: ${response.body}');
         setState(() {
          isLoading = false; // Update loading state
        });

      }
    } catch (error) {
      // Handle error
      print('Error: $error');
       setState(() {
          isLoading = false; // Update loading state
        });
    }
  }


Future<void> changeminWork() async {
    try {
      var url = Uri.parse('${widget.baseUrl}/changeminWork');
      var response = await http.post(
        url,
        body: jsonEncode({
          'email': widget.email,
          'minWork': _minWorkcontroller.text,
        }),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {

            var responseData = json.decode(response.body);

         setState(() {

            print(responseData);
             getUserGoal();
         }); 
        


      } else {
        // Some other error happened
        print('workweek update failed: ${response.statusCode}');
        print('Response body: ${response.body}');
  

      }
    } catch (error) {
      // Handle error
      print('Error: $error');
    
    }
  }

  Future<void> changeworkWeek() async {
    try {
      var url = Uri.parse('${widget.baseUrl}/changeworkWeek');
      var response = await http.post(
        url,
        body: jsonEncode({
          'email': widget.email,
          'workWeek': _workweekcontroller.text,
        }),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {

            var responseData = json.decode(response.body);

         setState(() {

            print(responseData);
             getUserGoal();
         }); 
        


      } else {
        // Some other error happened
        print('workweek update failed: ${response.statusCode}');
        print('Response body: ${response.body}');
  

      }
    } catch (error) {
      // Handle error
      print('Error: $error');
    
    }
  }
  

  
  Future<void> changeTDEE() async {
    try {
      var url = Uri.parse('${widget.baseUrl}/changeTDEE');
      var response = await http.post(
        url,
        body: jsonEncode({
          'email': widget.email,
          'tdee': tdeeController.text,
        }),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {

            var responseData = json.decode(response.body);

         setState(() {

            print(responseData);
             getUserGoal();
         }); 
        


      } else {
        // Some other error happened
        print('changeTDEE update failed: ${response.statusCode}');
        print('Response body: ${response.body}');
  

      }
    } catch (error) {
      // Handle error
      print('Error: $error');
    
    }
  }

    Future<void> changestartweight() async {
    try {
      var url = Uri.parse('${widget.baseUrl}/changestartweight');
      var response = await http.post(
        url,
        body: jsonEncode({
          'email': widget.email,
          'startweight': startingWeightController.text,
        }),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {

            var responseData = json.decode(response.body);

         setState(() {

            print(responseData);
             getUserGoal();
         }); 
        


      } else {
        // Some other error happened
        print('changeTDEE update failed: ${response.statusCode}');
        print('Response body: ${response.body}');
  

      }
    } catch (error) {
      // Handle error
      print('Error: $error');
    
    }
  }

    Future<void> changegoalweight() async {
    try {
      var url = Uri.parse('${widget.baseUrl}/changegoalweight');
      var response = await http.post(
        url,
        body: jsonEncode({
          'email': widget.email,
          'goalweight': goalWeightController.text,
        }),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {

            var responseData = json.decode(response.body);

         setState(() {

            print(responseData);
             getUserGoal();
         }); 
        


      } else {
        // Some other error happened
        print('changeTDEE update failed: ${response.statusCode}');
        print('Response body: ${response.body}');
  

      }
    } catch (error) {
      // Handle error
      print('Error: $error');
    
    }
  }

  //------------------

    Future<void> changecurrentweight() async {
    try {
      var url = Uri.parse('${widget.baseUrl}/changecurrentweight');
      var response = await http.post(
        url,
        body: jsonEncode({
          'email': widget.email,
          'currentweight': currentWeightController.text,
        }),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {

            var responseData = json.decode(response.body);

         setState(() {

            print(responseData);
             getUserGoal();
         }); 
        


      } else {
        // Some other error happened
        print('changeTDEE update failed: ${response.statusCode}');
        print('Response body: ${response.body}');
  

      }
    } catch (error) {
      // Handle error
      print('Error: $error');
    
    }
  }

  
    Future<void> changeweeklytarget() async {
    try {
      var url = Uri.parse('${widget.baseUrl}/changeweeklytarget');
      var response = await http.post(
        url,
        body: jsonEncode({
          'email': widget.email,
          'weeklytarget': SelectWEEKLYTARGET,
        }),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {

            var responseData = json.decode(response.body);

         setState(() {

            print(responseData);
             getUserGoal();
         }); 
        


      } else {
        // Some other error happened
        print('changeTDEE update failed: ${response.statusCode}');
        print('Response body: ${response.body}');
  

      }
    } catch (error) {
      // Handle error
      print('Error: $error');
    
    }
  }

  
    Future<void> changeactivitylevel() async {
    try {
      var url = Uri.parse('${widget.baseUrl}/changeactivitylevel');
      var response = await http.post(
        url,
        body: jsonEncode({
          'email': widget.email,
          'actlevel': SelectACTIVITYLEVEL,
        }),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {

            var responseData = json.decode(response.body);

         setState(() {

            print(responseData);
             getUserGoal();
         }); 
        


      } else {
        // Some other error happened
        print('changeTDEE update failed: ${response.statusCode}');
        print('Response body: ${response.body}');
  

      }
    } catch (error) {
      // Handle error
      print('Error: $error');
    
    }
  }



  //---------------

    Future<void> changefatprotiencarbsPer() async {
      //    const { email, fatper, carbper, proteinper } = req.body;
    try {
      var url = Uri.parse('${widget.baseUrl}/changefatprotiencarbsPer');
      var response = await http.post(
        url,
        body: jsonEncode({
          'email': widget.email,
          'fatper': fatperController.text,
          'carbper': carbsperController.text,
          'proteinper': proteinperController.text,
        }),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {

            var responseData = json.decode(response.body);

         setState(() {

            print(responseData);
             getUserGoal();
         }); 
        


      } else {
        // Some other error happened
        print('changefatprotiencarbsPer update failed: ${response.statusCode}');
        print('Response body: ${response.body}');
  

      }
    } catch (error) {
      // Handle error
      print('Error: $error');
    
    }
  }

  @override
  void initState() {
    super.initState();
    userDataList.clear();
    getUserGoal();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading?  Center(child: CircularProgressIndicator()) // Show a loading spinner 
    :
    Scaffold(
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
            SizedBox(width: 75),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Goals',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 7),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color.fromARGB(255, 240, 236, 236),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Goals',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 22),
InkWell(
  onTap: () {
    startingWeightController.clear();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String selectedDate =
            DateFormat('MM/dd/yyyy').format(DateTime.now());
  
        return AlertDialog(
          title: Text('Set Starting Weight'),
          content: TextField(
            controller: startingWeightController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Enter your starting weight (kg)',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (startingWeightController.text.isNotEmpty) {
                  double startingWeight =
                      double.parse(startingWeightController.text);
                  if (startingWeight > 40) {
                    print('Starting Weight: $startingWeight kg');
                    print('Selected Date: $selectedDate');

                        await changestartweight();

                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Under 40 is a dangerous weight zone'),
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter a value.'),
                    ),
                  );
                }
              },
              child: Text('Set'),
            ),
          ],
        );
      },
    );
  },
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        'Starting Weight',
        style: TextStyle(
          fontSize: 16,
        ),
      ),
      Text(
        '${userDataList[0]['startweight']} kg on ${userDataList[0]['date']}',
        style: TextStyle(
          fontSize: 16,
          color: const Color.fromARGB(255, 0, 130, 236),
        ),
      ),
    ],
  ),
),


                  SizedBox(height: 12),
                  Divider(),
                  SizedBox(height: 12),

   InkWell(
  onTap: () {
    currentWeightController.clear();
    showDialog(
      context: context,
      builder: (BuildContext context) {

        return AlertDialog(
          title: Text('Set Current Weight'),
          content: TextField(
            controller: currentWeightController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Enter your Current weight (kg)',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (currentWeightController.text.isNotEmpty) {
                  double currentweights =
                      double.parse(currentWeightController.text);
                  if (currentweights > 40) {
                    print('current Weight: $currentweights kg');
                

                        await changecurrentweight();

                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Under 40 is a dangerous weight zone'),
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter a value.'),
                    ),
                  );
                }
              },
              child: Text('Set'),
            ),
          ],
        );
      },
    );
  },
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        'Current Weight',
        style: TextStyle(
          fontSize: 16,
        ),
      ),
      Text(
        '${userDataList[0]['currentweight']} kg',
        style: TextStyle(
          fontSize: 16,
          color: const Color.fromARGB(255, 0, 130, 236),
        ),
      ),
    ],
  ),
),

                  SizedBox(height: 12),
                  Divider(),
                  SizedBox(height: 12),
            InkWell(
  onTap: () {
    goalWeightController.clear();
    showDialog(
      context: context,
      builder: (BuildContext context) {

        return AlertDialog(
          title: Text('Set Goal Weight'),
          content: TextField(
            controller: goalWeightController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Enter your Goal weight (kg)',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (goalWeightController.text.isNotEmpty) {
                  double goalweights =
                      double.parse(goalWeightController.text);
                  if (goalweights > 40) {
                    print('goal Weight: $goalweights kg');
                

                        await changegoalweight();

                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Under 40 is a dangerous weight zone'),
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter a value.'),
                    ),
                  );
                }
              },
              child: Text('Set'),
            ),
          ],
        );
      },
    );
  },
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        'Goal Weight',
        style: TextStyle(
          fontSize: 16,
        ),
      ),
      Text(
        '${userDataList[0]['goalWeight']} kg',
        style: TextStyle(
          fontSize: 16,
          color: const Color.fromARGB(255, 0, 130, 236),
        ),
      ),
    ],
  ),
), 
                   SizedBox(height: 12),
                  Divider(),
                  SizedBox(height: 12),

InkWell(
  onTap: () {
    // Check the target first
    String target = userDataList[0]['target'];
    print(target);
    if (target == 'Maintain Weight') {
      // If the target is 'Maintain Weight', do nothing
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        String? selectedWeeklyTarget = userDataList[0]['weeklyPer'];

        return AlertDialog(
          title: Text('Change Weekly Target'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: _getRadioOptions(target, selectedWeeklyTarget, (String? newValue) {
                  setState(() {
                    selectedWeeklyTarget = newValue;
                  });
                }),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async{
                // Handle setting goal weight
                if (selectedWeeklyTarget != null) {

                  // setState(() {
                  //   userDataList[0]['weeklyPer'] = selectedWeeklyTarget;
                  // });
                  SelectWEEKLYTARGET = selectedWeeklyTarget!;
                  print(SelectWEEKLYTARGET + "  <--Weekly target print");
                  await changeweeklytarget();

                }
                Navigator.of(context).pop();
              },
              child: Text('Set'),
            ),
          ],
        );
      },
    );
  },
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        'Weekly Target',
        style: TextStyle(
          fontSize: 16,
        ),
      ),
      Text(
        '${userDataList[0]['weeklyPer']} kg',
        style: TextStyle(
          fontSize: 16,
          color: const Color.fromARGB(255, 0, 130, 236),
        ),
      ),
    ],
  ),
),

                  SizedBox(height: 12),
                  Divider(),
                  SizedBox(height: 12),
                  InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          String selectedActivityLevel =
                              'Lightly Active'; // Default selection
                                 SelectACTIVITYLEVEL = "Lightly Active";
                          return StatefulBuilder(
                            builder: (BuildContext context, setState) {
                              return AlertDialog(
                                title: Text('Select Activity Level'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    for (var option in [
                                      "Not Very Active (e.g., bank teller, desk job)",
                                      "Lightly Active (e.g., teacher, salesperson)",
                                      "Active (e.g., food server, postal carrier)",
                                      "Very Active (e.g., bike messenger, carpenter)"
                                    ])
                                      RadioListTile(
                                        title: Text(option),
                                        value: option,
                                        groupValue: selectedActivityLevel,
                                        onChanged: (value) {
                                          if(value.toString()== "Not Very Active (e.g., bank teller, desk job)"){
                                            SelectACTIVITYLEVEL = "Not Very Active";

        //                                             case "Not Very Active":
        //   print("Not Very Active switch--->" + activityLevel);
        //   activityFactor = 1.2;
        //   break;
        // case "Lightly Active":
        //   print("Lightly Active switch--->" + activityLevel);
        //   activityFactor = 1.375;
        //   break;
        // case "Active":
        //   print(" Active switch--->" + activityLevel);
        //   activityFactor = 1.55;
        //   break;
        // case "Very Active":
        //   print("Very Active switch--->" + activityLevel);
        //   activityFactor = 1.9;
        //   break;

                                          }
                                          else if(value.toString()== "Lightly Active (e.g., teacher, salesperson)"){
                                              SelectACTIVITYLEVEL = "Lightly Active";
                                          }
                                           else if(value.toString()== "Active (e.g., food server, postal carrier)"){
                                              SelectACTIVITYLEVEL = "Active";
                                          }
                                           else if(value.toString()== "Very Active (e.g., bike messenger, carpenter)"){
                                              SelectACTIVITYLEVEL = "Very Active";
                                          }
                                          setState(() {
                                            selectedActivityLevel =
                                                value.toString();
                                          });
                                        },
                                      ),
                                  ],
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      // Handle setting the selected activity level
                                      print(
                                          'Selected Activity Level: $selectedActivityLevel');
                                print('SelectACTIVITYLEVEL: $SelectACTIVITYLEVEL');
                
                                    //SelectACTIVITYLEVEL = selectedActivityLevel;
                                    await changeactivitylevel();
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Set'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Activity Level',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${userDataList[0]['activity']}', // Replace with the default selected activity level
                          style: TextStyle(
                            fontSize: 16,
                            color: const Color.fromARGB(255, 0, 130, 236),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 5,
            ),
            SizedBox(
              height: 5,
            ),
            SizedBox(
              height: 5,
            ),

            /// sperate second one
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color.fromARGB(255, 240, 236, 236),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nutrition',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 22),
        InkWell(
  onTap: () {
   
tdeeController.clear();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Set TDEE Goal '),
          content: TextField(
            controller: tdeeController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'TDEE',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async{
                String tdeeInput = tdeeController.text;
                int? tdeeValue = int.tryParse(tdeeInput);

                if (tdeeValue == null || tdeeValue < 1000) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Value must be a number and at least 1000 kcal due to health issues',
                        
                      ),
                    ),
                  );
                } else {
                  // Handle setting the TDEE goal here, for example:
                  // setState(() {
                  //   userDataList[0]['TDEE'] = tdeeValue.toString();
                  // });
                  await changeTDEE();
                  Navigator.of(context).pop();
                }
              },
              child: Text('Set'),
            ),
          ],
        );
      },
    );
  },
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        'Calories-TDEE',
        style: TextStyle(
          fontSize: 16,
        ),
      ),
      Text(
        '${userDataList[0]['TDEE']} Kcal',
        style: TextStyle(
          fontSize: 16,
          color: const Color.fromARGB(255, 0, 130, 236),
        ),
      ),
    ],
  ),
),

                  SizedBox(height: 12),
                  Divider(),
                  SizedBox(height: 12),
InkWell(
  onTap: () {
    carbsperController.clear();
    proteinperController.clear();
    fatperController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Set Goals - Result must be 100%'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: carbsperController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Carbs Goal (default 50%)',
                ),
              ),
              TextField(
                controller: proteinperController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Protein Goal (default 25%)',
                ),
              ),
              TextField(
                controller: fatperController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Fat Goal (default 25%)',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Handle setting goals
                String carbsGoal = carbsperController.text;
                String proteinGoal = proteinperController.text;
                String fatGoal = fatperController.text;

                // Validate that all fields are numbers and sum up to 100
                try {
                  double carbs = double.parse(carbsGoal);
                  double protein = double.parse(proteinGoal);
                  double fat = double.parse(fatGoal);

                  if ((carbs + protein + fat) == 100) {
                  await  changefatprotiencarbsPer();
                    // Values are valid, update the userDataList or any other state management logic
                    // setState(() {
                    //   userDataList[0]['carbsPer'] = carbsGoal;
                    //   userDataList[0]['proteinPer'] = proteinGoal;
                    //   userDataList[0]['fatPer'] = fatGoal;
                    // });

                    Navigator.of(context).pop();
                  } else {
                    // Show error message 
                           ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('The total percentage must be equal to 100.'),
                          ),
                        );
                  }
                } catch (e) {
                  // Show error message if the input is not a valid number
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Error'),
                        content: Text('Please enter valid numbers.'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text('Set'),
            ),
          ],
        );
      },
    );
  },
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        'Carbs',
        style: TextStyle(
          fontSize: 16,
        ),
      ),
      Text(
        '${userDataList[0]['carbs']} %',
        style: TextStyle(
          fontSize: 16,
          color: const Color.fromARGB(255, 0, 130, 236),
        ),
      ),
    ],
  ),
),


                  SizedBox(height: 12),
                  Divider(),
                  SizedBox(height: 12),
                InkWell(
  onTap: () {
    carbsperController.clear();
    proteinperController.clear();
    fatperController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Set Goals - Result must be 100%'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: carbsperController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Carbs Goal (default 50%)',
                ),
              ),
              TextField(
                controller: proteinperController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Protein Goal (default 25%)',
                ),
              ),
              TextField(
                controller: fatperController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Fat Goal (default 25%)',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
              TextButton(
              onPressed: () async {
                // Handle setting goals
                String carbsGoal = carbsperController.text;
                String proteinGoal = proteinperController.text;
                String fatGoal = fatperController.text;

                // Validate that all fields are numbers and sum up to 100
                try {
                  double carbs = double.parse(carbsGoal);
                  double protein = double.parse(proteinGoal);
                  double fat = double.parse(fatGoal);

                  if ((carbs + protein + fat) == 100) {
                  await  changefatprotiencarbsPer();
                    // Values are valid, update the userDataList or any other state management logic
                    // setState(() {
                    //   userDataList[0]['carbsPer'] = carbsGoal;
                    //   userDataList[0]['proteinPer'] = proteinGoal;
                    //   userDataList[0]['fatPer'] = fatGoal;
                    // });

                    Navigator.of(context).pop();
                  } else {
                    // Show error message 
                           ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('The total percentage must be equal to 100.'),
                          ),
                        );
                  }
                } catch (e) {
                  // Show error message if the input is not a valid number
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Error'),
                        content: Text('Please enter valid numbers.'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text('Set'),
            ),
          ],
        );
      },
    );
  },
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        'Protein',
        style: TextStyle(
          fontSize: 16,
        ),
      ),
      Text(
        '${userDataList[0]['protien']} %',
        style: TextStyle(
          fontSize: 16,
          color: const Color.fromARGB(255, 0, 130, 236),
        ),
      ),
    ],
  ),
),

                  SizedBox(height: 12),
                  Divider(),
                  SizedBox(height: 12),
             InkWell(
  onTap: () {
    carbsperController.clear();
    proteinperController.clear();
    fatperController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Set Goals - Result must be 100%'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: carbsperController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Carbs Goal (default 50%)',
                ),
              ),
              TextField(
                controller: proteinperController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Protein Goal (default 25%)',
                ),
              ),
              TextField(
                controller: fatperController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Fat Goal (default 25%)',
                ),
              ),
            ],
          ),
          actions: <Widget>[
                TextButton(
              onPressed: () async {
                // Handle setting goals
                String carbsGoal = carbsperController.text;
                String proteinGoal = proteinperController.text;
                String fatGoal = fatperController.text;

                // Validate that all fields are numbers and sum up to 100
                try {
                  double carbs = double.parse(carbsGoal);
                  double protein = double.parse(proteinGoal);
                  double fat = double.parse(fatGoal);

                  if ((carbs + protein + fat) == 100) {
                  await  changefatprotiencarbsPer();
                    // Values are valid, update the userDataList or any other state management logic
                    // setState(() {
                    //   userDataList[0]['carbsPer'] = carbsGoal;
                    //   userDataList[0]['proteinPer'] = proteinGoal;
                    //   userDataList[0]['fatPer'] = fatGoal;
                    // });

                    Navigator.of(context).pop();
                  } else {
                    // Show error message 
                           ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('The total percentage must be equal to 100.'),
                          ),
                        );
                  }
                } catch (e) {
                  // Show error message if the input is not a valid number
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Error'),
                        content: Text('Please enter valid numbers.'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text('Set'),
            ),
          ],
        );
      },
    );
  },
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        'Fat',
        style: TextStyle(
          fontSize: 16,
        ),
      ),
      Text(
        '${userDataList[0]['fat']} %',
        style: TextStyle(
          fontSize: 16,
          color: const Color.fromARGB(255, 0, 130, 236),
        ),
      ),
    ],
  ),
),

                ],
              ),
            ),

            SizedBox(
              height: 5,
            ),
            SizedBox(
              height: 5,
            ),
            SizedBox(
              height: 5,
            ),

            /// sperate second one
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color.fromARGB(255, 240, 236, 236),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fitness',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 22),
                    InkWell(
                onTap: () {
                  // Handle onTap for Goal Weight
                 _workweekcontroller.clear();
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Set Workouts Goal '),
                        content: TextField(
                          controller: _workweekcontroller,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          ],
                          decoration: InputDecoration(
                              labelText: 'Enter a number between 0 and 12',
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              int parsedValue = int.parse(value);
                              if (parsedValue < 0 || parsedValue > 12) {
                                _workweekcontroller.text = '';
                              }
                            }
                          },
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              // Handle setting goal weight
                              if (_workweekcontroller.text.isNotEmpty) {
                                int parsedValue = int.parse(_workweekcontroller.text);
                                if (parsedValue >= 0 && parsedValue <= 10) {

                                  await changeworkWeek();
                                  Navigator.of(context).pop();

                                }
                              }
                            },
                            child: Text('Set'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Workouts / Week',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${userDataList[0]['workWeek']}',
                      style: TextStyle(
                        fontSize: 16,
                        color: const Color.fromARGB(255, 0, 130, 236),
                      ),
                    ),
                  ],
                ),
              ),
                  SizedBox(height: 12),
                  Divider(),
                  SizedBox(height: 12),

 InkWell(
      onTap: () {
        // Handle onTap for Current Weight
        _minWorkcontroller.clear();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Set Workouts Time Goal '),
              content: TextField(
                controller: _minWorkcontroller,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
                decoration: InputDecoration(
                  labelText: 'Enter a number between 10 and 200',
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: ()async {
                    // Handle setting current weight
                    if (_minWorkcontroller.text.isNotEmpty) {
                      int parsedValue = int.parse(_minWorkcontroller.text);
                      if (parsedValue >= 10 && parsedValue <= 200) {

                              await changeminWork();
                              Navigator.of(context).pop();


                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please enter a value between 10 and 200. \n default is 60'),
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please enter a value.'),
                        ),
                      );
                    }
                  },
                  child: Text('Set'),
                ),
              ],
            );
          },
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Minutes / Workout',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          Text(
            '${userDataList[0]['minWork']}',
            style: TextStyle(
              fontSize: 16,
              color: const Color.fromARGB(255, 0, 130, 236),
            ),
          ),
        ],
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

List<Widget> _getRadioOptions(String target, String? selectedWeeklyTarget, ValueChanged<String?> onChanged) {
  List<String> options = [];
  if (target == 'Lose Weight') {
    options = ['-0.5', '-1'];
  } else if (target == 'Gain Weight') {
    options = ['+0.5', '+1'];
  }

  return options.map((String value) {
    return RadioListTile<String>(
      title: Text(value.contains('-') ? '${value.substring(1)} kg lose per week' : '${value.substring(1)} kg gain per week'),
      value: value,
      groupValue: selectedWeeklyTarget,
      onChanged: onChanged,
    );
  }).toList();
}
} // end of _goalspageState class
