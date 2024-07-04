import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:gp/CoachFolder/WeeklyTemDiarySummary.dart';
import 'package:gp/CoachFolder/WeeklyTemplate.dart';
import 'package:gp/CoachFolder/CoachTrainnee.dart';
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
import 'package:gp/globals.dart' as globals;
import 'package:awesome_notifications/awesome_notifications.dart';

 

double FoodtotalCaloires=0;
double ExertotalCalories=0;
double RemaningTotalCalories=0;
String GoalStringShow='';

 

DateTime maxdateTimeBACK = DateTime.now();
DateTime GLOBALselectedDate = DateTime.now();

// Global variable to store the note content
String globalNote = '';

class WeeklyTemfooddairy extends StatefulWidget {
  final String baseUrl;
  final String name;
  final String TraineeEmail;
  final String CoachEmail;

  final DateTime selectedDateDisplay;

  const WeeklyTemfooddairy({
    Key? key,
    required this.baseUrl,
    required this.name,
    required this.TraineeEmail,
    required this.CoachEmail,
    required this.selectedDateDisplay,
  }) : super(key: key);

  @override
  State<WeeklyTemfooddairy> createState() => _WeeklyTemfooddairyState();
}

class _WeeklyTemfooddairyState extends State<WeeklyTemfooddairy> {
  static late DateTime selectedDate;


  @override
  void initState() {
    print("Selected Date to display:  ${widget.selectedDateDisplay}");
    super.initState();
    TDEEInfoHistorical();
    selectedDate = widget.selectedDateDisplay;
    //DateTime.now(); // Set the default selected date to current date
    GLOBALselectedDate = selectedDate;

    showdayofWeek();
    CalculatedWidgetCaloriesConcumption();

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

    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        // This is just a basic example. For real apps, you must show some
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }




 //TDEEInfoHistorical()
   Future<void> TDEEInfoHistorical() async {
    
    try {
      var url = Uri.parse('${widget.baseUrl}/TDEEInfoHistorical');
      var response = await http.post(
        url,
        body: jsonEncode({
          'email': widget.TraineeEmail,
          'date':  DateFormat('yyyy-MM-dd').format(selectedDate).toString(),  // Date of the diary entry
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);

        setState(() {
  
          GoalStringShow = responseData['afterTDEE'];
           

        });
      } else {
        // Handle error
       
        print('Saved diary food failed: ${response.statusCode}');
        print(
            'Response body: ${response.body}'); // back here for  Response body: "User does not have any logged photos yet."
      }
    } catch (error) {
      // Handle error
      print('Error: $error');
      
    }
  }

 //showdayofWeek()
 Future<void> showdayofWeek() async {

    try {
      var url = Uri.parse('${widget.baseUrl}/showdayofWeek');
      var response = await http.post(
        url,
        body: jsonEncode({
          'coachemail': widget.CoachEmail,
          'traineeEmail': widget.TraineeEmail,
          'weekdate': globals.GLOBALWEEKLYselectedDate,
          'dayLogs': [
            {
              'todaydate': DateFormat('yyyy-MM-dd')
                  .format(selectedDate)
                  .toString(), // Date of the diary entry
            }
          ]
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print("Hello1");
        var responseData = json.decode(response.body);
//print("Hello2");
        // Extracting data from the response and updating lists
        List<FoodItem> newFoodItemsBreakfast = [];
        if (responseData['allBreakfasts'] != null) {
          newFoodItemsBreakfast = (responseData['allBreakfasts'] as List)
              .map((item) => FoodItem.fromJson(item))
              .toList();
        }
//print("Hello3");

        List<FoodItem> newFoodItemsLunch = [];
        if (responseData['allLunches'] != null) {
          newFoodItemsLunch = (responseData['allLunches'] as List)
              .map((item) => FoodItem.fromJson(item))
              .toList();
        }
//print("Hello4");

        List<FoodItem> newFoodItemsDinner = [];
        if (responseData['allDinners'] != null) {
          newFoodItemsDinner = (responseData['allDinners'] as List)
              .map((item) => FoodItem.fromJson(item))
              .toList();
        }
//print("Hello5");

        List<FoodItem> newFoodItemsSnack = [];
        if (responseData['allSnacks'] != null) {
          newFoodItemsSnack = (responseData['allSnacks'] as List)
              .map((item) => FoodItem.fromJson(item))
              .toList();
        }
//print("Hello6");

        List<ExerciseItem> newExerciseItems = [];
        if (responseData['allExercises'] != null) {
          newExerciseItems = (responseData['allExercises'] as List)
              .map((item) => ExerciseItem.fromJson(item))
              .toList();
        }
        print("Hello7");

        String newGlobalNote = responseData['allNoteContents'];

        // Updating state with the new data
        setState(() {
          // Clearing the existing lists before updating them with new data
          foodItemsBreakfast.clear();
          foodItemsLunch.clear();
          foodItemsDinner.clear();
          foodItemsSnack.clear();
          ExerciseItems.clear();

          // Adding new data to the lists
          foodItemsBreakfast.addAll(newFoodItemsBreakfast);
          foodItemsLunch.addAll(newFoodItemsLunch);
          foodItemsDinner.addAll(newFoodItemsDinner);
          foodItemsSnack.addAll(newFoodItemsSnack);
          ExerciseItems.addAll(newExerciseItems);
          globalNote = newGlobalNote;

          CalculatedWidgetCaloriesConcumption();
        });
      } else {
        // Handle error
        print('Show diary food failed: ${response.statusCode}');
        print(
            'Response body: ${response.body}'); // back here for  Response body: "User does not have any logged photos yet."
      }
    } catch (error) {
      // Handle error
      print('Error: $error');
    }
  }

  //savedayofWeek()
  Future<void> savedayofWeek() async {
    try {
      var url = Uri.parse('${widget.baseUrl}/savedayofWeek');
      var response = await http.post(
        url,
        body: jsonEncode({
          'coachemail': widget.CoachEmail,
          'traineeEmail': widget.TraineeEmail,
          'weekdate': globals.GLOBALWEEKLYselectedDate,
          'dayLogs': [
            {
              'todaydate': DateFormat('yyyy-MM-dd')
                  .format(selectedDate)
                  .toString(), // Date of the diary entry
              'mealsExe': {
                'breakfast':
                    foodItemsBreakfast.map((item) => item.toJson()).toList(),
                'lunch': foodItemsLunch.map((item) => item.toJson()).toList(),
                'dinner': foodItemsDinner.map((item) => item.toJson()).toList(),
                'snack': foodItemsSnack.map((item) => item.toJson()).toList(),
              },
              'exerc': ExerciseItems.map((item) => item.toJson()).toList(),
              'noteCont': globalNote
            }
          ]
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);

        setState(() {
          print("Response 200 ok from savedayofWeek");
        });
      } else {
        // Handle error
        print('Saved dayweek diary food failed: ${response.statusCode}');
        print(
            'Response body: ${response.body}'); // back here for  Response body: "User does not have any logged photos yet."
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
        backgroundColor: Colors.redAccent,
        title: Row(
          children: [
            SizedBox(width: 5),
            Image.asset(
              'images/img6.png',
              height: 87,
              width: 75,
            ),
            SizedBox(width: 15),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Template Diary Food',
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
                    builder: (context) => WeeklyTemplate(
                      baseUrl: widget.baseUrl,
                      name: widget.name,
                      TraineeEmail: widget.TraineeEmail,
                      CoachEmail: widget.CoachEmail,
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
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                height: 7), // Adding space between AppBar and date selection
            Container(
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10), // Rounded corners
                color: Color.fromARGB(
                    255, 240, 236, 236), // Color the container in grey
              ),
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey[200],
                ),
                child: Center(
                  child: Text(
                    DateFormat('yyyy-MM-dd')
                        .format(selectedDate), // Display the selected date
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),

            SizedBox(height: 10),
            // Adding space between date selection and "Calories Consumption" section
            Container(
              height: 110,
              padding: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10), // Rounded corners
                color: Color.fromARGB(
                    255, 240, 236, 236), // Color the container in grey
              ), // Color the container in grey
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Calories Consumption',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                             GoalStringShow,
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Goal',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(width: 20), // Add spacing between columns
                      Text(
                        '-',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 20), // Add spacing between columns
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${FoodtotalCaloires}',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Food',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(width: 20), // Add spacing between columns
                      Text(
                        '+',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 20), // Add spacing between columns
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${ExertotalCalories}',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Exercise',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(width: 20), // Add spacing between columns
                      Text(
                        '=',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 20), // Add spacing between columns
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${RemaningTotalCalories}',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Remaining',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),

            //breakfastWidget(foodItems),

            breakfastWidget(
                foodItemsBreakfast), // Call breakfastWidget and pass the list of food items
            SizedBox(height: 10),

            LunchWidget(
                foodItemsLunch), // Call LunchWidget and pass the list of food items
            SizedBox(height: 10),

            DinnerWidget(
                foodItemsDinner), // Call DinnerWidget and pass the list of food items
            SizedBox(height: 10),

            SnackWidget(
                foodItemsSnack), // Call SnackWidget and pass the list of food items
            SizedBox(height: 10),

            ExerciseWidget(
                ExerciseItems), // Call SnackWidget and pass the list of food items
            SizedBox(height: 10),

            NoteWidget(
              baseUrl: widget.baseUrl,
              name: widget.name,
              TraineeEmail: widget.TraineeEmail,
              CoachEmail: widget.CoachEmail,
            ),
            SizedBox(height: 20),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // ElevatedButton.icon(
                    //   onPressed: () {
                    //     // Add functionality for Save Diary button here

                    //   },
                    //   style: ElevatedButton.styleFrom(
                    //     side: BorderSide(color: Colors.blue, width: 2),
                    //     padding:
                    //         EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    //   ),
                    //   icon: Icon(Icons.check_circle),
                    //   label: Text(
                    //     'Save Diary',
                    //     style: TextStyle(
                    //       fontSize: 14,
                    //       fontWeight: FontWeight.bold,
                    //     ),
                    //   ),
                    // ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WeeklyTemdailySummary(
                              baseUrl: widget.baseUrl,
                              name: widget.name,
                              TraineeEmail: widget.TraineeEmail,
                              CoachEmail: widget.CoachEmail,
                              selectedDateDisplay: selectedDate,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        side: BorderSide(color: Colors.blue, width: 2),
                        padding:
                            EdgeInsets.symmetric(horizontal: 35, vertical: 5),
                      ),
                      icon: Icon(Icons.restaurant),
                      label: Text(
                        'Nutrition',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                   globals.PERMISSIONforWEEKLY == 0
                  ? ElevatedButton.icon(
                      onPressed: () {
                        // Navigator.pushReplacement(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => WeeklyTemdailySummary(
                        //       baseUrl: widget.baseUrl,
                        //       name: widget.name,
                        //       TraineeEmail: widget.TraineeEmail,
                        //       CoachEmail: widget.CoachEmail,
                        //       selectedDateDisplay: selectedDate,
                        //     ),
                        //   ),
                        // );

                        // widget.TraineeEmail this is for email trainee
                        // widget.CoachEmail this is for email coach
                        sendnotification();


                        // globals.PERMISSIONforWEEKLY == 1 ? 'Show Day' : 'Log Day',

                        print('notifiy User');
                      },
                      style: ElevatedButton.styleFrom(
                        side: BorderSide(color: Colors.blue, width: 2),
                        padding:
                            EdgeInsets.symmetric(horizontal: 35, vertical: 5),
                      ),
                      icon: Icon(Icons.notification_add),
                      label: Text(
                        'Notifiy User',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ): SizedBox() // Return an empty SizedBox to hide the button

                  ],
                ),
                SizedBox(height: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // send notificatio for trainee
  Future<void> sendnotification() async {
    final url = Uri.parse(
        '${widget.baseUrl}/sendnotificationfromcoach/${widget.TraineeEmail}'); // Replace with your backend URL

    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        // If the server returns an OK response, parse the data
        final data = json.decode(response.body);
        if (data['status'] == "Notification added successfully") {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            animType: AnimType.bottomSlide,
            title: 'Notifiy user',
            // desc: 'Are you sure you want to delete this reminder?',
            btnOkText: 'Ok',
            btnOkOnPress: () {},
          ).show();
        }
      } else {
        // If the server did not return a 200 OK response, throw an error
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Widget breakfastWidget(List<FoodItem> foodItems) {
    if (foodItems.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), // Rounded corners
          color:
              Color.fromARGB(255, 240, 236, 236), // Color the container in grey
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Breakfast',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  '0', // Display 0 if there are no food items
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 10),
            Divider(),
            SizedBox(height: 10),
            Center(
              child: globals.PERMISSIONforWEEKLY == 0
                  ? ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => foodSearch(
                              baseUrl: widget.baseUrl,
                              name: widget.name,
                              TraineeEmail: widget.TraineeEmail,
                              CoachEmail: widget.CoachEmail,
                              mealName: 'Breakfast',
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        side: BorderSide(color: Colors.blue, width: 2),
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      ),
                      icon: Icon(Icons.food_bank_outlined),
                      label: Text(
                        'AddFood',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : SizedBox(), // Return an empty SizedBox to hide the button
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), // Rounded corners
          color:
              Color.fromARGB(255, 240, 236, 236), // Color the container in grey
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Breakfast',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  getTotalCalories(foodItems).toString(),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 10),
            Divider(),
            SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: foodItems.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              foodItems[index].mealName,
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              foodItems[index].size + ' gm',
                              style:
                                  TextStyle(fontSize: 15, color: Colors.grey),
                            ),
                          ],
                        ),
                        Spacer(),
                        Text(
                          foodItems[index].totCalories.toString(),
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          color: Colors.blue,
                          icon: Icon(Icons.info),
                          onPressed: () {
                            // You may want to use setState() to update the UI after deletion
                            // _showInfoDialogFood(context, foodItems[index]);
                            _showInfoDialogFood2(context, foodItems[index]);
                          },
                        ),
                        globals.PERMISSIONforWEEKLY == 0
                            ? IconButton(
                                color: Colors.red,
                                icon: Icon(Icons.delete),
                                onPressed: () async {
                                  // Handle delete functionality here
                                  // You may want to use setState() to update the UI after deletion
                                  setState(() {
                                    foodItems.removeAt(
                                        index); // Remove the item from the list

                                    CalculatedWidgetCaloriesConcumption();
                                  });
                                  await savedayofWeek();
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => WeeklyTemfooddairy(
                                        baseUrl: widget.baseUrl,
                                        name: widget.name,
                                        TraineeEmail: widget.TraineeEmail,
                                        CoachEmail: widget.CoachEmail,
                                        selectedDateDisplay: selectedDate,
                                      ),
                                    ),
                                  );
                                },
                              )
                            : SizedBox(), // Return an empty SizedBox to hide the button
                      ],
                    ),
                    SizedBox(height: 7),
                    Divider(), // Add a divider after each food item
                  ],
                );
              },
            ),
            SizedBox(height: 10),
            Center(
              child: globals.PERMISSIONforWEEKLY == 0
                  ? ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => foodSearch(
                              baseUrl: widget.baseUrl,
                              name: widget.name,
                              TraineeEmail: widget.TraineeEmail,
                              CoachEmail: widget.CoachEmail,
                              mealName: 'Breakfast',
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        side: BorderSide(color: Colors.blue, width: 2),
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      ),
                      icon: Icon(Icons.food_bank_outlined),
                      label: Text(
                        'AddFood',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : SizedBox(), // Return an empty SizedBox to hide the button
            ),
          ],
        ),
      );
    }
  }

//--------------------------------------------
  Widget LunchWidget(List<FoodItem> foodItems) {
    if (foodItems.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), // Rounded corners
          color:
              Color.fromARGB(255, 240, 236, 236), // Color the container in grey
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Lunch',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  '0', // Display 0 if there are no food items
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 10),
            Divider(),
            SizedBox(height: 10),
            Center(
              child: globals.PERMISSIONforWEEKLY == 0
                  ? ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => foodSearch(
                              baseUrl: widget.baseUrl,
                              name: widget.name,
                              TraineeEmail: widget.TraineeEmail,
                              CoachEmail: widget.CoachEmail,
                              mealName: 'Lunch',
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        side: BorderSide(color: Colors.blue, width: 2),
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      ),
                      icon: Icon(Icons.food_bank_outlined),
                      label: Text(
                        'AddFood',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : SizedBox(), // Return an empty SizedBox to hide the button
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), // Rounded corners
          color:
              Color.fromARGB(255, 240, 236, 236), // Color the container in grey
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Lunch',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  getTotalCalories(foodItems).toString(),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 10),
            Divider(),
            SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: foodItems.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              foodItems[index].mealName,
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              foodItems[index].size + ' gm',
                              style:
                                  TextStyle(fontSize: 15, color: Colors.grey),
                            ),
                          ],
                        ),
                        Spacer(),
                        Text(
                          foodItems[index].totCalories.toString(),
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          color: Colors.blue,
                          icon: Icon(Icons.info),
                          onPressed: () {
                            // You may want to use setState() to update the UI after deletion
                            //  _showInfoDialogFood(context, foodItems[index]);
                            _showInfoDialogFood2(context, foodItems[index]);
                          },
                        ),
                        globals.PERMISSIONforWEEKLY == 0
                            ? IconButton(
                                color: Colors.red,
                                icon: Icon(Icons.delete),
                                onPressed: () async {
                                  // Handle delete functionality here
                                  // You may want to use setState() to update the UI after deletion
                                  setState(() {
                                    foodItems.removeAt(
                                        index); // Remove the item from the list

                                    CalculatedWidgetCaloriesConcumption();
                                  });
                                  await savedayofWeek();
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => WeeklyTemfooddairy(
                                        baseUrl: widget.baseUrl,
                                        name: widget.name,
                                        TraineeEmail: widget.TraineeEmail,
                                        CoachEmail: widget.CoachEmail,
                                        selectedDateDisplay: selectedDate,
                                      ),
                                    ),
                                  );
                                },
                              )
                            : SizedBox(), // Return an empty SizedBox to hide the button
                      ],
                    ),
                    SizedBox(height: 7),
                    Divider(), // Add a divider after each food item
                  ],
                );
              },
            ),
            SizedBox(height: 10),
            Center(
              child: globals.PERMISSIONforWEEKLY == 0
                  ? ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => foodSearch(
                              baseUrl: widget.baseUrl,
                              name: widget.name,
                              TraineeEmail: widget.TraineeEmail,
                              CoachEmail: widget.CoachEmail,
                              mealName: 'Lunch',
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        side: BorderSide(color: Colors.blue, width: 2),
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      ),
                      icon: Icon(Icons.food_bank_outlined),
                      label: Text(
                        'AddFood',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : SizedBox(), // Return an empty SizedBox to hide the button
            ),
          ],
        ),
      );
    }
  }

//--------------------------------------------
  Widget DinnerWidget(List<FoodItem> foodItems) {
    if (foodItems.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), // Rounded corners
          color:
              Color.fromARGB(255, 240, 236, 236), // Color the container in grey
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Dinner',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  '0', // Display 0 if there are no food items
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 10),
            Divider(),
            SizedBox(height: 10),
            Center(
              child: globals.PERMISSIONforWEEKLY == 0
                  ? ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => foodSearch(
                              baseUrl: widget.baseUrl,
                              name: widget.name,
                              TraineeEmail: widget.TraineeEmail,
                              CoachEmail: widget.CoachEmail,
                              mealName: 'Dinner',
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        side: BorderSide(color: Colors.blue, width: 2),
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      ),
                      icon: Icon(Icons.food_bank_outlined),
                      label: Text(
                        'AddFood',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : SizedBox(), // Return an empty SizedBox to hide the button
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), // Rounded corners
          color:
              Color.fromARGB(255, 240, 236, 236), // Color the container in grey
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Dinner',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  getTotalCalories(foodItems).toString(),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 10),
            Divider(),
            SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: foodItems.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              foodItems[index].mealName,
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              foodItems[index].size + ' gm',
                              style:
                                  TextStyle(fontSize: 15, color: Colors.grey),
                            ),
                          ],
                        ),
                        Spacer(),
                        Text(
                          foodItems[index].totCalories.toString(),
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          color: Colors.blue,
                          icon: Icon(Icons.info),
                          onPressed: () {
                            // You may want to use setState() to update the UI after deletion
                            //  _showInfoDialogFood(context, foodItems[index]);
                            _showInfoDialogFood2(context, foodItems[index]);
                          },
                        ),
                        globals.PERMISSIONforWEEKLY == 0
                            ? IconButton(
                                color: Colors.red,
                                icon: Icon(Icons.delete),
                                onPressed: () async {
                                  // Handle delete functionality here
                                  // You may want to use setState() to update the UI after deletion
                                  setState(() {
                                    foodItems.removeAt(
                                        index); // Remove the item from the list

                                    CalculatedWidgetCaloriesConcumption();
                                  });
                                  await savedayofWeek();
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => WeeklyTemfooddairy(
                                        baseUrl: widget.baseUrl,
                                        name: widget.name,
                                        TraineeEmail: widget.TraineeEmail,
                                        CoachEmail: widget.CoachEmail,
                                        selectedDateDisplay: selectedDate,
                                      ),
                                    ),
                                  );
                                },
                              )
                            : SizedBox(), // Return an empty SizedBox to hide the button
                      ],
                    ),
                    SizedBox(height: 7),
                    Divider(), // Add a divider after each food item
                  ],
                );
              },
            ),
            SizedBox(height: 10),
            Center(
              child: globals.PERMISSIONforWEEKLY == 0
                  ? ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => foodSearch(
                              baseUrl: widget.baseUrl,
                              name: widget.name,
                              TraineeEmail: widget.TraineeEmail,
                              CoachEmail: widget.CoachEmail,
                              mealName: 'Dinner',
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        side: BorderSide(color: Colors.blue, width: 2),
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      ),
                      icon: Icon(Icons.food_bank_outlined),
                      label: Text(
                        'AddFood',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : SizedBox(), // Return an empty SizedBox to hide the button
            ),
          ],
        ),
      );
    }
  }

//--------------------------------------------
  Widget SnackWidget(List<FoodItem> foodItems) {
    if (foodItems.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), // Rounded corners
          color:
              Color.fromARGB(255, 240, 236, 236), // Color the container in grey
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Snack',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  '0', // Display 0 if there are no food items
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 10),
            Divider(),
            SizedBox(height: 10),
            Center(
              child: globals.PERMISSIONforWEEKLY == 0
                  ? ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => foodSearch(
                              baseUrl: widget.baseUrl,
                              name: widget.name,
                              TraineeEmail: widget.TraineeEmail,
                              CoachEmail: widget.CoachEmail,
                              mealName: 'Snack',
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        side: BorderSide(color: Colors.blue, width: 2),
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      ),
                      icon: Icon(Icons.food_bank_outlined),
                      label: Text(
                        'AddFood',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : SizedBox(), // Return an empty SizedBox to hide the button
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), // Rounded corners
          color:
              Color.fromARGB(255, 240, 236, 236), // Color the container in grey
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Snack',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  getTotalCalories(foodItems).toString(),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 10),
            Divider(),
            SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: foodItems.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              foodItems[index].mealName,
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              foodItems[index].size + ' gm',
                              style:
                                  TextStyle(fontSize: 15, color: Colors.grey),
                            ),
                          ],
                        ),
                        Spacer(),
                        Text(
                          foodItems[index].totCalories.toString(),
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          color: Colors.blue,
                          icon: Icon(Icons.info),
                          onPressed: () {
                            // You may want to use setState() to update the UI after deletion
                            // _showInfoDialogFood(context, foodItems[index]);
                            _showInfoDialogFood2(context, foodItems[index]);
                          },
                        ),
                        globals.PERMISSIONforWEEKLY == 0
                            ? IconButton(
                                color: Colors.red,
                                icon: Icon(Icons.delete),
                                onPressed: () async {
                                  // Handle delete functionality here
                                  // You may want to use setState() to update the UI after deletion
                                  setState(() {
                                    foodItems.removeAt(
                                        index); // Remove the item from the list

                                    CalculatedWidgetCaloriesConcumption();
                                  });
                                  await savedayofWeek();
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => WeeklyTemfooddairy(
                                        baseUrl: widget.baseUrl,
                                        name: widget.name,
                                        TraineeEmail: widget.TraineeEmail,
                                        CoachEmail: widget.CoachEmail,
                                        selectedDateDisplay: selectedDate,
                                      ),
                                    ),
                                  );
                                },
                              )
                            : SizedBox(), // Return an empty SizedBox to hide the button
                      ],
                    ),
                    SizedBox(height: 7),
                    Divider(), // Add a divider after each food item
                  ],
                );
              },
            ),
            SizedBox(height: 10),
            Center(
              child: globals.PERMISSIONforWEEKLY == 0
                  ? ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => foodSearch(
                              baseUrl: widget.baseUrl,
                              name: widget.name,
                              TraineeEmail: widget.TraineeEmail,
                              CoachEmail: widget.CoachEmail,
                              mealName: 'Snack',
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        side: BorderSide(color: Colors.blue, width: 2),
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      ),
                      icon: Icon(Icons.food_bank_outlined),
                      label: Text(
                        'AddFood',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : SizedBox(), // Return an empty SizedBox to hide the button
            ),
          ],
        ),
      );
    }
  } //end of snack

  Widget ExerciseWidget(List<ExerciseItem> ExerciseItems) {
    if (ExerciseItems.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), // Rounded corners
          color:
              Color.fromARGB(255, 240, 236, 236), // Color the container in grey
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Exercise',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  '0', // Display 0 if there are no exercise items
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 10),
            Divider(),
            SizedBox(height: 10),
            Center(
              child: globals.PERMISSIONforWEEKLY == 0
                  ? ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ExerciseSearch(
                              baseUrl: widget.baseUrl,
                              name: widget.name,
                              TraineeEmail: widget.TraineeEmail,
                              CoachEmail: widget.CoachEmail,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        side: BorderSide(color: Colors.blue, width: 2),
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      ),
                      icon: Icon(Icons.fitness_center),
                      label: Text(
                        'AddExercise',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : SizedBox(), // Return an empty SizedBox to hide the button
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), // Rounded corners
          color:
              Color.fromARGB(255, 240, 236, 236), // Color the container in grey
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Exercise',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  getTotalCaloriesExercise(ExerciseItems).toString(),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 10),
            Divider(),
            SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: ExerciseItems.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ExerciseItems[index].ExerName,
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              ExerciseItems[index].time + ' min',
                              style:
                                  TextStyle(fontSize: 15, color: Colors.grey),
                            ),
                          ],
                        ),
                        Spacer(),
                        Text(
                          ExerciseItems[index].totCalories.toString(),
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          color: Colors.blue,
                          icon: Icon(Icons.info),
                          onPressed: () {
                            // You may want to use setState() to update the UI after deletion
                            // _showInfoDialogExe(context, ExerciseItems[index]);
                            _showInfoDialogExer(context, ExerciseItems[index]);
                          },
                        ),
                        globals.PERMISSIONforWEEKLY == 0
                            ? IconButton(
                                color: Colors.red,
                                icon: Icon(Icons.delete),
                                onPressed: () async {
                                  // Handle delete functionality here
                                  // You may want to use setState() to update the UI after deletion
                                  setState(() {
                                    ExerciseItems.removeAt(
                                        index); // Remove the item from the list

                                    CalculatedWidgetCaloriesConcumption();
                                  });
                                  await savedayofWeek();
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => WeeklyTemfooddairy(
                                        baseUrl: widget.baseUrl,
                                        name: widget.name,
                                        TraineeEmail: widget.TraineeEmail,
                                        CoachEmail: widget.CoachEmail,
                                        selectedDateDisplay: selectedDate,
                                      ),
                                    ),
                                  );
                                },
                              )
                            : SizedBox(), // Return an empty SizedBox to hide the button
                      ],
                    ),
                    SizedBox(height: 7),
                    Divider(), // Add a divider after each AddExercise item
                  ],
                );
              },
            ),
            SizedBox(height: 10),
            Center(
              child: globals.PERMISSIONforWEEKLY == 0
                  ? ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ExerciseSearch(
                              baseUrl: widget.baseUrl,
                              name: widget.name,
                              TraineeEmail: widget.TraineeEmail,
                              CoachEmail: widget.CoachEmail,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        side: BorderSide(color: Colors.blue, width: 2),
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      ),
                      icon: Icon(Icons.fitness_center),
                      label: Text(
                        'AddExercise',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : SizedBox(), // Return an empty SizedBox to hide the button
            ),
          ],
        ),
      );
    }
  } //end of exercise

  void _showInfoDialogFood(BuildContext context, FoodItem foodItem) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(foodItem.mealName),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRowFood('Total Fat', foodItem.totFat),
                _buildInfoRowFood('Saturated Fat', foodItem.satFat),
                _buildInfoRowFood('Protein', foodItem.protein),
                _buildInfoRowFood('Sodium', foodItem.sodium),
                _buildInfoRowFood('Potassium', foodItem.potassium),
                _buildInfoRowFood('Cholesterol', foodItem.cholesterol),
                _buildInfoRowFood('Carbs', foodItem.carbs),
                _buildInfoRowFood('Fiber', foodItem.fiber),
                _buildInfoRowFood('Sugar', foodItem.sugar),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRowFood(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value),
        ],
      ),
    );
  }

  void _showInfoDialogFood2(BuildContext context, FoodItem foodItem) {
    List<Widget> nutritionalInfoWidgets = [
      _buildInfoRowFood('Total Fat', foodItem.totFat),
      _buildInfoRowFood('Saturated Fat', foodItem.satFat),
      _buildInfoRowFood('Protein', foodItem.protein),
      _buildInfoRowFood('Sodium', foodItem.sodium),
      _buildInfoRowFood('Potassium', foodItem.potassium),
      _buildInfoRowFood('Cholesterol', foodItem.cholesterol),
      _buildInfoRowFood('Carbs', foodItem.carbs),
      _buildInfoRowFood('Fiber', foodItem.fiber),
      _buildInfoRowFood('Sugar', foodItem.sugar),
    ];

    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.rightSlide,
      width: nutritionalInfoWidgets.length * 500.0,
      title: 'Nutrition Data',
      body: Container(
        height: 260,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: nutritionalInfoWidgets,
          ),
        ),
      ),
      btnCancelText: 'Close',
      btnCancelOnPress: () {},
    )..show();
  }

  void _showInfoDialogExe(BuildContext context, ExerciseItem exeItem) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(exeItem.ExerName),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRowFood('Description', exeItem.disc),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRowExe(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value),
        ],
      ),
    );
  }

  void _showInfoDialogExer(BuildContext context, ExerciseItem exeItem) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.rightSlide,
      title: 'Exercise Details',
      desc: "Name Exercise:\n${exeItem.ExerName}\n"
          "\nDescription:\n ${exeItem.disc}",

    descTextStyle: TextStyle(fontSize: 18),
    btnCancelText: 'Close',
    btnCancelOnPress: () {},
  )..show();
}


void CalculatedWidgetCaloriesConcumption(){

    double GoalCalcValue = 0 ;
   //GoalStringShow == '' ? 0 : double.parse(GoalStringShow);
   if(GoalStringShow == '') {
    GoalCalcValue = 3000;
   }
   else {
      GoalCalcValue = double.parse(GoalStringShow);
   }

    FoodtotalCaloires = getTotalCaloriesForAllMeals(foodItemsBreakfast, foodItemsLunch, foodItemsDinner, foodItemsSnack);
                            ExertotalCalories =  getTotalCaloriesForExercies(ExerciseItems);
                     setState(() {
                                RemaningTotalCalories = (GoalCalcValue - FoodtotalCaloires + ExertotalCalories);
                              
                                  RemaningTotalCalories = double.parse(RemaningTotalCalories.toStringAsFixed(2));
                              

                                    

                                    });
                              //RemaningTotalCalories < 0 ? 0 : RemaningTotalCalories;
                            
}


} //end of fooddiary class

class FoodItem {
  final String mealName;
  final int totCalories;
  final String size;
  final String totFat;
  final String satFat;
  final String protein;
  final String sodium;
  final String potassium;
  final String cholesterol;
  final String carbs;
  final String fiber;
  final String sugar;

  FoodItem({
    required this.mealName,
    required this.totCalories,
    required this.size,
    required this.totFat,
    required this.satFat,
    required this.protein,
    required this.sodium,
    required this.potassium,
    required this.cholesterol,
    required this.carbs,
    required this.fiber,
    required this.sugar,
  });

  Map<String, dynamic> toJson() {
    return {
      'mealName': mealName,
      'totCalories': totCalories,
      'size': size,
      'totFat': totFat,
      'satFat': satFat,
      'protein': protein,
      'sodium': sodium,
      'potassium': potassium,
      'cholesterol': cholesterol,
      'carbs': carbs,
      'fiber': fiber,
      'sugar': sugar,
    };
  }

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      mealName: json['mealName'],
      totCalories: json['totCalories'],
      size: json['size'],
      totFat: json['totFat'],
      satFat: json['satFat'],
      protein: json['protein'],
      sodium: json['sodium'],
      potassium: json['potassium'],
      cholesterol: json['cholesterol'],
      carbs: json['carbs'],
      fiber: json['fiber'],
      sugar: json['sugar'],

      // Parse other properties as needed
    );
  }
}

int getTotalCalories(List<FoodItem> foodItems) {
  int totalCalories = 0;
  for (var item in foodItems) {
    totalCalories += item.totCalories;
  }
  return totalCalories;
}

//List<FoodItem> foodItems = []; // Initialize an empty list
List<FoodItem> foodItemsBreakfast = [
  // FoodItem(
  //   mealName: "Chicken",
  //   totCalories: 300,
  //   size: "100",
  //   totFat: "20",
  //   satFat: "5",
  //   protein: "25",
  //   sodium: "500",
  //   potassium: "300",
  //   cholesterol: "100",
  //   carbs: "0",
  //   fiber: "0",
  //   sugar: "0",
  // ),
  // FoodItem(
  //   mealName: "Eggs",
  //  totCalories: 300,
  //   size: "50",
  //   totFat: "15",
  //   satFat: "4",
  //   protein: "13",
  //   sodium: "200",
  //   potassium: "150",
  //   cholesterol: "370",
  //   carbs: "1",
  //   fiber: "0",
  //   sugar: "0",
  // ),
  // FoodItem(
  //   mealName: "Toast",
  //     totCalories: 300,
  //   size: "30",
  //   totFat: "2",
  //   satFat: "0.5",
  //   protein: "3",
  //   sodium: "150",
  //   potassium: "50",
  //   cholesterol: "0",
  //   carbs: "18",
  //   fiber: "2",
  //   sugar: "3",
  // ),
];

List<FoodItem> foodItemsLunch = [
  //  FoodItem(
  //     mealName: "Toast",
  // totCalories: 300,
  //     size: "30",
  //     totFat: "2",
  //     satFat: "0.5",
  //     protein: "3",
  //     sodium: "150",
  //     potassium: "50",
  //     cholesterol: "0",
  //     carbs: "18",
  //     fiber: "2",
  //     sugar: "3",
  //   ),
];

List<FoodItem> foodItemsDinner = [
  // FoodItem(
  //     mealName: "Toast",
  //  totCalories: 300,
  //     size: "30",
  //     totFat: "2",
  //     satFat: "0.5",
  //     protein: "3",
  //     sodium: "150",
  //     potassium: "50",
  //     cholesterol: "0",
  //     carbs: "18",
  //     fiber: "2",
  //     sugar: "3",
  //   ),
];

List<FoodItem> foodItemsSnack = [];

class ExerciseItem {
  final String ExerName;
  final int totCalories;
  final String time;
  final String disc;

  ExerciseItem(
      {required this.ExerName,
      required this.totCalories,
      required this.time,
      required this.disc});

  Map<String, dynamic> toJson() {
    return {
      'ExerName': ExerName,
      'totCalories': totCalories,
      'time': time,
      'disc': disc,
    };
  }

  factory ExerciseItem.fromJson(Map<String, dynamic> json) {
    return ExerciseItem(
      ExerName: json['ExerName'],
      totCalories: json['totCalories'],
      time: json['time'],
      disc: json['disc'],
      // Parse other properties as needed
    );
  }
}

int getTotalCaloriesExercise(List<ExerciseItem> ExerciseItems) {
  int totalCalories = 0;
  for (var item in ExerciseItems) {
    totalCalories += item.totCalories;
  }
  return totalCalories;
}

List<ExerciseItem> ExerciseItems = [
  //ExerciseItem(ExerName: "Cardio", time: "30", totCalories: 350,disc:"up Down"),
];


double getTotalCaloriesForExercies(List<ExerciseItem> ExerciseItems) {
  double totalCalories = 0;
  

  // Calculate total calories for breakfast
  totalCalories += getTotalCaloriesExercise(ExerciseItems);

  return totalCalories;
}

class NoteWidget extends StatefulWidget {
  final String baseUrl;
  final String name;
  final String TraineeEmail;
  final String CoachEmail;

  const NoteWidget({
    Key? key,
    required this.baseUrl,
    required this.name,
    required this.TraineeEmail,
    required this.CoachEmail,
  }) : super(key: key);

  @override
  _NoteWidgetState createState() => _NoteWidgetState();
}

class _NoteWidgetState extends State<NoteWidget> {
  TextEditingController _noteController = TextEditingController();

  //savedayofWeek()
  Future<void> savedayofWeek() async {
    try {
      var url = Uri.parse('${widget.baseUrl}/savedayofWeek');
      var response = await http.post(
        url,
        body: jsonEncode({
          'coachemail': widget.CoachEmail,
          'traineeEmail': widget.TraineeEmail,
          'weekdate': globals.GLOBALWEEKLYselectedDate,
          'dayLogs': [
            {
              'todaydate': DateFormat('yyyy-MM-dd')
                  .format(GLOBALselectedDate)
                  .toString(), // Date of the diary entry
              'mealsExe': {
                'breakfast':
                    foodItemsBreakfast.map((item) => item.toJson()).toList(),
                'lunch': foodItemsLunch.map((item) => item.toJson()).toList(),
                'dinner': foodItemsDinner.map((item) => item.toJson()).toList(),
                'snack': foodItemsSnack.map((item) => item.toJson()).toList(),
              },
              'exerc': ExerciseItems.map((item) => item.toJson()).toList(),
              'noteCont': globalNote
            }
          ]
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);

        setState(() {
          print("Response 200 ok from savedayofWeek");
        });
      } else {
        // Handle error
        print('Saved dayweek diary food failed: ${response.statusCode}');
        print(
            'Response body: ${response.body}'); // back here for  Response body: "User does not have any logged photos yet."
      }
    } catch (error) {
      // Handle error
      print('Error: $error');
    }
  }

  void _saveNote() async {
    // Function to save the note
    globalNote = _noteController.text; // Update global variable
    await savedayofWeek();

    Navigator.of(context).pop(); // Close the pop-up dialog
    //   setState(() {
    //   //globalNote = _noteController.text; // Update global variable

    // });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => WeeklyTemfooddairy(
          baseUrl: widget.baseUrl,
          name: widget.name,
          TraineeEmail: widget.TraineeEmail,
          CoachEmail: widget.CoachEmail,
          selectedDateDisplay: GLOBALselectedDate,
        ),
      ),
    );
  }

  void _cancelNote() {
    // Function to cancel adding the note
    Navigator.of(context).pop(); // Close the pop-up dialog
  }

  void _clearNote() async {
    _noteController.clear(); // Clear the text field
    globalNote = ''; // Clear the global note content
    await savedayofWeek();

    // // Function to clear the note
    setState(() {
      _noteController.clear(); // Clear the text field
      globalNote = ''; // Clear the global note content
    });
    Navigator.of(context).pop(); // Close the pop-up dialog
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => WeeklyTemfooddairy(
          baseUrl: widget.baseUrl,
          name: widget.name,
          TraineeEmail: widget.TraineeEmail,
          CoachEmail: widget.CoachEmail,
          selectedDateDisplay: GLOBALselectedDate,
        ),
      ),
    );
  }

  void _showNoteDialog(BuildContext context) {
    _noteController.text = globalNote;
    // Function to show the pop-up dialog for adding notes
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add/Edit Note'),
          content: Container(
            width: double.maxFinite,
            child: TextField(
              controller: _noteController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                hintText: 'Enter your note here...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: _saveNote,
              child: Text('Save'),
            ),
            TextButton(
              onPressed: _clearNote,
              child: Text('Delete'),
            ),
            TextButton(
              onPressed: _cancelNote,
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10), // Rounded corners
        color:
            Color.fromARGB(255, 240, 236, 236), // Color the container in grey
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Note',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 10),
          Divider(),
          SizedBox(height: 10),
          // Show the note if it's not empty
          if (globalNote.isNotEmpty)
            Text(
              globalNote,
              style: TextStyle(fontSize: 16),
            ),
          SizedBox(height: 10),
          Divider(),
          SizedBox(height: 10),
          Center(
            child: globals.PERMISSIONforWEEKLY == 0
                ? ElevatedButton.icon(
                    onPressed: () {
                      _showNoteDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      side: BorderSide(color: Colors.blue, width: 2),
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    ),
                    icon: Icon(Icons.note_add),
                    label: Text(
                      'Note',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : SizedBox(), // Return an empty SizedBox to hide the button
          ),
        ],
      ),
    );
  }
}

class foodSearch extends StatefulWidget {
  final String baseUrl;
  final String name;
  final String TraineeEmail;
  final String CoachEmail;
  final String mealName;

  const foodSearch({
    Key? key,
    required this.baseUrl,
    required this.name,
    required this.TraineeEmail,
    required this.CoachEmail,
    required this.mealName,
  }) : super(key: key);

  @override
  State<foodSearch> createState() => _foodSearchState();
}

class _foodSearchState extends State<foodSearch> {
  TextEditingController _searchController = TextEditingController();
  bool _isAllSelected = true; // Track if "All" is selected
  List<CustomSearchFood> searchResults = []; // Holds search results

  final List<Foods> food = [
    Foods(
      name: 'Beef',
      imageUrl: 'https://www.themealdb.com/images/category/beef.png',
    ),
    Foods(
      name: 'Chicken',
      imageUrl: 'https://www.themealdb.com/images/category/chicken.png',
    ),
    Foods(
      name: 'Dessert',
      imageUrl: 'https://www.themealdb.com/images/category/dessert.png',
    ),
    Foods(
      name: 'Lamb',
      imageUrl: 'https://www.themealdb.com/images/category/lamb.png',
    ),
    Foods(
      name: 'Miscellaneous',
      imageUrl: 'https://www.themealdb.com/images/category/miscellaneous.png',
    ),
    Foods(
      name: 'Pasta',
      imageUrl: 'https://www.themealdb.com/images/category/pasta.png',
    ),
    Foods(
      name: 'Seafood',
      imageUrl: 'https://www.themealdb.com/images/category/seafood.png',
    ),
    Foods(
      name: 'Side',
      imageUrl: 'https://www.themealdb.com/images/category/side.png',
    ),
    Foods(
      name: 'Starter',
      imageUrl: 'https://www.themealdb.com/images/category/starter.png',
    ),
    Foods(
      name: 'Vegan',
      imageUrl: 'https://www.themealdb.com/images/category/vegan.png',
    ),
    Foods(
      name: 'Vegetarian',
      imageUrl: 'https://www.themealdb.com/images/category/vegetarian.png',
    ),
    Foods(
      name: 'Breakfast',
      imageUrl: 'https://www.themealdb.com/images/category/breakfast.png',
    ),
    Foods(
      name: 'Goat',
      imageUrl: 'https://www.themealdb.com/images/category/goat.png',
    ),
  ];

  Future<void> fetchRecipes(String category) async {
    try {
      final response = await http.get(
        Uri.parse('${widget.baseUrl}/recipesmobile?foodName=$category'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> recipesData = jsonDecode(response.body);
        List<Recipe> recipes = recipesData.map((recipeData) {
          return Recipe(
            name: recipeData['name'],
            description: recipeData['description'],
            imageUrl: recipeData['imageUrl'],
            price: recipeData['price'].toDouble(),
          );
        }).toList();

        // Navigate to FoodRecipesPage passing the fetched recipes
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SingleRecipeCategory(
              baseUrl: widget.baseUrl,
              category: category,
              recipes: recipes,
              name: widget.name,
              TraineeEmail: widget.TraineeEmail,
              CoachEmail: widget.CoachEmail,
              mealName: widget.mealName,
            ),
          ),
        );
      } else {
        print('Failed to fetch recipes. Status code: ${response.statusCode}');
        // Handle error
      }
    } catch (error) {
      print('Error fetching recipes: $error');
      // Handle error
    }
  }

  Future<void> getcustomFood() async {
    try {
      var url = Uri.parse('${widget.baseUrl}/getcustomFood');
      var response = await http.post(
        url,
        body: jsonEncode({
          'email': widget.CoachEmail,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        List<dynamic> formattedLogs = responseData['formattedLogs'];

        setState(() {
          Customsearchfood.clear(); // Clear the list before adding new records
          for (var logEntry in formattedLogs) {
            String mealName = logEntry['mealName'];
            String totCalories = logEntry['totCalories'];
            String size = logEntry['size'];
            String totFat = logEntry['totFat'];
            String satFat = logEntry['satFat'];
            String protein = logEntry['protein'];
            String sodium = logEntry['sodium'];
            String potassium = logEntry['potassium'];
            String cholesterol = logEntry['cholesterol'];
            String carbs = logEntry['carbs'];
            String fiber = logEntry['fiber'];
            String sugar = logEntry['sugar'];

            // Create a new CustomSearchFood object
            CustomSearchFood food = CustomSearchFood(
              mealName: mealName,
              totCalories: totCalories,
              size: size,
              totFat: totFat,
              satFat: satFat,
              protein: protein,
              sodium: sodium,
              potassium: potassium,
              cholesterol: cholesterol,
              carbs: carbs,
              fiber: fiber,
              sugar: sugar,
            );

            // Add the food to the Customsearchfood list
            Customsearchfood.add(food);
          }
        });
      } else {
        // Handle error
        print('Show Exercises failed: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (error) {
      // Handle error
      print('Error: $error');
    }
  }

  //savedayofWeek()
  Future<void> savedayofWeek() async {
    try {
      var url = Uri.parse('${widget.baseUrl}/savedayofWeek');
      var response = await http.post(
        url,
        body: jsonEncode({
          'coachemail': widget.CoachEmail,
          'traineeEmail': widget.TraineeEmail,
          'weekdate': globals.GLOBALWEEKLYselectedDate,
          'dayLogs': [
            {
              'todaydate': DateFormat('yyyy-MM-dd')
                  .format(GLOBALselectedDate)
                  .toString(), // Date of the diary entry
              'mealsExe': {
                'breakfast':
                    foodItemsBreakfast.map((item) => item.toJson()).toList(),
                'lunch': foodItemsLunch.map((item) => item.toJson()).toList(),
                'dinner': foodItemsDinner.map((item) => item.toJson()).toList(),
                'snack': foodItemsSnack.map((item) => item.toJson()).toList(),
              },
              'exerc': ExerciseItems.map((item) => item.toJson()).toList(),
              'noteCont': globalNote
            }
          ]
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);

        setState(() {
          print("Response 200 ok from savedayofWeek");
        });
      } else {
        // Handle error
        print('Saved dayweek diary food failed: ${response.statusCode}');
        print(
            'Response body: ${response.body}'); // back here for  Response body: "User does not have any logged photos yet."
      }
    } catch (error) {
      // Handle error
      print('Error: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    Customsearchfood.clear();
    getcustomFood();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[300],
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
            SizedBox(width: 65),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                '${widget.mealName}',
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
                  MaterialPageRoute(
                    builder: (context) => WeeklyTemfooddairy(
                      baseUrl: widget.baseUrl,
                      name: widget.name,
                      TraineeEmail: widget.TraineeEmail,
                      CoachEmail: widget.CoachEmail,
                      selectedDateDisplay: GLOBALselectedDate,
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
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.blue, width: 2),
                  color: Color.fromARGB(255, 240, 236, 236),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Icon(Icons.search),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        enabled:
                            _isAllSelected, // Ensures TextField is disabled when _isAllSelected is false
                        decoration: InputDecoration(
                          hintText: _isAllSelected ? "Search for a food" : " ",
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                              color: _isAllSelected
                                  ? const Color.fromARGB(255, 172, 169, 169)
                                  : Colors
                                      .red), // Change hint color based on _isAllSelected
                        ),
                        onChanged: (value) {
                          // Handle search query change
                          setState(() {
                            searchResults = Customsearchfood.where((food) =>
                                food.mealName
                                    .toLowerCase()
                                    .contains(value.toLowerCase())).toList();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isAllSelected =
                              false; // Update state when "Recipes" is selected
                        });

                        //         Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => CategoryFoodSearch(baseUrl: widget.baseUrl , name: widget.name,),
                        //   ),
                        // );
                      },
                      child: Container(
                        padding: EdgeInsets.only(
                            bottom: 2), // Add padding only to the bottom
                        decoration: BoxDecoration(
                          border: !_isAllSelected
                              ? Border(
                                  bottom: BorderSide(
                                      color: Colors.blue,
                                      width:
                                          2)) // Add blue bottom border if "Recipes" is selected
                              : null, // Otherwise, no border
                        ),
                        child: Text(
                          "Categories",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: !_isAllSelected
                                ? Colors.blue
                                : null, // Change text color if selected
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isAllSelected =
                              true; // Update state when "All" is selected
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.only(
                            bottom: 2), // Add padding only to the bottom
                        decoration: BoxDecoration(
                          border: _isAllSelected
                              ? Border(
                                  bottom: BorderSide(
                                      color: Colors.blue,
                                      width:
                                          2)) // Add blue bottom border if "All" is selected
                              : null, // Otherwise, no border
                        ),
                        child: Text(
                          "Custom",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _isAllSelected
                                ? Colors.blue
                                : null, // Change text color if selected
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Text("sad"),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                //  color: Colors.blue[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: _isAllSelected
                  ?
                  // Text("sad")
                  CustomSearchCategories(
                      searchResults.isNotEmpty
                          ? searchResults
                          : Customsearchfood,
                    )
                  : FoodSearchCategories(),
              //
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CustomFoodCategory(
                baseUrl: widget.baseUrl,
                name: widget.name,
                email: widget.TraineeEmail,
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

  Widget CustomSearchCategories(List<CustomSearchFood> customFoods) {
    if (customFoods.isEmpty) {
      return SizedBox(
        height: 500,
        child: Center(
          child: Text(
            'Create Your Custom Food',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(top: 13.0),
        child: SizedBox(
          width: double.infinity, // Adjust width as needed
          //height: double.infinity, // Adjust height as needed
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              customFoods.length,
              (index) {
                CustomSearchFood customFood = customFoods[index];
                return Card(
                  child: ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(customFood.mealName,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            Text('Calories: ${customFood.totCalories}'),
                            SizedBox(width: 5),
                            Text('Size: ${customFood.size}g'),
                          ],
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.info),
                          onPressed: () {
                            _showInfoDialog(context, customFood);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            _promptServingSize(context,
                                customFood); //here to work inside that fn
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
    }
  }

  void _showInfoDialog(BuildContext context, CustomSearchFood customFood) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(customFood.mealName),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Total Fat', customFood.totFat),
                _buildInfoRow('Saturated Fat', customFood.satFat),
                _buildInfoRow('Protein', customFood.protein),
                _buildInfoRow('Sodium', customFood.sodium),
                _buildInfoRow('Potassium', customFood.potassium),
                _buildInfoRow('Cholesterol', customFood.cholesterol),
                _buildInfoRow('Carbs', customFood.carbs),
                _buildInfoRow('Fiber', customFood.fiber),
                _buildInfoRow('Sugar', customFood.sugar),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value),
        ],
      ),
    );
  }

  void _promptServingSize(BuildContext context, CustomSearchFood customFood) {
    showDialog(
      context: context,
      builder: (context) {
        String servingSize = '';

        return AlertDialog(
          title: Text('Enter Serving Size'),
          content: TextField(
            onChanged: (value) {
              servingSize = value;
            },
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Serving Size (g)'),
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
                // You can use the servingSize here
                if (int.tryParse(servingSize) != null) {
                  print('Serving Size: $servingSize');

                  // Calculate the adjustment ratio based on the original size
                  double adjustmentRatio =
                      int.parse(servingSize) / double.parse(customFood.size);

                  // Calculate adjusted values
                  int adjustedCalories =
                      (double.parse(customFood.totCalories) * adjustmentRatio)
                          .round();
                  String adjustedTotFat =
                      (double.parse(customFood.totFat) * adjustmentRatio)
                          .toStringAsFixed(2);
                  String adjustedSatFat =
                      (double.parse(customFood.satFat) * adjustmentRatio)
                          .toStringAsFixed(2);
                  String adjustedProtein =
                      (double.parse(customFood.protein) * adjustmentRatio)
                          .toStringAsFixed(2);
                  String adjustedSodium =
                      (double.parse(customFood.sodium) * adjustmentRatio)
                          .toStringAsFixed(2);
                  String adjustedPotassium =
                      (double.parse(customFood.potassium) * adjustmentRatio)
                          .toStringAsFixed(2);
                  String adjustedCholesterol =
                      (double.parse(customFood.cholesterol) * adjustmentRatio)
                          .toStringAsFixed(2);
                  String adjustedCarbs =
                      (double.parse(customFood.carbs) * adjustmentRatio)
                          .toStringAsFixed(2);
                  String adjustedFiber =
                      (double.parse(customFood.fiber) * adjustmentRatio)
                          .toStringAsFixed(2);
                  String adjustedSugar =
                      (double.parse(customFood.sugar) * adjustmentRatio)
                          .toStringAsFixed(2);

                  // Check if mealName is 'Breakfast'
                  if (widget.mealName == 'Breakfast') {
                    FoodItem newItem = FoodItem(
                      mealName: customFood.mealName,
                      totCalories: adjustedCalories,
                      size: servingSize,
                      totFat: adjustedTotFat,
                      satFat: adjustedSatFat,
                      protein: adjustedProtein,
                      sodium: adjustedSodium,
                      potassium: adjustedPotassium,
                      cholesterol: adjustedCholesterol,
                      carbs: adjustedCarbs,
                      fiber: adjustedFiber,
                      sugar: adjustedSugar,
                    );

                    foodItemsBreakfast.add(newItem);
                    await savedayofWeek();
                  } else if (widget.mealName == 'Lunch') {
                    FoodItem newItem = FoodItem(
                      mealName: customFood.mealName,
                      totCalories: adjustedCalories,
                      size: servingSize,
                      totFat: adjustedTotFat,
                      satFat: adjustedSatFat,
                      protein: adjustedProtein,
                      sodium: adjustedSodium,
                      potassium: adjustedPotassium,
                      cholesterol: adjustedCholesterol,
                      carbs: adjustedCarbs,
                      fiber: adjustedFiber,
                      sugar: adjustedSugar,
                    );
                    foodItemsLunch.add(newItem);
                    await savedayofWeek();
                  } else if (widget.mealName == 'Dinner') {
                    FoodItem newItem = FoodItem(
                      mealName: customFood.mealName,
                      totCalories: adjustedCalories,
                      size: servingSize,
                      totFat: adjustedTotFat,
                      satFat: adjustedSatFat,
                      protein: adjustedProtein,
                      sodium: adjustedSodium,
                      potassium: adjustedPotassium,
                      cholesterol: adjustedCholesterol,
                      carbs: adjustedCarbs,
                      fiber: adjustedFiber,
                      sugar: adjustedSugar,
                    );
                    foodItemsDinner.add(newItem);
                    await savedayofWeek();
                  } else if (widget.mealName == 'Snack') {
                    FoodItem newItem = FoodItem(
                      mealName: customFood.mealName,
                      totCalories: adjustedCalories,
                      size: servingSize,
                      totFat: adjustedTotFat,
                      satFat: adjustedSatFat,
                      protein: adjustedProtein,
                      sodium: adjustedSodium,
                      potassium: adjustedPotassium,
                      cholesterol: adjustedCholesterol,
                      carbs: adjustedCarbs,
                      fiber: adjustedFiber,
                      sugar: adjustedSugar,
                    );
                    foodItemsSnack.add(newItem);
                    await savedayofWeek();
                  }
                  // Print adjusted values for debugging
                  print('Adjusted Calories: $adjustedCalories');
                  print('Adjusted TotFat: $adjustedTotFat');
                  print('Adjusted SatFat: $adjustedSatFat');
                  print('Adjusted Protein: $adjustedProtein');
                  print('Adjusted Sodium: $adjustedSodium');
                  print('Adjusted Potassium: $adjustedPotassium');
                  print('Adjusted Cholesterol: $adjustedCholesterol');
                  print('Adjusted Carbs: $adjustedCarbs');
                  print('Adjusted Fiber: $adjustedFiber');
                  print('Adjusted Sugar: $adjustedSugar');

                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WeeklyTemfooddairy(
                        baseUrl: widget.baseUrl,
                        name: widget.name,
                        TraineeEmail: widget.TraineeEmail,
                        CoachEmail: widget.CoachEmail,
                        selectedDateDisplay: GLOBALselectedDate,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('Invalid input. Please enter a valid integer.'),
                    ),
                  );
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget FoodSearchCategories() {
    return SizedBox(
      width: double.infinity, // Adjust width as needed
      //height: double.infinity, // Adjust height as needed

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Column(
            children: List.generate(
              (food.length / 2).ceil(),
              (rowIndex) {
                int startIndex = rowIndex * 2;
                int endIndex = startIndex + 2 <= food.length
                    ? startIndex + 2
                    : food.length;
                return Row(
                  children: List.generate(
                    endIndex - startIndex,
                    (indexInRow) {
                      int index = startIndex + indexInRow;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            fetchRecipes(food[index].name);
                          },
                          child: Card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.network(
                                  food[index].imageUrl,
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        Text(
                                          food[index].name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ExerciseSearch extends StatefulWidget {
  final String baseUrl;
  final String name;
  final String TraineeEmail;
  final String CoachEmail;

  const ExerciseSearch({
    Key? key,
    required this.baseUrl,
    required this.name,
    required this.TraineeEmail,
    required this.CoachEmail,
  }) : super(key: key);

  @override
  State<ExerciseSearch> createState() => _ExerciseSearchState();
}

class _ExerciseSearchState extends State<ExerciseSearch> {
  TextEditingController _searchController = TextEditingController();
  bool _isAllSelected = true; // Track if "All" is selected
  List<CustomSearchExercise> searchResults = []; // Holds search results

  final List<Products> products = [
    Products(
      name: 'Abs',
      imageUrl:
          'https://www.shutterstock.com/image-vector/human-abs-vector-cartoon-illustration-600w-2128378241.jpg',
    ),
    Products(
      name: 'Arms',
      imageUrl:
          'https://st2.depositphotos.com/3259223/8570/v/450/depositphotos_85705396-stock-illustration-body-builder-athlete-figure.jpg',
    ),
    Products(
      name: 'Back',
      imageUrl:
          'https://bonytobeastly.com/wp-content/uploads/2022/12/how-to-build-bigger-back-muscles-stretch-mediated-hypertrophy-1.jpg',
    ),
    // Products(
    //   name: 'Cardio',
    //   imageUrl:
    //       'https://www.planetware.com/wpimages/2020/02/france-in-pictures-beautiful-places-to-photograph-eiffel-tower.jpg',
    // ),
    Products(
      name: 'Chest',
      imageUrl:
          'https://cdn.muscleandstrength.com/sites/default/files/taxonomy/image/videos/chest_0.jpg',
    ),
    Products(
      name: 'Legs',
      imageUrl:
          'https://play-lh.googleusercontent.com/3rA3XaTEMaaNNWnSx2dAxUqLZPHPKKU9DTLnAAERG6kTwwBd-gDvN10F6bH_w_mxAioM',
    ),
    Products(
      name: 'Shoulders',
      imageUrl:
          'https://cdn.muscleandstrength.com/sites/default/files/taxonomy/image/videos/shoulders_0.jpg',
    ),
  ];

  Future<void> getcustomExe() async {
    try {
      var url = Uri.parse('${widget.baseUrl}/getcustomExe');
      var response = await http.post(
        url,
        body: jsonEncode({
          'email': widget.CoachEmail,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        List<dynamic> formattedLogs = responseData['formattedLogs'];

        setState(() {
          Customsearchexercise.clear();
          for (var logEntry in formattedLogs) {
            String exerName = logEntry['ExerName'];
            String totCalories = logEntry['totCalories'];
            String time = logEntry['time'];
            String disc = logEntry['disc'];

            // Create a new CustomSearchExercise object
            CustomSearchExercise exercise = CustomSearchExercise(
              ExerName: exerName,
              totCalories: totCalories,
              time: time,
              disc: disc,
            );
            // Add the exercise to the Customsearchexercise list
            Customsearchexercise.add(exercise);
          }
        });
      } else {
        // Handle error
        print('Show Exercises failed: ${response.statusCode}');
        print(
            'Response body: ${response.body}'); // back here for  Response body: "User does not have any logged photos yet."
      }
    } catch (error) {
      // Handle error
      print('Error: $error');
    }
  }

  //savedayofWeek()
  Future<void> savedayofWeek() async {
    try {
      var url = Uri.parse('${widget.baseUrl}/savedayofWeek');
      var response = await http.post(
        url,
        body: jsonEncode({
          'coachemail': widget.CoachEmail,
          'traineeEmail': widget.TraineeEmail,
          'weekdate': globals.GLOBALWEEKLYselectedDate,
          'dayLogs': [
            {
              'todaydate': DateFormat('yyyy-MM-dd')
                  .format(GLOBALselectedDate)
                  .toString(), // Date of the diary entry
              'mealsExe': {
                'breakfast':
                    foodItemsBreakfast.map((item) => item.toJson()).toList(),
                'lunch': foodItemsLunch.map((item) => item.toJson()).toList(),
                'dinner': foodItemsDinner.map((item) => item.toJson()).toList(),
                'snack': foodItemsSnack.map((item) => item.toJson()).toList(),
              },
              'exerc': ExerciseItems.map((item) => item.toJson()).toList(),
              'noteCont': globalNote
            }
          ]
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);

        setState(() {
          print("Response 200 ok from savedayofWeek");
        });
      } else {
        // Handle error
        print('Saved dayweek diary food failed: ${response.statusCode}');
        print(
            'Response body: ${response.body}'); // back here for  Response body: "User does not have any logged photos yet."
      }
    } catch (error) {
      // Handle error
      print('Error: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    Customsearchexercise.clear();
    getcustomExe();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[300],
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
            SizedBox(width: 65),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Exercises',
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
                  MaterialPageRoute(
                    builder: (context) => WeeklyTemfooddairy(
                      baseUrl: widget.baseUrl,
                      name: widget.name,
                      TraineeEmail: widget.TraineeEmail,
                      CoachEmail: widget.CoachEmail,
                      selectedDateDisplay: GLOBALselectedDate,
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
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.blue, width: 2),
                  color: Color.fromARGB(255, 240, 236, 236),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Icon(Icons.search),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        enabled:
                            _isAllSelected, // Ensures TextField is disabled when _isAllSelected is false
                        decoration: InputDecoration(
                          hintText:
                              _isAllSelected ? "Search for a Exercise" : " ",
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                              color: _isAllSelected
                                  ? const Color.fromARGB(255, 172, 169, 169)
                                  : Colors
                                      .red), // Change hint color based on _isAllSelected
                        ),
                        onChanged: (value) {
                          // Handle search query change
                          setState(() {
                            searchResults = Customsearchexercise.where((exer) =>
                                exer.ExerName.toLowerCase()
                                    .contains(value.toLowerCase())).toList();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isAllSelected =
                              false; // Update state when "Recipes" is selected
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.only(
                            bottom: 2), // Add padding only to the bottom
                        decoration: BoxDecoration(
                          border: !_isAllSelected
                              ? Border(
                                  bottom: BorderSide(
                                      color: Colors.blue,
                                      width:
                                          2)) // Add blue bottom border if "Recipes" is selected
                              : null, // Otherwise, no border
                        ),
                        child: Text(
                          "Exercises",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: !_isAllSelected
                                ? Colors.blue
                                : null, // Change text color if selected
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isAllSelected =
                              true; // Update state when "All" is selected
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.only(
                            bottom: 2), // Add padding only to the bottom
                        decoration: BoxDecoration(
                          border: _isAllSelected
                              ? Border(
                                  bottom: BorderSide(
                                      color: Colors.blue,
                                      width:
                                          2)) // Add blue bottom border if "All" is selected
                              : null, // Otherwise, no border
                        ),
                        child: Text(
                          "Custom",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _isAllSelected
                                ? Colors.blue
                                : null, // Change text color if selected
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Text("asd"),
            Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  //  color: Colors.blue[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _isAllSelected
                    ?
                    // Text("sad")
                    CustomSearchCategoriesExer(
                        searchResults.isNotEmpty
                            ? searchResults
                            : Customsearchexercise,
                      )
                    :
                    // Text("sad")
                    ExerciseSearchCategories()
                //
                ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CustomExerciseCategory(
                baseUrl: widget.baseUrl,
                name: widget.name,
                email: widget.TraineeEmail,
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

  Widget ExerciseSearchCategories() {
    return SizedBox(
      width: double.infinity, // Adjust width as needed
      //height: double.infinity, // Adjust height as needed

      child: Column(
        children: List.generate(
          (products.length / 2).ceil(),
          (rowIndex) {
            int startIndex = rowIndex * 2;
            int endIndex = startIndex + 2 <= products.length
                ? startIndex + 2
                : products.length;
            return Row(
              children: List.generate(
                endIndex - startIndex,
                (indexInRow) {
                  int index = startIndex + indexInRow;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SingleExerciseListPage(
                              baseUrl: widget.baseUrl,
                              category: products[index].name,
                              TraineeEmail: widget.TraineeEmail,
                              CoachEmail: widget.CoachEmail,
                              name: widget.name,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.network(
                              products[index].imageUrl,
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Column(
                                  children: [
                                    Text(
                                      products[index].name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget CustomSearchCategoriesExer(
      List<CustomSearchExercise> customExercises) {
    return Padding(
      padding: const EdgeInsets.only(top: 13.0),
      child: SizedBox(
        width: double.infinity, // Adjust width as needed
        //height: double.infinity, // Adjust height as needed

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
            customExercises.length,
            (index) {
              CustomSearchExercise customexe = customExercises[index];
              return Card(
                child: ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(customexe.ExerName,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Text('Calories: ${customexe.totCalories}'),
                          SizedBox(width: 5),
                          Text('Duration: ${customexe.time}m'),
                        ],
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.info),
                        onPressed: () {
                          _showInfoDialogExe(context, customexe);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          _promptServingSizeExe(context, customexe);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showInfoDialogExe(
      BuildContext context, CustomSearchExercise customExe) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(customExe.ExerName),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRowExe('Disecrption', customExe.disc),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRowExe(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value),
        ],
      ),
    );
  }

  void _promptServingSizeExe(
      BuildContext context, CustomSearchExercise customExe) {
    showDialog(
      context: context,
      builder: (context) {
        String duration = '';

        return AlertDialog(
          title: Text('Enter duration time'),
          content: TextField(
            onChanged: (value) {
              duration = value;
            },
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Duration time (m)'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // You can use the servingSize here
                if (int.tryParse(duration) != null) {
                  print('duration time: $duration');

                  // Calculate the adjustment ratio based on the original size
                  double adjustmentRatio =
                      int.parse(duration) / double.parse(customExe.time);

                  // Calculate adjusted values
                  int adjustedCalories =
                      (double.parse(customExe.totCalories) * adjustmentRatio)
                          .round();

                  ExerciseItem newItem = ExerciseItem(
                    ExerName: customExe.ExerName,
                    totCalories: adjustedCalories,
                    time: duration,
                    disc: customExe.disc,
                  );
                  ExerciseItems.add(newItem);
                  await savedayofWeek();

                  // Print adjusted values for debugging
                  print('Adjusted Calories: $adjustedCalories');

                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WeeklyTemfooddairy(
                        baseUrl: widget.baseUrl,
                        name: widget.name,
                        TraineeEmail: widget.TraineeEmail,
                        CoachEmail: widget.CoachEmail,
                        selectedDateDisplay: GLOBALselectedDate,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('Invalid input. Please enter a valid integer.'),
                    ),
                  );
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

// Start for Foodsearch Page -> For Categories display & For ALL display ..

//For Categories display category
class Foods {
  final String name;
  final String imageUrl;

  Foods({
    required this.name,
    required this.imageUrl,
  });
}

class Products {
  final String name;
  final String imageUrl;

  Products({
    required this.name,
    required this.imageUrl,
  });
}

//For Categories display for single

class SingleRecipeCategory extends StatefulWidget {
  final String baseUrl;
  final String category;
  final String name;
  final String TraineeEmail;
  final String CoachEmail;
  final String mealName;
  final List<Recipe> recipes;

  const SingleRecipeCategory({
    Key? key,
    required this.baseUrl,
    required this.category,
    required this.recipes,
    required this.name,
    required this.TraineeEmail,
    required this.CoachEmail,
    required this.mealName,
  }) : super(key: key);

  @override
  _SingleRecipeCategoryState createState() => _SingleRecipeCategoryState();
}

class _SingleRecipeCategoryState extends State<SingleRecipeCategory> {
  late List<Recipe> filteredRecipes;
  List<CartItem> cartItems = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredRecipes = List.from(widget.recipes);
  }

  void filterRecipes(String query) {
    setState(() {
      filteredRecipes = widget.recipes
          .where((recipe) =>
              recipe.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

//savedayofWeek()
  Future<void> savedayofWeek() async {
    try {
      var url = Uri.parse('${widget.baseUrl}/savedayofWeek');
      var response = await http.post(
        url,
        body: jsonEncode({
          'coachemail': widget.CoachEmail,
          'traineeEmail': widget.TraineeEmail,
          'weekdate': globals.GLOBALWEEKLYselectedDate,
          'dayLogs': [
            {
              'todaydate': DateFormat('yyyy-MM-dd')
                  .format(GLOBALselectedDate)
                  .toString(), // Date of the diary entry
              'mealsExe': {
                'breakfast':
                    foodItemsBreakfast.map((item) => item.toJson()).toList(),
                'lunch': foodItemsLunch.map((item) => item.toJson()).toList(),
                'dinner': foodItemsDinner.map((item) => item.toJson()).toList(),
                'snack': foodItemsSnack.map((item) => item.toJson()).toList(),
              },
              'exerc': ExerciseItems.map((item) => item.toJson()).toList(),
              'noteCont': globalNote
            }
          ]
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);

        setState(() {
          print("Response 200 ok from savedayofWeek");
        });
      } else {
        // Handle error
        print('Saved dayweek diary food failed: ${response.statusCode}');
        print(
            'Response body: ${response.body}'); // back here for  Response body: "User does not have any logged photos yet."
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
        title: Text(
          '${widget.category} Recipes',
          style:
              TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold),
        ),
        actions: [],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          iconSize: 40,
          color: Colors.blue[800],
          onPressed: () {
            //Navigator.of(context).pop();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => foodSearch(
                  baseUrl: widget.baseUrl,
                  name: widget.name,
                  TraineeEmail: widget.TraineeEmail,
                  CoachEmail: widget.CoachEmail,
                  mealName: widget.mealName,
                ),
              ),
            );
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Food Recipes',
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    filterRecipes('');
                  },
                ),
              ),
              onChanged: (value) {
                filterRecipes(value);
              },
            ),
          ),
          Expanded(
            child: filteredRecipes.isEmpty
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView.builder(
                    itemCount: filteredRecipes.length,
                    itemBuilder: (context, index) {
                      final recipe = filteredRecipes[index];
                      return GestureDetector(
                        onTap: () {
                          _showDescriptionDialog(context, recipe);
                        },
                        child: Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.network(
                                recipe.imageUrl,
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      recipe.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            _getCalories(context, recipe);
                                          },
                                          child: Text('Nutrition Data'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            // Handle onTap for Goal Weight
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                String servingSize = '';
                                                return AlertDialog(
                                                  title: Text(
                                                      'Enter Serving Size'),
                                                  content: TextField(
                                                    onChanged: (value) {
                                                      servingSize = value;
                                                    },
                                                    keyboardType:
                                                        TextInputType.number,
                                                    decoration: InputDecoration(
                                                      labelText:
                                                          'Serving Size (g)',
                                                    ),
                                                  ),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: Text('Cancel'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () async {
                                                        // Handle setting goal weight
                                                        // _LogSingleCategory(context, recipe);
                                                        String removeSuffix(
                                                            String value) {
                                                          if (value.endsWith(
                                                                  'g') &&
                                                              value !=
                                                                  'Calories') {
                                                            return value
                                                                .substring(
                                                                    0,
                                                                    value.length -
                                                                        1);
                                                          }
                                                          return value;
                                                        }

                                                        try {
                                                          final response =
                                                              await http.get(
                                                                  Uri.parse(
                                                                      '${widget.baseUrl}/nutrition?query=${recipe.name}'));
                                                          if (response
                                                                  .statusCode ==
                                                              200) {
                                                            final List<dynamic>
                                                                dataList =
                                                                jsonDecode(
                                                                    response
                                                                        .body);

                                                            if (dataList
                                                                .isNotEmpty) {
                                                              print("HereText");

                                                              String
                                                                  nameofMeal =
                                                                  dataList[0]
                                                                      ['name'];
                                                              print(
                                                                  "HereText1");

                                                              String calories =
                                                                  dataList[0][
                                                                          'calories']
                                                                      .toString();
                                                              print(
                                                                  "HereText2");

                                                              String
                                                                  servingSizedb =
                                                                  removeSuffix(dataList[
                                                                              0]
                                                                          [
                                                                          'serving_size_g']
                                                                      .toString());
                                                              print(
                                                                  "HereText3");

                                                              String totalFat =
                                                                  removeSuffix(dataList[
                                                                              0]
                                                                          [
                                                                          'fat_total_g']
                                                                      .toString());
                                                              print(
                                                                  "HereText4");

                                                              String
                                                                  saturatedFat =
                                                                  removeSuffix(dataList[
                                                                              0]
                                                                          [
                                                                          'fat_saturated_g']
                                                                      .toString());
                                                              print(
                                                                  "HereText4");

                                                              String protein =
                                                                  removeSuffix(dataList[
                                                                              0]
                                                                          [
                                                                          'protein_g']
                                                                      .toString());
                                                              print(
                                                                  "HereText5");

                                                              String sodium =
                                                                  removeSuffix(dataList[
                                                                              0]
                                                                          [
                                                                          'sodium_mg']
                                                                      .toString());
                                                              ;
                                                              print(
                                                                  "HereText6");

                                                              String potassium =
                                                                  removeSuffix(dataList[
                                                                              0]
                                                                          [
                                                                          'potassium_mg']
                                                                      .toString());
                                                              print(
                                                                  "HereText7");

                                                              String
                                                                  cholesterol =
                                                                  removeSuffix(dataList[
                                                                              0]
                                                                          [
                                                                          'cholesterol_mg']
                                                                      .toString());
                                                              print(
                                                                  "HereText8");

                                                              String
                                                                  totalCarbohydrates =
                                                                  removeSuffix(dataList[
                                                                              0]
                                                                          [
                                                                          'carbohydrates_total_g']
                                                                      .toString());
                                                              print(
                                                                  "HereText9");

                                                              String fiber =
                                                                  removeSuffix(dataList[
                                                                              0]
                                                                          [
                                                                          'fiber_g']
                                                                      .toString());
                                                              print(
                                                                  "HereText10");

                                                              String sugar =
                                                                  removeSuffix(dataList[
                                                                              0]
                                                                          [
                                                                          'sugar_g']
                                                                      .toString());
                                                              print(
                                                                  "HereText11");
                                                              // You can use the servingSize here
                                                              if (int.tryParse(
                                                                      servingSize) !=
                                                                  null) {
                                                                print(
                                                                    'Serving Size: $servingSize');

                                                                // Calculate the adjustment ratio based on the original size
                                                                double adjustmentRatio = int
                                                                        .parse(
                                                                            servingSize) /
                                                                    double.parse(
                                                                        servingSizedb);

                                                                // Calculate adjusted values
                                                                int adjustedCalories =
                                                                    (double.parse(calories) *
                                                                            adjustmentRatio)
                                                                        .round();
                                                                String
                                                                    adjustedTotFat =
                                                                    (double.parse(totalFat) *
                                                                            adjustmentRatio)
                                                                        .toStringAsFixed(
                                                                            2);
                                                                String
                                                                    adjustedSatFat =
                                                                    (double.parse(saturatedFat) *
                                                                            adjustmentRatio)
                                                                        .toStringAsFixed(
                                                                            2);
                                                                String
                                                                    adjustedProtein =
                                                                    (double.parse(protein) *
                                                                            adjustmentRatio)
                                                                        .toStringAsFixed(
                                                                            2);
                                                                String
                                                                    adjustedSodium =
                                                                    (double.parse(sodium) *
                                                                            adjustmentRatio)
                                                                        .toStringAsFixed(
                                                                            2);
                                                                String
                                                                    adjustedPotassium =
                                                                    (double.parse(potassium) *
                                                                            adjustmentRatio)
                                                                        .toStringAsFixed(
                                                                            2);
                                                                String
                                                                    adjustedCholesterol =
                                                                    (double.parse(cholesterol) *
                                                                            adjustmentRatio)
                                                                        .toStringAsFixed(
                                                                            2);
                                                                String
                                                                    adjustedCarbs =
                                                                    (double.parse(totalCarbohydrates) *
                                                                            adjustmentRatio)
                                                                        .toStringAsFixed(
                                                                            2);
                                                                String
                                                                    adjustedFiber =
                                                                    (double.parse(fiber) *
                                                                            adjustmentRatio)
                                                                        .toStringAsFixed(
                                                                            2);
                                                                String
                                                                    adjustedSugar =
                                                                    (double.parse(sugar) *
                                                                            adjustmentRatio)
                                                                        .toStringAsFixed(
                                                                            2);

                                                                // Check if mealName is 'Breakfast'
                                                                if (widget
                                                                        .mealName ==
                                                                    'Breakfast') {
                                                                  FoodItem
                                                                      newItem =
                                                                      FoodItem(
                                                                    mealName:
                                                                        nameofMeal,
                                                                    totCalories:
                                                                        adjustedCalories,
                                                                    size:
                                                                        servingSize,
                                                                    totFat:
                                                                        adjustedTotFat,
                                                                    satFat:
                                                                        adjustedSatFat,
                                                                    protein:
                                                                        adjustedProtein,
                                                                    sodium:
                                                                        adjustedSodium,
                                                                    potassium:
                                                                        adjustedPotassium,
                                                                    cholesterol:
                                                                        adjustedCholesterol,
                                                                    carbs:
                                                                        adjustedCarbs,
                                                                    fiber:
                                                                        adjustedFiber,
                                                                    sugar:
                                                                        adjustedSugar,
                                                                  );
                                                                  foodItemsBreakfast
                                                                      .add(
                                                                          newItem);
                                                                  await savedayofWeek();
                                                                } else if (widget
                                                                        .mealName ==
                                                                    'Lunch') {
                                                                  FoodItem
                                                                      newItem =
                                                                      FoodItem(
                                                                    mealName:
                                                                        nameofMeal,
                                                                    totCalories:
                                                                        adjustedCalories,
                                                                    size:
                                                                        servingSize,
                                                                    totFat:
                                                                        adjustedTotFat,
                                                                    satFat:
                                                                        adjustedSatFat,
                                                                    protein:
                                                                        adjustedProtein,
                                                                    sodium:
                                                                        adjustedSodium,
                                                                    potassium:
                                                                        adjustedPotassium,
                                                                    cholesterol:
                                                                        adjustedCholesterol,
                                                                    carbs:
                                                                        adjustedCarbs,
                                                                    fiber:
                                                                        adjustedFiber,
                                                                    sugar:
                                                                        adjustedSugar,
                                                                  );
                                                                  foodItemsLunch
                                                                      .add(
                                                                          newItem);
                                                                  await savedayofWeek();
                                                                } else if (widget
                                                                        .mealName ==
                                                                    'Dinner') {
                                                                  FoodItem
                                                                      newItem =
                                                                      FoodItem(
                                                                    mealName:
                                                                        nameofMeal,
                                                                    totCalories:
                                                                        adjustedCalories,
                                                                    size:
                                                                        servingSize,
                                                                    totFat:
                                                                        adjustedTotFat,
                                                                    satFat:
                                                                        adjustedSatFat,
                                                                    protein:
                                                                        adjustedProtein,
                                                                    sodium:
                                                                        adjustedSodium,
                                                                    potassium:
                                                                        adjustedPotassium,
                                                                    cholesterol:
                                                                        adjustedCholesterol,
                                                                    carbs:
                                                                        adjustedCarbs,
                                                                    fiber:
                                                                        adjustedFiber,
                                                                    sugar:
                                                                        adjustedSugar,
                                                                  );
                                                                  foodItemsDinner
                                                                      .add(
                                                                          newItem);
                                                                  await savedayofWeek();
                                                                } else if (widget
                                                                        .mealName ==
                                                                    'Snack') {
                                                                  FoodItem
                                                                      newItem =
                                                                      FoodItem(
                                                                    mealName:
                                                                        nameofMeal,
                                                                    totCalories:
                                                                        adjustedCalories,
                                                                    size:
                                                                        servingSize,
                                                                    totFat:
                                                                        adjustedTotFat,
                                                                    satFat:
                                                                        adjustedSatFat,
                                                                    protein:
                                                                        adjustedProtein,
                                                                    sodium:
                                                                        adjustedSodium,
                                                                    potassium:
                                                                        adjustedPotassium,
                                                                    cholesterol:
                                                                        adjustedCholesterol,
                                                                    carbs:
                                                                        adjustedCarbs,
                                                                    fiber:
                                                                        adjustedFiber,
                                                                    sugar:
                                                                        adjustedSugar,
                                                                  );
                                                                  foodItemsSnack
                                                                      .add(
                                                                          newItem);
                                                                  await savedayofWeek();
                                                                }
                                                                // Print adjusted values for debugging
                                                                print(
                                                                    'Adjusted Calories: $adjustedCalories');
                                                                print(
                                                                    'Adjusted TotFat: $adjustedTotFat');
                                                                print(
                                                                    'Adjusted SatFat: $adjustedSatFat');
                                                                print(
                                                                    'Adjusted Protein: $adjustedProtein');
                                                                print(
                                                                    'Adjusted Sodium: $adjustedSodium');
                                                                print(
                                                                    'Adjusted Potassium: $adjustedPotassium');
                                                                print(
                                                                    'Adjusted Cholesterol: $adjustedCholesterol');
                                                                print(
                                                                    'Adjusted Carbs: $adjustedCarbs');
                                                                print(
                                                                    'Adjusted Fiber: $adjustedFiber');
                                                                print(
                                                                    'Adjusted Sugar: $adjustedSugar');

                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                                Navigator
                                                                    .pushReplacement(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            WeeklyTemfooddairy(
                                                                      baseUrl:
                                                                          widget
                                                                              .baseUrl,
                                                                      name: widget
                                                                          .name,
                                                                      TraineeEmail:
                                                                          widget
                                                                              .TraineeEmail,
                                                                      CoachEmail:
                                                                          widget
                                                                              .CoachEmail,
                                                                      selectedDateDisplay:
                                                                          GLOBALselectedDate,
                                                                    ),
                                                                  ),
                                                                );
                                                              } else {
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                  SnackBar(
                                                                    content: Text(
                                                                        'Invalid input. Please enter a valid integer.'),
                                                                  ),
                                                                );
                                                              }
                                                            } else {
                                                              print(
                                                                  'No data found');
                                                            }
                                                          } else {
                                                            print(
                                                                'Error: ${response.statusCode}');
                                                          }
                                                        } catch (error) {
                                                          print(
                                                              'Error: $error');
                                                        }
                                                        //   Navigator.of(context).pop();
                                                      },
                                                      child: Text('Set'),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                            // Add to cart functionality
                                            // setState(() {
                                            //   cartItems.add(recipe);
                                            // });
                                            // _addToCart(context, recipe);
                                          },
                                          child: Text('Log Food'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showDescriptionDialog(BuildContext context, Recipe recipe) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.rightSlide,
      width: 500,
      body: Container(
        height: 400, // Set your desired height here
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(" " + recipe.name,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              Text(recipe.description),
            ],
          ),
        ),
      ),
      btnCancelText: 'Close',
      btnCancelOnPress: () {},
    )..show();
  }

  void _getCalories(BuildContext context, Recipe recipe) async {
    try {
      final response = await http
          .get(Uri.parse('${widget.baseUrl}/nutrition?query=${recipe.name}'));
      if (response.statusCode == 200) {
        final List<dynamic> dataList = jsonDecode(response.body);
        if (dataList.isNotEmpty) {
          final List<Widget> nutritionalInfoWidgets = dataList.map((data) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: ${data['name']}'),
                Text('Calories: ${data['calories']}'),
                Text('Serving Size: ${data['serving_size_g']}g'),
                Text('Total Fat: ${data['fat_total_g']}g'),
                Text('Saturated Fat: ${data['fat_saturated_g']}g'),
                Text('Protein: ${data['protein_g']}g'),
                Text('Sodium: ${data['sodium_mg']}mg'),
                Text('Potassium: ${data['potassium_mg']}mg'),
                Text('Cholesterol: ${data['cholesterol_mg']}mg'),
                Text('Total Carbohydrates: ${data['carbohydrates_total_g']}g'),
                Text('Fiber: ${data['fiber_g']}g'),
                Text('Sugar: ${data['sugar_g']}g'),
                SizedBox(height: 20),
              ],
            );
          }).toList();

          AwesomeDialog(
            context: context,
            dialogType: DialogType.info,
            animType: AnimType.rightSlide,
            width: nutritionalInfoWidgets.length * 500.0,
            title: 'Nutrition Data',
            body: Container(
              height: 260,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: nutritionalInfoWidgets,
                ),
              ),
            ),
            btnCancelText: 'Close',
            btnCancelOnPress: () {},
          )..show();
        } else {
          print('No data found');
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  void _LogSingleCategory(BuildContext context, Recipe recipe) async {
    try {
      final response = await http
          .get(Uri.parse('${widget.baseUrl}/nutrition?query=${recipe.name}'));
      if (response.statusCode == 200) {
        final List<dynamic> dataList = jsonDecode(response.body);
        if (dataList.isNotEmpty) {
          final List<Widget> nutritionalInfoWidgets = dataList.map((data) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: ${data['name']}'),
                Text('Calories: ${data['calories']}'),
                Text('Serving Size: ${data['serving_size_g']}g'),
                Text('Total Fat: ${data['fat_total_g']}g'),
                Text('Saturated Fat: ${data['fat_saturated_g']}g'),
                Text('Protein: ${data['protein_g']}g'),
                Text('Sodium: ${data['sodium_mg']}mg'),
                Text('Potassium: ${data['potassium_mg']}mg'),
                Text('Cholesterol: ${data['cholesterol_mg']}mg'),
                Text('Total Carbohydrates: ${data['carbohydrates_total_g']}g'),
                Text('Fiber: ${data['fiber_g']}g'),
                Text('Sugar: ${data['sugar_g']}g'),
                SizedBox(height: 20),
              ],
            );
          }).toList();
        } else {
          print('No data found');
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }
}

//---------------------------------------------------------------------------------------------------------------
//For Custom - ALL display
class CustomFoodCategory extends StatefulWidget {
  final String baseUrl;
  final String name;
  final String email;

  const CustomFoodCategory({
    Key? key,
    required this.baseUrl,
    required this.name,
    required this.email,
  }) : super(key: key);

  @override
  State<CustomFoodCategory> createState() => _CustomFoodCategoryState();
}

class _CustomFoodCategoryState extends State<CustomFoodCategory> {
  TextEditingController mealNameController = TextEditingController();
  TextEditingController totalCaloriesController = TextEditingController();
  TextEditingController servingSizeController = TextEditingController();
  TextEditingController totalFatController = TextEditingController();
  TextEditingController saturatedFatController = TextEditingController();
  TextEditingController proteinController = TextEditingController();
  TextEditingController sodiumController = TextEditingController();
  TextEditingController potassiumController = TextEditingController();
  TextEditingController cholesterolController = TextEditingController();
  TextEditingController carbsController = TextEditingController();
  TextEditingController fiberController = TextEditingController();
  TextEditingController sugarController = TextEditingController();

  List<String> savedItems = [];

  Future<void> savecustomFood() async {
    try {
      var url = Uri.parse('${widget.baseUrl}/savecustomFood');
      var response = await http.post(
        url,
        body: jsonEncode({
          'email': widget.email,
          'mealName': mealNameController.text,
          'totCalories': totalCaloriesController.text,
          'size': servingSizeController.text,
          'totFat': totalFatController.text,
          'satFat': saturatedFatController.text,
          'protein': proteinController.text,
          'sodium': sodiumController.text,
          'potassium': potassiumController.text,
          'cholesterol': cholesterolController.text,
          'carbs': carbsController.text,
          'fiber': fiberController.text,
          'sugar': sugarController.text,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);

        Navigator.of(context).pop();
        setState(() {});
      } else {
        // Handle error
        print('Show photos failed: ${response.statusCode}');
        print(
            'Response body: ${response.body}'); // back here for  Response body: "User does not have any logged photos yet."
      }
    } catch (error) {
      // Handle error
      print('Error: $error');
    }
  }

  void _saveItem() {
    String mealName = mealNameController.text;
    String totalCalories = totalCaloriesController.text;
    String servingSize = servingSizeController.text;

    if (isStringOnly(mealName)) {
      if (isNumeric(totalCalories) && isNumeric(servingSize)) {
        double totalCaloriesDouble = double.parse(totalCalories);
        double servingSizeDouble = double.parse(servingSize);

        if (_checkOptionalFields()) {
          // Optional fields are either empty or numeric
          // savedItems.add('$mealName - $totalCaloriesDouble cal - $servingSizeDouble');

          // Assign '0' to optional fields if they are empty
          totalFatController.text =
              totalFatController.text.isEmpty ? '0' : totalFatController.text;
          saturatedFatController.text = saturatedFatController.text.isEmpty
              ? '0'
              : saturatedFatController.text;
          proteinController.text =
              proteinController.text.isEmpty ? '0' : proteinController.text;
          sodiumController.text =
              sodiumController.text.isEmpty ? '0' : sodiumController.text;
          potassiumController.text =
              potassiumController.text.isEmpty ? '0' : potassiumController.text;
          cholesterolController.text = cholesterolController.text.isEmpty
              ? '0'
              : cholesterolController.text;
          carbsController.text =
              carbsController.text.isEmpty ? '0' : carbsController.text;
          fiberController.text =
              fiberController.text.isEmpty ? '0' : fiberController.text;
          sugarController.text =
              sugarController.text.isEmpty ? '0' : sugarController.text;

          savecustomFood();

          mealNameController.clear();
          totalCaloriesController.clear();
          servingSizeController.clear();
          setState(() {});
        } else {
          // Show error message if optional fields are not numeric
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Invalid Input'),
                content:
                    Text('Optional fields must contain only numeric values.'),
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
      } else {
        // Show error message if required fields are not numeric
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Invalid Input'),
              content: Text(
                  'Total Calories and Serving Size must be numeric values.'),
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
    } else {
      // Show error message if meal name is not string
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Invalid Input'),
            content: Text('Meal Name must contain only alphabetic characters.'),
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
  }

  bool _checkOptionalFields() {
    List<TextEditingController> optionalControllers = [
      totalFatController,
      saturatedFatController,
      proteinController,
      sodiumController,
      potassiumController,
      cholesterolController,
      carbsController,
      fiberController,
      sugarController,
    ];

    for (TextEditingController controller in optionalControllers) {
      String value = controller.text;
      if (value.isNotEmpty && !isNumeric(value)) {
        return false; // Non-numeric value found
      }
    }
    return true; // All optional fields are empty or numeric
  }

// Function to check if a string contains only alphabetic characters
  bool isStringOnly(String? value) {
    if (value == null || value.isEmpty) {
      return false;
    }
    final RegExp alphaRegex = RegExp(r'^[a-zA-Z\s]+$');
    return alphaRegex.hasMatch(value);
  }

// Function to check if a string contains only numeric characters
  bool isNumeric(String? value) {
    if (value == null || value.isEmpty) {
      return false;
    }
    return double.tryParse(value) != null;
  }

  void _clearFields() {
    mealNameController.clear();
    totalCaloriesController.clear();
    servingSizeController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Custom Recipe',
          style:
              TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold),
        ),
        actions: [],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          iconSize: 40,
          color: Colors.blue[800],
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Text(
                'Required',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              buildTextField(mealNameController, 'Meal Name'),
              buildTextField(totalCaloriesController, 'Total Calories'),
              buildTextField(servingSizeController, 'Serving Size'),
              SizedBox(height: 8),
              SizedBox(height: 8),
              Text(
                'Optional',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              buildTextField(totalFatController, 'Total Fat'),
              buildTextField(saturatedFatController, 'Saturated Fat'),
              buildTextField(proteinController, 'Protein'),
              buildTextField(sodiumController, 'Sodium'),
              buildTextField(potassiumController, 'Potassium'),
              buildTextField(cholesterolController, 'Cholesterol'),
              buildTextField(carbsController, 'Carbs'),
              buildTextField(fiberController, 'Fiber'),
              buildTextField(sugarController, 'Sugar'),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _saveItem,
                    child: Text('Save'),
                  ),
                  ElevatedButton(
                    onPressed: _clearFields,
                    child: Text('Clear'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String labelText) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.grey, // Border color
              width: 2, // Border width
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.blue, // Border color when focused
              width: 2, // Border width when focused
            ),
          ),
        ),
      ),
    );
  }
}

class CustomSearchFood {
  final String mealName;
  final String totCalories;
  final String size;
  final String totFat;
  final String satFat;
  final String protein;
  final String sodium;
  final String potassium;
  final String cholesterol;
  final String carbs;
  final String fiber;
  final String sugar;

  CustomSearchFood({
    required this.mealName,
    required this.totCalories,
    required this.size,
    required this.totFat,
    required this.satFat,
    required this.protein,
    required this.sodium,
    required this.potassium,
    required this.cholesterol,
    required this.carbs,
    required this.fiber,
    required this.sugar,
  });
}

List<CustomSearchFood> Customsearchfood = [
  // CustomSearchFood(
  //   mealName: 'Spaghetti Carbonara',
  //   totCalories: '500',
  //   size: '200',
  //   totFat: '20',
  //   satFat: '10',
  //   protein: '25',
  //   sodium: '800',
  //   potassium: '400',
  //   cholesterol: '50',
  //   carbs: '60',
  //   fiber: '5',
  //   sugar: '8',
  // ),
  // CustomSearchFood(
  //   mealName: 'Grilled Salmon',
  //   totCalories: '400',
  //   size: '150',
  //   totFat: '15',
  //   satFat: '5',
  //   protein: '30',
  //   sodium: '600',
  //   potassium: '450',
  //   cholesterol: '40',
  //   carbs: '20',
  //   fiber: '3',
  //   sugar: '2',
  // ),
  // CustomSearchFood(
  //   mealName: 'Your Carbonara',
  //   totCalories: '500',
  //   size: '200',
  //   totFat: '20',
  //   satFat: '10',
  //   protein: '25',
  //   sodium: '800',
  //   potassium: '400',
  //   cholesterol: '50',
  //   carbs: '60',
  //   fiber: '5',
  //   sugar: '8',
  // ),
];


double getTotalCaloriesForAllMeals(List<FoodItem> breakfastItems, List<FoodItem> lunchItems, List<FoodItem> dinnerItems, List<FoodItem> snackItems) {
  double totalCalories = 0;
  

  // Calculate total calories for breakfast
  totalCalories += getTotalCalories(breakfastItems);

  // Calculate total calories for lunch
  totalCalories += getTotalCalories(lunchItems);

  // Calculate total calories for dinner
  totalCalories += getTotalCalories(dinnerItems);

  // Calculate total calories for snacks
  totalCalories += getTotalCalories(snackItems);

  return totalCalories;
}

// <<<<<<< bahaa
// =======
// void CalculatedWidgetCaloriesConcumption() {
//   FoodtotalCaloires = getTotalCaloriesForAllMeals(
//       foodItemsBreakfast, foodItemsLunch, foodItemsDinner, foodItemsSnack);
//   ExertotalCalories = getTotalCaloriesForExercies(ExerciseItems);
//   RemaningTotalCalories = (2550 - FoodtotalCaloires + ExertotalCalories);
//   RemaningTotalCalories < 0 ? 0 : RemaningTotalCalories;
// }
// // int totalCaloriesForAllMeals = getTotalCaloriesForAllMeals(foodItemsBreakfast, foodItemsLunch, foodItemsDinner, foodItemsSnack);
// // print('Total Calories for all meals: $totalCaloriesForAllMeals');
// >>>>>>> main

// End for Foodsearch Page -> For Categories display & For ALL display ..
//---------------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------------

// Start for Excersiesearch Page -> For Categories display & For ALL display ..

//For Custom - ALL display
class CustomExerciseCategory extends StatefulWidget {
  final String baseUrl;
  final String name;
  final String email;

  const CustomExerciseCategory({
    Key? key,
    required this.baseUrl,
    required this.name,
    required this.email,
  }) : super(key: key);

  @override
  State<CustomExerciseCategory> createState() => _CustomExerciseCategoryState();
}

class _CustomExerciseCategoryState extends State<CustomExerciseCategory> {
  TextEditingController ExerNameController = TextEditingController();
  TextEditingController totalCaloriesController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController discController = TextEditingController();

  List<String> savedItems = [];

  // ExerName: String,
  //       totCalories: String,
  //       time: String,
  //       disc: String,
  Future<void> savecustomExe() async {
    try {
      var url = Uri.parse('${widget.baseUrl}/savecustomExe');
      var response = await http.post(
        url,
        body: jsonEncode({
          'email': widget.email,
          'ExerName': ExerNameController.text,
          'totCalories': totalCaloriesController.text,
          'time': timeController.text,
          'disc': discController.text,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);

        Navigator.of(context).pop();
        setState(() {});
      } else {
        // Handle error
        print('Show photos failed: ${response.statusCode}');
        print(
            'Response body: ${response.body}'); // back here for  Response body: "User does not have any logged photos yet."
      }
    } catch (error) {
      // Handle error
      print('Error: $error');
    }
  }

  void _saveItem() {
    String mealName = ExerNameController.text;
    String totalCalories = totalCaloriesController.text;
    String timeExe = timeController.text;
    String discExe = discController.text;

    if (isStringOnly(mealName) && isStringOnly(discExe)) {
      if (isNumeric(totalCalories) && isNumeric(timeExe)) {
        double totalCaloriesDouble = double.parse(totalCalories);
        savecustomExe();
      } else {
        // Show error message if required fields are not numeric
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Invalid Input'),
              content: Text('Total Calories and Time must be numeric values.'),
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
    } else {
      // Show error message if meal name is not string
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Invalid Input'),
            content: Text(
                'Exercise  Name and description  must contain only alphabetic characters.'),
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
  }

// Function to check if a string contains only alphabetic characters
  bool isStringOnly(String? value) {
    if (value == null || value.isEmpty) {
      return false;
    }
    final RegExp alphaRegex = RegExp(r'^[a-zA-Z\s]+$');
    return alphaRegex.hasMatch(value);
  }

// Function to check if a string contains only numeric characters
  bool isNumeric(String? value) {
    if (value == null || value.isEmpty) {
      return false;
    }
    return double.tryParse(value) != null;
  }

  void _clearFields() {
    ExerNameController.clear();
    totalCaloriesController.clear();
    timeController.clear();
    discController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Custom Exercise',
          style:
              TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold),
        ),
        actions: [],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          iconSize: 40,
          color: Colors.blue[800],
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Text(
                'Required',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              buildTextField(ExerNameController, 'Exercise Name'),
              buildTextField(totalCaloriesController, 'Total Calories'),
              buildTextField(timeController, 'Duration'),
              buildTextAreaCustom(discController, 'description'),
              SizedBox(height: 8),
              SizedBox(height: 8),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _saveItem,
                    child: Text('Save'),
                  ),
                  ElevatedButton(
                    onPressed: _clearFields,
                    child: Text('Clear'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String labelText) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.grey, // Border color
              width: 2, // Border width
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.blue, // Border color when focused
              width: 2, // Border width when focused
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextAreaCustom(
      TextEditingController controller, String labelText) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        maxLines: null, // Allows multiple lines
        keyboardType: TextInputType.multiline,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.grey, // Border color
              width: 2, // Border width
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.blue, // Border color when focused
              width: 2, // Border width when focused
            ),
          ),
        ),
      ),
    );
  }
}

class CustomSearchExercise {
  final String ExerName;
  final String totCalories;
  final String time;
  final String disc;

  CustomSearchExercise({
    required this.ExerName,
    required this.totCalories,
    required this.time,
    required this.disc,
  });
}

List<CustomSearchExercise> Customsearchexercise = [
  // CustomSearchExercise(
  //   ExerName: 'Jumping Jacks',
  //   totCalories: '500',
  //   time: '100',
  //   disc: 'up and down , right and left',
  // ),
  // CustomSearchExercise(
  //   ExerName: 'Jumping Pums',
  //   totCalories: '500',
  //   time: '20',
  //   disc: 'up and down',
  // ),
  // CustomSearchExercise(
  //   ExerName: 'Lifting Hand',
  //   totCalories: '500',
  //   time: '10',
  //   disc: 'Lifiting Items by weight',
  // ),
];

//-------------------------------------
class SingleExerciseListPage extends StatefulWidget {
  final String category;
  final String baseUrl;

  final String TraineeEmail;
  final String CoachEmail;
  final String name;

  SingleExerciseListPage(
      {Key? key,
      required this.baseUrl,
      required this.category,
      required this.TraineeEmail,
      required this.CoachEmail,
      required this.name})
      : super(key: key);

  @override
  _SingleExerciseListPageState createState() => _SingleExerciseListPageState();
}

class _SingleExerciseListPageState extends State<SingleExerciseListPage> {
  List<Exercise> exercises = []; // Holds Exercise objects
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchExercises();
  }

  Future<void> fetchExercises() async {
    try {
      final response = await http.get(
          Uri.parse('${widget.baseUrl}/exercisesmobile/${widget.category}'));
      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);

        final exerciseList = decodedData['exercises'] as List;
        setState(() {
          exercises = exerciseList
              .map((exerciseData) => Exercise.fromJson(exerciseData))
              .toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load exercises');
      }
    } catch (error) {
      print('Error fetching exercises: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  //savedayofWeek()
  Future<void> savedayofWeek() async {
    try {
      var url = Uri.parse('${widget.baseUrl}/savedayofWeek');
      var response = await http.post(
        url,
        body: jsonEncode({
          'coachemail': widget.CoachEmail,
          'traineeEmail': widget.TraineeEmail,
          'weekdate': globals.GLOBALWEEKLYselectedDate,
          'dayLogs': [
            {
              'todaydate': DateFormat('yyyy-MM-dd')
                  .format(GLOBALselectedDate)
                  .toString(), // Date of the diary entry
              'mealsExe': {
                'breakfast':
                    foodItemsBreakfast.map((item) => item.toJson()).toList(),
                'lunch': foodItemsLunch.map((item) => item.toJson()).toList(),
                'dinner': foodItemsDinner.map((item) => item.toJson()).toList(),
                'snack': foodItemsSnack.map((item) => item.toJson()).toList(),
              },
              'exerc': ExerciseItems.map((item) => item.toJson()).toList(),
              'noteCont': globalNote
            }
          ]
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);

        setState(() {
          print("Response 200 ok from savedayofWeek");
        });
      } else {
        // Handle error
        print('Saved dayweek diary food failed: ${response.statusCode}');
        print(
            'Response body: ${response.body}'); // back here for  Response body: "User does not have any logged photos yet."
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
        title: Text(
          'Exercises - ${widget.category}',
          style:
              TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[800]),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          iconSize: 40,
          color: Colors.blue[800],
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : exercises.isEmpty
              ? Center(child: Text('No exercises found'))
              : ListView.builder(
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = exercises[index];
                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Card(
                        elevation: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.network(
                              exercise.imageUrl!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.fill,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          // Add functionality here
                                          AwesomeDialog(
                                            context: context,
                                            dialogType: DialogType.info,
                                            animType: AnimType.rightSlide,
                                            // width: nutritionalInfoWidgets.length * 500.0,
                                            title: 'Exercise Details',
                                            desc: "Name Exercise: " +
                                                exercise.name +
                                                "\n" +
                                                "Time: " +
                                                exercise.time +
                                                "\n" +
                                                "Calories: " +
                                                exercise.calories +
                                                "\n" +
                                                "Description: " +
                                                exercise.description,
                                            descTextStyle:
                                                TextStyle(fontSize: 18),
                                            btnCancelText: 'Close',
                                            btnCancelOnPress: () {},
                                          )..show();
                                        },
                                        child: Text(
                                          "Details",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue[800],
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          // Add functionality here
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              String ExerciseTime = '';
                                              return AlertDialog(
                                                title:
                                                    Text('Enter Exercise Time'),
                                                content: TextField(
                                                  onChanged: (value) {
                                                    ExerciseTime = value;
                                                  },
                                                  keyboardType:
                                                      TextInputType.number,
                                                  decoration: InputDecoration(
                                                    labelText:
                                                        'Exercise Time (m)',
                                                  ),
                                                ),
                                                actions: <Widget>[
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () async {
                                                      // Handle setting goal weight

                                                      if (int.tryParse(
                                                              ExerciseTime) !=
                                                          null) {
                                                        print(
                                                            'Exercise Time: $ExerciseTime');

                                                        String timeNumber =
                                                            extractNumberFromString(
                                                                exercise.time);
                                                        String CaloriesNumber =
                                                            extractNumberFromString(
                                                                exercise
                                                                    .calories);

                                                        print(timeNumber);
                                                        print(CaloriesNumber);

                                                        // Calculate the adjustment ratio based on the original size
                                                        double adjustmentRatio =
                                                            int.parse(
                                                                    ExerciseTime) /
                                                                double.parse(
                                                                    timeNumber);

                                                        // // Calculate adjusted values
                                                        int adjustedCaloriesNumber =
                                                            (double.parse(
                                                                        CaloriesNumber) *
                                                                    adjustmentRatio)
                                                                .round();
                                                        String
                                                            adjustedtimeNumber =
                                                            (double.parse(
                                                                        timeNumber) *
                                                                    adjustmentRatio)
                                                                .toStringAsFixed(
                                                                    2);

                                                        // // Print adjusted values for debugging
                                                        print(
                                                            'Adjusted CaloriesNumber: $adjustedCaloriesNumber');
                                                        print(
                                                            'Adjusted timeNumber: $adjustedtimeNumber');
                                                        print(
                                                            'Adjusted name: ${exercise.name}');
                                                        print(
                                                            'Adjusted desc: ${exercise.description}');

                                                        ExerciseItem newItem =
                                                            ExerciseItem(
                                                          ExerName:
                                                              exercise.name,
                                                          totCalories:
                                                              adjustedCaloriesNumber,
                                                          time:
                                                              adjustedtimeNumber,
                                                          disc: exercise
                                                              .description,
                                                        );
                                                        ExerciseItems.add(
                                                            newItem);
                                                        await savedayofWeek();

                                                        Navigator.of(context)
                                                            .pop();
                                                        Navigator
                                                            .pushReplacement(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                WeeklyTemfooddairy(
                                                              baseUrl: widget
                                                                  .baseUrl,
                                                              name: widget.name,
                                                              TraineeEmail: widget
                                                                  .TraineeEmail,
                                                              CoachEmail: widget
                                                                  .CoachEmail,
                                                              selectedDateDisplay:
                                                                  GLOBALselectedDate,
                                                            ),
                                                          ),
                                                        );
                                                      } else {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                                'Invalid input. Please enter a valid integer.'),
                                                          ),
                                                        );
                                                      }

                                                      //   Navigator.of(context).pop();
                                                    },
                                                    child: Text('Set'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        child: Text(
                                          "Log Exercise",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue[800],
                                            fontSize: 18,
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
                    );
                  },
                ),
    );
  }
}

class Exercise {
  final String id;
  final String name; // Assuming 'name' is present in the response
  final String? imageUrl; // Handle cases where imageUrl may be absent
  final String description; // Handle cases where description may be absent
  final String time;
  final String calories;

  Exercise.fromJson(Map<String, dynamic> json)
      : id = json['_id'],
        name = json['name'] ?? 'Exercise ${json['id']}', // Default name
        imageUrl = json['image'],
        description = json['description'],
        time = json['time'],
        calories = json['calories'];
}

String extractNumberFromString(String text) {
  // Define a regular expression to match digits
  RegExp regex = RegExp(r'\d+');

  // Find the first match in the text
  RegExpMatch? match = regex.firstMatch(text);

  // If a match is found, return the matched substring (which contains only numbers)
  if (match != null) {
    return match
        .group(0)!; // Use null assertion operator (!) to ensure non-null
  }

  // If no match is found, return an empty string
  return '';
}

// End for Excersiesearch Page -> For Categories display & For ALL display ..
//---------------------------------------------------------------------------------------------------------------
