import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:gp/BottomNav.dart';
import 'package:gp/CoachInformations.dart';
import 'package:gp/ReportPosts.dart';
import 'package:http/http.dart' as http;
import 'CategoryPage.dart';
import 'addproduct.dart';
import 'exerciseslist.dart';
import 'product.dart';
// import 'showexercises.dart';
// import 'signupPage.dart';
import 'bmi.dart';
import 'bfp.dart';

class Market extends StatefulWidget {
  final String baseUrl;
  final String nameuser;
  final String email;

  const Market({Key? key, required this.baseUrl, required this.nameuser, required this.email})
      : super(key: key);

  @override
  _MarketPageState createState() => _MarketPageState();
}

class _MarketPageState extends State<Market> {
  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
    // fetchStatus();
  }

  // Future<void> fetchProducts() async {
  //   final response = await http.get(Uri.parse('${widget.baseUrl}/products'));
  //   if (response.statusCode == 200) {
  //     final List<dynamic> productsData = jsonDecode(response.body);
  //     setState(() {
  //       products = productsData.map((productData) {
  //         final List<int> bufferData =
  //             List<int>.from(productData['data']['data']);
  //         final Uint8List imageData = Uint8List.fromList(bufferData);
  //         return Product(
  //           id: productData['idproduct'],
  //           name: productData['nameproduct'],
  //           price: productData['priceproduct'].toInt(),
  //           count: productData['countproduct'],
  //           imageData: imageData,
  //           description: productData['descriptionproduct'],
  //         );
  //       }).toList();
  //     });
  //   } else {
  //     print('Failed to fetch products. Status code: ${response.statusCode}');
  //   }
  // }


  Future<void> fetchProducts() async {
  final response = await http.get(Uri.parse('${widget.baseUrl}/products'),
        headers: {"Connection": "keep-alive"} 

  );
  if (response.statusCode == 200) {
    final List<dynamic> productsData = jsonDecode(response.body);
    if (mounted) { // Check if the widget is still mounted
      setState(() {
        products = productsData.map((productData) {
          final List<int> bufferData =
              List<int>.from(productData['data']['data']);
          final Uint8List imageData = Uint8List.fromList(bufferData);
          return Product(
            id: productData['idproduct'],
            name: productData['nameproduct'],
            price: productData['priceproduct'].toInt(),
            count: productData['countproduct'],
            imageData: imageData,
            description: productData['descriptionproduct'],
          );
        }).toList();
      });
    }
  } else {
    print('Failed to fetch products. Status code: ${response.statusCode}');
  }
}

@override
void dispose() {
  // Cancel any ongoing requests or timers here if needed
  super.dispose();
}

  Future<String> fetchStatus(String username) async {
    final response =
        await http.get(Uri.parse('${widget.baseUrl}/statuscoach/$username'));
    if (response.statusCode == 200) {
      final dynamic responseBody = jsonDecode(response.body);

      // Check if responseBody is a List and not empty
      if (responseBody is List && responseBody.isNotEmpty) {
        final Map<String, dynamic> status = responseBody[0];
        // Extract the type field and print it
        final type = status['type'];
        // print('The type is: $type');

        // Optionally, update the state with the fetched status
        setState(() {
          // Update the state with the fetched status
          return type;
        });

        return type;
      } else {
        print('Response body is not in expected format: $responseBody');
      }
    } else {
      print('Failed to fetch status. Status code: ${response.statusCode}');
    }

    // Return null if unable to fetch status
    return "null";
  }

  @override
  // Widget build(BuildContext context) {
  //   // print(await fetchStatus(widget.nameuser));
  //   //  late String tt = fetchStatus(widget.nameuser).toString();
  //   //    print("tttt " +tt);

  //   bool showAllCategories =
  //       widget.nameuser == 'Ibrahim' || widget.nameuser == 'bahaa';

  //   return Scaffold(
  //     body: SingleChildScrollView(
  //       child: Container(
  //         padding: EdgeInsets.all(20),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Row(
  //               children: [
  //                 Expanded(
  //                   child: IconButton(
  //                     icon: Icon(Icons.arrow_back),
  //                     iconSize: 40,
  //                     color: Colors.blue[800],
  //                     onPressed: () {
  //                       Navigator.of(context).pop();
  //                     },
  //                   ),
  //                 ),
  //                 Spacer(),
  //                 Spacer(),
  //                 Spacer(),
  //                 Spacer(),
  //                 Spacer(),
  //                 // Padding(
  //                 //   padding: const EdgeInsets.all(8.0),
  //                 //   child: IconButton(
  //                 //     onPressed: () {},
  //                 //     icon: Icon(Icons.menu),
  //                 //     iconSize: 40,
  //                 //     color: Colors.blue[800],
  //                 //   ),
  //                 // ),

  //                 Image.asset(
  //                   'images/img6.png',
  //                   height: 80,
  //                   width: 90,
  //                 ),
  //               ],
  //             ),
  //             SizedBox(height: 30),
  //             Text(
  //               "Categories",
  //               style: TextStyle(
  //                   fontSize: 25,
  //                   fontWeight: FontWeight.bold,
  //                   color: Colors.blue[800]),
  //             ),
  //             SizedBox(height: 30),
  //             Container(
  //               height: 100,
  //               child: ListView(
  //                   scrollDirection: Axis.horizontal,
  //                   children: showAllCategories
  //                       ? [
  //                           Column(
  //                             children: [
  //                               Container(
  //                                 decoration: BoxDecoration(
  //                                   color: Colors.grey[200],
  //                                   borderRadius: BorderRadius.circular(30),
  //                                 ),
  //                                 padding: EdgeInsets.all(10),
  //                                 child: IconButton(
  //                                   onPressed: () {
  //                                     Navigator.push(
  //                                       context,
  //                                       MaterialPageRoute(
  //                                           builder: (context) => BMIPage(
  //                                               baseUrl: widget.baseUrl)),
  //                                     );
  //                                   },
  //                                   icon: Icon(Icons.fitness_center,
  //                                       size: 30, color: Colors.blue[800]),
  //                                 ),
  //                               ),
  //                               Text("BMI",
  //                                   style: TextStyle(
  //                                       fontWeight: FontWeight.bold,
  //                                       color: Colors.blue[800])),
  //                             ],
  //                           ),
  //                           Padding(padding: EdgeInsets.only(left: 10)),
  //                           Column(
  //                             children: [
  //                               Container(
  //                                 decoration: BoxDecoration(
  //                                   color: Colors.grey[200],
  //                                   borderRadius: BorderRadius.circular(30),
  //                                 ),
  //                                 padding: EdgeInsets.all(10),
  //                                 child: IconButton(
  //                                   onPressed: () {
  //                                     Navigator.push(
  //                                       context,
  //                                       MaterialPageRoute(
  //                                           builder: (context) => BfpCalculator(
  //                                               baseUrl: widget.baseUrl)),
  //                                     );
  //                                   },
  //                                   icon: Icon(Icons.boy_rounded,
  //                                       size: 30, color: Colors.blue[800]),
  //                                 ),
  //                               ),
  //                               Text("BFP",
  //                                   style: TextStyle(
  //                                       fontWeight: FontWeight.bold,
  //                                       color: Colors.blue[800])),
  //                             ],
  //                           ),
  //                           Padding(padding: EdgeInsets.only(left: 10)),
  //                           Column(
  //                             children: [
  //                               Container(
  //                                 decoration: BoxDecoration(
  //                                   color: Colors.grey[200],
  //                                   borderRadius: BorderRadius.circular(30),
  //                                 ),
  //                                 padding: EdgeInsets.all(10),
  //                                 child: IconButton(
  //                                   onPressed: () {
  //                                     Navigator.push(
  //                                       context,
  //                                       MaterialPageRoute(
  //                                           builder: (context) =>
  //                                               ImageUploadScreen(
  //                                                   baseUrl: widget.baseUrl)),
  //                                     );
  //                                   },
  //                                   icon: Icon(Icons.add_shopping_cart_rounded,
  //                                       size: 30, color: Colors.blue[800]),
  //                                 ),
  //                               ),
  //                               Text("Add Product",
  //                                   style: TextStyle(
  //                                       fontWeight: FontWeight.bold,
  //                                       color: Colors.blue[800])),
  //                             ],
  //                           ),
  //                           Padding(padding: EdgeInsets.only(left: 10)),
  //                           Column(
  //                             children: [
  //                               Container(
  //                                 decoration: BoxDecoration(
  //                                   color: Colors.grey[200],
  //                                   borderRadius: BorderRadius.circular(30),
  //                                 ),
  //                                 padding: EdgeInsets.all(10),
  //                                 child: IconButton(
  //                                   onPressed: () {
  //                                     Navigator.push(
  //                                       context,
  //                                       MaterialPageRoute(
  //                                           builder: (context) =>
  //                                               ImageDisplayScreen(
  //                                                 baseUrl: widget.baseUrl,
  //                                                 nameuser: widget.nameuser,
  //                                               )),
  //                                     );
  //                                   },
  //                                   icon: Icon(Icons.shopping_bag_outlined,
  //                                       size: 30, color: Colors.blue[800]),
  //                                 ),
  //                               ),
  //                               Text("Shopping",
  //                                   style: TextStyle(
  //                                       fontWeight: FontWeight.bold,
  //                                       color: Colors.blue[800])),
  //                             ],
  //                           ),
  //                           Padding(padding: EdgeInsets.only(left: 10)),
  //                           Column(
  //                             children: [
  //                               Container(
  //                                 decoration: BoxDecoration(
  //                                   color: Colors.grey[200],
  //                                   borderRadius: BorderRadius.circular(30),
  //                                 ),
  //                                 padding: EdgeInsets.all(10),
  //                                 child: IconButton(
  //                                   onPressed: () {
  //                                     Navigator.push(
  //                                       context,
  //                                       MaterialPageRoute(
  //                                           builder: (context) =>
  //                                               ExercisesListPage(
  //                                                   baseUrl: widget.baseUrl)),
  //                                     );
  //                                   },
  //                                   icon: Icon(Icons.sports_gymnastics_sharp,
  //                                       size: 30, color: Colors.blue[800]),
  //                                 ),
  //                               ),
  //                               Text("Exercises",
  //                                   style: TextStyle(
  //                                       fontWeight: FontWeight.bold,
  //                                       color: Colors.blue[800])),
  //                             ],
  //                           ),
  //                           Padding(padding: EdgeInsets.only(left: 10)),
  //                           Column(
  //                             children: [
  //                               Container(
  //                                 decoration: BoxDecoration(
  //                                   color: Colors.grey[200],
  //                                   borderRadius: BorderRadius.circular(30),
  //                                 ),
  //                                 padding: EdgeInsets.all(10),
  //                                 child: IconButton(
  //                                   onPressed: () {
  //                                     Navigator.push(
  //                                       context,
  //                                       MaterialPageRoute(
  //                                           builder: (context) => CategoryPage(
  //                                                 baseUrl: widget.baseUrl,
  //                                                 nameuser: widget.nameuser,
  //                                               )),
  //                                     );
  //                                   },
  //                                   icon: Icon(Icons.food_bank,
  //                                       size: 30, color: Colors.blue[800]),
  //                                 ),
  //                               ),
  //                               Text("Foods",
  //                                   style: TextStyle(
  //                                       fontWeight: FontWeight.bold,
  //                                       color: Colors.blue[800])),
  //                             ],
  //                           ),
  //                           Padding(padding: EdgeInsets.only(left: 10)),
  //                           Column(
  //                             children: [
  //                               Container(
  //                                 decoration: BoxDecoration(
  //                                   color: Colors.grey[200],
  //                                   borderRadius: BorderRadius.circular(30),
  //                                 ),
  //                                 padding: EdgeInsets.all(10),
  //                                 child: IconButton(
  //                                   onPressed: () {
  //                                     Navigator.push(
  //                                       context,
  //                                       MaterialPageRoute(
  //                                           builder: (context) =>
  //                                               CoachInformations(
  //                                                 baseUrl: widget.baseUrl,
  //                                               )),
  //                                     );
  //                                   },
  //                                   icon: Icon(
  //                                       Icons.supervised_user_circle_sharp,
  //                                       size: 30,
  //                                       color: Colors.blue[800]),
  //                                 ),
  //                               ),
  //                               Text("Coaches",
  //                                   style: TextStyle(
  //                                       fontWeight: FontWeight.bold,
  //                                       color: Colors.blue[800])),
  //                             ],
  //                           ),
  //                           Padding(padding: EdgeInsets.only(left: 10)),
  //                           Column(
  //                             children: [
  //                               Container(
  //                                 decoration: BoxDecoration(
  //                                   color: Colors.grey[200],
  //                                   borderRadius: BorderRadius.circular(30),
  //                                 ),
  //                                 padding: EdgeInsets.all(10),
  //                                 child: IconButton(
  //                                   onPressed: () {
  //                                     Navigator.push(
  //                                       context,
  //                                       MaterialPageRoute(
  //                                           builder: (context) => ReportPosts(
  //                                                 baseUrl: widget.baseUrl,
  //                                               )),
  //                                     );
  //                                   },
  //                                   icon: Icon(Icons.info_outlined,
  //                                       size: 30, color: Colors.blue[800]),
  //                                 ),
  //                               ),
  //                               Text("Reported",
  //                                   style: TextStyle(
  //                                       fontWeight: FontWeight.bold,
  //                                       color: Colors.blue[800])),
  //                             ],
  //                           ),
  //                         ]
  //                       : [
  //                           Column(
  //                             children: [
  //                               Container(
  //                                 decoration: BoxDecoration(
  //                                   color: Colors.grey[200],
  //                                   borderRadius: BorderRadius.circular(30),
  //                                 ),
  //                                 padding: EdgeInsets.all(10),
  //                                 child: IconButton(
  //                                   onPressed: () {
  //                                     Navigator.push(
  //                                       context,
  //                                       MaterialPageRoute(
  //                                           builder: (context) => BMIPage(
  //                                               baseUrl: widget.baseUrl)),
  //                                     );
  //                                   },
  //                                   icon: Icon(Icons.fitness_center,
  //                                       size: 30, color: Colors.blue[800]),
  //                                 ),
  //                               ),
  //                               Text("BMI",
  //                                   style: TextStyle(
  //                                       fontWeight: FontWeight.bold,
  //                                       color: Colors.blue[800])),
  //                             ],
  //                           ),
  //                           Padding(padding: EdgeInsets.only(left: 10)),
  //                           Column(
  //                             children: [
  //                               Container(
  //                                 decoration: BoxDecoration(
  //                                   color: Colors.grey[200],
  //                                   borderRadius: BorderRadius.circular(30),
  //                                 ),
  //                                 padding: EdgeInsets.all(10),
  //                                 child: IconButton(
  //                                   onPressed: () {
  //                                     Navigator.push(
  //                                       context,
  //                                       MaterialPageRoute(
  //                                           builder: (context) => BfpCalculator(
  //                                               baseUrl: widget.baseUrl)),
  //                                     );
  //                                   },
  //                                   icon: Icon(Icons.boy_rounded,
  //                                       size: 30, color: Colors.blue[800]),
  //                                 ),
  //                               ),
  //                               Text("BFP",
  //                                   style: TextStyle(
  //                                       fontWeight: FontWeight.bold,
  //                                       color: Colors.blue[800])),
  //                             ],
  //                           ),
  //                           Padding(padding: EdgeInsets.only(left: 10)),
  //                           Column(
  //                             children: [
  //                               Container(
  //                                 decoration: BoxDecoration(
  //                                   color: Colors.grey[200],
  //                                   borderRadius: BorderRadius.circular(30),
  //                                 ),
  //                                 padding: EdgeInsets.all(10),
  //                                 child: IconButton(
  //                                   onPressed: () {
  //                                     Navigator.push(
  //                                       context,
  //                                       MaterialPageRoute(
  //                                           builder: (context) =>
  //                                               ImageDisplayScreen(
  //                                                 baseUrl: widget.baseUrl,
  //                                                 nameuser: widget.nameuser,
  //                                               )),
  //                                     );
  //                                   },
  //                                   icon: Icon(Icons.shopping_bag_outlined,
  //                                       size: 30, color: Colors.blue[800]),
  //                                 ),
  //                               ),
  //                               Text("Shopping",
  //                                   style: TextStyle(
  //                                       fontWeight: FontWeight.bold,
  //                                       color: Colors.blue[800])),
  //                             ],
  //                           ),
  //                           Padding(padding: EdgeInsets.only(left: 10)),
  //                           Column(
  //                             children: [
  //                               Container(
  //                                 decoration: BoxDecoration(
  //                                   color: Colors.grey[200],
  //                                   borderRadius: BorderRadius.circular(30),
  //                                 ),
  //                                 padding: EdgeInsets.all(10),
  //                                 child: IconButton(
  //                                   onPressed: () {
  //                                     Navigator.push(
  //                                       context,
  //                                       MaterialPageRoute(
  //                                           builder: (context) =>
  //                                               ExercisesListPage(
  //                                                   baseUrl: widget.baseUrl)),
  //                                     );
  //                                   },
  //                                   icon: Icon(Icons.sports_gymnastics_sharp,
  //                                       size: 30, color: Colors.blue[800]),
  //                                 ),
  //                               ),
  //                               Text("Exercises",
  //                                   style: TextStyle(
  //                                       fontWeight: FontWeight.bold,
  //                                       color: Colors.blue[800])),
  //                             ],
  //                           ),
  //                           Padding(padding: EdgeInsets.only(left: 10)),
  //                           Column(
  //                             children: [
  //                               Container(
  //                                 decoration: BoxDecoration(
  //                                   color: Colors.grey[200],
  //                                   borderRadius: BorderRadius.circular(30),
  //                                 ),
  //                                 padding: EdgeInsets.all(10),
  //                                 child: IconButton(
  //                                   onPressed: () {
  //                                     Navigator.push(
  //                                       context,
  //                                       MaterialPageRoute(
  //                                           builder: (context) => CategoryPage(
  //                                                 baseUrl: widget.baseUrl,
  //                                                 nameuser: widget.nameuser,
  //                                               )),
  //                                     );
  //                                   },
  //                                   icon: Icon(Icons.food_bank,
  //                                       size: 30, color: Colors.blue[800]),
  //                                 ),
  //                               ),
  //                               Text("Foods",
  //                                   style: TextStyle(
  //                                       fontWeight: FontWeight.bold,
  //                                       color: Colors.blue[800])),
  //                             ],
  //                           ),
  //                         ]),
  //             ),
  //             SizedBox(height: 20),
  //             Text("New Arrivals",
  //                 style: TextStyle(
  //                     fontSize: 25,
  //                     fontWeight: FontWeight.bold,
  //                     color: Colors.blue[800])),
  //             SizedBox(height: 5),
  //             SingleChildScrollView(
  //               child: Wrap(
  //                 spacing: 4.0,
  //                 runSpacing: 4.0,
  //                 alignment: WrapAlignment.spaceEvenly,
  //                 children: products.isNotEmpty
  //                     ? List.generate((4 / 2).ceil(), (index) {
  //                         int startIndex;
  //                         int endIndex;

  //                         // Calculate startIndex and endIndex based on products length
  //                         startIndex = products.length - 4 + (index * 2);
  //                         endIndex = startIndex + 2;
  //                         if (startIndex > products.length) {
  //                           startIndex = products.length;
  //                           endIndex =
  //                               (products.length - 4).clamp(0, products.length);
  //                         }

  //                         return Row(
  //                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                           children: products
  //                               .sublist(startIndex, endIndex)
  //                               .map((product) {
  //                             return Expanded(
  //                               child: SizedBox(
  //                                 width: MediaQuery.of(context).size.width / 2 -
  //                                     8.0,
  //                                 child: Card(
  //                                   elevation: 4,
  //                                   child: Column(
  //                                     crossAxisAlignment:
  //                                         CrossAxisAlignment.start,
  //                                     children: [
  //                                       SizedBox(
  //                                         height: 250,
  //                                         child: Image.memory(
  //                                           product.imageData,
  //                                           fit: BoxFit.cover,
  //                                           width: double.infinity,
  //                                         ),
  //                                       ),
  //                                       Padding(
  //                                         padding: const EdgeInsets.all(8.0),
  //                                         child: Column(
  //                                           crossAxisAlignment:
  //                                               CrossAxisAlignment.start,
  //                                           children: [
  //                                             Text(
  //                                               product.name,
  //                                               style: TextStyle(
  //                                                   fontSize: 16,
  //                                                   fontWeight:
  //                                                       FontWeight.bold),
  //                                             ),
  //                                             SizedBox(height: 4),
  //                                             Text('Price: \$${product.price}',
  //                                                 style:
  //                                                     TextStyle(fontSize: 16)),
  //                                             SizedBox(height: 4),
  //                                             Text('Count: ${product.count}',
  //                                                 style:
  //                                                     TextStyle(fontSize: 16)),
  //                                           ],
  //                                         ),
  //                                       ),
  //                                     ],
  //                                   ),
  //                                 ),
  //                               ),
  //                             );
  //                           }).toList(),
  //                         );
  //                       }).toList()
  //                     : [
  //                         // Display a loading indicator if products list is empty
  //                         // Center(
  //                         //   child: CircularProgressIndicator(),
  //                         // ),

  //                         Center(
  //                           child: Container(
  //                             padding: EdgeInsets.all(16.0),
  //                             decoration: BoxDecoration(
  //                               color: Colors.white,
  //                               borderRadius: BorderRadius.circular(8.0),
  //                               boxShadow: [
  //                                 BoxShadow(
  //                                   color: Colors.grey.withOpacity(0.5),
  //                                   spreadRadius: 2,
  //                                   blurRadius: 5,
  //                                   offset: Offset(
  //                                       0, 3), // changes position of shadow
  //                                 ),
  //                               ],
  //                             ),
  //                             child: CircularProgressIndicator(
  //                               // Apply styling to CircularProgressIndicator here
  //                               strokeWidth: 3, // Example: custom stroke width
  //                               valueColor: AlwaysStoppedAnimation<Color>(
  //                                   Colors.blue), // Example: custom color
  //                             ),
  //                           ),
  //                         ),
  //                       ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: fetchStatus(widget.nameuser),
      builder: (context, snapshot) {
        // if (snapshot.connectionState == ConnectionState.waiting) {
        //   // While waiting for the future to complete, return a loading indicator
        //   // return CircularProgressIndicator();
        // } else if (snapshot.hasError) {
        //   // If an error occurred while fetching data, display an error message
        //   // return Text('Error: ${snapshot.error}');
        // } else {
        // If data is successfully fetched, use it to build the UI
        String? status = snapshot.data;
        // print(status);
        // Now you can use the fetched status to conditionally build your widget
        bool showAllCategories = status == 'admin';
        bool showCoachCategories = status == 'coach';
        
        // bool showAllCategories = status == 'Ibrahim' || status == 'bahaa';
        return Scaffold(
          body: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Expanded(
                      //   child: IconButton(
                      //     icon: Icon(Icons.arrow_back),
                      //     iconSize: 40,
                      //     color: Colors.blue[800],
                      //     onPressed: () {
                      //       Navigator.of(context).pop();
                      //     },
                      //   ),
                      // ),
                      Spacer(),
                      Spacer(),
                      Spacer(),
                      Spacer(),
                      Spacer(),
                      // Padding(
                      //   padding: const EdgeInsets.all(8.0),
                      //   child: IconButton(
                      //     onPressed: () {},
                      //     icon: Icon(Icons.menu),
                      //     iconSize: 40,
                      //     color: Colors.blue[800],
                      //   ),
                      // ),

                      Image.asset(
                        'images/img6.png',
                        height: 80,
                        width: 90,
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Text(
                    "Categories",
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800]),
                  ),
                  SizedBox(height: 30),
                  Container(
                    height: 100,
                    child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: showAllCategories
                            ? [
                                Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      padding: EdgeInsets.all(10),
                                      child: IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => BMIPage(
                                                    baseUrl: widget.baseUrl)),
                                          );
                                        },
                                        icon: Icon(Icons.fitness_center,
                                            size: 30, color: Colors.blue[800]),
                                      ),
                                    ),
                                    Text("BMI",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue[800])),
                                  ],
                                ),
                                Padding(padding: EdgeInsets.only(left: 10)),
                                Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      padding: EdgeInsets.all(10),
                                      child: IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    BfpCalculator(
                                                        baseUrl:
                                                            widget.baseUrl)),
                                          );
                                        },
                                        icon: Icon(Icons.boy_rounded,
                                            size: 30, color: Colors.blue[800]),
                                      ),
                                    ),
                                    Text("BFP",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue[800])),
                                  ],
                                ),
                                Padding(padding: EdgeInsets.only(left: 10)),
                                Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      padding: EdgeInsets.all(10),
                                      child: IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ImageUploadScreen(
                                                        baseUrl:
                                                            widget.baseUrl)),
                                          );
                                        },
                                        icon: Icon(
                                            Icons.add_shopping_cart_rounded,
                                            size: 30,
                                            color: Colors.blue[800]),
                                      ),
                                    ),
                                    Text("Add Product",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue[800])),
                                  ],
                                ),
                                Padding(padding: EdgeInsets.only(left: 10)),
                                Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      padding: EdgeInsets.all(10),
                                      child: IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ImageDisplayScreen(
                                                      baseUrl: widget.baseUrl,
                                                      nameuser: widget.nameuser,
                                                    )),
                                          );
                                        },
                                        icon: Icon(Icons.shopping_bag_outlined,
                                            size: 30, color: Colors.blue[800]),
                                      ),
                                    ),
                                    Text("Shopping",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue[800])),
                                  ],
                                ),
                                Padding(padding: EdgeInsets.only(left: 10)),
                                Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      padding: EdgeInsets.all(10),
                                      child: IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ExercisesListPage(
                                                        baseUrl:
                                                            widget.baseUrl)),
                                          );
                                        },
                                        icon: Icon(
                                            Icons.sports_gymnastics_sharp,
                                            size: 30,
                                            color: Colors.blue[800]),
                                      ),
                                    ),
                                    Text("Exercises",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue[800])),
                                  ],
                                ),
                                Padding(padding: EdgeInsets.only(left: 10)),
                                Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      padding: EdgeInsets.all(10),
                                      child: IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    CategoryPage(
                                                      baseUrl: widget.baseUrl,
                                                      nameuser: widget.nameuser,
                                                    )),
                                          );
                                        },
                                        icon: Icon(Icons.food_bank,
                                            size: 30, color: Colors.blue[800]),
                                      ),
                                    ),
                                    Text("Foods",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue[800])),
                                  ],
                                ),
                                Padding(padding: EdgeInsets.only(left: 10)),
                                Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      padding: EdgeInsets.all(10),
                                      child: IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    CoachInformations(
                                                      baseUrl: widget.baseUrl,
                                                    )),
                                          );
                                        },
                                        icon: Icon(
                                            Icons.supervised_user_circle_sharp,
                                            size: 30,
                                            color: Colors.blue[800]),
                                      ),
                                    ),
                                    Text("Coaches",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue[800])),
                                  ],
                                ),
                                Padding(padding: EdgeInsets.only(left: 10)),
                                Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      padding: EdgeInsets.all(10),
                                      child: IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ReportPosts(
                                                      baseUrl: widget.baseUrl,
                                                    )),
                                          );
                                        },
                                        icon: Icon(Icons.info_outlined,
                                            size: 30, color: Colors.blue[800]),
                                      ),
                                    ),
                                    Text("Reported",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue[800])),
                                  ],
                                ),
                              ]









                              : showCoachCategories
                              ?[



                                 Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      padding: EdgeInsets.all(10),
                                      child: IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => BMIPage(
                                                    baseUrl: widget.baseUrl)),
                                          );
                                        },
                                        icon: Icon(Icons.fitness_center,
                                            size: 30, color: Colors.blue[800]),
                                      ),
                                    ),
                                    Text("BMI",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue[800])),
                                  ],
                                ),
                                Padding(padding: EdgeInsets.only(left: 10)),
                                Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      padding: EdgeInsets.all(10),
                                      child: IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    BfpCalculator(
                                                        baseUrl:
                                                            widget.baseUrl)),
                                          );
                                        },
                                        icon: Icon(Icons.boy_rounded,
                                            size: 30, color: Colors.blue[800]),
                                      ),
                                    ),
                                    Text("BFP",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue[800])),
                                  ],
                                ),
                                Padding(padding: EdgeInsets.only(left: 10)),
                                Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      padding: EdgeInsets.all(10),
                                      child: IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ImageUploadScreen(
                                                        baseUrl:
                                                            widget.baseUrl)),
                                          );
                                        },
                                        icon: Icon(
                                            Icons.add_shopping_cart_rounded,
                                            size: 30,
                                            color: Colors.blue[800]),
                                      ),
                                    ),
                                    Text("Add Product",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue[800])),
                                  ],
                                ),
                                Padding(padding: EdgeInsets.only(left: 10)),
                                Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      padding: EdgeInsets.all(10),
                                      child: IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ImageDisplayScreen(
                                                      baseUrl: widget.baseUrl,
                                                      nameuser: widget.nameuser,
                                                    )),
                                          );
                                        },
                                        icon: Icon(Icons.shopping_bag_outlined,
                                            size: 30, color: Colors.blue[800]),
                                      ),
                                    ),
                                    Text("Shopping",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue[800])),
                                  ],
                                ),
                                Padding(padding: EdgeInsets.only(left: 10)),
                                Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      padding: EdgeInsets.all(10),
                                      child: IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ExercisesListPage(
                                                        baseUrl:
                                                            widget.baseUrl)),
                                          );
                                        },
                                        icon: Icon(
                                            Icons.sports_gymnastics_sharp,
                                            size: 30,
                                            color: Colors.blue[800]),
                                      ),
                                    ),
                                    Text("Exercises",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue[800])),
                                  ],
                                ),
                                Padding(padding: EdgeInsets.only(left: 10)),
                                Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      padding: EdgeInsets.all(10),
                                      child: IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    CategoryPage(
                                                      baseUrl: widget.baseUrl,
                                                      nameuser: widget.nameuser,
                                                    )),
                                          );
                                        },
                                        icon: Icon(Icons.food_bank,
                                            size: 30, color: Colors.blue[800]),
                                      ),
                                    ),
                                    Text("Foods",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue[800])),
                                  ],
                                ),
                                // Padding(padding: EdgeInsets.only(left: 10)),
                                // Column(
                                //   children: [
                                //     Container(
                                //       decoration: BoxDecoration(
                                //         color: Colors.grey[200],
                                //         borderRadius: BorderRadius.circular(30),
                                //       ),
                                //       padding: EdgeInsets.all(10),
                                //       child: IconButton(
                                //         onPressed: () {
                                //           Navigator.push(
                                //             context,
                                //             MaterialPageRoute(
                                //                 builder: (context) =>
                                //                     CoachInformations(
                                //                       baseUrl: widget.baseUrl,
                                //                     )),
                                //           );
                                //         },
                                //         icon: Icon(
                                //             Icons.supervised_user_circle_sharp,
                                //             size: 30,
                                //             color: Colors.blue[800]),
                                //       ),
                                //     ),
                                //     Text("Coaches",
                                //         style: TextStyle(
                                //             fontWeight: FontWeight.bold,
                                //             color: Colors.blue[800])),
                                //   ],
                                // ),
                                

















                              ]

                              









                            : [
                                Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      padding: EdgeInsets.all(10),
                                      child: IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => BMIPage(
                                                    baseUrl: widget.baseUrl)),
                                          );
                                        },
                                        icon: Icon(Icons.fitness_center,
                                            size: 30, color: Colors.blue[800]),
                                      ),
                                    ),
                                    Text("BMI",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue[800])),
                                  ],
                                ),
                                Padding(padding: EdgeInsets.only(left: 10)),
                                Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      padding: EdgeInsets.all(10),
                                      child: IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    BfpCalculator(
                                                        baseUrl:
                                                            widget.baseUrl)),
                                          );
                                        },
                                        icon: Icon(Icons.boy_rounded,
                                            size: 30, color: Colors.blue[800]),
                                      ),
                                    ),
                                    Text("BFP",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue[800])),
                                  ],
                                ),
                                Padding(padding: EdgeInsets.only(left: 10)),
                                Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      padding: EdgeInsets.all(10),
                                      child: IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ImageDisplayScreen(
                                                      baseUrl: widget.baseUrl,
                                                      nameuser: widget.nameuser,
                                                    )),
                                          );
                                        },
                                        icon: Icon(Icons.shopping_bag_outlined,
                                            size: 30, color: Colors.blue[800]),
                                      ),
                                    ),
                                    Text("Shopping",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue[800])),
                                  ],
                                ),
                                Padding(padding: EdgeInsets.only(left: 10)),
                                Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      padding: EdgeInsets.all(10),
                                      child: IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ExercisesListPage(
                                                        baseUrl:
                                                            widget.baseUrl)),
                                          );
                                        },
                                        icon: Icon(
                                            Icons.sports_gymnastics_sharp,
                                            size: 30,
                                            color: Colors.blue[800]),
                                      ),
                                    ),
                                    Text("Exercises",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue[800])),
                                  ],
                                ),
                                Padding(padding: EdgeInsets.only(left: 10)),
                                Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      padding: EdgeInsets.all(10),
                                      child: IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    CategoryPage(
                                                      baseUrl: widget.baseUrl,
                                                      nameuser: widget.nameuser,
                                                    )),
                                          );
                                        },
                                        icon: Icon(Icons.food_bank,
                                            size: 30, color: Colors.blue[800]),
                                      ),
                                    ),
                                    Text("Foods",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue[800])),
                                  ],
                                ),
                              ]
 
                              
                              
                              ),
                  ),
                  SizedBox(height: 20),
                  Text("New Arrivals",
                      style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800])),
                  SizedBox(height: 5),
                  SingleChildScrollView(
                    child: Wrap(
                      spacing: 4.0,
                      runSpacing: 4.0,
                      alignment: WrapAlignment.spaceEvenly,
                      children: products.isNotEmpty
                          ? List.generate((4 / 2).ceil(), (index) {
                              int startIndex;
                              int endIndex;

                              // Calculate startIndex and endIndex based on products length
                              startIndex = products.length - 4 + (index * 2);
                              endIndex = startIndex + 2;
                              if (startIndex > products.length) {
                                startIndex = products.length;
                                endIndex = (products.length - 4)
                                    .clamp(0, products.length);
                              }

                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: products
                                    .sublist(startIndex, endIndex)
                                    .map((product) {
                                  return Expanded(
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width /
                                              2 -
                                          8.0,
                                      child: Card(
                                        elevation: 4,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              height: 250,
                                              child: Image.memory(
                                                product.imageData,
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    product.name,
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  SizedBox(height: 4),
                                                  Text(
                                                      'Price: \$${product.price}',
                                                      style: TextStyle(
                                                          fontSize: 16)),
                                                  SizedBox(height: 4),
                                                  Text(
                                                      'Count: ${product.count}',
                                                      style: TextStyle(
                                                          fontSize: 16)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              );
                            }).toList()
                          : [
                              // Display a loading indicator if products list is empty
                              // Center(
                              //   child: CircularProgressIndicator(),
                              // ),

                              Center(
                                child: Container(
                                  padding: EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: Offset(
                                            0, 3), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  child: CircularProgressIndicator(
                                    // Apply styling to CircularProgressIndicator here
                                    strokeWidth:
                                        3, // Example: custom stroke width
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.blue), // Example: custom color
                                  ),
                                ),
                              ),
                            ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: BottomNav(
          indexbottom: '3',
          baseUrl: widget.baseUrl,
          name: widget.nameuser,
           email:   widget.email,
           
          ),

          
        );
        
        // }
      },
    );
  }
}
