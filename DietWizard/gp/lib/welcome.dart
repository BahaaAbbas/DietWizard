import 'dart:convert';
import 'dart:math';

import 'package:gp/dailyintake.dart/goalspage.dart';
import 'package:gp/dailyintake.dart/reminder.dart';
import 'package:gp/dailyintake.dart/TimerPage.dart';
import 'package:gp/CoachFolder/WeeklyTemplate.dart';
import 'package:gp/dailyintake.dart/dailySummary.dart';
import 'package:gp/dailyintake.dart/UserWeightReport.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:gp/GeminiChat/gemChatBot.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:gp/ProgressPhoto.dart';
import 'package:gp/ScreenChat/ChoseTarget.dart';
import 'package:gp/ScreenChat/chatScreen.dart';
import 'package:gp/ScreenChat/homeChat.dart';
import 'package:gp/CoachFolder/CoachTrainnee.dart';
import 'package:gp/WaterIntake/waterPage.dart';
import 'package:gp/dailyintake.dart/fooddairy.dart';
import 'package:gp/main.dart';
import 'package:line_icons/line_icons.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:flutter/services.dart';
import 'package:gp/loginPage.dart';
import 'package:gp/market.dart';
import 'package:gp/profile.dart';
import 'package:gp/ScreenChat/homeChat.dart';
import 'BottomNav.dart';
import 'home.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Add this line to import the intl package
import 'package:gp/globals.dart' as globals;

//---------------------------------------------------
int areYouNumber = 0;
String areYouCoachEmail = '';
String areYouTraineeEmail = '';
//----------
double StartWeightUser = 0.0;
double CurrentWeightUser = 0.0;
double EndWeightUser = 0.0;
double ProgressWeightUser = 0.0;

//---------------------------------------------------
DateTime GLOBALselectedDate = DateTime.now();

int totalCaloriesExerOVERALL = 0;
int totalCaloriesRemaningOVERALL = 0;
int totalCaloriesOVERALL = 0;
int totalCaloriesGOALS = 0;

double percentageCaloriesWelcome = 0.00;

//--------------------------------------------------

// Define parameters for Total, Goal, Left, and Unit for each nutrient
String TotalTotFat = '0';
String GoalTotFat = '0';
String LeftTotFat = '0';
String totFatUNIT = '';

String TotalProtein = '0';
String GoalProtein = '0';
String LeftProtein = '0';
String proteinUNIT = '';

String TotalCarbs = '0';
String GoalCarbs = '0';
String LeftCarbs = '0';
String carbsUNIT = '';

// Define percentage variables
double percentageTotFat = 0.0;

double percentageProtein = 0.0;

double percentageCarbs = 0.0;

//--------------------------------------------------

String GlobalEmail = "";
String GlobalCoachEmail = "";
String GlobalUsername = "";

//--------------------------------------------------

class WelcomePage extends StatefulWidget {
  final String baseUrl;
  final String name;
  final String email;
  final String? password;

  const WelcomePage(
      {Key? key,
      required this.baseUrl,
      required this.name,
      required this.email,
      this.password})
      : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final PageController _page2ndController = PageController();
  int _current2ndPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
    _page2ndController.addListener(() {
      setState(() {
        _current2ndPage = _page2ndController.page?.round() ?? 0;
      });
    });

    WelcomeCaloriesDiaryinfo();
    WelcomeMacrosDiaryinfo();
    fetchCoaches();
    GlobalEmail = widget.email;
    GlobalUsername = widget.name;
    print(GlobalUsername + widget.name);
    areYou();
    startcurrentgoal();
  }

  Future<void> startcurrentgoal() async {
    try {
      var url = Uri.parse('${widget.baseUrl}/startcurrentgoal');
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
          StartWeightUser = double.parse(responseData['weight']);
          CurrentWeightUser = double.parse(responseData['current']);
          EndWeightUser = double.parse(responseData['goalWeight']);

          if (EndWeightUser == StartWeightUser) {
            ProgressWeightUser = 100 / 100;
          } else {
            ProgressWeightUser = (((CurrentWeightUser - StartWeightUser) /
                        (EndWeightUser - StartWeightUser)) *
                    100) /
                100;
          }

          print('ProgressWeightUser: $ProgressWeightUser');
          //  print(CurrentWeightUser);
          // print(EndWeightUser);
        });
      } else {
        // Some other error happened
        print('getting info start current goal failed: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (error) {
      // Handle error
      print('Error: $error');
    }
  }

  //areYou()
  Future<void> areYou() async {
    try {
      var url = Uri.parse('${widget.baseUrl}/areYou');
      var response = await http.post(
        url,
        body: jsonEncode({
          'email': widget.email,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);

        if (responseData == 'admin') {
          print('User is an admin');
          areYouNumber = 1;
        } else if (responseData == 'usernocoach') {
          print('User is a user without a coach');
          areYouNumber = 2;
        } else if (responseData is Map<String, dynamic>) {
          String userEmail = responseData['user'];
          String coachEmail = responseData['coach'];
          print('User email: $userEmail');
          print('Coach email: $coachEmail');
          areYouCoachEmail = responseData['coach'];
          areYouTraineeEmail = responseData['user'];
          areYouNumber = 3;
        } else if (responseData == 'coach') {
          print('User is a coach');
          areYouNumber = 4;
        } else {
          areYouNumber = 0;
          print('Unexpected response format: $responseData');
        }
      } else {
        // Handle error
        print('are You fn failed: ${response.statusCode}');
        print(
            'Response body: ${response.body}'); // back here for  Response body: "User does not have any logged photos yet."
      }
    } catch (error) {
      // Handle error
      print('Error: $error');
    }
  }

  //WelcomeCaloriesDiaryinfo()
  Future<void> WelcomeCaloriesDiaryinfo() async {
    try {
      var url = Uri.parse('${widget.baseUrl}/WelcomeCaloriesDiaryinfo');
      var response = await http.post(
        url,
        body: jsonEncode({
          'email': widget.email,
          'daydate': [
            {
              'todaydate': DateFormat('yyyy-MM-dd')
                  .format(GLOBALselectedDate)
                  .toString(), // Date of the diary entry
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
          percentageCaloriesWelcome = 0;

          totalCaloriesRemaningOVERALL =
              (responseData['totalCaloriesRemaningOVERALL'] ?? 0).toInt();
          totalCaloriesExerOVERALL =
              (responseData['totalCaloriesExerOVERALL'] ?? 0).toInt();
          totalCaloriesOVERALL =
              (responseData['totalCaloriesOVERALL'] ?? 0).toInt();
          totalCaloriesGOALS =
              (responseData['totalCaloriesGOALS'] ?? 0).toInt();

          if (totalCaloriesRemaningOVERALL <= 0) {
            percentageCaloriesWelcome = 1.00;
          } else if (totalCaloriesRemaningOVERALL == totalCaloriesGOALS) {
            percentageCaloriesWelcome = 0.00;
          } else {
            percentageCaloriesWelcome =
                (totalCaloriesRemaningOVERALL / totalCaloriesGOALS) / 100;
          }

          // Optionally, you can round the percentages to two decimal places
          //percentageCaloriesWelcome = double.parse(percentageCaloriesBreakfast.toStringAsFixed(2));

          // Print statements for debugging
          // print('Total Calories Exerc: $totalCaloriesExerOVERALL');
          // print('Total Calories Overall: $totalCaloriesOVERALL');
          // print('Total Calories Goals: $totalCaloriesGOALS');
          // print('Total Calories Remaning: $totalCaloriesRemaningOVERALL');
          // print('Percentage Calories Welcome Remaning: $percentageCaloriesWelcome');
        });
      } else {
        // Handle error
        print(
            'Show Calories Welcome Summary Food  failed: ${response.statusCode}');
        print(
            'Response body: ${response.body}'); // back here for  Response body: "User does not have any logged photos yet."
      }
    } catch (error) {
      // Handle error
      print('Error: $error');
    }
  }

  //WelcomeMacrosDiaryinfo()
  Future<void> WelcomeMacrosDiaryinfo() async {
    try {
      var url = Uri.parse('${widget.baseUrl}/WelcomeMacrosDiaryinfo');
      var response = await http.post(
        url,
        body: jsonEncode({
          'email': widget.email,
          'daydate': [
            {
              'todaydate': DateFormat('yyyy-MM-dd')
                  .format(GLOBALselectedDate)
                  .toString(), // Date of the diary entry
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

          TotalTotFat = responseData['TotalTotFat']?.toString() ?? '0';
          GoalTotFat = responseData['GoalTotFat']?.toString() ?? '0';
          LeftTotFat = responseData['LeftTotFat']?.toString() ?? '0';
          totFatUNIT = responseData['totFatUNIT'] ?? '';

          TotalProtein = responseData['TotalProtein']?.toString() ?? '0';
          GoalProtein = responseData['GoalProtein']?.toString() ?? '0';
          LeftProtein = responseData['LeftProtein']?.toString() ?? '0';
          proteinUNIT = responseData['proteinUNIT'] ?? '';

          TotalCarbs = responseData['TotalCarbs']?.toString() ?? '0';
          GoalCarbs = responseData['GoalCarbs']?.toString() ?? '0';
          LeftCarbs = responseData['LeftCarbs']?.toString() ?? '0';
          carbsUNIT = responseData['carbsUNIT'] ?? '';

          // Calculate percentages
          percentageTotFat = (double.parse(LeftTotFat) == 0)
              ? 100.0
              : (double.parse(TotalTotFat) / double.parse(GoalTotFat)) * 100;

          percentageProtein = (double.parse(LeftProtein) == 0)
              ? 100.0
              : (double.parse(TotalProtein) / double.parse(GoalProtein)) * 100;

          percentageCarbs = (double.parse(LeftCarbs) == 0)
              ? 100.0
              : (double.parse(TotalCarbs) / double.parse(GoalCarbs)) * 100;

          // Optionally, you can round the percentages to two decimal places
          percentageTotFat = double.parse(percentageTotFat.toStringAsFixed(2));
          percentageProtein =
              double.parse(percentageProtein.toStringAsFixed(2));
          percentageCarbs = double.parse(percentageCarbs.toStringAsFixed(2));
        });
      } else {
        // Handle error
        print('Show  Macros Summary Food  failed: ${response.statusCode}');
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
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        title: Row(
          children: [
            CupertinoButton(
              child: Icon(
                CupertinoIcons.person_crop_circle_fill,
                size: 45,
                color: Colors.blue,
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(
                      baseUrl: widget.baseUrl,
                      name: widget.name,
                      email: widget.email,
                    ),
                  ),
                );
              },
            ),
            SizedBox(width: 5),
            Image.asset(
              'images/img6.png',
              height: 87,
              width: 75,
            ),
            SizedBox(width: 0),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'DietWizard',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 2, 6, 248)),
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
                    builder: (context) => NotificationMessages(
                      username: widget.name,
                      baseUrl: widget.baseUrl,
                      email: widget.email,
                      //password: widget.password!,
                    ),
                  ),
                );
              },
              icon: Icon(
                Icons.circle_notifications,
                color: Color.fromARGB(255, 104, 159, 221),
                size: 35,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: 10),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.grey[200],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today",
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Container(
                    height: 300, // Adjust the height as needed
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (int page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                      children: [
                        buildCaloriesCard(),
                        buildMacrosCard(),
                      ],
                    ),
                  ),
                  SizedBox(
                      height:
                          10), // Adjust spacing between PageView and indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      2, // Number of pages
                      (index) => buildIndicator(
                          index, 1), // Pass index and page number 2
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Container(
              padding: EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.grey[200],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Coaches",
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 15.0),
                  Container(
                    height: 480, // Adjust the height as needed
                    child: PageView(
                      controller: _page2ndController,
                      onPageChanged: (int page) {
                        setState(() {
                          _current2ndPage = page;
                        });
                      },
                      children: [
                        ListView.builder(
                          itemCount: coaches.length,
                          itemBuilder: (context, index) {
                            final coach = coaches[index];

                            // print('Coach Data: ${coach}');
                            //     print('Data Field: ${coach['data']}');
                            //     print('Binary Field: ${coach['data']['\$binary']}');
                            //     print('Base64 Field: ${coach['data']['\$binary']['base64']}');
                            // Directly access the list of integers in the 'data' field
                            List<dynamic> imageDataList = coach['data']['data'];
                            // Convert the list of integers to Uint8List
                            Uint8List decodedImage =
                                Uint8List.fromList(imageDataList.cast<int>());

                            return CoahcesWidget2(
                              coachName: coach['username'],
                              imageDataCoach: decodedImage,
                              textBelowImage: "Let's reach your goals together",
                            );
                          },
                        ),

                        // CoahcesWidget2(
                        //   coachName: "ibrahim",
                        //   imagePath: "images/t1.png",
                        //   textBelowImage:
                        //       "Boost yourself with coaching.\nLet's reach your goals together",
                        // ),
                        // CoahcesWidget2(
                        //   coachName: "bahaa",
                        //   imagePath: "images/t2.jpg",
                        //   textBelowImage:
                        //       "Boost yourself with coaching.\nLet's reach your goals together",
                        // ),
                      ],
                    ),
                  ),
                  SizedBox(
                      height:
                          10), // Adjust spacing between PageView and indicators
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: List.generate(
                  //     1, // Number of pages
                  //     (index) => buildIndicator(
                  //         index, 1), // Pass index and page number 2
                  //   ),
                  // ),
                ],
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Container(
              padding: EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.grey[200],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Discover",
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 15.0),
                  Container(
                    // height: 500, // Adjust the height as needed
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            DiscoverWidget(
                                iconData: Icons.water_drop_outlined,
                                boldText: "Water",
                                lightText: "Keep Fresh",
                                indextoPage: 1),
                            DiscoverWidget(
                                iconData: Icons.food_bank,
                                boldText: "DiaryFood",
                                lightText: "Log Food",
                                indextoPage: 4)
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // DiscoverWidget(
                            //     iconData: Icons.water_drop_outlined,
                            //     boldText: "Ibrahim",
                            //     lightText: "His Work",
                            //     indextoPage: 3),

                            // DiscoverWidget(
                            //     iconData: Icons.water_drop_outlined,
                            //     boldText: "Progress",
                            //     lightText: "Track Progress",
                            //     indextoPage: 2)
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // DiscoverWidget(
                            //     iconData: Icons.alarm,
                            //     boldText: "Reminder",
                            //     lightText: "Never Forget",
                            //     indextoPage: 5),

                            // DiscoverWidget(
                            //     iconData: Icons.water_drop_outlined,
                            //     boldText: "Goals",
                            //     lightText: "Keep Track",
                            //     indextoPage: 6)
                          ],
                        ),

                        areYouNumber == (3) || areYouNumber == (4) ? // are you 3 or 4 ?
                        Row(
                          mainAxisAlignment: (areYouNumber == 3 || areYouNumber == 4) 
                            ? MainAxisAlignment.center 
                            : MainAxisAlignment.spaceBetween,
                          children: [
                           areYouNumber == 4 ? 
                           DiscoverWidget(
                                iconData: Icons.person,
                                boldText: "Coach",
                                lightText: "Coach Life",
                                indextoPage: 7):

                               DiscoverWidget(
                                iconData: Icons.supervised_user_circle,
                                boldText: "User Template",
                                lightText: "Keep Track",
                                indextoPage: 8),

                                DiscoverWidget(
                                iconData: Icons.person,
                                boldText: "ChatBot",
                                lightText: "Bot",
                                indextoPage: 10),


                          //  areYouNumber == 3 ? DiscoverWidget(
                          //       iconData: Icons.supervised_user_circle,
                          //       boldText: "User Template",
                          //       lightText: "Keep Track",
                          //       indextoPage: 8): 

                          //       DiscoverWidget(
                          //       iconData: Icons.person,
                          //          boldText: "ChatBot",
                          //       lightText: "Bot",
                          //       indextoPage: 10),
                          ],
                        )
                        : DiscoverWidget(
                                iconData: Icons.person,
                                boldText: "ChatBot",
                                lightText: "Bot",
                                indextoPage: 10)
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
/*

floatingActionButton: FloatingActionButton(
  onPressed: () {},
  backgroundColor: Colors.blue,
  foregroundColor: Colors.white,
  elevation: 4.0,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
  child: PopupMenuButton(
    child: Icon(Icons.add),
    itemBuilder: (BuildContext context) => <PopupMenuEntry>[
      PopupMenuItem(
        child: ListTile(
          leading: Icon(Icons.home),
          title: Text('Home'),
        ),
        value: 'home',
      ),
      PopupMenuItem(
        child: ListTile(
          leading: Icon(Icons.person),
          title: Text('Profile'),
        ),
        value: 'profile',
      ),
      PopupMenuItem(
        child: ListTile(
          leading: Icon(Icons.shopping_cart),
          title: Text('Market'),
        ),
        value: 'market',
      ),
    ],
    onSelected: (value) {
      switch (value) {
        case 'home':
         
          break;
        case 'profile':
          
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfilePage(
                baseUrl: widget.baseUrl,
                name: widget.name,
                email: widget.email,
                password: widget.password,
              ),
            ),
          );
          break;
        case 'market':
        
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Market(baseUrl: widget.baseUrl)),
              );
          break;
      }
    },
  ),
),

*/
      bottomNavigationBar: BottomNav(
        indexbottom: '0',
        baseUrl: widget.baseUrl,
        name: widget.name,
        email: widget.email,
        password: widget.password ?? 'default_password',
      ),
    );
  }

  Widget buildCaloriesCard() {
    return GestureDetector(
      onTap: () {
        print("pressed");
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
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Calories",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4.0),
              Text(
                "Remaining = Goal - Food + Exercise",
                style: TextStyle(
                  fontSize: 14.0,
                ),
              ),
              SizedBox(height: 25.0),
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: 150.0,
                      child: Stack(
                        children: [
                          Center(
                            child: SizedBox(
                              width: 100,
                              height: 100,
                              child: CircularProgressIndicator(
                                value: percentageCaloriesWelcome,
                                strokeWidth: 10,
                                backgroundColor: Colors.grey[300],
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.blue),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "${totalCaloriesRemaningOVERALL} Kcal",
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "Remaining",
                                    style: TextStyle(
                                      fontSize: 12.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.green,
                            ),
                            SizedBox(width: 8.0),
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Goal"),
                                  SizedBox(height: 3.0),
                                  Text("${totalCaloriesGOALS} Kcal",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.fastfood,
                              color: Colors.blue,
                            ),
                            SizedBox(width: 8.0),
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Food"),
                                  SizedBox(height: 3.0),
                                  Text("${totalCaloriesOVERALL} Kcal",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            ImageIcon(
                              AssetImage('images/icons8-fire-48.png'),
                              color: Colors.red,
                            ),
                            SizedBox(width: 8.0),
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Exercise"),
                                  SizedBox(height: 3.0),
                                  Text("${totalCaloriesExerOVERALL} Kcal",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  } // buildcaloriescard

  Widget buildMacrosCard() {
    return GestureDetector(
      onTap: () {
        print("pressed");
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
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Macros",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 55.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text(
                        "Protien",
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: 105.0,
                        child: Stack(
                          children: [
                            Center(
                              child: SizedBox(
                                width: 90,
                                height: 90,
                                child: CircularProgressIndicator(
                                  value: percentageProtein / 100,
                                  strokeWidth: 10,
                                  backgroundColor: Colors.grey[300],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Color.fromARGB(255, 10, 229, 245)),
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "${TotalProtein} g",
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "Protein",
                                      style: TextStyle(
                                        fontSize: 12.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        "Carbs",
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: 105.0,
                        child: Stack(
                          children: [
                            Center(
                              child: SizedBox(
                                width: 90,
                                height: 90,
                                child: CircularProgressIndicator(
                                  value: percentageCarbs / 100,
                                  strokeWidth: 10,
                                  backgroundColor: Colors.grey[300],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Color.fromARGB(255, 159, 5, 173)),
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "${TotalCarbs} g",
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "Carbs",
                                      style: TextStyle(
                                        fontSize: 12.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        "Fat",
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: 105.0,
                        child: Stack(
                          children: [
                            Center(
                              child: SizedBox(
                                width: 90,
                                height: 90,
                                child: CircularProgressIndicator(
                                  value: percentageTotFat / 100,
                                  strokeWidth: 10,
                                  backgroundColor: Colors.grey[300],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.orange),
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "${TotalTotFat} g",
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "Fat",
                                      style: TextStyle(
                                        fontSize: 12.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildIndicator(int index, int whichPage) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5.0),
      width: 10.0,
      height: 10.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: whichPage == 1 && _currentPage == index
            ? Colors.blue
            : whichPage == 2 && _current2ndPage == index
                ? Colors.blue
                : Colors.grey,
      ),
    );
  }

  Future<void> fetchCoachInformation(String name) async {
    final url = Uri.parse('${widget.baseUrl}/getcoach/${name}');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the JSON
        // and show coach information in a dialog.
        final coachInfo = json.decode(response.body);
        // GlobalCoachEmail = coachInfo['Email'];
        AwesomeDialog(
          context: context,
          dialogType: DialogType.info,
          animType: AnimType.rightSlide,
          title: coachInfo['firstname'] + " " + coachInfo['lastname'],
          desc:
              'Age: ${coachInfo['age']}\nGender: ${coachInfo['gender']}\nYears of Experience: ${coachInfo['yearsexperiences']}\nqualifications: ${coachInfo['qualifications']}\nEmail: ${coachInfo['email']}\nNumber of trainees: ${coachInfo['Numberoftrainees']}\nWeight: ${coachInfo['Weight']}\nheight: ${coachInfo['height']}',
          descTextStyle:
              TextStyle(fontSize: 18.0), // Adjust the font size as needed

          btnOkOnPress: () {},
        )..show();
      } else if (response.statusCode == 404) {
        // If the coach is not found (404), show an error dialog.
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.bottomSlide,
          title: 'Error',
          desc: 'Coach not found.',
          btnOkOnPress: () {},
        )..show();
      } else {
        // If the server returns an error response, show an error dialog.
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.bottomSlide,
          title: 'Error',
          desc: 'Failed to fetch coach information.',
          btnOkOnPress: () {},
        )..show();
      }
    } catch (error) {
      // If an error occurs during the HTTP request, show an error dialog.
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.bottomSlide,
        title: 'Error',
        desc: 'Failed to fetch coach information: $error',
        btnOkOnPress: () {},
      )..show();
    }
  }

  Future<void> fetchCoachInformation2(String name) async {
    final url = Uri.parse('${widget.baseUrl}/getcoach/${name}');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the JSON
        // and show coach information in a dialog.
        final coachInfo = json.decode(response.body);
        // print(coachInfo['email']);
        GlobalCoachEmail = coachInfo['email'];
      } else if (response.statusCode == 404) {
        // If the coach is not found (404), show an error dialog.
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.bottomSlide,
          title: 'Error',
          desc: 'Coach not found.',
          btnOkOnPress: () {},
        )..show();
      } else {
        // If the server returns an error response, show an error dialog.
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.bottomSlide,
          title: 'Error',
          desc: 'Failed to fetch coach information.',
          btnOkOnPress: () {},
        )..show();
      }
    } catch (error) {
      // If an error occurs during the HTTP request, show an error dialog.
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.bottomSlide,
        title: 'Error',
        desc: 'Failed to fetch coach information: $error',
        btnOkOnPress: () {},
      )..show();
    }
  }

  List<dynamic> coaches = []; // List to store fetched coach data

  Future<void> fetchCoaches() async {
    final response = await http.get(Uri.parse('${widget.baseUrl}/getallcoach'));

    if (response.statusCode == 200) {
      if (mounted) {
        // Check if the widget is still mounted
        setState(() {
          coaches = json.decode(response.body);
        });
      }
    } else {
      print('Failed to fetch coaches. Error: ${response.statusCode}');
    }
  }

  @override
  void dispose() {
    // Cancel any ongoing requests or timers here
    super.dispose();
  }

  Widget CoahcesWidget2({
    required String coachName,
    //required String imagePath,
    required Uint8List imageDataCoach,
    required String textBelowImage,
  }) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Coach",
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 14.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(
                      coachName,
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        // AwesomeDialog(
                        //   context: context,
                        //   dialogType: DialogType.info, // Change dialogType according to your requirement
                        //   animType: AnimType.rightSlide,
                        //   title: coachName,
                        //   desc: "This is the coach dialog content.",
                        //   // btnCancelOnPress: () {},
                        //   btnOkOnPress: () {},
                        // )..show();
                        fetchCoachInformation(coachName);
                      },
                      child: SizedBox(
                        width: 250,
                        child: Image.memory(
                          imageDataCoach,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10.0),
            Center(
              child: Text(
                textBelowImage,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10.0),
            Center(
              child: ElevatedButton.icon(
                onPressed: () async {
                  print("Chat Coach");
                  await fetchCoachInformation2(coachName);
                  print(GlobalEmail);
                  print(GlobalCoachEmail);
                  print(GlobalUsername);

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => chatScreen(
                        username: GlobalUsername,
                        baseUrl: MyApp.baseUrl,
                        signInConstructorEmail: GlobalEmail,
                        chatwithConstructorEmail: GlobalCoachEmail,
                        // (chatWith == signedInUserEmail) ? myEmail : chatWith,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  side: BorderSide(color: Colors.blue, width: 2),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                ),
                icon: Icon(Icons.messenger),
                label: Text(
                  'Contact Coach',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget DiscoverWidget({
    required IconData iconData,
    required String boldText,
    required String lightText,
    required int indextoPage,
  }) {
    return GestureDetector(
      onTap: () {
        if (indextoPage == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => waterpage(
                baseUrl: widget.baseUrl,
                name: widget.name,
                email: widget.email,
              ),
            ),
          );
        } else if (indextoPage == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ProgressPhoto(
                baseUrl: widget.baseUrl,
                name: widget.name,
                email: widget.email,
              ),
            ),
          );
        } else if (indextoPage == 3) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(
                baseUrl: widget.baseUrl,
                name: widget.name,
                email: widget.email,
                // password: widget.password!,
                password: widget.password ?? 'default_password',
              ),
            ),
          );
        } else if (indextoPage == 4) {
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
        }
        else if (indextoPage == 10) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                baseUrl: widget.baseUrl,
                name: widget.name,
                email: widget.email,
              ),
            ),
          );
        } else if (indextoPage == 5) {
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
        } else if (indextoPage == 6) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => goalspage(
                baseUrl: widget.baseUrl,
                name: widget.name,
                email: widget.email,
              ),
            ),
          );
        } else if (indextoPage == 7) {
          if (areYouNumber == 4) {
            globals.PERMISSIONforWEEKLY = 0;

            print(" coach pressed");

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => coachTrainee(
                  baseUrl: widget.baseUrl,
                  name: widget.name,
                  email: widget.email,
                ),
              ),
            );
          } else {
            //     showDialog(
            //   context: context,
            //   builder: (BuildContext context) {
            //     return AlertDialog(
            //       title: Text('Not allowed!'),
            //       content: Text("You are not a coach...!",  style: TextStyle(
            //       fontSize: 18.0,

            //     ), ),
            //       actions: [
            //         TextButton(
            //           child: Text('OK'),
            //           onPressed: () {
            //             Navigator.of(context).pop();
            //           },
            //         ),
            //       ],
            //     );
            //   },
            // );

            AwesomeDialog(
              context: context,
              dialogType: DialogType.error,
              animType: AnimType.rightSlide,
              title: "Not allowed!",
              desc: "You are not a coach...!",
              width: 600,
              btnOkText: "OK",
              btnOkOnPress: () {
                // Navigator.of(context).pop();
              },
            )..show();

          }
        } else if (indextoPage == 8) {
          if (areYouNumber == 1) {
            print("admin pressed");
          } else if (areYouNumber == 2) {
            print("user with no coach pressed");
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('No Coach For Now'),
                  content: Text(
                    "Sign with Coach First...!",
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
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
          } else if (areYouNumber == 3) {
            print("user with coach pressed");
            globals.PERMISSIONforWEEKLY = 1;

            Navigator.pushReplacement(
              context,
              CupertinoPageRoute(
                builder: (context) => WeeklyTemplate(
                  baseUrl: widget.baseUrl,
                  name: widget.name,
                  CoachEmail: areYouCoachEmail,
                  TraineeEmail: areYouTraineeEmail,
                ),
              ),
            );
          } else {
            print("something happened");
            globals.PERMISSIONforWEEKLY = 0;
            // showDialog(
            //   context: context,
            //   builder: (BuildContext context) {
            //     return AlertDialog(
            //       title: Text('User with Coach Only'),
            //       content: Text(
            //         "For User with Coach Only...!",
            //         style: TextStyle(
            //           fontSize: 18.0,
            //         ),
            //       ),
            //       actions: [
            //         TextButton(
            //           child: Text('OK'),
            //           onPressed: () {
            //             Navigator.of(context).pop();
            //           },
            //         ),
            //       ],
            //     );
            //   },
            // );

          AwesomeDialog(
  context: context,
  dialogType: DialogType.warning,
  animType: AnimType.rightSlide,
  title: "User with Coach Only",
  desc: "For User with Coach Only...!",
  width: 600,
  btnOkText: "OK",
  btnOkOnPress: () {
    // Navigator.of(context).pop();
  },
)..show();




          }
        }
      },
      child: Container(
        width: 180,
        //color: Colors.blue,

        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                  padding: EdgeInsets.all(10.0),
                  child: Center(
                    child: Icon(
                      iconData,
                      size: 30.0,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Center(
                  child: Text(
                    boldText,
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Center(
                  child: Text(
                    lightText,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey[600], // Lighter text color
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class menuProfile extends StatefulWidget {
  final String baseUrl;
  final String name;
  final String email;

  const menuProfile({
    Key? key,
    required this.baseUrl,
    required this.name,
    required this.email,
  }) : super(key: key);

  @override
  _menuProfileState createState() => _menuProfileState();
}

class _menuProfileState extends State<menuProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 60.0,
                left: 40.0,
                right: 60.0,
                bottom: 20.0,
              ),
              child: Container(
                color: Color.fromARGB(255, 255, 255, 255),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.lightBlue,
                      child: Text(
                        widget.name.isNotEmpty
                            ? widget.name[0].toUpperCase()
                            : '',
                        style: TextStyle(fontSize: 39.0, color: Colors.white),
                      ),
                    ),
                    SizedBox(
                      width: 30,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.name,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.email,
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Divider(thickness: 1, color: Colors.grey),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${StartWeightUser}',
                          style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                        ),
                        SizedBox(height: 10.0),
                        Text(
                          'Start',
                          style: TextStyle(
                              fontSize: 18.0, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 120.0,
                          height: 120.0,
                          child: CircularProgressIndicator(
                            value: ProgressWeightUser,
                            strokeWidth: 8.0,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.blue),
                          ),
                        ),
                        Text(
                          '${CurrentWeightUser}\nCurrent',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${EndWeightUser}',
                          style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                        ),
                        SizedBox(height: 10.0),
                        Text(
                          'Goal',
                          style: TextStyle(
                              fontSize: 18.0, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Divider(thickness: 1, color: Colors.grey),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListTile(
                onTap: () {
                  print('Settings pressed');

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TimerPageShown(
                        baseUrl: widget.baseUrl,
                        name: widget.name,
                        email: widget.email,
                      ),
                    ),
                  );
                },
                leading: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.punch_clock),
                    SizedBox(width: 12),
                  ],
                ),
                title: Text(
                  'TimerClock',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListTile(
                onTap: () {
                  print('Settings pressed');
                  Navigator.pushReplacement(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => UserWeightReport(
                        baseUrl: widget.baseUrl,
                        name: widget.name,
                        email: widget.email,
                      ),
                    ),
                  );
                },
                leading: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.monitor_weight),
                    SizedBox(width: 12),
                  ],
                ),
                title: Text(
                  'Weight Report',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListTile(
                onTap: () {
                  print('Settings pressed');

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProgressPhoto(
                        baseUrl: widget.baseUrl,
                        name: widget.name,
                        email: widget.email,
                      ),
                    ),
                  );
                },
                leading: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.photo_album),
                    SizedBox(width: 12),
                  ],
                ),
                title: Text(
                  'Progress Photo',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListTile(
                onTap: () {
                  print('Settings pressed');

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => goalspage(
                        baseUrl: widget.baseUrl,
                        name: widget.name,
                        email: widget.email,
                      ),
                    ),
                  );
                },
                leading: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.grade_outlined),
                    SizedBox(width: 12),
                  ],
                ),
                title: Text(
                  'Goals',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListTile(
                onTap: () {
                  print('Settings pressed');

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
                leading: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.alarm),
                    SizedBox(width: 12),
                  ],
                ),
                title: Text(
                  'Reminder',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            //          Padding(
            //   padding: const EdgeInsets.all(10.0),
            //   child: ListTile(
            //     onTap: () {
            //       print('Settings pressed');

            //       Navigator.pushReplacement(
            //         context,
            //         MaterialPageRoute(
            //           builder: (context) => ChatPage(
            //             baseUrl: widget.baseUrl,
            //             name: widget.name,
            //             email: widget.email,
            //           ),
            //         ),
            //       );
            //     },
            //     leading: Row(
            //       mainAxisSize: MainAxisSize.min,
            //       children: [
            //         Icon(Icons.chat_outlined),
            //         SizedBox(width: 12),
            //       ],
            //     ),
            //     title: Text(
            //       'ChatBot',
            //       style: TextStyle(
            //         fontWeight: FontWeight.w600,
            //         fontSize: 20,
            //       ),
            //     ),
            //   ),
            // ),
            // Padding(
            //   padding: const EdgeInsets.all(10.0),
            //   child: ListTile(
            //     onTap: () {
            //       print('Settings pressed');
            //     },
            //     leading: Row(
            //       mainAxisSize: MainAxisSize.min,
            //       children: [
            //         Icon(Icons.settings),
            //         SizedBox(width: 12),
            //       ],
            //     ),
            //     title: Text(
            //       'Settings',
            //       style: TextStyle(
            //         fontWeight: FontWeight.w600,
            //         fontSize: 20,
            //       ),
            //     ),
            //   ),
            // ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 53.0),
                child: ElevatedButton(
                  onPressed: () {
                    globals.LoggedInUSEREmail = '';
                    globals.GLOBALWEEKLYselectedDate = '';
                    globals.PERMISSIONforWEEKLY = 0;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            LoginPage(baseUrl: widget.baseUrl),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    side: BorderSide(color: Colors.blue, width: 2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Text(
                      'Log Out',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(
        indexbottom: '4',
        baseUrl: widget.baseUrl,
        name: widget.name,
        email: widget.email,
      ),
    );
  }
}

// Area For - Half Progress Bar

// Area For - Half Progress Bar

class NotificationMessages extends StatefulWidget {
  final String baseUrl;
  final String username;
  final String email;

  const NotificationMessages(
      {Key? key,
      required this.username,
      required this.baseUrl,
      required this.email})
      : super(key: key);

  @override
  State<NotificationMessages> createState() => _NotificationMessagesState();
}

class _NotificationMessagesState extends State<NotificationMessages> {
  bool firstTextPressed = false;
  bool secondTextPressed = false;

  List<dynamic> notifications = [];

  @override
  void initState() {
    super.initState();
    fetchNotifications();
    print(widget.email);
  }

  Future<void> fetchNotifications() async {
    final response = await http.get(
      Uri.parse('${widget.baseUrl}/getnotification/${widget.username}'),
    );

    if (response.statusCode == 200) {
      setState(() {
        notifications = json.decode(response.body);
      });
    } else {
      // Handle error
      setState(() {
        notifications = []; // Clear existing notifications
      });
      print('Failed to load notifications');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    final response = await http.delete(
      Uri.parse('${widget.baseUrl}/notifications/$notificationId'),
    );

    if (response.statusCode == 200) {
      // Notification deleted successfully
      // Show success dialog

      setState(() {
        notifications.removeWhere(
            (notification) => notification['idnotification'] == notificationId);
      });

      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.rightSlide,
        title: "Notification Deleted",
        desc: "Deleted Notification successfully",
        width: 600,
        btnOkText: "Ok",
        btnOkOnPress: () {
          // Fetch notifications after deletion
          fetchNotifications();
        },
      )..show();
    } else {
      // Handle error
      print('Failed to delete notification');
    }
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       backgroundColor: Color.fromARGB(255, 255, 255, 255),
  //       title: Row(
  //         children: [
  //           IconButton(
  //             onPressed: () {
  //               Navigator.pushReplacement(
  //                 context,
  //                 MaterialPageRoute(
  //                     builder: (context) => WelcomePage(
  //                           name: widget.username,
  //                           baseUrl: widget.baseUrl,
  //                           email: widget.email,
  //                           password: widget.password,
  //                         )),
  //               );
  //             },
  //             icon: Icon(
  //               Icons.arrow_back,
  //               color: Color.fromARGB(255, 104, 159, 221),
  //               size: 35,
  //             ),
  //           ),
  //           Padding(
  //             padding: const EdgeInsets.only(left: 18.0),
  //             child: Text(
  //               'Notifications',
  //               style: TextStyle(
  //                   fontSize: 28,
  //                   fontWeight: FontWeight.bold,
  //                   color: Color.fromARGB(255, 2, 6, 248)),
  //             ),
  //           ),
  //         ],
  //       ),
  //       actions: [
  //         Padding(
  //           padding: EdgeInsets.only(right: 17, top: 2.0),
  //           child: IconButton(
  //             onPressed: () {
  //               Navigator.pushReplacement(
  //                 context,
  //                 MaterialPageRoute(
  //                     builder: (context) => homeChat(
  //                           username: widget.username,
  //                           baseUrl: widget.baseUrl,
  //                           password: widget.password,
  //                           email: widget.email,
  //                         )),
  //               );
  //             },
  //             icon: Icon(
  //               Icons.message_outlined,
  //               color: Color.fromARGB(255, 104, 159, 221),
  //               size: 35,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        title: Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WelcomePage(
                      name: widget.username,
                      baseUrl: widget.baseUrl,
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
            Padding(
              padding: const EdgeInsets.only(left: 18.0),
              child: Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 2, 6, 248),
                ),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 17, top: 2.0),
            child: IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => homeChat(
                      username: widget.username,
                      baseUrl: widget.baseUrl,
                      email: widget.email,
                    ),
                  ),
                );
              },
              icon: Icon(
                Icons.message_rounded,
                color: Color.fromARGB(255, 104, 159, 221),
                size: 35,
              ),
            ),
          ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Text('No notifications'),
            )
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(notifications[index]['titleNotification']),
                    subtitle:
                        Text(notifications[index]['descriptionNotification']),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        deleteNotification(
                            notifications[index]['idnotification'].toString());
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}


//



//