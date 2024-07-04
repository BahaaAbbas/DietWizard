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
import 'package:gp/dailyintake.dart/fooddairy.dart';
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


//--------------------------------------------
DateTime GLOBALselectedDate = DateTime.now();

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

class dailySummary extends StatefulWidget {
  final String baseUrl;
  final String name;
  final String email;
   final DateTime selectedDateDisplay;

  const dailySummary({
    Key? key,
    required this.baseUrl,
    required this.name,
    required this.email,
    required this.selectedDateDisplay,
  }) : super(key: key);

  @override
  State<dailySummary> createState() => _dailySummaryState();
}

class _dailySummaryState extends State<dailySummary> {
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
                  'todaydate':  DateFormat('yyyy-MM-dd').format(GLOBALselectedDate).toString(),  // Date of the diary entry 
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

    // selectedDate =
    //     DateTime.now(); // Set the default selected date to current date

    //         GLOBALselectedDate = selectedDate;

        selectedDate = widget.selectedDateDisplay;
       // DateTime.now(); // Set the default selected date to current date

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
            SizedBox(width: 35),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Diary Summary',
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
                    builder: (context) => fooddairy(
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
      Navigator.pushReplacement(
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


// CalTotGivenNutDiaryinfo()
//  Future<void> CalTotGivenNutDiaryinfo() async {
//     try {
//       var url = Uri.parse('${widget.baseUrl}/CalTotGivenNutDiaryinfo');
//       var response = await http.post(
//         url,
//         body: jsonEncode({
//           'email': widget.email,
//             'daydate': [   
//                 {
//                   'todaydate':  DateFormat('yyyy-MM-dd').format(GLOBALselectedDate).toString(),  // Date of the diary entry 

//                 }
//               ],

//               "givenNute": GlobalMealNameForMacros
//         }),
//         headers: {'Content-Type': 'application/json'},
//       );

//         if (response.statusCode == 200) {
//           print("Hello1");
//           var responseData = json.decode(response.body);

//  // Update state with new data
// setState(() {
//   // Assign values from response data
// percentageBreakfast = 0.0;
//  percentageLunch = 0.0;
//  percentageDinner = 0.0;
//  percentageSnack = 0.0;
// totalgivenNuteGOALS =0.0;
// totalgivenNuteOVERALL =0.0;

//   totalgivenNuteBreakfast = (responseData['totalgivenNuteBreakfast'] ?? 0.0).toDouble();
//   totalgivenNuteLunch = (responseData['totalgivenNuteLunch'] ?? 0.0).toDouble();
//   totalgivenNuteDinner = (responseData['totalgivenNuteDinner'] ?? 0.0).toDouble();
//   totalgivenNutesnack = (responseData['totalgivenNutenack'] ?? 0.0).toDouble();
//   totalgivenNuteOVERALL = (responseData['totalgivenNuteOVERALL'] ?? 0.0).toDouble();
//   totalgivenNuteGOALS = (responseData['totalgivenNuteGOALS'] ?? 0.0).toDouble();
//   totalgivenNuteUNIT = responseData['totalgivenNuteUNIT'] ?? '';

//   // Calculate percentages
//   		  if (totalgivenNuteOVERALL != 0) {
//                 percentageBreakfast =  (totalgivenNuteBreakfast / totalgivenNuteOVERALL) * 100;
//                 percentageLunch =  (totalgivenNuteLunch / totalgivenNuteOVERALL) * 100;
//                 percentageDinner =  (totalgivenNuteDinner / totalgivenNuteOVERALL) * 100;
//                 percentageSnack =  (totalgivenNutesnack / totalgivenNuteOVERALL) * 100;
//         }
//   // Optionally, you can round the percentages to two decimal places
//   percentageBreakfast = double.parse(percentageBreakfast.toStringAsFixed(2));
//   percentageLunch = double.parse(percentageLunch.toStringAsFixed(2));
//   percentageDinner = double.parse(percentageDinner.toStringAsFixed(2));
//   percentageSnack = double.parse(percentageSnack.toStringAsFixed(2));

 
//     // Print statements for debugging
//   print('Total NUTRI Breakfast: $totalgivenNuteBreakfast');
//   print('Total NUTRI Lunch: $totalgivenNuteLunch');
//   print('Total NUTRI Dinner: $totalgivenNuteDinner');
//   print('Total NUTRI Snack: $totalgivenNutesnack');
//   print('Total NUTRI Overall: $totalgivenNuteOVERALL');
//    print('Total NUTRI Goals: $totalgivenNuteGOALS');
//   print('Total NUTRI Unit: $totalgivenNuteUNIT');
//   print('Percentage NUTRI Breakfast: $percentageBreakfast');
//   print('Percentage NUTRI Lunch: $percentageLunch');
//   print('Percentage NUTRI Dinner: $percentageDinner');
//   print('Percentage NUTRI Snack: $percentageSnack');

// });

//         }else {
//         // Handle error
//         print('Show Calories Summary Food  failed: ${response.statusCode}');
//         print(
//             'Response body: ${response.body}'); // back here for  Response body: "User does not have any logged photos yet."
//       }
//     } catch (error) {
//       // Handle error
//       print('Error: $error');
//     }
//   }

Future<void> CalTotGivenNutDiaryinfo() async {
  try {
    var url = Uri.parse('${widget.baseUrl}/CalTotGivenNutDiaryinfo');
    var response = await http.post(
      url,
      body: jsonEncode({
        'email': widget.email,
        'daydate': [
          {
            'todaydate': DateFormat('yyyy-MM-dd').format(GLOBALselectedDate).toString(),
          }
        ],
        'givenNute': GlobalMealNameForMacros
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      print("Hello1");
      var responseData = json.decode(response.body);

      setState(() {
        // Reset values
        totalgivenNuteBreakfast = 0.0;
        totalgivenNuteLunch = 0.0;
        totalgivenNuteDinner = 0.0;
        totalgivenNutesnack = 0.0;
        totalgivenNuteOVERALL = 0.0;
        totalgivenNuteGOALS = 0.0;
        totalgivenNuteUNIT = '';

        // Assign values from response data, parsing as needed
        totalgivenNuteBreakfast = parseValue(responseData['totalgivenNuteBreakfast']);
        totalgivenNuteLunch = parseValue(responseData['totalgivenNuteLunch']);
        totalgivenNuteDinner = parseValue(responseData['totalgivenNuteDinner']);
        totalgivenNutesnack = parseValue(responseData['totalgivenNuteSnack']);
        totalgivenNuteOVERALL = parseValue(responseData['totalgivenNuteOVERALL']);
        totalgivenNuteGOALS = parseValue(responseData['totalgivenNuteGOALS']);
        totalgivenNuteUNIT = responseData['totalgivenNuteUNIT'] ?? '';

        // Calculate percentages
        if (totalgivenNuteOVERALL != 0) {
          percentageBreakfast = (totalgivenNuteBreakfast / totalgivenNuteOVERALL) * 100;
          percentageLunch = (totalgivenNuteLunch / totalgivenNuteOVERALL) * 100;
          percentageDinner = (totalgivenNuteDinner / totalgivenNuteOVERALL) * 100;
          percentageSnack = (totalgivenNutesnack / totalgivenNuteOVERALL) * 100;
        }

        // Optionally, round the percentages to two decimal places
        percentageBreakfast = double.parse(percentageBreakfast.toStringAsFixed(2));
        percentageLunch = double.parse(percentageLunch.toStringAsFixed(2));
        percentageDinner = double.parse(percentageDinner.toStringAsFixed(2));
        percentageSnack = double.parse(percentageSnack.toStringAsFixed(2));
      });

      // Print statements for debugging
      print('Total NUTRI Breakfast: $totalgivenNuteBreakfast');
      print('Total NUTRI Lunch: $totalgivenNuteLunch');
      print('Total NUTRI Dinner: $totalgivenNuteDinner');
      print('Total NUTRI Snack: $totalgivenNutesnack');
      print('Total NUTRI Overall: $totalgivenNuteOVERALL');
      print('Total NUTRI Goals: $totalgivenNuteGOALS');
      print('Total NUTRI Unit: $totalgivenNuteUNIT');
      print('Percentage NUTRI Breakfast: $percentageBreakfast');
      print('Percentage NUTRI Lunch: $percentageLunch');
      print('Percentage NUTRI Dinner: $percentageDinner');
      print('Percentage NUTRI Snack: $percentageSnack');

    } else {
      // Handle error
      print('Show Calories Summary Food failed: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  } catch (error) {
    // Handle error
    print('Error: $error');
  }
}

// Function to parse values safely
double parseValue(dynamic value) {
  if (value is int) {
    return value.toDouble();
  } else if (value is double) {
    return value;
  } else if (value is String) {
    return double.tryParse(value.replaceAll(',', '.')) ?? 0.0; // Handle possible comma separators
  } else {
    return 0.0;
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
                                builder: (context) => dailySummary(
                                  baseUrl: widget.baseUrl,
                                  name: widget.name,
                                  email: widget.email,
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
                calories: totalgivenNuteBreakfast,
                 UNIT:  totalgivenNuteUNIT
              ),
              _buildCircularProgressWithSquare(
                color: Colors.red,
                label: 'Lunch',
                percentage: percentageLunch / 100,
                calories: totalgivenNuteLunch,
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
                calories: totalgivenNuteDinner,
                 UNIT:  totalgivenNuteUNIT
              ),
              _buildCircularProgressWithSquare(
                color: Colors.lime,
                label: 'Snack',
                 percentage: percentageSnack / 100,
                calories: totalgivenNutesnack,
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
    required double calories,
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



