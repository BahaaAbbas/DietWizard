import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_dialog/awesome_dialog.dart';

class coach {
  final Uint8List imageData;

  coach({
    required this.imageData,
  });
}

class CoachInformations extends StatefulWidget {
  final String baseUrl;
  const CoachInformations({Key? key, required this.baseUrl}) : super(key: key);

  @override
  _CoachInformationsState createState() => _CoachInformationsState();
}

class _CoachInformationsState extends State<CoachInformations> {
  List<Map<String, dynamic>>? _coachInfoList;
  List<coach> coachs = [];
  Future<void> fetchCoachInformation(BuildContext context) async {
    final url = Uri.parse('${widget.baseUrl}/GetAllcoachPageInformation');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final coachInfoList = json.decode(response.body);
        final List<dynamic> coachData = jsonDecode(response.body);
        setState(() {
          _coachInfoList = List<Map<String, dynamic>>.from(coachInfoList);
          coachs = coachData.map((coachsData) {
            final List<int> bufferData =
                List<int>.from(coachsData['data']['data']);
            final Uint8List imageData = Uint8List.fromList(bufferData);

            return coach(
              imageData: imageData,
            );
          }).toList();
        });
      } else if (response.statusCode == 404) {
        Widget errorWidget = _buildErrorCard('Coach not found.');
        setState(() {
          _coachInfoList = null;
        });
      } else {
        Widget errorWidget =
            _buildErrorCard('Failed to fetch coach information.');
        setState(() {
          _coachInfoList = null;
          ;
        });
      }
    } catch (error) {
      Widget errorWidget =
          _buildErrorCard('Failed to fetch coach information: $error');
      setState(() {
        _coachInfoList = null;
        ;
      });
    }
  }

  Future<void> deleteCoach(int idcoach) async {
    final url = Uri.parse('${widget.baseUrl}/deletecoach/$idcoach');

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        fetchCoachInformation(context);
      } else {
        // Handle errors here
        print('Failed to delete coach: ${response.statusCode}');
      }
    } catch (error) {
      // Handle errors here
      print('Failed to delete coach: $error');
    }
  }



  Future<void> ActivateCoach(int idcoach) async {
    final url = Uri.parse('${widget.baseUrl}/activatecoach/$idcoach');

    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        fetchCoachInformation(context);
      } else {
        // Handle errors here
        print('Failed to delete coach: ${response.statusCode}');
      }
    } catch (error) {
      // Handle errors here
      print('Failed to delete coach: $error');
    }
  }







  Widget _buildCoachCards(List<Map<String, dynamic>> coachInfoList) {
    return Column(
      children: coachInfoList.map((coachInfo) {
        //  final coach = coachs[index];
        return SizedBox(
          height: 520, // Adjust the height as needed
          width: 400,
          child: Card(
            child: Stack(
              children: [
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    icon: Icon(Icons.delete),
                    color: Colors.red,
                    onPressed: () {
                      AwesomeDialog(
                        context: context,
                        dialogType: DialogType
                            .warning, // You can choose different dialog types like DialogType.info, DialogType.success, DialogType.error, etc.
                        animType: AnimType.scale,
                        title: 'Confirm Delete',
                        desc: 'Are you sure you want to delete this coach',
                        btnCancelText: 'Cancel',
                        btnCancelOnPress: () {},
                        btnOkText: 'Delete',
                        btnOkOnPress: () {
                          // Call your delete function here passing the coach's id
                          deleteCoach(coachInfo['idcoach']);
                          // Show success dialog
                          AwesomeDialog(
                            context: context,
                            dialogType: DialogType.success,
                            animType: AnimType.rightSlide,
                            title: 'Delete Coach',
                            desc: 'Deleted successfully',
                            width: 600,
                            btnOkText: 'Close',
                            btnOkOnPress: () {},
                          )..show();
                        },
                      )..show();
                    },
                  ),
                ),

                 Positioned(
                  top: 10,
                  right: 50,
                  child: IconButton(
                    icon: Icon(Icons.edit),
                    color: Colors.green,
                    onPressed: () {
                      AwesomeDialog(
                        context: context,
                        dialogType: DialogType.warning,  
                        animType: AnimType.scale,
                        title: 'Confirm Activate',
                        desc: 'Are you sure you want to Activate this coach',
                        btnCancelText: 'Cancel',
                        btnCancelOnPress: () {},
                        btnOkText: 'Activate',
                        btnOkOnPress: () {
                          // Call your delete function here passing the coach's id
                          ActivateCoach(coachInfo['idcoach']);
                          // Show success dialog
                          AwesomeDialog(
                            context: context,
                            dialogType: DialogType.success,
                            animType: AnimType.rightSlide,
                            title: 'Activate Coach',
                            desc: 'Activate successfully',
                            width: 600,
                            btnOkText: 'Close',
                            btnOkOnPress: () {},
                          )..show();
                        },
                      )..show();
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      Text(
                        '${coachInfo['firstname']} ${coachInfo['lastname']}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      SizedBox(height: 8),
                       Center(
                        child: CircleAvatar(
                          radius: 100, // Adjust the radius as needed
                          backgroundImage: MemoryImage(
                            coachs[coachInfoList.indexOf(coachInfo)].imageData,
                          ),
                        ),
                      ),
                       Text(
                        'Username: ${coachInfo['username']}',
                          style: TextStyle(fontSize: 16),
                      ),
                      
                      Text(
                        'Age: ${coachInfo['age']}',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Gender: ${coachInfo['gender']}',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Years of Experience: ${coachInfo['yearsexperiences']}',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Qualifications: ${coachInfo['qualifications']}',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Email: ${coachInfo['email']}',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Number of Trainees: ${coachInfo['Numberoftrainees']}',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Weight: ${coachInfo['Weight']}',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Height: ${coachInfo['height']}',
                        style: TextStyle(fontSize: 16),
                      ),
                       Text(
                        'Activation: ${coachInfo['Activate']}',
                        style: TextStyle(fontSize: 16),
                      ),                                        
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildErrorCard(String errorMessage) {
    return Card(
      child: ListTile(
        title: Text('Error'),
        subtitle: Text(errorMessage),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Coaches Informations',
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
                'https://photos.peopleimages.com/picture/202309/2931335-men-pushup-and-together-for-fitness-on-floor-with-high-five-synergy-and-motivation-in-gym-for-body-health.-personal-trainer-support-and-connection-for-exercise-workout-and-training-with-teamwork-fit_400_400.jpg',
                width: 400,
                height: 200,
              ),
              SizedBox(height: 30),

              ElevatedButton(
                onPressed: () {
                  fetchCoachInformation(context);
                },
                child: Text(
                  'Show Coach Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Show the coach information widgets if available
              if (_coachInfoList != null) _buildCoachCards(_coachInfoList!),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
