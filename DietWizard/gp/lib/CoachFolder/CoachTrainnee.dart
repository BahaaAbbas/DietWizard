import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:gp/BottomNav.dart';
import 'package:gp/CoachFolder/TraineeProgress.dart';
import 'package:gp/CoachFolder/WeeklyTemplate.dart';
import 'package:gp/CoachFolder/ChartLineCode.dart';
import 'package:gp/ScreenChat/chatScreen.dart';
import 'package:gp/ScreenChat/testfortest.dart';
import 'package:gp/dailyintake.dart/dailySummary.dart';
import 'package:gp/main.dart';
import 'package:gp/welcome.dart';
import 'package:line_icons/line_icons.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:flutter/services.dart';
import 'package:gp/loginPage.dart';
import 'package:gp/market.dart';
import 'package:gp/profile.dart';
import 'package:gp/showexercises.dart';
import 'dart:math';
// import 'dart:ffi';
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

import 'package:gp/globals.dart' as globals;


  final List<UsersForsearch> _usersForsearchs = [];
  final List<Trainee> _trainees = [];

  String TrainerFULLNAME = '';
  int TrainerMaxOfTr=0;

class coachTrainee extends StatefulWidget {
  final String baseUrl;
  final String name;
  final String email;

  const coachTrainee({
    Key? key,
    required this.baseUrl,
    required this.name,
    required this.email,
  }) : super(key: key);

  @override
  State<coachTrainee> createState() => _coachTraineeState();
}

class _coachTraineeState extends State<coachTrainee> {

  DateTime startDate1 = DateTime(2024, 5, 1); // Sample start date
  DateTime endDate1 = DateTime(2024, 5, 15); // Sample end date


 
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');


   //      const { coachemail, startdate,enddate,currentNumTrainee,traineeEmail,traineeName,} = req.body;





    //showusertrainee()
   Future<void> showusertrainee() async {
    try {
      var url = Uri.parse('${widget.baseUrl}/showusertrainee');
      
      var response = await http.post(
        url,
        body: jsonEncode({
          'coachemail': widget.email,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);

  setState(() {
        // Clear the existing list of trainees
        _trainees.clear();
        // Fill the list with data from the response
        responseData['coach'].forEach((traineeData) {

          _trainees.add(
            Trainee(
              traineeName: traineeData['traineeName'],
              traineeEmail: traineeData['traineeEmail'],
              startdate: DateTime.parse(traineeData['startdate']),
              enddate: DateTime.parse(traineeData['enddate']),
            ),
          );
        });
      });
      } else {
        // Handle error
        if(response.statusCode == 404 ){
              setState(() {
              _trainees.clear();
            });
        }
       

        print('Saved trainee failed: ${response.statusCode}');   
        print(
            'Response body: ${response.body}'); // back here for  Response body: "User does not have any logged photos yet."
      }
    } catch (error) {
      // Handle error
      print('Error: $error');
    }
  }









    //saveusertrainee()
   Future<void> saveusertrainee() async {
    try {
      var url = Uri.parse('${widget.baseUrl}/saveusertrainee');
          var traineeData = _trainees.map((trainee) => trainee.toJson()).toList(); // Convert Trainee objects to JSON format

      var response = await http.post(
        url,
        body: jsonEncode({
          'coachemail': widget.email,
        'trainees': traineeData, // Pass the list of trainee data
            // 'traineeEmail': _trainees.map((trainee) => trainee.traineeEmail).toList(),

            // 'traineeName': _trainees.map((trainee) => trainee.traineeName).toList(),

            // 'startdate': _trainees.map((trainee) => DateFormat('yyyy-MM-dd').format(trainee.startdate).toString()).toList(),

            // 'enddate': _trainees.map((trainee) => DateFormat('yyyy-MM-dd').format(trainee.enddate).toString()).toList(),

            'currentNumTrainee':_trainees.length.toString(),

        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);


        // setState(() {
  
 
        // });
      } else {
        // Handle error
        print('Saved trainee failed: ${response.statusCode}');
        print(
            'Response body: ${response.body}'); // back here for  Response body: "User does not have any logged photos yet."
      }
    } catch (error) {
      // Handle error
      print('Error: $error');
    }
  }



 //returncoachnameandnumtrainees()
 Future<void> returncoachnameandnumtrainees() async {
    try {
      var url = Uri.parse('${widget.baseUrl}/returncoachnameandnumtrainees');
      var response = await http.post(
        url,
        body: jsonEncode({
          'coachemail': widget.email,
        }),
        headers: {'Content-Type': 'application/json'},
      );

 if (response.statusCode == 200) {
      var responseData = json.decode(response.body);

      setState(() {
      TrainerFULLNAME = responseData['fullname'];
      TrainerMaxOfTr= responseData['Numberoftrainees'];
      });

    }else {
        // Handle error
        traineesInfoList.clear();
        print('Show Info Trainer name and maxnumber failed: ${response.statusCode}');
        print(
            'Response body: ${response.body}'); // back here for  Response body: "User does not have any logged photos yet."
      }
    } catch (error) {
      // Handle error
      print('Error: $error');
    }
  }






 //TraineesInfo()
 Future<void> TraineesInfo(String TrEmail) async {

DateTime selectedDate = DateTime.now(); // Set the default selected date to current date
  
    try {
      var url = Uri.parse('${widget.baseUrl}/TraineesInfo');
      var response = await http.post(
        url,
        body: jsonEncode({
          'email': TrEmail,
          'dateToday':  DateFormat('yyyy-MM-dd').format(selectedDate).toString(),  // Date of the diary entry 
        }),
        headers: {'Content-Type': 'application/json'},
      );

        if (response.statusCode == 200) {
          print("Hello1");
          var responseData = json.decode(response.body);

         
          traineesInfoList.clear();


          TraineesInfoClass traineesInfo = TraineesInfoClass.fromJson(responseData);

          
          traineesInfoList.add(traineesInfo);

// Iterate over each TraineesInfo object in the traineesInfoList
// for (var traineeInfo in traineesInfoList) {
//   // Print each property of the TraineesInfo object
//   print('TDEE: ${traineeInfo.TDEE}');
//   print('Target: ${traineeInfo.target}');
//   print('Activity: ${traineeInfo.activity}');
//   print('Sex: ${traineeInfo.sex}');
//   print('Age: ${traineeInfo.age}');
//   print('Height: ${traineeInfo.height}');
//   print('Weight: ${traineeInfo.weight}');
//   print('Goal Weight: ${traineeInfo.goalWeight}');
//   print('Date: ${traineeInfo.date}');
//   print('Carbs: ${traineeInfo.carbs}');
//   print('Min Work: ${traineeInfo.minWork}');
//   print('Work Week: ${traineeInfo.workWeek}');
//   print('Carbs Per: ${traineeInfo.carbsPer}');
//   print('Protein Per: ${traineeInfo.protienPer}');
//   print('Fat Per: ${traineeInfo.fatPer}');
//   print('Protein: ${traineeInfo.protein}');
//   print('Saturated Fat: ${traineeInfo.satFat}');
//   print('Total Fat: ${traineeInfo.totFat}');
//   print('Sodium: ${traineeInfo.sodium}');
//   print('Potassium: ${traineeInfo.potassium}');
//   print('Cholesterol: ${traineeInfo.cholesterol}');
//   print('Fiber: ${traineeInfo.fiber}');
//   print('Sugar: ${traineeInfo.sugar}');
//   print('\n'); // Add a new line for separation
// }

         


        }else {
        // Handle error
        traineesInfoList.clear();
        print('Show Info Trainee    failed: ${response.statusCode}');
        print(
            'Response body: ${response.body}'); // back here for  Response body: "User does not have any logged photos yet."
      }
    } catch (error) {
      // Handle error
      print('Error: $error');
    }
  }



//returnuserforsearch()
  Future<void> returnuserforsearch() async {

    final url = Uri.parse('${widget.baseUrl}/returnuserforsearch');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
    
      final List<dynamic> usersList = json.decode(response.body);

        // Convert each JSON object in the list to a UsersForsearch instance
        final List<UsersForsearch> loadedUsers = usersList.map((json) {
          return UsersForsearch.fromJson(json);
        }).toList();

      // Print each user
        for (var user in loadedUsers) {
          print('User: ${user.name}, Email: ${user.email}');
        }



        // Update the state
        setState(() {
          _usersForsearchs.clear();
          _usersForsearchs.addAll(loadedUsers);
        });




      }  else {
        // Handle error
        print('Show all user failed: ${response.statusCode}');
        print(
            'Response body: ${response.body}'); // back here for  Response body: "User does not have any logged photos yet."
      }
    } catch (error) {
          print('Error: $error');
    }
  }


 void reloadPage() {
    setState(() {}); // Trigger state change
  }








  @override
  void initState() {
    super.initState();

  
  //TraineesInfo();
  returnuserforsearch();
  showusertrainee();
  returncoachnameandnumtrainees();
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
                'Coach Trainee',
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
            SizedBox(height: 15),
            Container(
              // height: 60,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10), // Rounded corners
                color: Color.fromARGB(
                    255, 240, 236, 236), // Color the container in grey
               
              ),
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Coach ',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 22),
                  Center(
                    child: Text(
                      //'Bahaa Abbas', // Replace with the actual coach's name
                      TrainerFULLNAME,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 20), // Adjust spacing as needed
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Current # of Trainees:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                       // '4', // Replace with the actual number of trainees
                         _trainees.length.toString(), // Dynamic number of trainees
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                    ],
                  ),
                             SizedBox(height: 20), // Adjust spacing as needed
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Max # of Trainees:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        //'4', // Replace with the actual number of trainees
                        '${TrainerMaxOfTr}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                    ],
                  ),
                   SizedBox(height: 22),
                ],
              ),
            ),
            SizedBox(height: 15),
            Container(
              // height: 60,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10), // Rounded corners
                color: Color.fromARGB(
                    255, 240, 236, 236), // Color the container in grey
              ),
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Trainees Info',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                   ElevatedButton.icon(
                                   onPressed: ()  {
                                     print("Chat Coach");
                    
                      if(_trainees.length < TrainerMaxOfTr )   _showAddTraineeDialog();
                      else _showCapacityFullDialog();
                   
                   
                                    
                                   },
                                   style: ElevatedButton.styleFrom(
                                     side: BorderSide(color: Colors.green, width: 2),
                                     padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                   ),
                                   icon: Icon(Icons.add),
                                   label: Text(
                                     'Add Trainee',
                                     style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                                     ),
                                   ),
                                 ),
                                         

                    ],
                  ),
                  SizedBox(height: 10),
           

      
              // ..._trainees.map((trainee) => TraineesInfoCont(trainee)).toList(),
               _trainees.isEmpty
              ? Center(
                  child: Text(
                    'No trainees added yet.',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _trainees
                      .map((trainee) => TraineesInfoCont(trainee))
                      .toList(),
                ),
     
            SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


 Widget TraineesInfoCont(Trainee trainee) {
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
     // color: Color.fromARGB(255, 240, 236, 236),
        color: Color.fromARGB(246, 143, 158, 245),
    ),
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    margin: EdgeInsets.symmetric(vertical: 15),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
               trainee.traineeName,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
                      Column(
                        children: [
                          ElevatedButton.icon(
                                           onPressed: ()  {
                                             print("delete trainee ");
                                            
                                                  _showDeleteConfirmationDialog(trainee);
                                                
                           
                                            
                                           },
                                           style: ElevatedButton.styleFrom(
                                             side: BorderSide(color: Colors.red, width: 2),
                                             padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                           ),
                                           icon: Icon(Icons.delete),
                                           label: Text(
                                             'Delete Trainee',
                                             style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                                             ),
                                           ),
                                         ),
                                           ElevatedButton.icon(
                                   onPressed: ()  {
                                     print("edit trainee ");
                                       _showEditDialog(trainee);
                 
                   
                                    
                                   },
                                   style: ElevatedButton.styleFrom(
                                     side: BorderSide(color: Colors.blue, width: 2),
                                     padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                   ),
                                   icon: Icon(Icons.edit),
                                   label: Text(
                                     'Edit Trainee',
                                     style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                                     ),
                                   ),
                                 ),
              
                        ],
                      ),

                                     

          ],
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Start Date:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              DateFormat('yyyy-MM-dd').format(trainee.startdate),
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
        SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'End Date:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              DateFormat('yyyy-MM-dd').format(trainee.enddate),
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                await TraineesInfo(trainee.traineeEmail);
                print("Now");
                _showInfoDialogTrainee(context, traineesInfoList);
              },
              style: ElevatedButton.styleFrom(
                side: BorderSide(color: Colors.blue, width: 2),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              ),
              icon: Icon(Icons.info),
              label: Text(
                'Trainee Info',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                print('EditFood pressed');
                print(trainee.traineeEmail);
                  Navigator.pushReplacement(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => TraineeProgress(
                              baseUrl: widget.baseUrl,
                              name: widget.name,
                              email: trainee.traineeEmail,
                             
                            ),
                          ),
                        );
              },
              style: ElevatedButton.styleFrom(
                side: BorderSide(color: Colors.blue, width: 2),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              ),
              icon: Icon(Icons.priority_high_rounded),
              label: Text(
                'Trainee Progress',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
     
       
          ],
        ),
          SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                print('DeleteFood pressed');
                    Navigator.pushReplacement(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => WeeklyTemplate(
                              baseUrl: widget.baseUrl,
                              name: widget.name,
                              CoachEmail: widget.email,
                              TraineeEmail: trainee.traineeEmail,
                             
                            ),
                          ),
                        );
              },
              style: ElevatedButton.styleFrom(
                side: BorderSide(color: Colors.blue, width: 2),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              ),
              icon: Icon(Icons.folder),
              label: Text(
                'Weekly Template',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                print('ViewDetails pressed');
                
                     Navigator.pushReplacement(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => ChartLineDisplay(         
                               baseUrl: widget.baseUrl,
                              name: widget.name,
                              email: trainee.traineeEmail,
                             // email: widget.email,
                            ),
                          ),
                        );
              },
              style: ElevatedButton.styleFrom(
                side: BorderSide(color: Colors.blue, width: 2),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              ),
              icon: Icon(Icons.details),
              label: Text(
                'Trainee Report',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
               Center(
                 child: ElevatedButton.icon(
                               onPressed: () {
                  print('contact pressed');
                  
                                           Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => chatScreen(
                username: GlobalUsername,
                baseUrl: widget.baseUrl,
                signInConstructorEmail: widget.email,
                chatwithConstructorEmail: trainee.traineeEmail,
                   // (chatWith == signedInUserEmail) ? myEmail : chatWith,

              ),
            ),
          );
                               },
                               style: ElevatedButton.styleFrom(
                  side: BorderSide(color: Colors.blue, width: 2),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                               ),
                               icon: Icon(Icons.chat_outlined),
                               label: Text(
                  'Contact Trainee',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                               ),
                             ),
               ),


      ],
    ),
  );
}

  void _showCapacityFullDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Capacity Full'),
          content: Text("Can't add because your trainee capacity is full for now."),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  
void _showDeleteConfirmationDialog(Trainee trainee) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Trainee'),
          content: Text('Are you sure you want to delete (${trainee.traineeName} Trainee?)'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Yes'),
              onPressed: () {
                setState(() {
                  _trainees.remove(trainee);
                });
                 saveusertrainee();
                Navigator.of(context).pop();
                     reloadPage(); // Reload the page after popping the dialog

              },
            ),
          ],
        );
      },
    );
  }

void _showEditDialog(Trainee trainee) {
  DateTime _startDate = trainee.startdate;
  DateTime _endDate = trainee.enddate;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Edit Trainee'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Edit Start Date:'),
                ElevatedButton(
                  onPressed: () {
                    showDatePicker(
                      context: context,
                      initialDate: _startDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    ).then((value) {
                      if (value != null) {
                        setState(() {
                          _startDate = value;
                        });
                      }
                    });
                  },
                  child: Text('Select Start Date'),
                ),
                Text(
                  'Selected Start Date: ${_startDate.toLocal().toString().split(' ')[0]}',
                ),
                SizedBox(height: 10),
                Text('Edit End Date:'),
                ElevatedButton(
                  onPressed: () {
                    showDatePicker(
                      context: context,
                      initialDate: _endDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    ).then((value) {
                      if (value != null) {
                        setState(() {
                          _endDate = value;
                        });
                      }
                    });
                  },
                  child: Text('Select End Date'),
                ),
                Text(
                  'Selected End Date: ${_endDate.toLocal().toString().split(' ')[0]}',
                ),
              ],
            ),
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                child: Text('Save'),
                onPressed: () {
                  final differenceInDays = _endDate.difference(_startDate).inDays;
                  if (differenceInDays < 30) {
                    // Show a message that the period should be at least 30 days
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('The period should be at least 30 days')),
                    );
                  } else {
                    // Save the edited dates
                    setState(() {
                      trainee.startdate = _startDate;
                      trainee.enddate = _endDate;
                    });

                    saveusertrainee();

                    Navigator.of(context).pop(); // Close the dialog first
                    reloadPage(); // Reload the page after popping the dialog
                  }
                },
              ),
            ],
          );
        },
      );
    },
  );
}


 void _showAddTraineeDialog()  {
  final _nameController = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Text('Add Trainer'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Autocomplete<UsersForsearch>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<UsersForsearch>.empty();
                    }
                    return _usersForsearchs.where((UsersForsearch user) {
                      return user.name
                          .toLowerCase()
                          .contains(textEditingValue.text.toLowerCase());
                    });
                  },
                  displayStringForOption: (UsersForsearch option) => option.name,
                  fieldViewBuilder: (BuildContext context, TextEditingController fieldTextEditingController, FocusNode fieldFocusNode, VoidCallback onFieldSubmitted) {
                    _nameController.value = fieldTextEditingController.value;
                    return TextField(
                      controller: fieldTextEditingController,
                      focusNode: fieldFocusNode,
                      decoration: InputDecoration(
                        labelText: 'Trainer Name',
                      ),
                    );
                  },
                  onSelected: (UsersForsearch selection) {
                    _nameController.text = selection.name;
                    print('Selected user: ${selection.name}'); // Debug print
                  },
                  optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<UsersForsearch> onSelected, Iterable<UsersForsearch> options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4.0,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                                maxHeight: options.length * 60.0 <= 150.0 ? options.length * 60.0 : 200.0, // Dynamically adjust height
                            maxWidth: 200),
                          child: ListView.builder(
                            padding: EdgeInsets.all(8.0),
                            itemCount: options.length,
                            itemBuilder: (BuildContext context, int index) {
                              final UsersForsearch option = options.elementAt(index);
                              return GestureDetector(
                                onTap: () {
                                  onSelected(option);
                                },
                                child: ListTile(
                                  title: Text(option.name),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Text('Start Date:'),
                    TextButton(
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _startDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null && picked != _startDate) {
                          setState(() {
                            _startDate = picked;
                          });
                        }
                      },
                      child: Text(_dateFormat.format(_startDate)),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text('End Date:'),
                    TextButton(
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _endDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null && picked != _endDate) {
                          setState(() {
                            _endDate = picked;
                          });
                        }
                      },
                      child: Text(_dateFormat.format(_endDate)),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final enteredName = _nameController.text;
                  print('Entered name: $enteredName'); // Debug print
                  final userExists = _usersForsearchs.any((user) => user.name == enteredName);
                
                  final differenceInDays = _endDate.difference(_startDate).inDays;

                  if (userExists && differenceInDays >= 30) {
                  
             
              final user = _usersForsearchs.firstWhere((user) => user != null && user.name == enteredName);

               _trainees.add(Trainee(
                              traineeName: _nameController.text,
                              traineeEmail: user.email,
                              startdate: _startDate,
                              enddate: _endDate,
                            ));
                         
                    
           
                    //  setState(() {
                    //         _trainees.add(Trainee(
                    //           traineeName: _nameController.text,
                    //           traineeEmail: user.email,
                    //           startdate: _startDate,
                    //           enddate: _endDate,
                    //         ));
                    //   });
                      
                     
                          print('Added trainees:');
                          _trainees.forEach((trainee) {
                            print('Name: ${trainee.traineeName}, Start Date: ${trainee.startdate}, End Date: ${trainee.enddate}');
                           });
                       
                    saveusertrainee();


                     Navigator.of(context).pop(); // Close the dialog first
                     reloadPage(); // Reload the page after popping the dialog

                  } else {
                    if (!userExists) {
                      // Show a message that the username does not exist
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('This username does not exist')),
                      );
                    } else if (differenceInDays < 30) {
                      // Show a message that the period should be at least 30 days
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('The period should be at least 30 days')),
                      );
                    }
                  }


               

                },
                child: Text('Add'),
              ),
            ],
          );
        },
      );
    },
  );
}


}

//------------------------------------------------------------------------------
class TraineesInfoClass {
  final String email;

  final String     TDEE;
  final String    target;
  final String     activity;
  final String    sex;

  final String     age;
  final String    height;

  final String     startweight;
  final String     currentweight;
  final String    goalWeight;
  final String     date;

  final String    carbs;
  final String     minWork;
  final String    workWeek;

  final String     carbsPer;
  final String    protienPer;
  final String     fatPer;
  final String    protein;

   final String     satFat;
  final String    totFat;
  final String     sodium;
  final String    potassium;

  final String     cholesterol;
  final String    fiber;
  final String     sugar;
 


   

  TraineesInfoClass({
    required this.email,
    required this.TDEE,
    required this.target,
    required this.activity,
    required this.sex,
    required this.age,
    required this.height,
    required this.startweight,
    required this.currentweight,
    required this.goalWeight,
    required this.date,
    required this.carbs,
    required this.minWork,
    required this.workWeek,
    required this.carbsPer,
    required this.protienPer,
    required this.fatPer,
    required this.protein,
    required this.satFat,
    required this.totFat,
    required this.sodium,
    required this.potassium,
    required this.cholesterol,
    required this.fiber,
    required this.sugar,
  });


  Map<String, dynamic> toJson() {
    return {
      
      'email': email,
      'TDEE': TDEE,
      'target': target,
      'activity': activity,
      'sex': sex,
      'age': age,
      'height': height,
      'startweight': startweight,
      'currentweight': currentweight,
      'goalWeight': goalWeight,
      'date': date,
      'carbs': carbs,
      'minWork': minWork,
      'workWeek': workWeek,
      'carbsPer': carbsPer,
      'protienPer': protienPer,
      'fatPer': fatPer,
      'protein': protein,
      'satFat': satFat,
      'totFat': totFat,
      'sodium': sodium,
      'potassium': potassium,
      'cholesterol': cholesterol,
      'fiber': fiber,
      'sugar': sugar,
    };
  }

    factory TraineesInfoClass.fromJson(Map<String, dynamic> json) {
    return TraineesInfoClass(
      email: json['email'],
      TDEE: json['TDEE'],
      target: json['target'],
      activity: json['activity'],
      sex: json['sex'],
      age: json['age'],
      height: json['height'],
      currentweight: json['currentweight'],
      startweight: json['startweight'],
      goalWeight: json['goalWeight'],
      date: json['date'],
      carbs: json['carbs'],
      minWork: json['minWork'],
      workWeek: json['workWeek'],
      carbsPer: json['carbsPer'],
      protienPer: json['protienPer'],
      fatPer: json['fatPer'],
      protein: json['protein'],
      satFat: json['satFat'],
      totFat: json['totFat'],
      sodium: json['sodium'],
      potassium: json['potassium'],
      cholesterol: json['cholesterol'],
      fiber: json['fiber'],
      sugar: json['sugar'],
    );
  }

}


List<TraineesInfoClass> traineesInfoList = [

];


Widget _buildInfoRowTrainee(String label, String value) {
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(value),
          ],
        ),
      ),
      Divider(
        thickness: 1,
        color: Colors.grey,
      ),
    ],
  );
}


void _showInfoDialogTrainee(BuildContext context, List<TraineesInfoClass> traineesInfoList) {
  List<Widget> traineesInfoWidgets = [];

  // Iterate over each TraineesInfo object in the traineesInfoList
  for (var traineeInfo in traineesInfoList) {
    // Add widgets for each property of the TraineesInfo object
    traineesInfoWidgets.addAll([
      _buildInfoRowTrainee('Email', '${traineeInfo.email} '),
      _buildInfoRowTrainee('TDEE', '${traineeInfo.TDEE} kcal'),
      _buildInfoRowTrainee('Target', traineeInfo.target),
      _buildInfoRowTrainee('Activity', traineeInfo.activity),
      _buildInfoRowTrainee('Sex', traineeInfo.sex),
      _buildInfoRowTrainee('Age', traineeInfo.age),
      _buildInfoRowTrainee('Height', '${traineeInfo.height} cm'),
      _buildInfoRowTrainee('Start Weight', 'start ${traineeInfo.startweight} kg on ${traineeInfo.date}'),
      _buildInfoRowTrainee('Current Weight', '${traineeInfo.currentweight} kg'),
      _buildInfoRowTrainee('Goal Weight','${traineeInfo.goalWeight} kg'),
      _buildInfoRowTrainee('Min Work', '${traineeInfo.minWork} m'),
      _buildInfoRowTrainee('Work Week', traineeInfo.workWeek),
      _buildInfoRowTrainee('Carbs', '${traineeInfo.carbs} g'),
      _buildInfoRowTrainee('Carbs Per', '${traineeInfo.carbsPer} %'),
      _buildInfoRowTrainee('Protein', '${traineeInfo.protein} g'),
      _buildInfoRowTrainee('Protein Per', '${traineeInfo.protienPer} %'),
      _buildInfoRowTrainee('Total Fat', '${traineeInfo.totFat} g'),
      _buildInfoRowTrainee('Fat Per', '${traineeInfo.fatPer} %'),
      _buildInfoRowTrainee('Saturated Fat', '${traineeInfo.satFat} g'),
      _buildInfoRowTrainee('Fiber', '${traineeInfo.fiber} g'),
      _buildInfoRowTrainee('Sugar', '${traineeInfo.sugar} g'),
      _buildInfoRowTrainee('Sodium', '${traineeInfo.sodium} mg'),
      _buildInfoRowTrainee('Potassium','${traineeInfo.potassium} mg'),
      _buildInfoRowTrainee('Cholesterol','${traineeInfo.cholesterol} mg'),

      SizedBox(height: 10), // Add space between TraineesInfo objects
          // Display additional information: start {weight} on {date}
     
    ]);
  }

  AwesomeDialog(
    context: context,
    dialogType: DialogType.info,
    animType: AnimType.rightSlide,
    //width: MediaQuery.of(context).size.width * 0.9,
     width: traineesInfoWidgets.length * 700.0,
    title: 'Trainee\'s Info',
    body: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: traineesInfoWidgets,
      ),
    ),
    btnCancelText: 'Close',
    btnCancelOnPress: () {},
  )..show();
}



//------------------------------------------------------------------------------

class Trainee {
  final String traineeName;
   final String traineeEmail;
   DateTime startdate;
   DateTime enddate;




  Trainee({
    required this.traineeName,
    required this.traineeEmail,
    required this.startdate,
    required this.enddate,

  });

    Map<String, dynamic> toJson() {
        final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
    return {
      'traineeName': traineeName,
      'traineeEmail': traineeEmail,
     'startdate': _dateFormat.format(startdate),
    'enddate': _dateFormat.format(enddate),
    
    };
  }

    factory Trainee.fromJson(Map<String, dynamic> json) {
    return Trainee(
      traineeName: json['traineeName'],
      traineeEmail: json['traineeEmail'],
      startdate: json['startdate'],
      enddate: json['enddate'],
     
    );
  }


}


class UsersForsearch{
  final String name;
  final String email;


  UsersForsearch({
    required this.name,
    required this.email,
  });

    factory UsersForsearch.fromJson(Map<String, dynamic> json) {
    return UsersForsearch(
      name: json['username'],
      email: json['email'],
    );
  }

}



//------------------------------------------------------------------------------

