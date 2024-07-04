import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:gp/BottomNav.dart';
import 'package:gp/CoachFolder/CoachTrainnee.dart';
import 'package:gp/CoachFolder/WeeklyTemDiaryFood.dart';
import 'package:gp/CoachFolder/TraineeProgress.dart';
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

DateTime GLOBALselectedDate = DateTime.now();
DateTime maxdateTimeBACK = DateTime.now();

class WeeklyTemplate extends StatefulWidget {
  final String baseUrl;
  final String name;
  final String TraineeEmail;
  final String CoachEmail;

  const WeeklyTemplate({
    Key? key,
    required this.baseUrl,
    required this.name,
    required this.TraineeEmail,
    required this.CoachEmail,
  }) : super(key: key);

  @override
  State<WeeklyTemplate> createState() => _WeeklyTemplateState();
}

class _WeeklyTemplateState extends State<WeeklyTemplate> {
  DateTime DayDate = DateTime(2024, 5, 1); // Sample start date
  List<Map<String, dynamic>> weeklyData = [];

  static late DateTime selectedDate;

  void _selectDate(BuildContext context) async {
    // Calculate the previous Monday from the current selectedDate
    DateTime previousMonday =
        selectedDate.subtract(Duration(days: selectedDate.weekday - 1));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: previousMonday,
      firstDate:
          maxdateTimeBACK, // Set the first selectable date to maxdateTimeBACK
      lastDate: DateTime(2101), // Allow selection until the year 2101
      selectableDayPredicate: (DateTime date) {
        // Enable selection only for the first day of the week (Monday)
        return date.weekday == DateTime.monday;
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;

        GLOBALselectedDate = selectedDate;
        globals.GLOBALWEEKLYselectedDate =
            '${DateFormat('yyyy-MM-dd').format(selectedDate.subtract(Duration(days: selectedDate.weekday - 1)))} - ${DateFormat('yyyy-MM-dd').format(selectedDate.add(Duration(days: 7 - selectedDate.weekday)))}';
        print(globals.GLOBALWEEKLYselectedDate);
        summaryshowdayofWeek();
      });
    }
  }

  void _changeDate(bool isNext) {
    setState(() {
      // Calculate the first day of the next or previous week
      DateTime newSelectedDate = isNext
          ? selectedDate.add(Duration(days: 7)) // Move to next week
          : selectedDate.subtract(Duration(days: 7)); // Move to previous week

      // Calculate the first and last day of the new week
      DateTime firstDayOfWeek =
          newSelectedDate.subtract(Duration(days: newSelectedDate.weekday - 1));
      DateTime lastDayOfWeek = firstDayOfWeek.add(Duration(days: 6));

      // Check if maxdateTimeBACK falls within the new week or if it's after the last day of the week
      bool maxDateWithinWeek = maxdateTimeBACK.isAfter(firstDayOfWeek) ||
          maxdateTimeBACK.isBefore(lastDayOfWeek);

      // Allow navigation if maxdateTimeBACK is within the new week or later
      if (maxDateWithinWeek || isNext) {
        selectedDate = newSelectedDate;
      }

      // Update the selected week dates
      firstDayOfWeek =
          selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
      lastDayOfWeek = firstDayOfWeek.add(Duration(days: 6));

      // Update the global selected date and weekly selected date range
      GLOBALselectedDate = selectedDate;
      globals.GLOBALWEEKLYselectedDate =
          '${DateFormat('yyyy-MM-dd').format(firstDayOfWeek)} - ${DateFormat('yyyy-MM-dd').format(lastDayOfWeek)}';
      print(globals.GLOBALWEEKLYselectedDate);
      summaryshowdayofWeek();
    });
  }

  //LASTDAYBACKHistorical()
  Future<void> LASTDAYBACKHistorical() async {
    try {
      var url = Uri.parse('${widget.baseUrl}/LASTDAYBACKHistorical');
      var response = await http.post(
        url,
        body: jsonEncode({
          'email': widget.TraineeEmail,
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

  //summaryshowdayofWeek()
  Future<void> summaryshowdayofWeek() async {
    try {
      var url = Uri.parse('${widget.baseUrl}/summaryshowdayofWeek');
      var response = await http.post(
        url,
        body: jsonEncode({
          'coachemail': widget.CoachEmail,
          'traineeEmail': widget.TraineeEmail,
          'weekdate': globals.GLOBALWEEKLYselectedDate,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);

        setState(() {
          weeklyData = List<Map<String, dynamic>>.from(responseData);
          print("Response 200 ok from summaryshowdayofWeek");
        });
      } else {
        // Handle error
        print('summary showdayofWeek food failed: ${response.statusCode}');
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
    LASTDAYBACKHistorical();
    selectedDate =
        DateTime.now(); // Set the default selected date to current date
    GLOBALselectedDate = selectedDate;
    globals.GLOBALWEEKLYselectedDate =
        '${DateFormat('yyyy-MM-dd').format(selectedDate.subtract(Duration(days: selectedDate.weekday - 1)))} - ${DateFormat('yyyy-MM-dd').format(selectedDate.add(Duration(days: 7 - selectedDate.weekday)))}';
    print(globals.GLOBALWEEKLYselectedDate);

    summaryshowdayofWeek();
  }

  @override
  Widget build(BuildContext context) {
    DateTime selectedDateForWeek =
        DateTime.parse(globals.GLOBALWEEKLYselectedDate.split(' - ').first);

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
                'Weekly Template',
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
                if (globals.PERMISSIONforWEEKLY == 1) {
                  Navigator.pushReplacement(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => WelcomePage(
                        baseUrl: widget.baseUrl,
                        name: widget.name,
                        email: widget.TraineeEmail,
                      ),
                    ),
                  );
                } else {
                  globals.PERMISSIONforWEEKLY = 0;
                  Navigator.pushReplacement(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => coachTrainee(
                        baseUrl: widget.baseUrl,
                        name: widget.name,
                        email: widget.CoachEmail,
                      ),
                    ),
                  );
                }
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
            SizedBox(height: 15),
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
                        '${DateFormat('yyyy-MM-dd').format(selectedDate.subtract(Duration(days: selectedDate.weekday - 1)))} - ${DateFormat('yyyy-MM-dd').format(selectedDate.add(Duration(days: 7 - selectedDate.weekday)))}',
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
                    'Weekly  Template',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  ...weeklyData.asMap().entries.map((entry) {
                    int index = entry.key;
                    var dayData = entry.value;
                    DateTime dayDate =
                        selectedDateForWeek.add(Duration(days: index));
                    return TraineesWeeklyRepCont(
                      'Day ${index + 1}',
                      dayDate,
                      _parseToDouble(dayData['totalCaloriesFood']),
                      _parseToDouble(dayData['totalProteinFood']),
                      _parseToDouble(dayData['totalCarbsFood']),
                      _parseToDouble(dayData['totalTotFatFood']),
                      _parseToDouble(dayData['totalCaloriesExercise']),
                    );
                  }).toList(),
                  // TraineesWeeklyRepCont(
                  //     'Day 1',
                  //     selectedDate.add(Duration(days: -1)),
                  //     2500,
                  //     150,
                  //     300,
                  //     50,
                  //     60), // here pass the day1- date
                  // TraineesWeeklyRepCont(
                  //     'Day 2',
                  //     selectedDate.add(Duration(days: 0)),
                  //     2500,
                  //     150,
                  //     300,
                  //     50,
                  //     60), // here pass the day2- date
                  // TraineesWeeklyRepCont(
                  //     'Day 3',
                  //     selectedDate.add(Duration(days: 1)),
                  //     2500,
                  //     150,
                  //     300,
                  //     50,
                  //     60), // here pass the day3- date
                  // TraineesWeeklyRepCont(
                  //     'Day 4',
                  //     selectedDate.add(Duration(days: 2)),
                  //     2500,
                  //     150,
                  //     300,
                  //     50,
                  //     60), // here pass the day4- date
                  // TraineesWeeklyRepCont(
                  //     'Day 5',
                  //     selectedDate.add(Duration(days: 3)),
                  //     2500,
                  //     150,
                  //     300,
                  //     50,
                  //     60), // here pass the day5- date
                  // TraineesWeeklyRepCont(
                  //     'Day 6',
                  //     selectedDate.add(Duration(days: 4)),
                  //     2500,
                  //     150,
                  //     300,
                  //     50,
                  //     60), // here pass the day6- date
                  // TraineesWeeklyRepCont(
                  //     'Day 7',
                  //     selectedDate.add(Duration(days: 5)),
                  //     2500,
                  //     150,
                  //     300,
                  //     50,
                  //     60), // here pass the day7- date
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget TraineesWeeklyRepCont(
      String DayNumber,
      DateTime DayDate,
      double TotCal,
      double TotProtein,
      double TotCarbs,
      double TotFat,
      double TotExe) {
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
          Text(
            DayNumber,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Day Date:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                DateFormat('yyyy-MM-dd').format(DayDate),
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
                'Total Calories:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                TotCal == 0.0 ? 'Not Logged Yet' : '${TotCal}',
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
                'Total Protein:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                TotProtein == 0.0 ? 'Not Logged Yet' : '${TotProtein}',
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
                'Total Carbs:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                TotCarbs == 0.0 ? 'Not Logged Yet' : '${TotCarbs}',
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
                'Total Fat:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                TotFat == 0.0 ? 'Not Logged Yet' : '${TotFat}',
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
                'Exercises:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                TotExe == 0.0 ? 'Not Logged Yet' : '${TotExe}',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Divider(
            thickness: 1,
            color: const Color.fromARGB(255, 218, 12, 12),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  if (DayDate.isBefore(maxdateTimeBACK)) {
                    // Display a snackbar or a dialog to inform the user
                    // showDialog(
                    //   context: context,
                    //   builder: (BuildContext context) {
                    //     return AlertDialog(
                    //       title: Text('Error'),
                    //       content: Text("You can't reach before trainee's start date."),
                    //       actions: <Widget>[
                    //         TextButton(
                    //           onPressed: () {
                    //             Navigator.of(context).pop();
                    //           },
                    //           child: Text('OK'),
                    //         ),
                    //       ],
                    //     );
                    //   },
                    // );

                    AwesomeDialog(
                      context: context,
                      dialogType: DialogType.error,
                      animType: AnimType.rightSlide,
                      title: "Error",
                      desc: "You can't reach before trainee's start date.",
                      width: 600,
                      btnOkText: "OK",
                      btnOkOnPress: () {
                        // Navigator.of(context).pop();
                      },
                    )..show();
                  } else {
                    // Navigate to the new page
                    Navigator.pushReplacement(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => WeeklyTemfooddairy(
                          baseUrl: widget.baseUrl,
                          name: widget.name,
                          TraineeEmail: widget.TraineeEmail,
                          CoachEmail: widget.CoachEmail,
                          selectedDateDisplay: DayDate,
                        ),
                      ),
                    );
                  }

                  //         Navigator.pushReplacement(
                  //   context,
                  //   CupertinoPageRoute(
                  //     builder: (context) => WeeklyTemfooddairy(
                  //       baseUrl: widget.baseUrl,
                  //       name: widget.name,
                  //       TraineeEmail: widget.TraineeEmail,
                  //       CoachEmail: widget.CoachEmail,
                  //       selectedDateDisplay: DayDate,

                  //     ),
                  //   ),
                  // );
                },
                style: ElevatedButton.styleFrom(
                  side: BorderSide(color: Colors.blue, width: 2),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                ),
                icon: Icon(Icons.info),
                label: Text(
                  globals.PERMISSIONforWEEKLY == 1 ? 'Show Day' : 'Log Day',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // ElevatedButton.icon(
              //   onPressed: () {
              //     print('EditFood pressed');

              //   },
              //   style: ElevatedButton.styleFrom(
              //     side: BorderSide(color: Colors.blue, width: 2),
              //     padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              //   ),
              //   icon: Icon(Icons.priority_high_rounded),
              //   label: Text(
              //     'Trainee Progress',
              //     style: TextStyle(
              //       fontSize: 14,
              //       fontWeight: FontWeight.bold,
              //     ),
              //   ),
              // ),
            ],
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  double _parseToDouble(dynamic value) {
    if (value == "Not Logged Yet") return 0.0;
    return (value is int) ? value.toDouble() : value;
  }
}

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
