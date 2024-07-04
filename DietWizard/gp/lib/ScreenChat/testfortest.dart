// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// class MyWidget extends StatefulWidget {
//   final String baseUrl;

//   MyWidget({required this.baseUrl});

//   @override
//   _MyWidgetState createState() => _MyWidgetState();
// }

// class _MyWidgetState extends State<MyWidget> {
//   List<dynamic> coaches = []; // List to store fetched coach data
//   List<dynamic> searchResults = []; // List to store search results
//   TextEditingController _searchController = TextEditingController();
//   PageController _page2ndController = PageController();
//   int _current2ndPage = 0;

//   @override
//   void initState() {
//     super.initState();
//     fetchCoaches();
//     _searchController.addListener(_onSearchChanged);
//   }

//   Future<void> fetchCoaches() async {
//     final response = await http.get(Uri.parse('${widget.baseUrl}/getallcoach'));

//     if (response.statusCode == 200) {
//       if (mounted) { // Check if the widget is still mounted
//         setState(() {
//           coaches = json.decode(response.body);
//           searchResults = coaches; // Initialize search results with all coaches
//         });
//       }
//     } else {
//       print('Failed to fetch coaches. Error: ${response.statusCode}');
//     }
//   }

//   void _onSearchChanged() {
//     setState(() {
//       if (_searchController.text.isEmpty) {
//         searchResults = coaches;
//       } else {
//         searchResults = coaches.where((coach) {
//           return coach['username']
//               .toLowerCase()
//               .contains(_searchController.text.toLowerCase());
//         }).toList();
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _searchController.removeListener(_onSearchChanged);
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: TextField(
//             controller: _searchController,
//             decoration: InputDecoration(
//               labelText: 'Search by coach name',
//               border: OutlineInputBorder(),
//             ),
//           ),
//         ),
//         Container(
//           height: 480, // Adjust the height as needed
//           child: PageView(
//             controller: _page2ndController,
//             onPageChanged: (int page) {
//               setState(() {
//                 _current2ndPage = page;
//               });
//             },
//             children: [
//               ListView.builder(
//                 itemCount: searchResults.length,
//                 itemBuilder: (context, index) {
//                   final coach = searchResults[index];

//                   // print('Coach Data: ${coach}');
//                   // print('Data Field: ${coach['data']}');
//                   // print('Binary Field: ${coach['data']['\$binary']}');
//                   // print('Base64 Field: ${coach['data']['\$binary']['base64']}');
//                   // Directly access the list of integers in the 'data' field
//                   List<dynamic> imageDataList = coach['data']['data'];
//                   // Convert the list of integers to Uint8List
//                   Uint8List decodedImage = Uint8List.fromList(imageDataList.cast<int>());

//                   return CoahcesWidget2(
//                     coachName: coach['username'],
//                     imageDataCoach: decodedImage,
//                     textBelowImage: "Let's reach your goals together",
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

// Widget CoahcesWidget2({
//   required String coachName,
//   required Uint8List imageDataCoach,
//   required String textBelowImage,
// }) {
//   return Card(
//     child: Padding(
//       padding: EdgeInsets.all(20.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             "Coach",
//             style: TextStyle(
//               fontSize: 18.0,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           SizedBox(height: 14.0),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               Column(
//                 children: [
//                   Text(
//                     coachName,
//                     style: TextStyle(
//                       fontSize: 18.0,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   SizedBox(height: 10),
//                   GestureDetector(
//                     onTap: () {},
//                     child: SizedBox(
//                       width: 250,
//                       child: Image.memory(
//                         imageDataCoach,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           SizedBox(height: 10.0),
//           Center(
//             child: Text(
//               textBelowImage,
//               style: TextStyle(
//                 fontSize: 16.0,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           SizedBox(height: 10.0),
//           Center(
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   'Rating: ',
//                   style: TextStyle(
//                     fontSize: 16.0,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 RatingBarIndicator(
//                   rating: 4.5, // Example rating
//                   itemBuilder: (context, index) => Icon(
//                     Icons.star,
//                     color: Colors.amber,
//                   ),
//                   itemCount: 5,
//                   itemSize: 24.0,
//                   direction: Axis.horizontal,
//                 ),
//                 SizedBox(width: 8),
//                 Text(
//                   '4.5', // Example rating number
//                   style: TextStyle(
//                     fontSize: 16.0,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.orange,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(height: 10.0),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               ElevatedButton.icon(
//                 onPressed: () async {
//                   print("Info Coach");
//                   fetchCoachInformation(coachName);
//                 },
//                 style: ElevatedButton.styleFrom(
//                   side: BorderSide(color: Colors.blue, width: 2),
//                   padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                 ),
//                 icon: Icon(Icons.info),
//                 label: Text(
//                   'Info',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               ElevatedButton.icon(
//                 onPressed: () async {
//                   print("Rating Coach");
//                   // Show rating dialog
//                   showDialog(
//                     context: context,
//                     builder: (BuildContext context) {
//                       return AlertDialog(
//                         title: Text("Rate the Coach"),
//                         content: RatingForm(
//                           onSubmit: (newRating) {
//                             // Handle rating submission
//                             Navigator.of(context).pop();
//                           },
//                         ),
//                       );
//                     },
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   side: BorderSide(color: Colors.blue, width: 2),
//                   padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                 ),
//                 icon: Icon(Icons.rate_review),
//                 label: Text(
//                   'Rate',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               ElevatedButton.icon(
//                 onPressed: () async {
//                   print("Chat Coach");
//                   await fetchCoachInformation2(coachName);
//                   print(GlobalEmail);
//                   print(GlobalCoachEmail);
//                   print(GlobalUsername);

//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => chatScreen(
//                         username: GlobalUsername,
//                         baseUrl: MyApp.baseUrl,
//                         signInConstructorEmail: GlobalEmail,
//                         chatwithConstructorEmail: GlobalCoachEmail,
//                       ),
//                     ),
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   side: BorderSide(color: Colors.blue, width: 2),
//                   padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                 ),
//                 icon: Icon(Icons.messenger),
//                 label: Text(
//                   'Contact',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     ),
//   );
// }

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
//         ElevatedButton(
//           onPressed: () {
//             widget.onSubmit(_currentRating);
//           },
//           child: Text("Submit"),
//         ),
//       ],
//     );
//   }
// }
