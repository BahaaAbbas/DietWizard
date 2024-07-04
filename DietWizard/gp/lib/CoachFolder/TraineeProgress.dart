import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:gp/BottomNav.dart';
import 'package:gp/CoachFolder/CoachTrainnee.dart';
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

double FoodtotalCaloires=0;
double ExertotalCalories=0;
double RemaningTotalCalories=0;
String GoalStringShow='';

DateTime maxdateTimeBACK = DateTime.now();
DateTime GLOBALselectedDate = DateTime.now();

// Global variable to store the note content
String globalNote = '';


class TraineeProgress extends StatefulWidget {
  final String baseUrl;
  final String name;
  final String email;

  const TraineeProgress({
    Key? key,
    required this.baseUrl,
    required this.name,
    required this.email,
  }) : super(key: key);

  @override
  State<TraineeProgress> createState() => _TraineeProgressState();
}

class _TraineeProgressState extends State<TraineeProgress> {
 static late DateTime selectedDate;
 bool isLoadingHist = true;

  @override
  void initState() {
    super.initState();

LASTDAYBACKHistorical();
 TDEEInfoHistorical();

    selectedDate =
        DateTime.now(); // Set the default selected date to current date
        GLOBALselectedDate = selectedDate;
   

 showDiaryinfo();
  CalculatedWidgetCaloriesConcumption(); 
 

  }


void _selectDate(BuildContext context) async {
  
    // final DateTime? picked = await showDatePicker(
    //   context: context,
    //   initialDate: selectedDate,
    //   firstDate: DateTime(2000),
    //   lastDate: DateTime(2101),
    // );
    // if (picked != null && picked != selectedDate) {
    //   setState(() {
    //     selectedDate = picked;
    //      GLOBALselectedDate = selectedDate;
    //      showDiaryinfo();
    //   });

    // }
         final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      if (maxdateTimeBACK != null && picked.isBefore(maxdateTimeBACK!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("No Info to go beyond your Trainne's Starting date!"),
          ),
        );
      } else {
        setState(() {
          selectedDate = picked;
          GLOBALselectedDate = selectedDate;
          showDiaryinfo();
             TDEEInfoHistorical();
            CalculatedWidgetCaloriesConcumption(); 

        });
      }
    }
  
}

void _changeDate(bool isNext) {

    // setState(() {
    //   selectedDate = isNext
    //       ? selectedDate.add(Duration(days: 1))
    //       : selectedDate.subtract(Duration(days: 1));

    //        GLOBALselectedDate = selectedDate;
    //          showDiaryinfo();
    // });
  
  
   setState(() {
      DateTime newDate = isNext
          ? selectedDate.add(Duration(days: 1))
          : selectedDate.subtract(Duration(days: 1));

      if (maxdateTimeBACK != null && newDate.isBefore(maxdateTimeBACK!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("You can't go beyond your starting date!"),
          ),
        );
      } else {
        selectedDate = newDate;
        GLOBALselectedDate = selectedDate;
        showDiaryinfo();
             TDEEInfoHistorical();
      }
    });


}

  //LASTDAYBACKHistorical()
   Future<void> LASTDAYBACKHistorical() async {
    
    try {
      var url = Uri.parse('${widget.baseUrl}/LASTDAYBACKHistorical');
      var response = await http.post(
        url,
        body: jsonEncode({
          'email': widget.email,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);

        setState(() {
  
          maxdateTimeBACK = DateTime.parse(responseData['maxBackDate']);
            
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

   //TDEEInfoHistorical()
   Future<void> TDEEInfoHistorical() async {
    
    try {
      var url = Uri.parse('${widget.baseUrl}/TDEEInfoHistorical');
      var response = await http.post(
        url,
        body: jsonEncode({
          'email': widget.email,
          'date':  DateFormat('yyyy-MM-dd').format(selectedDate).toString(),  // Date of the diary entry
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);

        setState(() {
  
          GoalStringShow = responseData['afterTDEE'];
             // isLoadingHist = false; // Update loading state
                 CalculatedWidgetCaloriesConcumption();

        });
      } else {
        // Handle error
         isLoadingHist = false; // Update loading state
        print('Saved diary food failed: ${response.statusCode}');
        print(
            'Response body: ${response.body}'); // back here for  Response body: "User does not have any logged photos yet."
      }
    } catch (error) {
      // Handle error
      print('Error: $error');
       isLoadingHist = false; // Update loading state
    }
  }



 //showDiaryinfo()
 Future<void> showDiaryinfo() async {
    try {
      var url = Uri.parse('${widget.baseUrl}/showDiaryinfo');
      var response = await http.post(
        url,
        body: jsonEncode({
          'email': widget.email,
            'daydate': [   
                {
                  'todaydate':  DateFormat('yyyy-MM-dd').format(selectedDate).toString(),  // Date of the diary entry 
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
    
    TDEEInfoHistorical();
     CalculatedWidgetCaloriesConcumption(); 

  });

}else {
        // Handle error
          // Clearing the existing lists before updating them with new data
          if(response.statusCode == 400){
            setState(() {
            foodItemsBreakfast.clear();
              foodItemsLunch.clear();
              foodItemsDinner.clear();
              foodItemsSnack.clear();
              ExerciseItems.clear();
               CalculatedWidgetCaloriesConcumption(); 
              print("Should clear , sorry");
                  
                      });

          }
  
        print('Show diary food failed: ${response.statusCode}');
        print(
            'Response body: ${response.body}'); // back here for  Response body: "User does not have any logged photos yet."
      }
    } catch (error) {
      // Handle error
      print('Error: $error');
    }
  }


    //saveDiaryinfo()
   Future<void> saveDiaryinfo() async {
    try {
      var url = Uri.parse('${widget.baseUrl}/saveDiaryinfo');
      var response = await http.post(
        url,
        body: jsonEncode({
          'email': widget.email,
            'daydate': [   
                {
                  'todaydate':  DateFormat('yyyy-MM-dd').format(selectedDate).toString(),  // Date of the diary entry
                  'mealsExe': {
                    'breakfast': foodItemsBreakfast.map((item) => item.toJson()).toList(),
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
  CalculatedWidgetCaloriesConcumption();
 
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

  @override
  Widget build(BuildContext context) {
     return isLoadingHist?  Center(child: CircularProgressIndicator()) // Show a loading spinner 
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
            SizedBox(width: 35),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Trainee\'s Diary ',
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
                            builder: (context) => coachTrainee(
                              baseUrl: widget.baseUrl,
                              name: widget.name,
                              //email: widget.email,
                              email: globals.LoggedInUSEREmail,
                             
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () => _changeDate(false),
                  ),
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[200],
                      ),
                      child: Text(
                        DateFormat('yyyy-MM-dd')
                            .format(selectedDate), // Display the selected date
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_forward),
                    onPressed: () => _changeDate(true),
                  ),
                ],
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
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Goal',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(width: 20), // Add spacing between columns
                      Text(
                        '-',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 20), // Add spacing between columns
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${FoodtotalCaloires}',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Food',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(width: 20), // Add spacing between columns
                      Text(
                        '+',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 20), // Add spacing between columns
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${ExertotalCalories}',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Exercise',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(width: 20), // Add spacing between columns
                      Text(
                        '=',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 20), // Add spacing between columns
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${RemaningTotalCalories}',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Remaining',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
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

            NoteWidget(baseUrl: widget.baseUrl,name: widget.name,email: widget.email,),
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
                              builder: (context) => dailySummaryTrainees(
                                baseUrl: widget.baseUrl,
                                name: widget.name,
                                email: widget.email,
                                TraineeDate: selectedDate,
                              ),
                            ),
                          );
                       
                      },

                      style: ElevatedButton.styleFrom(
                        side: BorderSide(color: Colors.blue, width: 2),
                        padding:
                            EdgeInsets.symmetric(horizontal: 55, vertical: 5),
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
             
                      ],
                    ),
                    SizedBox(height: 7),
                    Divider(), // Add a divider after each food item
                  ],
                );
              },
            ),
            SizedBox(height: 10),
   
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
                 
                      ],
                    ),
                    SizedBox(height: 7),
                    Divider(), // Add a divider after each food item
                  ],
                );
              },
            ),
            SizedBox(height: 10),
         
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
                   
                      ],
                    ),
                    SizedBox(height: 7),
                    Divider(), // Add a divider after each food item
                  ],
                );
              },
            ),
            SizedBox(height: 10),
    
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
                       
                      ],
                    ),
                    SizedBox(height: 7),
                    Divider(), // Add a divider after each food item
                  ],
                );
              },
            ),
            SizedBox(height: 10),
     
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
                         
                      ],
                    ),
                    SizedBox(height: 7),
                    Divider(), // Add a divider after each AddExercise item
                  ],
                );
              },
            ),
            SizedBox(height: 10),
       
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
                              

                                      isLoadingHist = false; // Update loading state

                                    });
                            
                            
}

} //end of fooddiary class

class FoodItem {

   final String     mealName;
    final int    totCalories;
   final String     size;
    final String    totFat;
     final String   satFat;
     final String   protein;
     final String   sodium;
     final String   potassium;
     final String   cholesterol;
    final String    carbs;
    final String    fiber;
    final String    sugar;
  


  FoodItem({
    required this.mealName, required this.totCalories, required this.size,
    required this.totFat, required this.satFat, required this.protein,
    required this.sodium, required this.potassium, required this.cholesterol,
    required this.carbs, required this.fiber, required this.sugar,
  
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

   final String     ExerName;
    final int    totCalories;
   final String     time;
    final String    disc;
   

  ExerciseItem(
      {required this.ExerName, required this.totCalories, required this.time,required this.disc});

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
  final String email;

  const NoteWidget({
    Key? key,
    required this.baseUrl,
    required this.name,
    required this.email,
  }) : super(key: key);



  @override
  _NoteWidgetState createState() => _NoteWidgetState();
}

class _NoteWidgetState extends State<NoteWidget> {
  TextEditingController _noteController = TextEditingController();


 //saveDiaryinfo()
   Future<void> saveDiaryinfo() async {
    try {
      var url = Uri.parse('${widget.baseUrl}/saveDiaryinfo');
      var response = await http.post(
        url,
        body: jsonEncode({
          'email': widget.email,
            'daydate': [   
                {
                  'todaydate':  DateFormat('yyyy-MM-dd').format(GLOBALselectedDate).toString(),  // Date of the diary entry
                  'mealsExe': {
                    'breakfast': foodItemsBreakfast.map((item) => item.toJson()).toList(),
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

    foodItemsBreakfast.clear();
    foodItemsLunch.clear();
    foodItemsDinner.clear();
    foodItemsSnack.clear();
    ExerciseItems.clear();


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





  void _saveNote() async{
    // Function to save the note
      globalNote = _noteController.text; // Update global variable
     await saveDiaryinfo();

   
     Navigator.of(context).pop(); // Close the pop-up dialog
    //   setState(() {
    //   //globalNote = _noteController.text; // Update global variable
        
    // });
         Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TraineeProgress(
                      baseUrl: widget.baseUrl,
                      name: widget.name,
                      email: widget.email,
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
    await saveDiaryinfo();
  

  // // Function to clear the note
  setState(() {
   
     _noteController.clear(); // Clear the text field
    globalNote = ''; // Clear the global note content

  });
   Navigator.of(context).pop(); // Close the pop-up dialog
     Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TraineeProgress(
                      baseUrl: widget.baseUrl,
                      name: widget.name,
                      email: widget.email,
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
        color: Color.fromARGB(255, 240, 236, 236), // Color the container in grey
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
   
        ],
      ),
    );
  }
}

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






//-----------------------------------------------------------------------------------------------------------------



  int totalCaloriesBreakfast = 0;
  int totalCaloriesLunch = 0;
  int totalCaloriesDinner = 0;
  int totalCaloriesSnack = 0;
  int totalCaloriesOVERALL = 0;
  int totalCaloriesGOALS = 0;
  String totalCaloriesUNIT = '';

  double percentageCaloriesBreakfast = 0.00;
  double percentageCaloriesLunch = 0.00;
  double percentageCaloriesDinner = 0.00;
  double percentageCaloriesSnack = 0.00;
//----------------------------------------------
// Define parameters for Total, Goal, Left, and Unit for each nutrient
String TotalTotFat = '0';
String GoalTotFat = '0';
String LeftTotFat = '0';
String totFatUNIT = '';

String TotalSatFat = '0';
String GoalSatFat = '0';
String LeftSatFat = '0';
String satFatUNIT = '';

String TotalProtein = '0';
String GoalProtein = '0';
String LeftProtein = '0';
String proteinUNIT = '';

String TotalSodium = '0';
String GoalSodium = '0';
String LeftSodium = '0';
String sodiumUNIT = '';

String TotalPotassium = '0';
String GoalPotassium = '0';
String LeftPotassium = '0';
String potassiumUNIT = '';

String TotalCholesterol = '0';
String GoalCholesterol = '0';
String LeftCholesterol = '0';
String cholesterolUNIT = '';

String TotalCarbs = '0';
String GoalCarbs = '0';
String LeftCarbs = '0';
String carbsUNIT = '';

String TotalFiber = '0';
String GoalFiber = '0';
String LeftFiber = '0';
String fiberUNIT = '';

String TotalSugar = '0';
String GoalSugar = '0';
String LeftSugar = '0';
String sugarUNIT = '';



// Define percentage variables
double percentageTotFat = 0.0;
double percentageSatFat = 0.0;
double percentageProtein = 0.0;
double percentageSodium = 0.0;
double percentagePotassium = 0.0;
double percentageCholesterol = 0.0;
double percentageCarbs = 0.0;
double percentageFiber = 0.0;
double percentageSugar = 0.0;
//----------------------------------------------

// Define parameters

double totalgivenNuteBreakfast = 0.0;
double totalgivenNuteLunch = 0.0;
double totalgivenNuteDinner = 0.0;
double totalgivenNutesnack = 0.0;
double totalgivenNuteOVERALL = 0.0;
double totalgivenNuteGOALS = 0.0;
String totalgivenNuteUNIT = '';

// Define percentage variables
double percentageBreakfast = 0.0;
double percentageLunch = 0.0;
double percentageDinner = 0.0;
double percentageSnack = 0.0;

//----------------------------------------
String GlobalMealNameForMacros = '';

class dailySummaryTrainees extends StatefulWidget {
  final String baseUrl;
  final String name;
  final String email;
  final DateTime TraineeDate;

  const dailySummaryTrainees({
    Key? key,
    required this.baseUrl,
    required this.name,
    required this.email,
    required this.TraineeDate,
  }) : super(key: key);

  @override
  State<dailySummaryTrainees> createState() => _dailySummaryTraineesState();
}

class _dailySummaryTraineesState extends State<dailySummaryTrainees> {
  late DateTime selectedDate;
  bool _isAllSelected = true; // Track if "All" is selected




 //CalTotCaloriesDiaryinfo()
 Future<void> CalTotCaloriesDiaryinfo() async {
    try {
      var url = Uri.parse('${widget.baseUrl}/CalTotCaloriesDiaryinfo');
      var response = await http.post(
        url,
        body: jsonEncode({
          'email': widget.email,
            'daydate': [   
                {
                  'todaydate':  DateFormat('yyyy-MM-dd').format(selectedDate).toString(),  // Date of the diary entry 
                }
              ]
        }),
        headers: {'Content-Type': 'application/json'},
      );

        if (response.statusCode == 200) {
          print("Hello1");
          var responseData = json.decode(response.body);

          // Updating state with the new data
       setState(() {
 percentageCaloriesBreakfast = 0.00;
percentageCaloriesLunch = 0.00;
 percentageCaloriesDinner = 0.00;
 percentageCaloriesSnack = 0.00;

  totalCaloriesBreakfast = (responseData['totalCaloriesBreakfast'] ?? 0).toInt();
  totalCaloriesLunch = (responseData['totalCaloriesLunch'] ?? 0).toInt();
  totalCaloriesDinner = (responseData['totalCaloriesDinner'] ?? 0).toInt();
  totalCaloriesSnack = (responseData['totalCaloriesSnack'] ?? 0).toInt();
  totalCaloriesOVERALL = (responseData['totalCaloriesOVERALL'] ?? 0).toInt();
  totalCaloriesGOALS = (responseData['totalCaloriesGOALS'] ?? 0).toInt();
  totalCaloriesUNIT = responseData['totalCaloriesUNIT'] ?? '';

  if (totalCaloriesOVERALL != 0) {
    percentageCaloriesBreakfast = (totalCaloriesBreakfast / totalCaloriesOVERALL) * 100;
    percentageCaloriesLunch = (totalCaloriesLunch / totalCaloriesOVERALL) * 100;
    percentageCaloriesDinner = (totalCaloriesDinner / totalCaloriesOVERALL) * 100;
    percentageCaloriesSnack = (totalCaloriesSnack / totalCaloriesOVERALL) * 100;
  }

  // Optionally, you can round the percentages to two decimal places
  percentageCaloriesBreakfast = double.parse(percentageCaloriesBreakfast.toStringAsFixed(2));
  percentageCaloriesLunch = double.parse(percentageCaloriesLunch.toStringAsFixed(2));
  percentageCaloriesDinner = double.parse(percentageCaloriesDinner.toStringAsFixed(2));
  percentageCaloriesSnack = double.parse(percentageCaloriesSnack.toStringAsFixed(2));

  // Print statements for debugging
  // print('Total Calories Breakfast: $totalCaloriesBreakfast');
  // print('Total Calories Lunch: $totalCaloriesLunch');
  // print('Total Calories Dinner: $totalCaloriesDinner');
  // print('Total Calories Snack: $totalCaloriesSnack');
  // print('Total Calories Overall: $totalCaloriesOVERALL');
  // print('Total Calories Goals: $totalCaloriesGOALS');
  // print('Total Calories Unit: $totalCaloriesUNIT');
  // print('Percentage Calories Breakfast: $percentageCaloriesBreakfast');
  // print('Percentage Calories Lunch: $percentageCaloriesLunch');
  // print('Percentage Calories Dinner: $percentageCaloriesDinner');
  // print('Percentage Calories Snack: $percentageCaloriesSnack');
});

        }else {
        // Handle error
        print('Show Calories Summary Food  failed: ${response.statusCode}');
        print(
            'Response body: ${response.body}'); // back here for  Response body: "User does not have any logged photos yet."
      }
    } catch (error) {
      // Handle error
      print('Error: $error');
    }
  }



  
 //CalTotGoalLeftNutDiaryinfo()
 Future<void> CalTotGoalLeftNutDiaryinfo() async {
    try {
      var url = Uri.parse('${widget.baseUrl}/CalTotGoalLeftNutDiaryinfo');
      var response = await http.post(
        url,
        body: jsonEncode({
          'email': widget.email,
            'daydate': [   
                {
                  'todaydate':  DateFormat('yyyy-MM-dd').format(selectedDate).toString(),  // Date of the diary entry 
                }
              ]
        }),
        headers: {'Content-Type': 'application/json'},
      );

        if (response.statusCode == 200) {
          print("Hello1");
          var responseData = json.decode(response.body);

         // Update state with new data
setState(() {
  // Assign values from response data

 percentageTotFat = 0.0;
 percentageSatFat = 0.0;
 percentageProtein = 0.0;
 percentageSodium = 0.0;
 percentagePotassium = 0.0;
 percentageCholesterol = 0.0;
percentageCarbs = 0.0;
 percentageFiber = 0.0;
 percentageSugar = 0.0;

  TotalTotFat = responseData['TotalTotFat']?.toString() ?? '0';
  GoalTotFat = responseData['GoalTotFat']?.toString() ?? '0';
  LeftTotFat = responseData['LeftTotFat']?.toString() ?? '0';
  totFatUNIT = responseData['totFatUNIT'] ?? '';


  TotalSatFat = responseData['TotalSatFat']?.toString() ?? '0';
  GoalSatFat = responseData['GoalSatFat']?.toString() ?? '0';
  LeftSatFat = responseData['LeftSatFat']?.toString() ?? '0';
  satFatUNIT = responseData['satFatUNIT'] ?? '';

  TotalProtein = responseData['TotalProtein']?.toString() ?? '0';
  GoalProtein = responseData['GoalProtein']?.toString() ?? '0';
  LeftProtein = responseData['LeftProtein']?.toString() ?? '0';
  proteinUNIT = responseData['proteinUNIT'] ?? '';

  TotalSodium = responseData['TotalSodium']?.toString() ?? '0';
  GoalSodium = responseData['GoalSodium']?.toString() ?? '0';
  LeftSodium = responseData['LeftSodium']?.toString() ?? '0';
  sodiumUNIT = responseData['sodiumUNIT'] ?? '';

  TotalPotassium = responseData['TotalPotassium']?.toString() ?? '0';
  GoalPotassium = responseData['GoalPotassium']?.toString() ?? '0';
  LeftPotassium = responseData['LeftPotassium']?.toString() ?? '0';
  potassiumUNIT = responseData['potassiumUNIT'] ?? '';

  TotalCholesterol = responseData['TotalCholesterol']?.toString() ?? '0';
  GoalCholesterol = responseData['GoalCholesterol']?.toString() ?? '0';
  LeftCholesterol = responseData['LeftCholesterol']?.toString() ?? '0';
  cholesterolUNIT = responseData['cholesterolUNIT'] ?? '';

  TotalCarbs = responseData['TotalCarbs']?.toString() ?? '0';
  GoalCarbs = responseData['GoalCarbs']?.toString() ?? '0';
  LeftCarbs = responseData['LeftCarbs']?.toString() ?? '0';
  carbsUNIT = responseData['carbsUNIT'] ?? '';

  TotalFiber = responseData['TotalFiber']?.toString() ?? '0';
  GoalFiber = responseData['GoalFiber']?.toString() ?? '0';
  LeftFiber = responseData['LeftFiber']?.toString() ?? '0';
  fiberUNIT = responseData['fiberUNIT'] ?? '';

  TotalSugar = responseData['TotalSugar']?.toString() ?? '0';
  GoalSugar = responseData['GoalSugar']?.toString() ?? '0';
  LeftSugar = responseData['LeftSugar']?.toString() ?? '0';
  sugarUNIT = responseData['sugarUNIT'] ?? '';

  // Calculate percentages
  percentageTotFat = (double.parse(LeftTotFat) == 0) ? 100.0 : (double.parse(TotalTotFat) / double.parse(GoalTotFat)) * 100;
  percentageSatFat = (double.parse(LeftSatFat) == 0) ? 100.0 : (double.parse(TotalSatFat) / double.parse(GoalSatFat)) * 100;
  percentageProtein = (double.parse(LeftProtein) == 0) ? 100.0 : (double.parse(TotalProtein) / double.parse(GoalProtein)) * 100;
  percentageSodium = (double.parse(LeftSodium) == 0) ? 100.0 : (double.parse(TotalSodium) / double.parse(GoalSodium)) * 100;
  percentagePotassium = (double.parse(LeftPotassium) == 0) ? 100.0 : (double.parse(TotalPotassium) / double.parse(GoalPotassium)) * 100;
  percentageCholesterol = (double.parse(LeftCholesterol) == 0) ? 100.0 : (double.parse(TotalCholesterol) / double.parse(GoalCholesterol)) * 100;
  percentageCarbs = (double.parse(LeftCarbs) == 0) ? 100.0 : (double.parse(TotalCarbs) / double.parse(GoalCarbs)) * 100;
  percentageFiber = (double.parse(LeftFiber) == 0) ? 100.0 : (double.parse(TotalFiber) / double.parse(GoalFiber)) * 100;
  percentageSugar = (double.parse(LeftSugar) == 0) ? 100.0 : (double.parse(TotalSugar) / double.parse(GoalSugar)) * 100;

  // Optionally, you can round the percentages to two decimal places
  percentageTotFat = double.parse(percentageTotFat.toStringAsFixed(2));
  percentageSatFat = double.parse(percentageSatFat.toStringAsFixed(2));
  percentageProtein = double.parse(percentageProtein.toStringAsFixed(2));
  percentageSodium = double.parse(percentageSodium.toStringAsFixed(2));
  percentagePotassium = double.parse(percentagePotassium.toStringAsFixed(2));
  percentageCholesterol = double.parse(percentageCholesterol.toStringAsFixed(2));
  percentageCarbs = double.parse(percentageCarbs.toStringAsFixed(2));
  percentageFiber = double.parse(percentageFiber.toStringAsFixed(2));
  percentageSugar = double.parse(percentageSugar.toStringAsFixed(2));
});

        }else {
        // Handle error
        print('Show Calories Summary Food  failed: ${response.statusCode}');
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
   selectedDate =  widget.TraineeDate ;
    // selectedDate =
    //     DateTime.now(); // Set the default selected date to current date

            GLOBALselectedDate = selectedDate;

            _isAllSelected == true ? CalTotCaloriesDiaryinfo() : CalTotGoalLeftNutDiaryinfo() ;
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
          GLOBALselectedDate = selectedDate;
             _isAllSelected == true ? CalTotCaloriesDiaryinfo() : CalTotGoalLeftNutDiaryinfo() ;
      });
    }
  }

  void _changeDate(bool isNext) {
    setState(() {
      selectedDate = isNext
          ? selectedDate.add(Duration(days: 1))
          : selectedDate.subtract(Duration(days: 1));
            GLOBALselectedDate = selectedDate;

               _isAllSelected == true ? CalTotCaloriesDiaryinfo() : CalTotGoalLeftNutDiaryinfo() ;
    });
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
                'Trainee\'s Summary',
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
                    builder: (context) => TraineeProgress(
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
              child: Center(
                child: Text(
                   DateFormat('yyyy-MM-dd')
                       .format(selectedDate), // Display the selected date
                   style: TextStyle(fontSize: 18),
                 ),
              ),
              
            ),

            // SizedBox(height: 10),
            // Adding space between date selection and "Calories/Nutients" section
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
                              true; // Update state when "All" is selected
                              
                        });
                        CalTotCaloriesDiaryinfo();
                        
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
                          "CALORIES",
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
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isAllSelected =
                              false; // Update state when "Recipes" is selected
                        });
                        CalTotGoalLeftNutDiaryinfo() ;
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
                          "NUTRIENTS",
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
                  ],
                ),
              ),
            ),

            // SizedBox(height: 10),
            _isAllSelected?
                
                  CaloriesDailySummary(name: widget.name,baseUrl: widget.baseUrl,email:widget.email,)
                  : 
                  NutrientsDailySummary(
              name: widget.name,
              baseUrl: widget.baseUrl,
              email: widget.email,
            ),
           // SizedBox(height: 10),
            // NutrientsDailySummary(
            //   name: widget.name,
            //   baseUrl: widget.baseUrl,
            //   email: widget.email,
            // ),
          ],
        ),
      ),
    );
  }
}

class CaloriesDailySummary extends StatefulWidget {
  final String baseUrl;
  final String name;
  final String email;

  const CaloriesDailySummary({
    Key? key,
    required this.baseUrl,
    required this.name,
    required this.email,
  }) : super(key: key);

  @override
  State<CaloriesDailySummary> createState() => _CaloriesDailySummaryState();
}

class _CaloriesDailySummaryState extends State<CaloriesDailySummary> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(15),
      ),
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Calories Summary',
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCircularProgressWithSquare(
                color: Colors.blue,
                label: 'Breakfast',
                percentage: percentageCaloriesBreakfast/100,
                calories: totalCaloriesBreakfast,
              ),
              _buildCircularProgressWithSquare(
                color: Colors.red,
                label: 'Lunch',
                percentage: percentageCaloriesLunch/100,
                calories: totalCaloriesLunch,
              ),
            ],
          ),
          SizedBox(height: 20.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCircularProgressWithSquare(
                color: Colors.green,
                label: 'Dinner',
                percentage: percentageCaloriesDinner/100,
                calories: totalCaloriesDinner,
              ),
              _buildCircularProgressWithSquare(
                color: Colors.lime,
                label: 'Snack',
                percentage: percentageCaloriesSnack/100,
                calories: totalCaloriesSnack,
              ),
            ],
          ),
          Divider(), // Divider added
          SizedBox(height: 20.0),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Calories',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${totalCaloriesOVERALL}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.0),
              Divider(), // Divider added
              SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Goal',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${totalCaloriesGOALS}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircularProgressWithSquare({
    required Color color,
    required String label,
    required double percentage,
    required int calories,
  }) {
    return Column(
      children: [
        SizedBox(
          width: 100,
          height: 100,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale:
                    2, // Increase the scale to make the circular radius bigger
                child: CircularProgressIndicator(
                  value: percentage,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
              Text(
                '${(percentage * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        // SizedBox(height: 10.0),

        Container(
          width: 70,
          height: 30,
          color: color,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(height: 5.0),
        Text(
          '$calories Kcal',
          style: TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class NutrientsDailySummary extends StatefulWidget {
  final String baseUrl;
  final String name;
  final String email;

  const NutrientsDailySummary({
    Key? key,
    required this.baseUrl,
    required this.name,
    required this.email,
  }) : super(key: key);

  @override
  State<NutrientsDailySummary> createState() => _NutrientsDailySummaryState();
}

class _NutrientsDailySummaryState extends State<NutrientsDailySummary> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total, Goal, and Left Headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 30), // Spacer
              Text(
                'Goal',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 30), // Spacer
              Text(
                'Left',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 5.0), // Spacer
          Divider(),

          SizedBox(height: 20.0), // Spacer
          _buildNutrientContainer('Protein', TotalProtein, GoalProtein, LeftProtein+proteinUNIT, percentageProtein / 100),
          SizedBox(height: 20.0), // Spacer
          _buildNutrientContainer('Carbs', TotalCarbs, GoalCarbs, LeftCarbs+carbsUNIT, percentageCarbs / 100),
          SizedBox(height: 20.0), // Spacer
          _buildNutrientContainer('Total Fat', TotalTotFat, GoalTotFat, LeftTotFat+totFatUNIT, percentageTotFat / 100),
          SizedBox(height: 20.0), // Spacer
          _buildNutrientContainer('Saturated Fat', TotalSatFat, GoalSatFat, LeftSatFat+satFatUNIT , percentageSatFat / 100),
          SizedBox(height: 20.0), // Spacer
          _buildNutrientContainer('Sugar',  TotalSugar, GoalSugar, LeftSugar+sugarUNIT , percentageSugar / 100),
          SizedBox(height: 20.0), // Spacer
          _buildNutrientContainer('Fiber',  TotalFiber, GoalFiber, LeftFiber+fiberUNIT , percentageFiber / 100),
          SizedBox(height: 20.0), // Spacer
          _buildNutrientContainer('Sodium',  TotalSodium, GoalSodium, LeftSodium+sodiumUNIT , percentageSodium / 100),
          SizedBox(height: 20.0), // Spacer
          _buildNutrientContainer('Potassium', TotalPotassium, GoalPotassium, LeftPotassium+potassiumUNIT , percentagePotassium / 100),
           SizedBox(height: 20.0), // Spacer
          _buildNutrientContainer('Cholesterol',  TotalCholesterol, GoalCholesterol, LeftCholesterol+cholesterolUNIT , percentageCholesterol / 100),
        ],
      ),
    );
  }

 Widget _buildNutrientContainer(
    String nutrient, String total, String goal, String left, double progressValue) {
  return GestureDetector(
    onTap: () {
      // Handle the press event here
      print('Container pressed!');
      Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MacrosDailySummary(
                                  baseUrl: widget.baseUrl,
                                  name: widget.name,
                                  email: widget.email,
                                  macroName: nutrient ,
                                  
                                ),
                              ),
                            );
    },
    child: Container(
      decoration: BoxDecoration(
          // Add decoration properties here if needed
          //color: Colors.grey[200],
          //borderRadius: BorderRadius.circular(5),
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            nutrient,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5.0), // Spacer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(total),
              SizedBox(width: 30), // Spacer
              Text(goal),
              SizedBox(width: 30), // Spacer
              Text(left),
            ],
          ),
          SizedBox(height: 15.0), // Spacer
          // Linear Progress Bar
          SizedBox(
            height: 6.0, // Adjust the height as needed
            child: LinearProgressIndicator(
              value: progressValue, // Example value
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
          SizedBox(height: 10.0), // Spacer
          Divider(thickness: 1, color: Colors.grey),
        ],
      ),
    ),
  );
}

}




class MacrosDailySummary extends StatefulWidget {
  final String baseUrl;
  final String name;
  final String email;
  final String macroName;

  const MacrosDailySummary({
    Key? key,
    required this.baseUrl,
    required this.name,
    required this.email,
     required this.macroName,
  }) : super(key: key);


  @override
   State<MacrosDailySummary> createState() => _MacrosDailySummaryState();

}

class _MacrosDailySummaryState extends State<MacrosDailySummary> {

//GlobalMealNameForMacros




  @override
  void initState() {
    super.initState();
    if(widget.macroName == 'Protein') {
      GlobalMealNameForMacros = 'protein';
    }
    
    else if(widget.macroName == 'Carbs') {
      GlobalMealNameForMacros = 'carbs';
    }

    else if(widget.macroName == 'Total Fat') {
      GlobalMealNameForMacros = 'totFat';
    }

    else if(widget.macroName == 'Saturated Fat') {
      GlobalMealNameForMacros = 'satFat';
    }

    else if(widget.macroName == 'Sugar') {
      GlobalMealNameForMacros = 'sugar';
    }

    else if(widget.macroName == 'Fiber') {
      GlobalMealNameForMacros = 'fiber';
    }

    else if(widget.macroName == 'Sodium') {
      GlobalMealNameForMacros = 'sodium';
    }

    else if(widget.macroName == 'Potassium') {
      GlobalMealNameForMacros = 'potassium';
    }

    else if(widget.macroName == 'Cholesterol') {
      GlobalMealNameForMacros = 'cholesterol';
    }


    CalTotGivenNutDiaryinfo();

  
 
  }


 //CalTotGivenNutDiaryinfo()
 Future<void> CalTotGivenNutDiaryinfo() async {
    try {
      var url = Uri.parse('${widget.baseUrl}/CalTotGivenNutDiaryinfo');
      var response = await http.post(
        url,
        body: jsonEncode({
          'email': widget.email,
            'daydate': [   
                {
                  'todaydate':  DateFormat('yyyy-MM-dd').format(GLOBALselectedDate).toString(),  // Date of the diary entry 

                }
              ],

              "givenNute": GlobalMealNameForMacros
        }),
        headers: {'Content-Type': 'application/json'},
      );

        if (response.statusCode == 200) {
          print("Hello1");
          var responseData = json.decode(response.body);

 // Update state with new data
setState(() {
  // Assign values from response data
percentageBreakfast = 0.0;
 percentageLunch = 0.0;
 percentageDinner = 0.0;
 percentageSnack = 0.0;


  totalgivenNuteBreakfast = (responseData['totalgivenNuteBreakfast'] ?? 0.0).toDouble();
  totalgivenNuteLunch = (responseData['totalgivenNuteLunch'] ?? 0.0).toDouble();
  totalgivenNuteDinner = (responseData['totalgivenNuteDinner'] ?? 0.0).toDouble();
  totalgivenNutesnack = (responseData['totalgivenNutenack'] ?? 0.0).toDouble();
  totalgivenNuteOVERALL = (responseData['totalgivenNuteOVERALL'] ?? 0.0).toDouble();
  totalgivenNuteGOALS = (responseData['totalgivenNuteGOALS'] ?? 0.0).toDouble();
  totalgivenNuteUNIT = responseData['totalgivenNuteUNIT'] ?? '';

  // Calculate percentages
  		  if (totalgivenNuteOVERALL != 0) {
                percentageBreakfast =  (totalgivenNuteBreakfast / totalgivenNuteOVERALL) * 100;
                percentageLunch =  (totalgivenNuteLunch / totalgivenNuteOVERALL) * 100;
                percentageDinner =  (totalgivenNuteDinner / totalgivenNuteOVERALL) * 100;
                percentageSnack =  (totalgivenNutesnack / totalgivenNuteOVERALL) * 100;
        }
  // Optionally, you can round the percentages to two decimal places
  percentageBreakfast = double.parse(percentageBreakfast.toStringAsFixed(2));
  percentageLunch = double.parse(percentageLunch.toStringAsFixed(2));
  percentageDinner = double.parse(percentageDinner.toStringAsFixed(2));
  percentageSnack = double.parse(percentageSnack.toStringAsFixed(2));

 
    // Print statements for debugging
  // print('Total NUTRI Breakfast: $totalgivenNuteBreakfast');
  // print('Total NUTRI Lunch: $totalgivenNuteLunch');
  // print('Total NUTRI Dinner: $totalgivenNuteDinner');
  // print('Total NUTRI Snack: $totalgivenNutesnack');
  // print('Total NUTRI Overall: $totalgivenNuteOVERALL');
  // print('Total NUTRI Goals: $totalgivenNuteGOALS');
  // print('Total NUTRI Unit: $totalgivenNuteUNIT');
  // print('Percentage NUTRI Breakfast: $percentageBreakfast');
  // print('Percentage NUTRI Lunch: $percentageLunch');
  // print('Percentage NUTRI Dinner: $percentageDinner');
  // print('Percentage NUTRI Snack: $percentageSnack');

});

        }else {
        // Handle error
        print('Show Calories Summary Food  failed: ${response.statusCode}');
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
        backgroundColor: Colors.teal[100],
          automaticallyImplyLeading: false,
          title: Row(
          children: [
            SizedBox(width: 5),
             IconButton(
              onPressed: () {

                 Navigator.of(context).pop(); // Close the pop-up dialog
             
              },
              icon: Icon(
                Icons.arrow_back,
                color: Color.fromARGB(255, 104, 159, 221),
                size: 35,
              ),
            ),
            SizedBox(width: 35),
            Text('${widget.macroName}'), // her macroname
           
             ]
             
          ),
      
      ),

      body:  Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(15),
      ),
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.macroName} Summary',
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCircularProgressWithSquare(
                color: Colors.blue,
                label: 'Breakfast',
                percentage: percentageBreakfast / 100,
                calories: totalgivenNuteBreakfast.toInt(),
                 UNIT:  totalgivenNuteUNIT
              ),
              _buildCircularProgressWithSquare(
                color: Colors.red,
                label: 'Lunch',
                percentage: percentageLunch / 100,
                calories: totalgivenNuteLunch.toInt(),
                 UNIT:  totalgivenNuteUNIT
              ),
            ],
          ),
          SizedBox(height: 20.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCircularProgressWithSquare(
                color: Colors.green,
                label: 'Dinner',
              percentage: percentageDinner / 100,
                calories: totalgivenNuteDinner.toInt(),
                 UNIT:  totalgivenNuteUNIT
              ),
              _buildCircularProgressWithSquare(
                color: Colors.lime,
                label: 'Snack',
                 percentage: percentageSnack / 100,
                calories: totalgivenNutesnack.toInt(),
                 UNIT:  totalgivenNuteUNIT
              ),
            ],
          ),
          Divider(), // Divider added
          SizedBox(height: 20.0),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total ${widget.macroName}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${totalgivenNuteOVERALL}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.0),
              Divider(), // Divider added
              SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Goal',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${totalgivenNuteGOALS}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
                Divider(), // Divider added
            ],
          ),
        ],
      ),
    ),



      );
  }




  Widget _buildCircularProgressWithSquare({
    required Color color,
    required String label,
    required double percentage,
    required int calories,
    required String UNIT,
  }) {
    return Column(
      children: [
        SizedBox(
          width: 100,
          height: 100,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale:
                    2, // Increase the scale to make the circular radius bigger
                child: CircularProgressIndicator(
                  value: percentage,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
              Text(
                '${(percentage * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        // SizedBox(height: 10.0),

        Container(
          width: 70,
          height: 30,
          color: color,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(height: 5.0),
        Text(
          '$calories ${UNIT}',
          style: TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------



