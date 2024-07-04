import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gp/ScreenChat/chatScreen.dart';
import 'package:gp/loginPage.dart';
import 'package:gp/main.dart';
import 'package:gp/signupcoach.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Import for jsonEncode
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:intl/intl.dart';

final FirebaseFirestore fireStoreinst = FirebaseFirestore.instance;
final FirebaseAuth _auth = FirebaseAuth.instance;
late String signedInUserEmail;
String? selectedOptionTarget;
String? selectedOptionActivity;
List<String>? selectedOptionInfo;
List<String>? selectedOptionInfowithoutGoalWeight;
List<String>? SelectedForTDEE;
bool Switch3and4 = false;
String selectedChoiceWeekly = 'Maintain Weight';
String AFTERTDEE ='';
String BURN ='';


class choseTarget extends StatefulWidget {
  final String baseUrl;
  final int display;
  const choseTarget({Key? key, required this.display, required this.baseUrl})
      : super(key: key);

  @override
  State<choseTarget> createState() => _choseTargetState();
}

class _choseTargetState extends State<choseTarget> {
  late User signedInUser;

  String? selectedOption;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        setState(() {
          signedInUser = user;
          signedInUserEmail = signedInUser.email!;
        });
        print("signed email = ${signedInUser.email}");
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (widget.display == 1) {
      // activity-back ----
      body = TargetOptionClass();
    } else if (widget.display == 2) {
      // target - next  ----  info - back
      body = ActivityOptionClass();
    } else if (widget.display == 3) {
      // activity - next  ----
      body = InfoOptionClass();
    } else if (widget.display == 4) {
      // activity - next  ----
      body = goalWeight();
    } else {
      body = TDEEResult();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 80, 236, 236),
        title: Row(
          children: [
            Image.asset(
              'images/img6.png',
              height: 87,
              width: 100,
            ),
            SizedBox(width: 45),
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Text(
                'DietWizard',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(left: 5, top: 8.0),
            // child: IconButton(
            //   onPressed: () {},
            //   icon: Icon(Icons.close),
            // ),
          ),
        ],
      ),
      body: body,
    );
  }
}

class TargetOptionClass extends StatefulWidget {
  @override
  _TargetOptionClassState createState() => _TargetOptionClassState();
}

class _TargetOptionClassState extends State<TargetOptionClass> {
  String selectedOption = '';
  void _submitTargetData() {
    if (selectedOption.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Missing Information"),
            content: Text("Please choose your target."),
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
    } else {
      print('Selected option: $selectedOption');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => choseTarget(display: 2, baseUrl: MyApp.baseUrl),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(left: 15, right: 15, bottom: 15),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Choose your target',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 5),
                decoration: BoxDecoration(
                  border:
                      Border.all(color: const Color.fromARGB(255, 12, 12, 12)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TargetOption('Lose Weight'),
                    TargetOption('Gain Weight'),
                    // TargetOption('Gain muscles'),
                    TargetOption('Maintain Weight'),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _submitTargetData();
                          },
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.blue),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          child: Text(
                            'Next',
                            style: TextStyle(color: Colors.white),
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
      ),
    );
  }

  Widget TargetOption(String option) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        title: Text(option),
        leading: Radio<String>(
          value: option,
          groupValue: selectedOption,
          onChanged: (value) {
            setState(() {
              selectedOption = value!;
              selectedOptionTarget = value;
            });
          },
        ),
      ),
    );
  }
}

class ActivityOptionClass extends StatefulWidget {
  @override
  _ActivityOptionClassState createState() => _ActivityOptionClassState();
}

class _ActivityOptionClassState extends State<ActivityOptionClass> {
  String selectedOption = '';
  void _submitActivityData() {
    if (selectedOption.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Missing Information"),
            content: Text("Please choose your activity level."),
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
    } else {
      print('Selected option: $selectedOption');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => choseTarget(display: 3, baseUrl: MyApp.baseUrl),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(left: 15, right: 15, bottom: 15),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Choose your Activity Level',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 5),
                decoration: BoxDecoration(
                  border:
                      Border.all(color: const Color.fromARGB(255, 12, 12, 12)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ActivityOption("Not Very Active",
                        "Spend most of the day sitting (e.g., bankteller, desk job)"),
                    ActivityOption("Lightly Active",
                        "Spend a good part of the day on your feet (e.g., teacher, salesperson)"),
                    ActivityOption("Active",
                        "Spend a good part of the day doing some physical activity (e.g., food server, postal carrier)"),
                    ActivityOption("Very Active",
                        "Spend a good part of the day doing heavy physical activity (e.g., bike messenger, carpenter)"),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            //_submitActivityData();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => choseTarget(
                                    display: 1, baseUrl: MyApp.baseUrl),
                              ),
                            );
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Color.fromARGB(255, 247, 246, 255)),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          child: Text(
                            'Back',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _submitActivityData();
                          },
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.blue),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          child: Text(
                            'Next',
                            style: TextStyle(color: Colors.white),
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
      ),
    );
  }

  Widget ActivityOption(String option, String additionalText) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        title: Text(
          option,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(additionalText),
        leading: Radio<String>(
          value: option,
          groupValue: selectedOption,
          onChanged: (value) {
            setState(() {
              selectedOption = value!;
              selectedOptionActivity = value;
            });
          },
        ),
      ),
    );
  }
}

class InfoOptionClass extends StatefulWidget {
  const InfoOptionClass({Key? key}) : super(key: key);
  @override
  _InfoOptionClassState createState() => _InfoOptionClassState();
}

class _InfoOptionClassState extends State<InfoOptionClass> {
  String selectedOption = '';
  TextEditingController _heightController = TextEditingController();
  TextEditingController _weightController = TextEditingController();
  TextEditingController _goalWeightController = TextEditingController();
  TextEditingController _ageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (Switch3and4 == true) {
      selectedOption = selectedOptionInfo![0];
      _ageController.text = selectedOptionInfo![1];
      _heightController.text = selectedOptionInfo![2];
      _weightController.text = selectedOptionInfo![3];
      _goalWeightController.text = selectedOptionInfo![4];
      Switch3and4 = false;
    }
  }

  void _validateAge(BuildContext context, String value) {
    if (value.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error-Empty'),
            content: Text('Please enter your age'),
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
      return;
    }
    double? age = double.tryParse(value);
    if (age == null || age < 14 || age > 88) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error-incorrect age'),
            content: Text('Age must be between 14 and 88'),
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
      return;
    }

    print('Valid age: $age');
  }

  void _validateHeight(BuildContext context, String value) {
    if (value.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error-Empty'),
            content: Text('Please enter your Height'),
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
      return;
    }
    double? height = double.tryParse(value);
    if (height == null || height < 100 || height > 220) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error-incorrect height'),
            content: Text('Height must be between 100cm and 220cm'),
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
      return;
    }

    print(' Height: $height');
  }

  void _validateWeight(BuildContext context, String value) {
    if (value.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error-Empty'),
            content: Text('Please enter your Weight'),
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
      return;
    }
    double? weight = double.tryParse(value);
    if (weight == null || weight < 30 || weight > 220) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error-incorrect weight'),
            content: Text('weight must be between 30kg and 220kg'),
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
      return;
    }

    print(' Weight: $weight');
  }

  void calculategoalwieght() {
    if (selectedOption.isEmpty ||
        _ageController.text.isEmpty ||
        _heightController.text.isEmpty ||
        _weightController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Missing Information For Goal Weghit Calculation"),
            content: Text("Please fill in all information."),
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
    } else {
      selectedOptionInfo = [
        selectedOption,
        _ageController.text,
        _heightController.text,
        _weightController.text,
        "Test"
      ];

      selectedOptionInfowithoutGoalWeight = [
        selectedOption,
        _ageController.text,
        _heightController.text,
        _weightController.text
      ];

      for (int i = 0; i < selectedOptionInfowithoutGoalWeight!.length; i++) {
        print(
            'selectedOptionInfowithoutGoalWeight[$i]: ${selectedOptionInfowithoutGoalWeight![i]}\n');
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => choseTarget(display: 4, baseUrl: MyApp.baseUrl),
        ),
      );
    }
  }

  void _submitInfoData() {
    if (selectedOption.isEmpty ||
        _ageController.text.isEmpty ||
        _heightController.text.isEmpty ||
        _weightController.text.isEmpty ||
        _goalWeightController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Missing Information"),
            content: Text("Please fill in all information."),
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
    } else if (double.parse(_ageController.text) < 14.0 ||
        double.parse(_ageController.text) > 88.0 ||
        double.parse(_heightController.text) < 100.0 ||
        double.parse(_heightController.text) > 220.0 ||
        double.parse(_weightController.text) < 40.0 ||
        double.parse(_weightController.text) > 220.0) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Follow the rules!"),
            content: Text("Please fill fields as asked you."),
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
    } else {
      print('Selected Target: $selectedOptionTarget');
      print('Selected option: $selectedOptionActivity');
      selectedOptionInfo = [
        selectedOption,
        _ageController.text,
        _heightController.text,
        _weightController.text,
        _goalWeightController.text
      ];

      SelectedForTDEE = [
        selectedOptionTarget!,
        selectedOptionActivity!,
        selectedOption,
        _ageController.text,
        _heightController.text,
        _weightController.text,
        _goalWeightController.text,
        "TDEE for now"
      ];

      for (int i = 0; i < SelectedForTDEE!.length; i++) {
        print('TDEE[$i]: ${SelectedForTDEE![i]}\n');
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => choseTarget(display: 5, baseUrl: MyApp.baseUrl),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(left: 15, right: 15, bottom: 15),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 10,
              ),
              Text(
                'Choose your sex',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Radio<String>(
                    value: 'Male',
                    groupValue: selectedOption,
                    onChanged: (value) {
                      setState(() {
                        selectedOption = value!;
                      });
                    },
                  ),
                  Text('Male'),
                  SizedBox(width: 20),
                  Radio<String>(
                    value: 'Female',
                    groupValue: selectedOption,
                    onChanged: (value) {
                      setState(() {
                        selectedOption = value!;
                      });
                    },
                  ),
                  Text('Female'),
                ],
              ),
              SizedBox(height: 15),
              Text(
                'How old are you?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 7),
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _ageController,
                    keyboardType: TextInputType.number,
                  onSubmitted: (value) {
                    _validateAge(context, value);
                  },
                  decoration: InputDecoration(
                    labelText: 'Age',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    // prefixIcon: Icon(Icons.person),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'How tall are you in Centimeters?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 7),
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _heightController,
                     keyboardType: TextInputType.number,
                  onSubmitted: (value) {
                    _validateHeight(context, value);
                  },
                  decoration: InputDecoration(
                    labelText: 'Height',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    // prefixIcon: Icon(Icons.person),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'How much do you weight in Kilograms?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 7),
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _weightController,
                     keyboardType: TextInputType.number,
                  onSubmitted: (value) {
                    _validateWeight(context, value);
                  },
                  decoration: InputDecoration(
                    labelText: 'Weight',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    // prefixIcon: Icon(Icons.person),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'What\'s your goal weight in Kilograms?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 7),
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _goalWeightController,
                     keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Goal Weight',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    // prefixIcon: Icon(Icons.person),
                  ),
                ),
              ),
              SizedBox(height: 5),
              InkWell(
                onTap: () {
                  calculategoalwieght();
                },
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Don\'t know what is your goal weight? ',
                        style: TextStyle(
                            color: const Color.fromARGB(255, 240, 111, 111)),
                      ),
                      TextSpan(
                        text: 'Press here',
                        style: TextStyle(color: Colors.black.withOpacity(0.85)),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              choseTarget(display: 2, baseUrl: MyApp.baseUrl),
                        ),
                      );
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Color.fromARGB(255, 247, 246, 255)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    child: Text(
                      'Back',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _submitInfoData();
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.blue),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    child: Text(
                      'Next',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class goalWeight extends StatefulWidget {
  @override
  _goalWeightClassState createState() => _goalWeightClassState();
}

class _goalWeightClassState extends State<goalWeight> {
  TextEditingController _heightController = TextEditingController();
  TextEditingController _weightController = TextEditingController();
  TextEditingController _goalWeightController = TextEditingController();
  TextEditingController _ageController = TextEditingController();
  TextEditingController _sexController = TextEditingController();
  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _goalWeightController.dispose();
    _ageController.dispose();
    _sexController.dispose();
    super.dispose();
  }

  void CalGoalWeight() {
    if (_ageController.text.isEmpty ||
        _heightController.text.isEmpty ||
        _weightController.text.isEmpty ||
        _sexController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Missing Information"),
            content: Text("Please fill in all information."),
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
    } else {
      double heightInCm = double.parse(_heightController.text);
      double weightInKg = double.parse(_weightController.text);
      double idealWeight = 0.0;

      if (_sexController.text == 'Male') {
        idealWeight = 52 + 1.9 * ((heightInCm / 2.54) - 60);
      } else if (_sexController.text == 'Female') {
        idealWeight = 49 + 1.7 * ((heightInCm / 2.54) - 60);
      }

      _goalWeightController.text = idealWeight.round().toStringAsFixed(1);
    }
  }

  @override
  void initState() {
    super.initState();
    if (selectedOptionInfowithoutGoalWeight?.isNotEmpty ?? false) {
      _sexController.text = selectedOptionInfowithoutGoalWeight![0];
      _ageController.text = selectedOptionInfowithoutGoalWeight![1];
      _heightController.text = selectedOptionInfowithoutGoalWeight![2];
      _weightController.text = selectedOptionInfowithoutGoalWeight![3];
    }
  }

  void _DoneButton() {
    if (_sexController.text.isEmpty ||
        _ageController.text.isEmpty ||
        _heightController.text.isEmpty ||
        _weightController.text.isEmpty ||
        _goalWeightController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Missing Information"),
            content: Text("Please fill in all information."),
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
    } else {
      selectedOptionInfo?[4] = _goalWeightController.text;
      Switch3and4 = true;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => choseTarget(display: 3, baseUrl: MyApp.baseUrl),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(left: 15, right: 15, bottom: 15),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 10,
              ),
              Text(
                'Ideal Weight Calculator  ',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15),
              Text(
                'Your Sex: ',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 7),
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _sexController,
                  enabled: false,
                  style: TextStyle(
                    color: const Color.fromARGB(255, 32, 32, 32),
                    fontSize: 17,
                  ),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    // prefixIcon: Icon(Icons.person),
                  ),
                ),
              ),
              SizedBox(height: 15),
              Text(
                'Your Age: ',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 7),
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _ageController,
                  style: TextStyle(
                    color: const Color.fromARGB(255, 32, 32, 32),
                    fontSize: 17,
                  ),
                  enabled: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    // prefixIcon: Icon(Icons.person),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Your Height in Centimeters: ',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 7),
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _heightController,
                  style: TextStyle(
                    color: const Color.fromARGB(255, 32, 32, 32),
                    fontSize: 17,
                  ),
                  enabled: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    // prefixIcon: Icon(Icons.person),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Your Weight in Kilograms: ',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 7),
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _weightController,
                  style: TextStyle(
                    color: const Color.fromARGB(255, 32, 32, 32),
                    fontSize: 17,
                  ),
                  enabled: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    // prefixIcon: Icon(Icons.person),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Your Goal Weight in Kilograms is: ',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 7),
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _goalWeightController,
                  style: TextStyle(
                    color: const Color.fromARGB(255, 32, 32, 32),
                    fontSize: 17,
                  ),
                  enabled: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    // prefixIcon: Icon(Icons.person),
                  ),
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Based on J. D. Robinson Formula',
                style:
                    TextStyle(color: const Color.fromARGB(255, 240, 111, 111)),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      CalGoalWeight();
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Color.fromARGB(255, 247, 246, 255)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    child: Text(
                      'Calculate',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _DoneButton();
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.blue),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    child: Text(
                      'Done',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TDEEResult extends StatefulWidget {
  @override
  _TDEEResultClassState createState() => _TDEEResultClassState();
}

class _TDEEResultClassState extends State<TDEEResult> {
  TextEditingController _TDEEController = TextEditingController();
  
  TextEditingController _TDEEAFTERController = TextEditingController();

  String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  bool isDropdownDisabled = false;
  late double originalTDEE;

  Future<void> TDEESubmit() async {
    try {
      var url = Uri.parse('${MyApp.baseUrl}/fill');
      var response = await http.post(
        url,
        body: jsonEncode({
          'email': signedInUserEmail,
          'target': SelectedForTDEE![0],
          'activity': SelectedForTDEE![1],
          'sex': SelectedForTDEE![2],
          'age': SelectedForTDEE![3],
          'height': SelectedForTDEE![4],
          'weight': SelectedForTDEE![5],
          'goalWeight': SelectedForTDEE![6],
          'beforeTDEE': SelectedForTDEE![7],
          'afterTDEE':AFTERTDEE,
          'burn':SelectedForTDEE![7],
                     
          'date': formattedDate,
          'weeklyPer':selectedChoiceWeekly,
          'carbsPer': '50',
          'protienPer': '25',
          'fatPer': '25',
          'workWeek': '4',
          'minWork': '60',
          'totFat': calculateFat(SelectedForTDEE![7]),
          'satFat': calculateSaturatedFat(SelectedForTDEE![7]),
          'protein': calculateProtein(SelectedForTDEE![7]),
          'sodium': calculateSodium(SelectedForTDEE![2]),
          'potassium': calculatePotassium(SelectedForTDEE![2]),
          'cholesterol': calculateCholesterol(SelectedForTDEE![2]),
          'carbs': calculateCarbohydrates(SelectedForTDEE![7]),
          'fiber': calculateFiber(SelectedForTDEE![2]),
          'sugar': calculateSugar(SelectedForTDEE![2]),

          // email:String,
          // TDEE:String,
          // target: String,
          // activity: String,
          // sex: String,
          // age: String,
          // height: String,
          // weight: String,
          // goalWeight: String,
          // date: String,
          // carbsPer:String,
          // protienPer:String,
          // fatPer: String,
          // workWeek:String,
          // minWork:String,

          // totFat: String,
          // satFat: String,
          // protein: String,
          // sodium: String,
          // potassium: String,
          // cholesterol: String,
          // carbs: String,
          // fiber: String,
          // sugar: String,
        }),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        // Signup successful
        print('TDEE inserted succesfully');
        for (int i = 0; i < SelectedForTDEE!.length; i++) {
          print('SelectedForTDEE[$i]: ${SelectedForTDEE![i]}\n');
        }

        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.bottomSlide,
          title: 'Signed Up Successfully',
          desc: 'Congrats for Sign Up!!',
          btnOkOnPress: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginPage(baseUrl: MyApp.baseUrl),
                ));
          },
        )..show();
        // Navigate to login page
      } else {
        // Some other error happened
        print('Sending TDEE failed: ${response.statusCode}');
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



    Future<void> TDEECoachSubmit() async {
    try {
      var url = Uri.parse('${MyApp.baseUrl}/fill');
      var response = await http.post(
        url,
        body: jsonEncode({
          'email': signedInUserEmail,
          'target': SelectedForTDEE![0],
          'activity': SelectedForTDEE![1],
          'sex': SelectedForTDEE![2],
          'age': SelectedForTDEE![3],
          'height': SelectedForTDEE![4],
          'weight': SelectedForTDEE![5],
          'goalWeight': SelectedForTDEE![6],
          'beforeTDEE': SelectedForTDEE![7],
          'afterTDEE':AFTERTDEE,
          'burn':SelectedForTDEE![7],
                     
          'date': formattedDate,
          'weeklyPer':selectedChoiceWeekly,
          'carbsPer': '50',
          'protienPer': '25',
          'fatPer': '25',
          'workWeek': '4',
          'minWork': '60',
          'totFat': calculateFat(SelectedForTDEE![7]),
          'satFat': calculateSaturatedFat(SelectedForTDEE![7]),
          'protein': calculateProtein(SelectedForTDEE![7]),
          'sodium': calculateSodium(SelectedForTDEE![2]),
          'potassium': calculatePotassium(SelectedForTDEE![2]),
          'cholesterol': calculateCholesterol(SelectedForTDEE![2]),
          'carbs': calculateCarbohydrates(SelectedForTDEE![7]),
          'fiber': calculateFiber(SelectedForTDEE![2]),
          'sugar': calculateSugar(SelectedForTDEE![2]),
 
        }),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        // Signup successful
        print('TDEE inserted succesfully');
        for (int i = 0; i < SelectedForTDEE!.length; i++) {
          print('SelectedForTDEE[$i]: ${SelectedForTDEE![i]}\n');
        }

        // AwesomeDialog(
        //   context: context,
        //   dialogType: DialogType.success,
        //   animType: AnimType.bottomSlide,
        //   title: 'Signed Up Successfully',
        //   desc: 'Congrats for Sign Up!!',
        //   btnOkOnPress: () {
        //     Navigator.pushReplacement(
        //         context,
        //         MaterialPageRoute(
        //           builder: (context) => LoginPage(baseUrl: MyApp.baseUrl),
        //         ));
        //   },
        // )..show();
        // Navigate to login page
      } else {
        // Some other error happened
        print('Sending TDEE failed: ${response.statusCode}');
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
// Functions to calculate nutrition values based on TDEE and percentages

  String calculateFat(String tdee) {
    double tdeeNum = double.parse(tdee);
    double fatPercentage = 0.25; // Assuming 25% fat intake
    double fatCalories = tdeeNum * fatPercentage;
    double fatGrams = fatCalories / 9; // 9 calories per gram of fat
    return fatGrams.toStringAsFixed(2);
  }

  String calculateSaturatedFat(String tdee) {
    double tdeeNum = double.parse(tdee);
    double saturatedFatPercentage =
        0.1; // Assuming 10% of fat intake is saturated fat
    double saturatedFatCalories = tdeeNum * saturatedFatPercentage;
    double saturatedFatGrams =
        saturatedFatCalories / 9; // 9 calories per gram of fat
    return saturatedFatGrams.toStringAsFixed(2);
  }

  String calculateProtein(String tdee) {
    double tdeeNum = double.parse(tdee);
    double proteinPercentage = 0.25; // Assuming 25% protein intake
    double proteinCalories = tdeeNum * proteinPercentage;
    double proteinGrams = proteinCalories / 4; // 4 calories per gram of protein
    return proteinGrams.toStringAsFixed(2);
  }

    String calculateCarbohydrates(String tdee) {
    double tdeeNum = double.parse(tdee);
    double carbsPercentage = 0.50; // Assuming 50% carbohydrate intake
    double carbCalories = tdeeNum * carbsPercentage;
    double carbGrams = carbCalories / 4; // 4 calories per gram of carbohydrate
    return carbGrams.toStringAsFixed(2);
  }


  String calculateSodium(String sex) {
    if (sex == 'male') {
      return '2300'; // Max sodium intake for males
    } else {
      return '2300'; // Max sodium intake for females
    }
  }

  String calculatePotassium(String sex) {
    return '4700'; // Adequate intake for both males and females
  }

  String calculateCholesterol(String sex) {
    return '300'; // Max cholesterol intake
  }


  String calculateFiber(String sex) {
    if (sex == 'male') {
      return '38'; // Fiber recommendation for males
    } else {
      return '25'; // Fiber recommendation for females
    }
  }

  String calculateSugar(String sex) {
    if (sex == 'male') {
      return '36'; // Max added sugar intake for males
    } else {
      return '25'; // Max added sugar intake for females
    }
  }

  @override
  void initState() {
    super.initState();
    if (SelectedForTDEE?.isNotEmpty ?? false) {
      //0-target 1-activity 2-sex 3-age 4-height 5-weight 6-goalweight
      double heightInCm = double.parse(SelectedForTDEE![4]);
      double weightInKg = double.parse(SelectedForTDEE![5]);
      int age = int.parse(SelectedForTDEE![3]);
      String activityLevel = SelectedForTDEE![1];
      String sex = SelectedForTDEE![2];

      // calculate BMR
      double bmr = 0.0;
      if (sex == "Male") {
        bmr = (10 * weightInKg) + (6.25 * heightInCm) - (5 * age) + 5;
      } else if (sex == "Female") {
        bmr = (10 * weightInKg) + (6.25 * heightInCm) - (5 * age) - 161;
      }
      // apply activity factor
      double activityFactor = 1.2;
      switch (activityLevel) {
        case "Not Very Active":
          print("Not Very Active switch--->" + activityLevel);
          activityFactor = 1.2;
          break;
        case "Lightly Active":
          print("Lightly Active switch--->" + activityLevel);
          activityFactor = 1.375;
          break;
        case "Active":
          print(" Active switch--->" + activityLevel);
          activityFactor = 1.55;
          break;
        case "Very Active":
          print("Very Active switch--->" + activityLevel);
          activityFactor = 1.9;
          break;
      }

      // calculate tdee
      print(activityFactor);
      print(bmr);
      double tdee = bmr * activityFactor;
      print(tdee);
      _TDEEController.text = tdee.round().toStringAsFixed(1);
      SelectedForTDEE![7] = _TDEEController.text;
    }

    // Assuming SelectedForTDEE is already defined and contains the necessary data
    if (SelectedForTDEE![0] == 'Lose Weight') {
      selectedChoiceWeekly = '0.5kg Lose per week';
      isDropdownDisabled = false;
    } else if (SelectedForTDEE![0] == 'Gain Weight') {
      selectedChoiceWeekly = '0.5kg Gain per week';
      isDropdownDisabled = false;
    } else if (SelectedForTDEE![0] == 'Maintain Weight') {
      selectedChoiceWeekly = 'Maintain Weight';
      isDropdownDisabled = true;
    }

      // Store the original TDEE value
    originalTDEE = double.parse(SelectedForTDEE![7]);

    // Set the initial value of the dropdown and determine if it should be disabled
    if (SelectedForTDEE![0] == 'Lose Weight') {
      selectedChoiceWeekly = '0.5kg Lose per week';
      isDropdownDisabled = false;
    } else if (SelectedForTDEE![0] == 'Gain Weight') {
      selectedChoiceWeekly = '0.5kg Gain per week';
      isDropdownDisabled = false;
    } else if (SelectedForTDEE![0] == 'Maintain Weight') {
      selectedChoiceWeekly = 'Maintain Weight';
      isDropdownDisabled = true;
    }
    
    // Set initial value for _TDEEAFTERController
    _updateTDEE();

  }

  


  void _updateTDEE() {
    double newTDEE = originalTDEE;

    if (selectedChoiceWeekly == '0.5kg Lose per week') {
      newTDEE = originalTDEE - 550;
    } else if (selectedChoiceWeekly == '1kg Lose per week') {
      newTDEE = originalTDEE - 1100;
    } else if (selectedChoiceWeekly == '0.5kg Gain per week') {
      newTDEE = originalTDEE + 550;
    } else if (selectedChoiceWeekly == '1kg Gain per week') {
      newTDEE = originalTDEE + 1100;
    }

    setState(() {
   

         _TDEEAFTERController.text = newTDEE.round().toStringAsFixed(1);
      AFTERTDEE = newTDEE.round().toStringAsFixed(1);
      print(SelectedForTDEE![7]);
      print(selectedChoiceWeekly);
    });
  }


  @override
  void dispose() {
    _TDEEController.dispose();
    super.dispose();
  }

     @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(left: 15, right: 15, bottom: 15),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 10,
              ),
              Text(
                'TDEE Calculator  ',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30),
              Text(
                'Your TDEE: ',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 7),
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _TDEEController,
                  enabled: false,
                  style: TextStyle(
                    color: const Color.fromARGB(255, 32, 32, 32),
                    fontSize: 17,
                  ),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 5),
              Text(
                '              Maintain TDEE  \n Based on Mifflin-St Jeor Formula',
                style: TextStyle(
                    color: const Color.fromARGB(255, 240, 111, 111), fontSize: 16),
              ),

               SizedBox(height: 10),
              Divider(thickness: 2, color: Colors.grey),
              SizedBox(height: 10),

              Text(
                'Choose Weekly Target:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              DropdownButton<String>(
                value: selectedChoiceWeekly,
                onChanged: isDropdownDisabled
                    ? null
                    : (String? newValue) {
                        setState(() {
                          selectedChoiceWeekly = newValue!;
                          _updateTDEE();
                        });
                      },
                items: _getDropdownItems(),
                disabledHint: Text('Maintain Weight'),
              ),
              SizedBox(height: 30),
              Text(
                'NEW TDEE: ',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 7),
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _TDEEAFTERController,
                  enabled: false,
                  style: TextStyle(
                    color: const Color.fromARGB(255, 32, 32, 32),
                    fontSize: 17,
                  ),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              choseTarget(display: 3, baseUrl: MyApp.baseUrl),
                        ),
                      );
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Color.fromARGB(255, 247, 246, 255)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    child: Text(
                      'Back',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      TDEESubmit();
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    child: Text(
                      'Finish User',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Text(
                'Continue Information For Coach',
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
              ElevatedButton(
                onPressed: () {
                  TDEECoachSubmit();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>SignupCoachPage(baseUrl: MyApp.baseUrl , email: signedInUserEmail,),
                    ),
                  );
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                child: Text(
                  'Coaches',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _getDropdownItems() {
    if (SelectedForTDEE![0] == 'Lose Weight') {
      return <String>['0.5kg Lose per week', '1kg Lose per week']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList();
    } else if (SelectedForTDEE![0] == 'Gain Weight') {
      return <String>['0.5kg Gain per week', '1kg Gain per week']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList();
    } else {
      return <String>['Maintain Weight']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList();
    }
  }
}
