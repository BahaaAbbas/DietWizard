import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ExerciseListPage extends StatefulWidget {
  final String category;
  final String baseUrl;

  ExerciseListPage({Key? key, required this.baseUrl, required this.category})
      : super(key: key);

  @override
  _ExerciseListPageState createState() => _ExerciseListPageState();
}

class _ExerciseListPageState extends State<ExerciseListPage> {
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
                                  Center(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        // Add functionality here
                                        AwesomeDialog(
                                          context: context,
                                          dialogType: DialogType.info,
                                          animType: AnimType.rightSlide,
                                          // width: nutritionalInfoWidgets.length * 500.0,
                                          title: 'Exercise Details',
                                          desc:"Name Exercise: "+ exercise.name +"\n"+"Time: "+ exercise.time +"\n"+"Calories: "+ exercise.calories +"\n"+"Description: "+ exercise.description,
                                          descTextStyle: TextStyle(fontSize: 18),
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
                                  ),

                                  // SizedBox(height: 5),
                                  // Text(
                                  //   exercise.name,
                                  //   style: TextStyle(
                                  //     fontWeight: FontWeight.bold,
                                  //   ),
                                  // ),

                                  // SizedBox(height: 5),
                                  // Text(
                                  //   exercise.description ,
                                  //   style: TextStyle(
                                  //     fontWeight: FontWeight.bold,
                                  //   ),
                                  // ),
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
