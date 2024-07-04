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
import 'package:fl_chart/fl_chart.dart';
import 'package:gp/WaterIntake/BarchartThing.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Import for jsonEncode
import 'package:gp/welcome.dart';

bool flagOkwater = false;
String? IdealwaterIntake;
String? GoalwaterIntake;
int Todayintake=0;
class TodayIntakeClass {
  static int todayIntake = 0;
}
int Percentageintake=0;
 List<String> intakeLogs = [];

class waterpage extends StatefulWidget {
  final String baseUrl;
  final String name;
  final String email;


  const waterpage(
      {Key? key,
      required this.baseUrl,
      required this.name,
      required this.email,
      })
      : super(key: key);

  @override
  State<waterpage> createState() => _waterpageState();
}

class _waterpageState extends State<waterpage> {
 
    bool isLoading = true; // Add a loading indicator



Future<void> showloggedwater() async {
    try {
      var url = Uri.parse('${widget.baseUrl}/showloggedwater');
      var response = await http.post(
        url,
        body: jsonEncode({
          'email': widget.email,    
        }),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
       
var responseData = json.decode(response.body);
  // Extract formattedLogs and goalintake from responseData
  List<dynamic> formattedLogs = responseData['formattedLogs'];

    
      setState(() {
        GoalwaterIntake = responseData['goalintake'];
         Todayintake = responseData['TodayAmount'];

         // Updating Todayintake
          TodayIntakeClass.todayIntake = Todayintake;
        int goalintake = int.parse(responseData['goalintake'].toString());

         Percentageintake = ((Todayintake/goalintake)*100).toInt();
         print("Percentageintake=${Percentageintake}");

         
      });
  // Clear existing data in intakeLogs array
  intakeLogs.clear();

  // Iterate over formattedLogs, cast each element to String, and add it to intakeLogs
  for (var item in formattedLogs) {
    String log = item.toString(); // Explicitly cast to String
    print(log); // Optionally, print each log
    intakeLogs.add(log);
  }

  // Print goalintake for verification
  

      } else {
        // Some other error happened
        print(widget.email + widget.baseUrl);
        print('Show logged water failed: ${response.statusCode}');
        print('Response body: ${response.body}');

      }
    } catch (error) {
      // Handle error
      print('Error: $error');
    }
  }



Future<void> goalwaterintake() async {

    if(GoalwaterIntake != null) {
    try {
      var url = Uri.parse('${widget.baseUrl}/setgoalintake');
      var response = await http.post(
        url,
        body: jsonEncode({
          'email': widget.email,
          'goalintake': GoalwaterIntake,  
        }),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
       
      //var responseData = json.decode(response.body);
      print('Response body inside 200 OK code: ${response.body}');
     

      } else {
        // Some other error happened
        print('set water goal failed: ${response.statusCode}');
        print('Response body: ${response.body}');

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                "Error",
                style: TextStyle(color: Colors.red),
              ),
              content: Text(
                response.body != null ? response.body : "Some Error Happened",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              actions: <Widget>[
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
    } catch (error) {
      // Handle error
      print('Errorhh?: $error');
    }
    }
  }

    Future<void> idealintakeCalc() async {
    try {
      var url = Uri.parse('${widget.baseUrl}/idealintake');
      var response = await http.post(
        url,
        body: jsonEncode({
          'email': widget.email,    
        }),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
       
      var responseData = json.decode(response.body);
      print('Response body inside 200 OK code: ${response.body}');
       // IdealwaterIntake = responseData['dailyWaterIntake'];

      setState(() {
        IdealwaterIntake = responseData['dailyWaterIntake'];
      });
        print('Ideal intake calculated: $IdealwaterIntake ');

      } else {
        // Some other error happened
        print(widget.email + widget.baseUrl);
        print('Ideal intake calculater failed: ${response.statusCode}');
        print('Response body: ${response.body}');

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                "Error",
                style: TextStyle(color: Colors.red),
              ),
              content: Text(
                response.body != null ? response.body : "Some Error Happened",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              actions: <Widget>[
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
    } catch (error) {
      // Handle error
      print('Error: $error');
    }
  }



 





  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    idealintakeCalc(); // Call the function when the page initializes
    showloggedwater();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
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
                'Water',
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
            Container(
              padding: EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                color: Color.fromARGB(255, 231, 85, 85),
              ),
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Text(
                    'Water Intake',
                    style: TextStyle(fontSize: 24, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 200,
                          height: 200,
                          child: CircularProgressIndicator(
                          //  value: 0.9,
                           value: Percentageintake! > 100 ? 1.0 : Percentageintake!.toDouble() / 100.0,
                            strokeWidth: 10,
                            backgroundColor: Colors.white,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.blue,
                            ),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${Percentageintake}%',
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              '${Todayintake} ml',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(
                              height: 2,
                            ),
                            Text(
                              //'of $GoalwaterIntake ml',
                              'of ${GoalwaterIntake ?? IdealwaterIntake} ml',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            'Ideal water intake',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '$IdealwaterIntake ml',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            'Goal water intake',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            //'$GoalwaterIntake ml',
                            '${GoalwaterIntake ?? '0'} ml',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: ElevatedButton(
                      onPressed: () {
                         _showSetGoalDialog(context); // Show set goal dialog
                      },
                      style: ElevatedButton.styleFrom(
                        side: BorderSide(color: Colors.blue, width: 2),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: Text(
                          'Set Goal ',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                ],
              ),
            ),
            //second  container here
            SizedBox(height: 15),
            Container(
              padding: EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                color: Colors.grey[200],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _showIntakeDialog(context);
                        },
                        style: ElevatedButton.styleFrom(
                          side: BorderSide(color: Colors.blue, width: 2),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Text(
                            'Log',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.0),
                  Container(
                    height: 300,
                    child: Center(child: WaterIntakeTracker()),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
            SizedBox(height: 20),
            Container(
              height: 300,
              child: Center(child: barChart(email:widget.email,)),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
      // bottomNavigationBar: BottomNav(
      //     indexbottom: '1',
      //     baseUrl: widget.baseUrl,
      //     name: widget.name,
      //     email: widget.email,
      //      ),
    );
  }

 Widget WaterIntakeTracker() {
  if (intakeLogs.isEmpty) {
    return Center(
      child: Text(
        'You have logged nothing',
        style: TextStyle(fontSize: 18),
      ),
    );
  } else {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: DataTable(
              columns: [
                DataColumn(
                    label: Text('Edit',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Time',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Amount (ml)',
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: List.generate(
                intakeLogs.length,
                (index) {
                  List<String> splitLog = intakeLogs[index].split('-');
                  List<String> timeSplit = splitLog[1].split(' '); // Split time and meridian
                  String time = timeSplit[0]; // Extract time
                  String meridian = timeSplit[1]; // Extract meridian
                  String amount = splitLog[2]; // Get amount

                  return DataRow(cells: [
                    DataCell(IconButton(
                      icon: Icon(Icons
                          .edit), // You can replace this with your own edit icon
                      onPressed: () {
                        // Implement edit functionality here
                        // This function will be called when the edit button is pressed
                        _showEditDialog(context, index);
                        print(intakeLogs);
                      },
                    )),
                    DataCell(Text('$time $meridian')), // Display time
                    DataCell(Text(amount)), // Display amount
                  ]);
                },
              ),
            ),
          ),
        ),
        SizedBox(height: 30),
      ],
    );
  }
}

Future<void> _showIntakeDialog(BuildContext context) async {
  TimeOfDay selectedTime = TimeOfDay.now();
  String amount = '';

  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Log Water Intake'),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (picked != null && picked != selectedTime)
                      setState(() {
                        selectedTime = picked;
                      });
                  },
                  child: Text('Selected Time: ${selectedTime.format(context)}'),
                ),
                SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(labelText: 'Amount (ml)'),
                  onChanged: (value) => amount = value,
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (amount.isNotEmpty && int.tryParse(amount) != null) {
                //  request body
                Map<String, dynamic> requestBody = {
                  'email': widget.email,
                  'goalintake': GoalwaterIntake,
                  'log': 
                    // Send log entry in the corrected format
                    [
                      {
                        'date': "${DateTime.now().month}/${DateTime.now().day}/${DateTime.now().year}", // Date
                        'time': selectedTime.format(context), // Time
                        'amount': int.parse(amount), // Amount
                      }
                      
                    ],
                  
                };

                try {
                  var url = Uri.parse('${widget.baseUrl}/logwaterdaily');
                  var response = await http.post(
                    url,
                    body: jsonEncode(requestBody),
                    headers: {'Content-Type': 'application/json'},
                  );

                  if (response.statusCode == 200) {
                    print('Water intake logged successfully');
                    // Add the logged data to the intakellogs list
                     setState(() {
                     showloggedwater();
                    });
                    Navigator.of(context).pop(); // Close the dialog
                  } else {
                    print('Failed to log water intake: ${response.statusCode}');
                    // Show error dialog
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(
                            "Error",
                            style: TextStyle(color: Colors.red),
                          ),
                          content: Text(
                            response.body != null ? response.body : "Some Error Happened",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          actions: <Widget>[
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
                } catch (error) {
                  print('Error logging water intake: $error');
                }
              } else {
                // Show error dialog if amount is empty or not valid
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Error'),
                      content: Text('Please enter a valid amount.'),
                      actions: [
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
            child: Text('Save'),
          ),
        ],
      );
    },
  );
}


  Future<void> _showEditDialog(BuildContext context, int index) async {
    TimeOfDay selectedTime = TimeOfDay.now();

    List<String> splitLog = intakeLogs[index].split('-');
    List<String> dateSplit = splitLog[0].split('/'); // Split date into components
    List<String> timeSplit = splitLog[1].split(' '); // Split time and meridian
    String month = dateSplit[0]; // Extract month
    String day = dateSplit[1]; // Extract day
    String year = dateSplit[2]; // Extract year
    String time = timeSplit[0]; // Extract time
    String oldDate = '$month/$day/$year'; // Combine date components

    String meridian = timeSplit[1]; // Extract meridian
    String editedTime = '$time $meridian';
    String oldTime = editedTime;

    String editedAmount = splitLog[2]; // Get amount
    String oldAmount = editedAmount;

// String editedTime = "231";
// String editedAmount = "311";

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Water Intake'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (picked != null) {
                        setState(() {
                          flagOkwater = true;
                          selectedTime = picked;
                        });
                      }
                    },
                    //child: Text('Selected Time: ${editedTime}'),
                    child: Text(
                        'Selected Time: ${flagOkwater ? selectedTime.format(context) : editedTime}'),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(labelText: 'Amount (ml)'),
                    controller: TextEditingController(text: editedAmount),
                    onChanged: (value) => editedAmount = value,
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                flagOkwater = false;
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async{
                flagOkwater = false;
                if (editedAmount.isNotEmpty &&
                    int.tryParse(editedAmount) != null) {
 

                      Map<String, dynamic> requestBody = {
                    'email': widget.email,
                    'goalintake': GoalwaterIntake,
                    'log': [
                      // First log entry
                      {
                        'date': oldDate, // Date        
                        'time': oldTime, // Time
                        'amount': int.parse(oldAmount), // Amount
                      },
                      // Second log entry
                      {
                        'date': "${DateTime.now().month}/${DateTime.now().day}/${DateTime.now().year}", // Date
                        'time': selectedTime.format(context), // Time
                        'amount': int.parse(editedAmount), // Amount
                      },
                    ],
                  };


                try {
                  var url = Uri.parse('${widget.baseUrl}/saveeditloggedwater');
                  var response = await http.post(
                    url,
                    body: jsonEncode(requestBody),
                    headers: {'Content-Type': 'application/json'},
                  );

                  if (response.statusCode == 200) {
                    print('Water intake logged successfully');
                    // Add the logged data to the intakellogs list
                     setState(() {
                      showloggedwater();
                    });
                   // Navigator.of(context).pop(); // Close the dialog
                  } else {
                    print('Failed to log water intake: ${response.statusCode}');
                    // Show error dialog
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(
                            "Error",
                            style: TextStyle(color: Colors.red),
                          ),
                          content: Text(
                            response.body != null ? response.body : "Some Error Happened",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          actions: <Widget>[
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
                } catch (error) {
                  print('Error logging water intake: $error');
                }
                  
                  Navigator.of(context).pop();
                } else {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Error'),
                        content: Text('Please fill in the amount.'),
                        actions: [
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
              child: Text('Save'),
            ),
            ElevatedButton(
              onPressed: ()async {
                flagOkwater = false;

              Map<String, dynamic> requestBody = {
                    'email': widget.email,
                    'goalintake': GoalwaterIntake,
                    'log': [
                      // First log entry
                      {
                        'date': oldDate, // Date        
                        'time': oldTime, // Time
                        'amount': int.parse(oldAmount), // Amount
                      },
                      // Second log entry

                    ],
                  };


                try {
                  var url = Uri.parse('${widget.baseUrl}/deleteditloggedwater');
                  var response = await http.post(
                    url,
                    body: jsonEncode(requestBody),
                    headers: {'Content-Type': 'application/json'},
                  );

                  if (response.statusCode == 200) {
                    print('Water intake logged successfully');
                    // Add the logged data to the intakellogs list
                     setState(() {
                      showloggedwater();
                    });
                   // Navigator.of(context).pop(); // Close the dialog
                  } else {
                    print('Failed to log water intake: ${response.statusCode}');
                    // Show error dialog
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(
                            "Error",
                            style: TextStyle(color: Colors.red),
                          ),
                          content: Text(
                            response.body != null ? response.body : "Some Error Happened",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          actions: <Widget>[
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
                } catch (error) {
                  print('Error logging water intake: $error');
                }
                  
                  Navigator.of(context).pop();






              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red[200]),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showSetGoalDialog(BuildContext context) async {
    int? newGoal;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Set New Goal'),
          content: TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'New Goal (ml)'),
            onChanged: (value) {
              newGoal = int.tryParse(value);
            },
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
                if (newGoal != null && newGoal! > 1500) {
                  setState(() {
                    GoalwaterIntake = newGoal!.toString();
                  });
                  goalwaterintake();
                  Navigator.of(context).pop();
                } else {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Error'),
                        content: Text('Please enter a valid goal value grater than 1500.'),
                        actions: [
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
  }
}