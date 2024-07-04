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
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:path/path.dart' as path;
import 'package:gp/welcome.dart';
import 'package:gp/globals.dart' as globals;

List<Map<String, dynamic>> savedPhotos = [];

class ProgressPhotocoach extends StatefulWidget {
  final String baseUrl;
  final String name;
  final String email;

  const ProgressPhotocoach({
    Key? key,
    required this.baseUrl,
    required this.name,
    required this.email,
  }) : super(key: key);

  @override
  State<ProgressPhotocoach> createState() => _ProgressPhotocoachState();
}

class _ProgressPhotocoachState extends State<ProgressPhotocoach> {
  Future<void> showprogressphotos() async {
    try {
      var url = Uri.parse('${widget.baseUrl}/showprogressphotos');
      var response = await http.post(
        url,
        body: jsonEncode({
          'email': widget.email,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        List<dynamic> formattedLogs = responseData['formattedLogs'];

        setState(() {
          savedPhotos.clear();
          for (var logEntry in formattedLogs) {
            String date = logEntry['date'];
            DateTime dateTime = DateTime.parse(date);

            String weight = logEntry['weight'];

            String photoID = logEntry['photoID'];

            // Iterate through each image in the 'images' list
            for (var image in logEntry['images']) {
              String imageData =
                  image['data']; // Retrieve image data as base64 string

              String contentType =
                  image['contentType']; // Retrieve image content type

              // Decode base64 string to Uint8List
              Uint8List decodedImage = base64Decode(imageData);

              // Add the image details to savedPhotos list
              savedPhotos.add({
                'date': dateTime,
                'weight': weight,
                'image': decodedImage,
                'photoID': photoID,
              });
            }
          }
        });
      } else {
        // Handle error
        print('Show photos failed: ${response.statusCode}');
        print(
            'Response body: ${response.body}'); // back here for  Response body: "User does not have any logged photos yet."
      }
    } catch (error) {
      // Handle error
      print('Error: $error');
    }
  }

  void navigateToAddPhotoPage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddPhotoPage(
            imageFile: File(pickedFile.path),
            email: widget.email,
            baseUrl: widget.baseUrl,
            refreshPhotos: showprogressphotos, // Pass the function
          ),
        ),
      ).then((value) {
        if (value != null) {
          setState(() {
            // savedPhotos.add(value);
          });
        }
      });
    }
  }

  void navigateToEditPhotoPage(int index) async {
    final updatedPhotoDetails = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPhotoPage(
          photoDetails: savedPhotos[index],
          email: widget.email,
          baseUrl: widget.baseUrl,
          refreshPhotos: showprogressphotos, // Pass the function
        ),
      ),
    );

    if (updatedPhotoDetails != null) {
      setState(() {
        //savedPhotos[index] = updatedPhotoDetails;
        // showprogressphotos();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    savedPhotos.clear();
    showprogressphotos();
  }

  @override
  Widget build(BuildContext context) {
    if (savedPhotos.isEmpty) {
      return Scaffold(
        // appBar: AppBar(
        //   backgroundColor: Colors.redAccent,
        //   title: Row(
        //     children: [
        //       SizedBox(width: 5),
        //       Image.asset(
        //         'images/img6.png',
        //         height: 87,
        //         width: 75,
        //       ),
        //       SizedBox(width: 35),
        //       Padding(
        //         padding: const EdgeInsets.only(top: 8.0),
        //         child: Text(
        //           'Progress Photo',
        //           style: TextStyle(
        //             fontSize: 24,
        //             fontWeight: FontWeight.bold,
        //             color: Color.fromARGB(255, 2, 6, 248),
        //           ),
        //         ),
        //       )
        //     ],
        //   ),
        //   actions: [
        //     Padding(
        //       padding: EdgeInsets.only(right: 8, top: 2.0),
        //       child: IconButton(
        //         onPressed: () {
        //           // Navigator.pushReplacement(
        //           //   context,
        //           //   MaterialPageRoute(
        //           //     builder: (context) => LoginPage(baseUrl: widget.baseUrl),
        //           //   ),
        //           // );
        //           setState(() {
        //             showprogressphotos();
        //           });
        //         },
        //         icon: Icon(
        //           Icons.home,
        //           color: Color.fromARGB(255, 104, 159, 221),
        //           size: 35,
        //         ),
        //       ),
        //     ),
        //   ],
        // ),
        body: Column(
          children: [
            SizedBox(height: 20),
            // ElevatedButton(
            //   onPressed: () {
            //     showModalBottomSheet(
            //       context: context,
            //       builder: (BuildContext context) {
            //         return Container(
            //           child: Wrap(
            //             children: <Widget>[
            //               ListTile(
            //                 leading: Icon(Icons.photo_library),
            //                 title: Text('Pick from gallery'),
            //                 onTap: () {
            //                   navigateToAddPhotoPage(ImageSource.gallery);
            //                   Navigator.pop(context);
            //                 },
            //               ),
            //               ListTile(
            //                 leading: Icon(Icons.camera_alt),
            //                 title: Text('Use Camera'),
            //                 onTap: () {
            //                   navigateToAddPhotoPage(ImageSource.camera);
            //                   Navigator.pop(context);
            //                 },
            //               ),
            //               ListTile(
            //                 leading: Icon(Icons.cancel),
            //                 title: Text('Cancel'),
            //                 onTap: () {
            //                   Navigator.pop(context);
            //                 },
            //               ),
            //             ],
            //           ),
            //         );
            //       },
            //     );
            //   },
            //   style: ElevatedButton.styleFrom(
            //     side: BorderSide(color: Colors.blue, width: 2),
            //   ),
            //   child: Padding(
            //     padding:
            //         const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            //     child: Text(
            //       'Add Photo',
            //       style: TextStyle(
            //         color: Colors.blue,
            //         fontSize: 16,
            //         fontWeight: FontWeight.bold,
            //       ),
            //     ),
            //   ),
            // ),

            SizedBox(height: 30),
            Center(
              child: Text(
                'No progress photos Logged Yet...',
                style: TextStyle(fontSize: 18),
              ),
            ),
            SizedBox(height: 30),
            Expanded(
              child: ListView.builder(
                itemCount: savedPhotos.length,
                itemBuilder: (context, index) {
                  final DateTime date = savedPhotos[index]['date'];

                  final String formattedDate =
                      '${date.month}/${date.day}/${date.year}';

                  Map<String, dynamic> photoDetails = savedPhotos[index];
                  Uint8List imageData = photoDetails['image'];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[200],
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 120,
                            child: Image.memory(
                              imageData,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Date: $formattedDate',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 20),
                                Text(
                                  'Weight: ${savedPhotos[index]['weight']}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    navigateToEditPhotoPage(index);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    side: BorderSide(
                                        color: Colors.blue, width: 2),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    child: Text(
                                      'Show Image',
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
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    } else {
      return Scaffold(
        // appBar:  AppBar(
        //   backgroundColor: Colors.redAccent,
        //   title: Row(
        //     children: [
        //       SizedBox(width: 5),
        //       Image.asset(
        //         'images/img6.png',
        //         height: 87,
        //         width: 75,
        //       ),
        //       SizedBox(width: 35),
        //       Padding(
        //         padding: const EdgeInsets.only(top: 8.0),
        //         child: Text(
        //           'Progress Photo',
        //           style: TextStyle(
        //             fontSize: 24,
        //             fontWeight: FontWeight.bold,
        //             color: Color.fromARGB(255, 2, 6, 248),
        //           ),
        //         ),
        //       )
        //     ],
        //   ),
        //   actions: [
        //     Padding(
        //       padding: EdgeInsets.only(right: 8, top: 2.0),
        //       child: IconButton(
        //         onPressed: () {
        //           Navigator.pushReplacement(
        //                   context,
        //                   CupertinoPageRoute(
        //                     builder: (context) => WelcomePage(
        //                       baseUrl: widget.baseUrl,
        //                       name: widget.name,
        //                       email: widget.email,
                             
        //                     ),
        //                   ),
        //                 );
        //         },
        //         icon: Icon(
        //           Icons.home,
        //           color: Color.fromARGB(255, 104, 159, 221),
        //           size: 35,
        //         ),
        //       ),
        //     ),
        //   ],
        // ),
        body: Column(
          children: [
            SizedBox(height: 20),
            // ElevatedButton(
            //   onPressed: () {
            //     showModalBottomSheet(
            //       context: context,
            //       builder: (BuildContext context) {
            //         return Container(
            //           child: Wrap(
            //             children: <Widget>[
            //               ListTile(
            //                 leading: Icon(Icons.photo_library),
            //                 title: Text('Pick from gallery'),
            //                 onTap: () {
            //                   navigateToAddPhotoPage(ImageSource.gallery);
            //                   Navigator.pop(context);
            //                 },
            //               ),
            //               ListTile(
            //                 leading: Icon(Icons.camera_alt),
            //                 title: Text('Use Camera'),
            //                 onTap: () {
            //                   navigateToAddPhotoPage(ImageSource.camera);
            //                   Navigator.pop(context);
            //                 },
            //               ),
            //               ListTile(
            //                 leading: Icon(Icons.cancel),
            //                 title: Text('Cancel'),
            //                 onTap: () {
            //                   Navigator.pop(context);
            //                 },
            //               ),
            //             ],
            //           ),
            //         );
            //       },
            //     );
            //   },
            //   style: ElevatedButton.styleFrom(
            //     side: BorderSide(color: Colors.blue, width: 2),
            //   ),
            //   child: Padding(
            //     padding:
            //         const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            //     child: Text(
            //       'Add Photo',
            //       style: TextStyle(
            //         color: Colors.blue,
            //         fontSize: 16,
            //         fontWeight: FontWeight.bold,
            //       ),
            //     ),
            //   ),
            // ),

            SizedBox(height: 30),
            Expanded(
              child: ListView.builder(
                itemCount: savedPhotos.length,
                itemBuilder: (context, index) {
                  final DateTime date = savedPhotos[index]['date'];
                  final String formattedDate =
                      '${date.month}/${date.day}/${date.year}';
                  //   '${date.month}/${date.day}/${date.year}';
                  Map<String, dynamic> photoDetails = savedPhotos[index];
                  Uint8List imageData = photoDetails['image'];
                 // print(imageData);
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[200],
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 120,
                            child: Image.memory(
                              imageData, // Assuming savedPhotos[index]['image'] contains the image URL
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Date: $formattedDate',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 20),
                                Text(
                                  'Weight: ${savedPhotos[index]['weight']}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    navigateToEditPhotoPage(index);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    side: BorderSide(
                                        color: Colors.blue, width: 2),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    child: Text(
                                      'Show Image',
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
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }
  }
}

class AddPhotoPage extends StatefulWidget {
  final File imageFile;
  final String email;
  final String baseUrl;
  final VoidCallback? refreshPhotos; // Callback function

  const AddPhotoPage({
    Key? key,
    required this.imageFile,
    required this.email,
    required this.baseUrl,
    this.refreshPhotos, // Receive the callback function
  }) : super(key: key);

  @override
  _AddPhotoPageState createState() => _AddPhotoPageState();
}

class _AddPhotoPageState extends State<AddPhotoPage> {
  DateTime selectedDate = DateTime.now();
  TextEditingController weightController = TextEditingController();

  Future<void> savePhotoDetails() async {
    // Validate that all required data is available
    if (widget.imageFile == null ||
        selectedDate == null ||
        weightController.text.isEmpty ||
        widget.email.isEmpty) {
      print('Error: Missing required data');
      return; // Exit the function early if data is missing
    }

    // Construct the photoDetails map
    final Map<String, dynamic> photoDetails = {
      'image': widget.imageFile,

      'date': selectedDate, // Use the formatted date
      'weight': double.tryParse(weightController.text) ?? 0,
      'email': widget.email, // Include email in photoDetails
    };

    // Create the request
    final url = Uri.parse('${widget.baseUrl}/setprogressphoto');
    final request = http.MultipartRequest('POST', url);

    // Add image if selected
    request.files.add(await http.MultipartFile.fromPath(
      'image',
      photoDetails['image']!.path,
    ));

    // Add other fields to request
    request.fields.addAll({
      'email': photoDetails['email'],
      'date': photoDetails['date'].toString(),
      'weight': photoDetails['weight'].toString(), // Convert weight to String
    });

    // Send the request
    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        print('Photo Reached successfully');
        _showSuccessDialogAddPhoto();
      } else {
        print('Failed to add Photo. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error adding Photo: $e');
    }
  }

  void _showSuccessDialogAddPhoto() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.rightSlide,
      title: 'Photo Added Successfully',
      desc: 'Your Photo has been added successfully.',
      btnOkOnPress: () {
        Navigator.of(context).pop(); // Navigate back to the previous screen

        setState(() {
          widget.refreshPhotos?.call();
        });
      },
    )..show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Photo Details'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.file(widget.imageFile),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2015, 8),
                      lastDate: DateTime(2101),
                    );
                    if (picked != null && picked != selectedDate) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                  child: Text(
                    'Select Date',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
                Text(
                  '${selectedDate.month}/${selectedDate.day}/${selectedDate.year}',
                ),
              ],
            ),
            SizedBox(height: 20),
            TextField(
              controller: weightController,
              decoration: InputDecoration(
                labelText: 'Weight',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    savePhotoDetails();
                  },
                  child: Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class EditPhotoPage extends StatefulWidget {
  final Map<String, dynamic> photoDetails;
  final String email;
  final String baseUrl;
  final VoidCallback? refreshPhotos; // Callback function

  const EditPhotoPage({
    Key? key,
    required this.photoDetails,
    required this.email,
    required this.baseUrl,
    this.refreshPhotos, // Receive the callback function
  }) : super(key: key);

  @override
  _EditPhotoPageState createState() => _EditPhotoPageState();
}

class _EditPhotoPageState extends State<EditPhotoPage> {
  DateTime selectedDate = DateTime.now();
  TextEditingController weightController = TextEditingController();

  late String _imagePath; // Change to String
  DateTime? OLDdate;
  String? photoID;
  @override
  void initState() {
    super.initState();
    selectedDate = widget.photoDetails['date'];
    OLDdate = widget.photoDetails['date'];
    photoID = widget.photoDetails['photoID'];
    print(selectedDate);
    print(OLDdate);
    print(photoID);

    _imagePath = base64Encode(widget.photoDetails['image']);
    weightController.text = widget.photoDetails['weight'].toString();
  }

  void saveEditedPhotoDetails() {
    final updatedPhotoDetails = {
      'image': _imagePath, // Pass image path instead of File
      'date': selectedDate,
      'weight': double.tryParse(weightController.text) ?? 0,
    };
    Navigator.pop(context, updatedPhotoDetails);
  }

  Future<void> updatePhotoDetails() async {
    // Validate that all required data is available
    if (selectedDate == null ||
        weightController.text.isEmpty ||
        widget.email.isEmpty) {
      print('Error: Missing required data');
      return; // Exit the function early if data is missing
    }

    // Construct the photoDetails map
    final Map<String, dynamic> photoDetails = {
      'date': selectedDate, // Use the formatted date
      'weight': double.tryParse(weightController.text) ?? 0,
      'email': widget.email, // Include email in photoDetails
    };

    // Create the request body as JSON
    final Map<String, dynamic> requestBody = {
      'photoID': photoID,
      'email': photoDetails['email'],
      'date': photoDetails['date'].toIso8601String(),
      'olddate': OLDdate!.toIso8601String(), // Convert DateTime to string
      'weight': photoDetails['weight'].toString(), // Convert weight to String
    };

    // Send the request
    try {
      final url = Uri.parse('${widget.baseUrl}/updateprogressphotos');
      final response = await http.post(
        url,
        body: json.encode(requestBody), // Encode request body as JSON
        headers: {
          'Content-Type': 'application/json'
        }, // Set headers for JSON content
      );

      if (response.statusCode == 200) {
        print('Photo Reached successfully');
        _showSuccessDialogupdate();
      } else {
        print('Failed to update Photo. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating Photo: $e');
    }
  }

  Future<void> deletePhotoDetails() async {
    // Validate that all required data is available
    if (selectedDate == null ||
        weightController.text.isEmpty ||
        widget.email.isEmpty) {
      print('Error: Missing required data');
      return; // Exit the function early if data is missing
    }

    // Construct the photoDetails map
    final Map<String, dynamic> photoDetails = {
      'date': selectedDate, // Use the formatted date
      'weight': double.tryParse(weightController.text) ?? 0,
      'email': widget.email, // Include email in photoDetails
    };

    // Create the request body as JSON
    final Map<String, dynamic> requestBody = {
      'photoID': photoID,
      'email': photoDetails['email'],
      'date': photoDetails['date'].toIso8601String(),
      'olddate': OLDdate!.toIso8601String(), // Convert DateTime to string
      'weight': photoDetails['weight'].toString(), // Convert weight to String
    };

    // Send the request
    try {
      final url = Uri.parse('${widget.baseUrl}/deleteprogressphotos');
      final response = await http.post(
        url,
        body: json.encode(requestBody), // Encode request body as JSON
        headers: {
          'Content-Type': 'application/json'
        }, // Set headers for JSON content
      );

      if (response.statusCode == 200) {
        print('Photo Reached successfully');
        _showSuccessDialogdelete();
      } else {
        print('Failed to delete Photo. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting Photo: $e');
    }
  }

  void _showSuccessDialogupdate() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.rightSlide,
      title: 'Photo Updated Successfully',
      desc: 'Your photo has been Updated successfully.',
      btnOkOnPress: () {
        Navigator.of(context).pop(); // Navigate back to the previous screen

        setState(() {
          //_image = null;
          //  _titleController.clear();
          // _contentController.clear();
          widget.refreshPhotos?.call();
        });
      },
    )..show();
  }

  void _showSuccessDialogdelete() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.rightSlide,
      title: 'Photo Deleted',
      desc: 'Your photo has been Deleted.',
      btnOkOnPress: () {
        Navigator.of(context).pop(); // Navigate back to the previous screen

        setState(() {
          widget.refreshPhotos?.call();
        });
      },
    )..show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Show Photo'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image.file(File(_imagePath)), // Convert path to File
            Image.memory(
              base64Decode(_imagePath),
              fit: BoxFit.cover, // Adjust as needed
            ),
      
          ],
        ),
      ),
    );
  }
}
