import 'dart:convert';
import 'dart:math';

import 'package:gp/dailyintake.dart/goalspage.dart';
import 'package:gp/dailyintake.dart/reminder.dart';
import 'package:gp/dailyintake.dart/TimerPage.dart';
import 'package:gp/CoachFolder/WeeklyTemplate.dart';
import 'package:gp/dailyintake.dart/dailySummary.dart';
import 'package:gp/dailyintake.dart/UserWeightReport.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:gp/BottomNav.dart';
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
import 'package:gp/welcome.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Add this line to import the intl package
import 'package:gp/globals.dart' as globals;
import 'package:flutter_rating_bar/flutter_rating_bar.dart';


List<String> responseDetails = [];
List<Map<String, dynamic>> coachDataList = [];

class  coachesRating extends StatefulWidget {
  final String baseUrl;
  final String name;
  final String email;


  const coachesRating(
      {Key? key,
      required this.baseUrl,
      required this.name,
      required this.email,
      })
      : super(key: key);

  @override
  State<coachesRating> createState() => coachesRatingState();
}



class coachesRatingState extends State<coachesRating> {
    TextEditingController _searchController = TextEditingController();
      final PageController _page2ndController = PageController();
       int _current2ndPage = 0;

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
  List<dynamic> searchResults = []; // List to store search results

  Future<void> fetchCoaches() async {
  final response = await http.get(Uri.parse('${widget.baseUrl}/getallcoach'));

  if (response.statusCode == 200) {
    if (mounted) { // Check if the widget is still mounted
      setState(() {
        coaches = json.decode(response.body);
         searchResults = coaches; // Initialize search results with all coaches
      });
    }
  } else {
    print('Failed to fetch coaches. Error: ${response.statusCode}');
  }
}

  void _onSearchChanged() {
    setState(() {
      if (_searchController.text.isEmpty) {
        searchResults = coaches;
      } else {
        searchResults = coaches.where((coach) {
          return coach['username']
              .toLowerCase()
              .contains(_searchController.text.toLowerCase());
        }).toList();
      }
    });
  }


  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }


  Future<void> canRatingOrNOT() async {
  try {
    var url = Uri.parse('${widget.baseUrl}/canRatingOrNOT');
    var response = await http.post(
      url,
      body: jsonEncode({
        'email': widget.email,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
        responseDetails.clear(); 

      setState(() {
        if (responseData['message'] == 'no belongs') {
        
          print('The email does not belong to any trainee.');

          
        
        } else if (responseData['message'] == 'belong to coach') {
         
          print('The email belongs to a trainee.');
          print('Coach Email: ${responseData['coachemail']}');
          print('Trainee Email: ${responseData['traineeEmail']}');

         
          responseDetails = [
            'The email belongs to a trainee.',
            'Coach Email: ${responseData['coachemail']}',
            'Trainee Email: ${responseData['traineeEmail']}'
          ];
         
        }
      });


    } else {
      // Handle other status codes
      print('Request failed: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  } catch (error) {
    // Handle any errors that occur during the request
    print('Error: $error');
  }
}

  Future<void> INFOrateCoaches() async {
  try {
    final response = await http.get(Uri.parse('${widget.baseUrl}/INFOrateCoaches'));

    if (response.statusCode == 200) {
      // Parse JSON data
      final List<dynamic> coachesData = jsonDecode(response.body);

      // Clear existing data in the list
      coachDataList.clear();

      // Iterate through the data and add it to the global list
      for (var coachData in coachesData) {
        coachDataList.add({
          'coachid': coachData['coachid'],
          'coachemail': coachData['coachemail'],
          'currentRate': coachData['currentRate'],
          'NumOfRates': coachData['NumOfRates'],
          // Add other fields as needed
        });
      }
    } else {
      print('Failed to fetch coaches. Error: ${response.statusCode}');
    }
  } catch (error) {
    print('Error fetching coaches: $error');
  }
}

Future<void> FilterByNumRates() async {
  try {
    final response = await http.get(Uri.parse('${widget.baseUrl}/FilterByNumRates'));

    if (response.statusCode == 200) {
      // Parse the response body
      final List<dynamic> sortedCoachIds = json.decode(response.body);
      
      // Print the received data
      print('Received sorted coach IDs: $sortedCoachIds');
      
      // Sort the coaches list based on the order of sortedCoachIds
      coaches.sort((a, b) {
        final aId = sortedCoachIds.indexWhere((id) => id['coachemail'] == a['email']);
        final bId = sortedCoachIds.indexWhere((id) => id['coachemail'] == b['email']);
        return aId.compareTo(bId);
      });
      
      // Update the search results with sorted coaches
      if (mounted) {
        setState(() {
          searchResults = List.from(coaches); // Copy the sorted coaches to searchResults
        });
      }
    } else {
      print('Failed to fetch coaches. Error: ${response.statusCode}');
    }
  } catch (error) {
    print('Error fetching coaches: $error');
  }
}






Future<void> FilterByHighestRating() async {
  try {
    final response = await http.get(Uri.parse('${widget.baseUrl}/FilterByHighestRating'));

    if (response.statusCode == 200) {
      // Parse the response body
      final List<dynamic> sortedCoachRatings = json.decode(response.body);
      
      // Print the received data
      print('Received sorted coach ratings: $sortedCoachRatings');
      
      // Sort the coaches list based on the order of sortedCoachRatings
      coaches.sort((a, b) {
        final aRating = sortedCoachRatings.indexWhere((rating) => rating['coachemail'] == a['email']);
        final bRating = sortedCoachRatings.indexWhere((rating) => rating['coachemail'] == b['email']);
        return aRating.compareTo(bRating);
      });
      
      // Update the search results with sorted coaches
      if (mounted) {
        setState(() {
          searchResults = List.from(coaches); // Copy the sorted coaches to searchResults
        });
      }
    } else {
      print('Failed to fetch coaches. Error: ${response.statusCode}');
    }
  } catch (error) {
    print('Error fetching coaches: $error');
  }
}










@override
  void initState() {
    super.initState();
     responseDetails.clear(); 
    fetchCoaches();
    canRatingOrNOT();
    INFOrateCoaches();
    GlobalEmail = widget.email;
    GlobalUsername= widget.name;
    print(GlobalUsername + widget.name);
  _searchController.addListener(_onSearchChanged);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Color.fromARGB(255, 255, 255, 255),
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
                'Coaches',
                style: TextStyle(
                    fontSize: 30,
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
        padding: EdgeInsets.only(top: 5),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                        enabled: true,
                            
                        decoration: InputDecoration(
                          hintText:  "Search for a Coach",
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                              color: 
                                   const Color.fromARGB(255, 172, 169, 169)
                                  
                                      ), // Change hint color based on _isAllSelected
                        ),
                        onChanged: (value) {
                          // Handle search query change
                          // setState(() {
                          //   searchResults = Customsearchfood.where((food) =>
                          //       food.mealName
                          //           .toLowerCase()
                          //           .contains(value.toLowerCase())).toList();
                          // });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

          Container(
              padding: EdgeInsets.only(top:20.0,right:5 , bottom: 20 , left:5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                color: Colors.grey[200],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                        Text(
                        'Filter By: ',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 2, 6, 248)),
                      ),
                      ElevatedButton(
                        onPressed: () {
             
                        FilterByNumRates();

                        },
                        style: ElevatedButton.styleFrom(
                          side: BorderSide(color: Colors.blue, width: 2),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 13, vertical: 10),
                          child: Text(
                            '# of Rates',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                                     ElevatedButton(
                        onPressed: () {
                        
                       
                         FilterByHighestRating();
                        },
                        style: ElevatedButton.styleFrom(
                          side: BorderSide(color: Colors.blue, width: 2),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 13, vertical: 10),
                          child: Text(
                            'Highest Rating',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 10),
                ],
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
                          itemCount: searchResults.length,
                          itemBuilder: (context, index) {
                            final coach = searchResults[index];

                    // print('Coach Data: ${coach}');
                    //     print('Data Field: ${coach['data']}');
                    //     print('Binary Field: ${coach['data']['\$binary']}');
                    //     print('Base64 Field: ${coach['data']['\$binary']['base64']}');
                      // Directly access the list of integers in the 'data' field
                      List<dynamic> imageDataList = coach['data']['data'];
                      // Convert the list of integers to Uint8List
                      Uint8List decodedImage = Uint8List.fromList(imageDataList.cast<int>());

               
     // Find the matching coach data from the global coachDataList
    var matchedCoachData = coachDataList.firstWhere(
      (data) => data['coachemail'] == coach['email'],
      orElse: () => {
        'NumOfRates': '0',
        'currentRate': 0.00
      }, // Return a default map if no match is found
    );

    // Extract values from the matchedCoachData
    String numOfRates = matchedCoachData['NumOfRates'].toString();
      double rating = matchedCoachData['currentRate'] is double
        ? matchedCoachData['currentRate']
        : double.tryParse(matchedCoachData['currentRate'].toString()) ?? 3.50;

                      return CoahcesWidget2(
                        coachName: coach['username'],
                        coachEmail: coach['email'],
                        imageDataCoach: decodedImage,
                        rating:  rating,
                        Numofrates: numOfRates,
                        
                       
                      );
                          },
                        ),

                      
                      ],
                    ),
                  ),
                  SizedBox(height:10),

          ],
        ),

      ),
       bottomNavigationBar: BottomNav(
          indexbottom: '1',
          baseUrl: widget.baseUrl,
          name: widget.name,
          email: widget.email,
           ),
    );
  }


Widget CoahcesWidget2({
  required String coachName,
  required String coachEmail,
  required Uint8List imageDataCoach,

  required double rating , // Add a rating parameter
  required String Numofrates,
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
                    onTap: () {},
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
          SizedBox(height: 15.0),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Rating: ',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                RatingBarIndicator(
                  rating: rating,
                  itemBuilder: (context, index) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  itemCount: 5,
                  itemSize: 24.0,
                  direction: Axis.horizontal,
                ),
                SizedBox(width: 8),
                Text(
                  rating.toStringAsFixed(2), // Display the rating number
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.0),

           Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '# of Rates: ',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(width: 8),
                Text(
                  Numofrates, // Display the rating number
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  print("Info Coach");
                  fetchCoachInformation(coachName);
                },
                style: ElevatedButton.styleFrom(
                  side: BorderSide(color: Colors.blue, width: 2),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                ),
                icon: Icon(Icons.info),
                label: Text(
                  'Info',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton.icon(

//               onPressed: () async {
//   print("Rating Coach");
//   if (responseDetails.isEmpty) {
//     // Show a dialog that the user cannot rate
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Cannot Rate"),
//           content: Text("You are not a trainee for this coach."),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text("OK"),
//             ),
//           ],
//         );
//       },
//     );
//   } else {
//     // Extract the coach email and trainee email from responseDetails
//     String coachEmail = responseDetails
//         .firstWhere((detail) => detail.startsWith('Coach Email:'))
//         .split(': ')[1];
//     String traineeEmail = responseDetails
//         .firstWhere((detail) => detail.startsWith('Trainee Email:'))
//         .split(': ')[1];

//     // Check if the current user's email matches the trainee email
//     if (widget.email == traineeEmail) {
//       // Show rating dialog
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text("Rate the Coach"),
//             content: RatingForm(
//               onSubmit: (newRating) async {
//                 // Handle rating submission
//                 Navigator.of(context).pop();

//                 // Send the rating to the backend
//                 var url = Uri.parse('${widget.baseUrl}/rateCoach');
//                 var response = await http.post(
//                   url,
//                   body: jsonEncode({
//                     'coachemail': coachEmail,
//                     'traineeEmail': traineeEmail,
//                     'rating': newRating,
//                   }),
//                   headers: {'Content-Type': 'application/json'},
//                 );

//                 if (response.statusCode == 200) {
//                   // Successfully rated the coach
//                   print('Successfully rated the coach');
//                 } else {
//                   // Failed to rate the coach
//                   print('Failed to rate the coach: ${response.statusCode}');
//                   print('Response body: ${response.body}');
//                 }
//               },
//             ),
//           );
//         },
//       );
//     } else {
//       // Show a dialog that the user cannot rate
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text("Cannot Rate"),
//             content: Text("You are not a trainee for this coach."),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: Text("OK"),
//               ),
//             ],
//           );
//         },
//       );
//     }
//   }
// },

onPressed: () async {
  print("Rating Coach");

  if (responseDetails.isEmpty) {
    // Show a dialog that the user cannot rate
    // showDialog(
    //   context: context,
    //   builder: (BuildContext context) {
    //     return AlertDialog(
    //       title: Text("Cannot Rate"),
    //       content: Text("You are not a trainee for this coach."),
    //       actions: [
    //         TextButton(
    //           onPressed: () {
    //             Navigator.of(context).pop();
    //           },
    //           child: Text("OK"),
    //         ),
    //       ],
    //     );
    //   },
    // );


  AwesomeDialog(
  context: context,
  dialogType: DialogType.error,
  animType: AnimType.rightSlide,
  title: "Cannot Rate",
  desc: "You are not a trainee for this coach.",
  width: 600,
  btnOkText: "OK",
  btnOkOnPress: () {
    // Navigator.of(context).pop();
  },
)..show();




  } else {
    // Extract the coach email and trainee email from responseDetails
    String coachEmailResponse = responseDetails
        .firstWhere((detail) => detail.startsWith('Coach Email:'))
        .split(': ')[1];
    String traineeEmail = responseDetails
        .firstWhere((detail) => detail.startsWith('Trainee Email:'))
        .split(': ')[1];

    // Assuming widget.coachEmail is the email of the coach whose card was pressed
    if (widget.email == traineeEmail && coachEmail == coachEmailResponse) {
      // Show rating dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Rate the Coach"),
            content: RatingForm(
              onSubmit: (newRating) async {
                // Handle rating submission
                Navigator.of(context).pop();

                // Send the rating to the backend
                var url = Uri.parse('${widget.baseUrl}/rateCoach');
                var response = await http.post(
                  url,
                  body: jsonEncode({
                    'coachemail': coachEmailResponse,
                    'traineeEmail': traineeEmail,
                    'rating': newRating,
                  }),
                  headers: {'Content-Type': 'application/json'},
                );

                if (response.statusCode == 200) {
                  // Successfully rated the coach
                  print('Successfully rated the coach');
                } else {
                  // Failed to rate the coach
                  print('Failed to rate the coach: ${response.statusCode}');
                  print('Response body: ${response.body}');
                }
              },
            ),
          );
        },
      );
    } else {
      // Show a dialog that the user cannot rate
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Cannot Rate"),
            content: Text("You are not a trainee for this coach."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }
},


                style: ElevatedButton.styleFrom(
                  side: BorderSide(color: Colors.blue, width: 2),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                ),
                icon: Icon(Icons.rate_review),
                label: Text(
                  'Rate',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton.icon(
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
                  'Contact',
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


// class RatingForm extends StatefulWidget {
//   final Function(double) onSubmit;

//   RatingForm({required this.onSubmit});

//   @override
//   _RatingFormState createState() => _RatingFormState();
// }

// class _RatingFormState extends State<RatingForm> {
//   double _currentRating = 0.0;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         RatingBar.builder(
//           initialRating: _currentRating,
//           minRating: 0,
//           direction: Axis.horizontal,
//           allowHalfRating: true,
//           itemCount: 5,
//           itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
//           itemBuilder: (context, _) => Icon(
//             Icons.star,
//             color: Colors.amber,
//           ),
//           onRatingUpdate: (rating) {
//             setState(() {
//               _currentRating = rating;
//             });
//           },
//         ),
//         SizedBox(height: 20),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             ElevatedButton(
//               onPressed: () {
//                 widget.onSubmit(_currentRating);
//               },
//               child: Text("Submit"),
//             ),
//               ElevatedButton(
//           onPressed: () {
//             //widget.onSubmit(_currentRating);
//              Navigator.of(context).pop(); // Close the pop-up dialog
//           },
//           child: Text("Close"),
//         ),
//           ],
//         ),
//       ],
//     );
//   }
// }

class RatingForm extends StatefulWidget {
  final Function(double) onSubmit;

  RatingForm({required this.onSubmit});

  @override
  _RatingFormState createState() => _RatingFormState();
}

class _RatingFormState extends State<RatingForm> {
  double _currentRating = 0.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RatingBar.builder(
          initialRating: _currentRating,
          minRating: 0,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: 5,
          itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
          itemBuilder: (context, _) => Icon(
            Icons.star,
            color: Colors.amber,
          ),
          onRatingUpdate: (rating) {
            setState(() {
              _currentRating = rating;
            });
          },
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                widget.onSubmit(_currentRating);
              },
              child: Text("Submit"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the pop-up dialog
              },
              child: Text("Close"),
            ),
          ],
        ),
      ],
    );
  }
}
