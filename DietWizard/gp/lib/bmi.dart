import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_dialog/awesome_dialog.dart';

class BMIPage extends StatefulWidget {
  final String baseUrl;
  const BMIPage({Key? key, required this.baseUrl}) : super(key: key);
  @override
  _BMIPageState createState() => _BMIPageState();
}

class _BMIPageState extends State<BMIPage> {
  TextEditingController weightController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  double bmiResult = 0;
  String message = '';

  Future<void> calculateBMI() async {
    if (_validateInputs()) {
      double weight = double.parse(weightController.text);
      double height =
          double.parse(heightController.text) / 100; // convert height to meters

      final response = await http.post(
        Uri.parse('${widget.baseUrl}/calculateBMI'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'weight': weight,
          'height': height,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          bmiResult = jsonResponse['bmi'];
          message = jsonResponse['message'];
        });
      } else {
        setState(() {
          message = 'Failed to calculate BMI';
        });
      }
    } else {
      _showAlertDialog('Please fill in all fields.');
    }
  }

  bool _validateInputs() {
    return weightController.text.isNotEmpty && heightController.text.isNotEmpty;
  }

  void _showAlertDialog(String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.rightSlide,
      title: 'Error',
      desc: 'Please fill in all fields.',
      // btnCancelOnPress: () {},
      btnOkOnPress: () {},
    )..show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'BMI Calculator',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.blue[800],
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          iconSize: 40,
          color: Colors.blue[800],
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          // Add a new actions property here
          IconButton(
            icon: Icon(
                Icons.tips_and_updates_outlined), // Choose your desired icon
            iconSize: 40,
            color: Colors.blue[800],
            onPressed: () {
              AwesomeDialog(
                context: context,
                dialogType: DialogType.info,
                animType: AnimType.rightSlide,
                width: 500,
                body: Container(
                  height: 280, // Set your desired height here
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("                   Range of BMI ",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        SizedBox(height: 20),
                        Text(
                            'bmi = weight / ((height) * (height))\n' +
                                '\n' +
                                'bmi < 18.5  is' +
                                ' Underweight\n' +
                                '\n' +
                                'bmi >= 18.5 and bmi < 25 is Normal weight \n' +
                                '\n' +
                                'bmi >= 25 and bmi < 30 is Overweight \n' +
                                '\n' +
                                'bmi >= 30 is Obesity',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                btnCancelText: 'Close',
                btnCancelOnPress: () {},
              )..show();





              
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        // Add SingleChildScrollView here
        child: Padding(
          padding: EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.network(
                'https://media.licdn.com/dms/image/D4D12AQEN7C96fg33YQ/article-cover_image-shrink_600_2000/0/1704190425684?e=2147483647&v=beta&t=MXnUDyh8xQo_7sdrR-bGHBQZ-xIawXW19CgW4vRIdGM',
                width: 200,
                height: 200,
              ),
              SizedBox(height: 30),
              TextField(
                controller: weightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Weight (kg)'),
              ),
              SizedBox(height: 20),
              TextField(
                controller: heightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Height (cm)'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: calculateBMI,
                child: Text(
                  'Calculate BMI',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'BMI: ${bmiResult.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 10),
              Text(
                message,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
