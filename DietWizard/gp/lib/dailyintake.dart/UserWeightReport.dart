import 'package:flutter/material.dart';
import 'package:gp/CoachFolder/CoachTrainnee.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:gp/CoachFolder/ProgressPhotoCoach.dart';
import 'package:gp/BottomNav.dart';
import 'package:gp/CoachFolder/TraineeProgress.dart';
import 'package:gp/CoachFolder/WeeklyTemplate.dart';
import 'package:gp/CoachFolder/ChartLineCode.dart';
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

String Titlechart = 'Weight Tracking Chart by USER Logging';
int TitlechartNumber = 1;

class UserWeightReport extends StatefulWidget {
  final String baseUrl;
  final String name;
  final String email;

  const UserWeightReport({
    Key? key,
    required this.baseUrl,
    required this.name,
    required this.email,
  }) : super(key: key);

  @override
  _UserWeightReportState createState() => _UserWeightReportState();
}

class _UserWeightReportState extends State<UserWeightReport> {
  List<WeightTracker> _data = [];
  @override
  void initState() {
    super.initState();
    weightbyUSER();
  }

  List<WeightTracker> dataUSER = [];

  //   List<WeightTracker> dataFOOD = [
  //   WeightTracker(DateTime.parse('2022-05-26'), 93),
  //   WeightTracker(DateTime.parse('2022-09-23'), 105),
  //   WeightTracker(DateTime.parse('2023-05-26'), 88),

  // ];

  Future<void> weightFood() async {
    try {
      var url = Uri.parse('${widget.baseUrl}/weightFood');
      var response = await http.post(
        url,
        body: jsonEncode({
          'email': widget.email,
        }),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);
        setState(() {
          _data = jsonData.map((data) => WeightTracker.fromJson(data)).toList();
        });
      } else {
        // Some other error happened
        print('fetch weights failed: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (error) {
      // Handle error
      print('Error: $error');
    }
  }


  Future<void> weightbyUSER() async {
    try {
      var url = Uri.parse('${widget.baseUrl}/weightbyUSER');
      var response = await http.post(
        url,
        body: jsonEncode({
          'email': widget.email,
        }),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);
        setState(() {
          _data = jsonData.map((data) => WeightTracker.fromJson(data)).toList();
        });
      } else {
        // Some other error happened
        print('fetch weights failed: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (error) {
      // Handle error
      print('Error: $error');
    }
  }

 Future<void> buttonINFOCURRENT() async {
  try {
    var url = Uri.parse('${widget.baseUrl}/buttonINFOCURRENT');
    var response = await http.post(
      url,
      body: jsonEncode({
        'email': widget.email,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Parse the JSON response body
      Map<String, dynamic> responseData = jsonDecode(response.body);

      // Extract data from the response
      String firstEntryWeight = responseData['firstEntryWeight'];
      String lastEntryWeight = responseData['lastEntryWeight'];
      String weightDifference = responseData['weightDifference'];
      String kgLeftToGoal = responseData['kgLeftToGoal'];
      String bmi = responseData['bmi'];

   AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.bottomSlide,
      title: 'Report Information',
      desc: 'First Weight: $firstEntryWeight kg\n'
          'Last Weight: $lastEntryWeight kg\n'
          'Weight Difference: $weightDifference kg\n'
          'Left To Goal: $kgLeftToGoal kg\n'
          'BMI: $bmi',
      descTextStyle: TextStyle(
        fontSize: 20.0, // Set the desired font size here
        fontWeight: FontWeight.bold, // Optional: Set the desired font weight
      ),
      btnOkOnPress: () {},
    )..show();
    } else {
      // Some other error happened
      print('fetch weights failed: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  } catch (error) {
    // Handle error
    print('Error: $error');
  }
}



  @override
  Widget build(BuildContext context) {

     DateTime? minDate;
    DateTime? maxDate;
    if (_data.isNotEmpty) {
      minDate = DateTime.parse(_data.first.date);
      maxDate = DateTime.parse(_data.last.date).add(Duration(days: 1)); // Ensure the end date is covered
    }

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
                'User Progress',
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
                      builder: (context) => WelcomePage(
                            name: widget.name,
                            baseUrl: widget.baseUrl,
                            email: widget.email,
                          )),
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
          children: [
            Container(
              height: 550,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: SfCartesianChart(
                primaryXAxis: DateTimeAxis(
                  dateFormat: DateFormat.yMMMd(),
                  intervalType: DateTimeIntervalType.days,
        interval: 7,
            minimum: minDate,
            maximum: maxDate,
            edgeLabelPlacement: EdgeLabelPlacement.shift,
            rangePadding: ChartRangePadding.none,

                ),
                title: ChartTitle(
                  text: Titlechart,
                  textStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                legend: Legend(isVisible: true),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CartesianSeries>[
                  LineSeries<WeightTracker, DateTime>(
                    dataSource: _data,
                    xValueMapper: (WeightTracker weightTrack, _) =>
                        DateTime.parse(weightTrack.date),
                    yValueMapper: (WeightTracker weightTrack, _) =>
                        weightTrack.weight,
                    name: 'Weight Track',
                    dataLabelSettings: DataLabelSettings(isVisible: true),
                    markerSettings: MarkerSettings(
                      isVisible: true,
                      width: 6,
                      height: 6,
                      shape: DataMarkerType.circle,
                      borderWidth: 2,
                      borderColor: Colors.black,
                      color: Color.fromARGB(255, 20, 142, 163),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    weightFood();
                    setState(() {
                      Titlechart = 'Weight Tracking Chart by FOOD Logging';
                      TitlechartNumber = 0;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    side: BorderSide(color: Colors.blue, width: 2),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  ),
                  icon: Icon(Icons.auto_graph),
                  label: Text(
                    'ChartbyFood',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    weightbyUSER();
                    setState(() {
                      Titlechart = 'Weight Tracking Chart by USER Logging';
                      TitlechartNumber = 1;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    side: BorderSide(color: Colors.blue, width: 2),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  ),
                  icon: Icon(Icons.auto_graph),
                  label: Text(
                    'ChartbyUser',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                    ElevatedButton.icon(
                  onPressed: () {
                      buttonINFOCURRENT();
                  },
                  style: ElevatedButton.styleFrom(
                    side: BorderSide(color: Colors.blue, width: 2),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  ),
                  icon: Icon(Icons.auto_graph),
                  label: Text(
                    'Info',
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
      ),
    );
  }
}

class WeightTracker {
  final String
      date; // Keeping it as a String to match the formatted date from the backend
  final double weight;

  WeightTracker(this.date, this.weight);

  factory WeightTracker.fromJson(Map<String, dynamic> json) {
    return WeightTracker(
      json['date'],
      double.parse(json['weight']), // Explicitly parse the string to a double
    );
  }
}
