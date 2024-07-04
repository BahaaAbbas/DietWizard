import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:gp/CartProduct.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_dialog/awesome_dialog.dart';




class Product {
  final int id;
  final String name;
  final int price; // Change the type to int
  final int count;
  final Uint8List imageData;
  final String description;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.count,
    required this.imageData,
    required this.description,
  });
}

class ImageDisplayScreen extends StatefulWidget {
  final String baseUrl;
  final String nameuser;
  const ImageDisplayScreen(
      {Key? key, required this.baseUrl, required this.nameuser})
      : super(key: key);
  @override
  _ImageDisplayScreenState createState() => _ImageDisplayScreenState();
}

class _ImageDisplayScreenState extends State<ImageDisplayScreen> {
  List<Product> products = [];
  List<Product> productcart = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }
 
  Future<void> addToCart(Product product) async {
    try {
      final String base64Image =
          base64Encode(product.imageData); // Encode image data as base64 string

      final response = await http.post(
        Uri.parse('${widget.baseUrl}/product/addcart'),
        body: jsonEncode({
          'productId': product.id,
          'name': product.name,
          'price': product.price,
          'count': product.count,
          'imageData':
              base64Image, // Include the base64 encoded image data in the request body
          'user': widget.nameuser
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          productcart.add(product);
        });
        // Show a success message or handle accordingly
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.rightSlide,
          title:  product.name  ,
          desc: 'Added Successfully',
          // btnCancelOnPress: () {},
          btnOkOnPress: () {},
        )..show();




      } else {
        print(
            'Failed to add item to cart. Status code: ${response.statusCode}');
        // Show an error message or handle accordingly
      }
    } catch (error) {
      print('Error adding item to cart: $error');
    }
  }

// here fetch the products in our database in our project not in the user item in cart
  Future<void> fetchProducts() async {
    final response = await http.get(Uri.parse('${widget.baseUrl}/products'));

    if (response.statusCode == 200) {
      final List<dynamic> productsData = jsonDecode(response.body);
      setState(() {
        products = productsData.map((productData) {
          final List<int> bufferData =
              List<int>.from(productData['data']['data']);
          final Uint8List imageData = Uint8List.fromList(bufferData);
          return Product(
            id: productData['idproduct'],
            name: productData['nameproduct'],
            price: productData['priceproduct'].toInt(), // Convert to int
            count: productData['countproduct'],
            imageData: imageData,
            description: productData['descriptionproduct'],
          );
        }).toList();
      });
    } else {
      print('Failed to fetch products. Status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Products',
          style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800]),
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
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartProduct(
                    // productItems: productcart,
                    baseUrl: widget.baseUrl,
                    nameuser: widget.nameuser,
                  ),
                ),
              );
            },
            icon: Icon(Icons.shopping_cart_outlined),
            iconSize: 40,
            color: Colors.blue[800],
          ),
        ],
      ),
      // body: SingleChildScrollView(
      //   child: Wrap(
      //     spacing: 4.0,
      //     runSpacing: 4.0,
      //     children: products.map((product) {
      //       return GestureDetector(
      //         onTap: () {
      //           AwesomeDialog(
      //             context: context,
      //             dialogType: DialogType
      //                 .info, // Change dialogType according to your requirement
      //             animType: AnimType.rightSlide,
      //             title: product.name,
      //             desc: product.description,
      //             // btnCancelOnPress: () {},
      //             btnOkOnPress: () {},
      //           )..show();
      //         },
      //         child: SizedBox(
      //           width: MediaQuery.of(context).size.width / 2 - 8.0,
      //           child: Card(
      //             elevation: 4,
      //             child: Column(
      //               crossAxisAlignment: CrossAxisAlignment.start,
      //               children: [
      //                 SizedBox(
      //                   height: 250,
      //                   width: 200,
      //                   child: Image.memory(
      //                     product.imageData,
      //                     fit: BoxFit.cover,
      //                     width: double.infinity,
      //                   ),
      //                 ),
      //                 Padding(
      //                   padding: const EdgeInsets.all(8.0),
      //                   child: Column(
      //                     crossAxisAlignment: CrossAxisAlignment.start,
      //                     children: [
      //                       Text(
      //                         product.name,
      //                         style: TextStyle(
      //                           fontSize: 16,
      //                           fontWeight: FontWeight.bold,
      //                         ),
      //                       ),
      //                       SizedBox(height: 4),
      //                       Text(
      //                         'Price: \$${product.price}',
      //                         style: TextStyle(fontSize: 16),
      //                       ),
      //                       SizedBox(height: 4),
      //                       Text(
      //                         'Count: ${product.count}',
      //                         style: TextStyle(fontSize: 16),
      //                       ),
      //                       SizedBox(height: 4),
      //                       ElevatedButton(
      //                         onPressed: () {
      //                           addToCart(product); // Call the function to add product to cart
      //                         },
      //                         child: Center(
      //                           child: Text('Add to Cart'),
      //                         ),
      //                       ),
      //                     ],
      //                   ),
      //                 ),
      //               ],
      //             ),
      //           ),
      //         ),
      //       );
      //     }).toList(),
      //   ),
      // ),









    body: SingleChildScrollView(
  child: products.isEmpty
      // ? Center(
      //     child: CircularProgressIndicator(),
      //   )
        ? Center(
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
                                strokeWidth: 3, // Example: custom stroke width
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.blue), // Example: custom color
                              ),
                            ),
                          )
      : Wrap(
          spacing: 4.0,
          runSpacing: 4.0,
          children: products.map((product) {
            return GestureDetector(
              onTap: () {
                AwesomeDialog(
                  context: context,
                  dialogType: DialogType
                      .info, // Change dialogType according to your requirement
                  animType: AnimType.rightSlide,
                  title: product.name,
                  desc: product.description,
                  // btnCancelOnPress: () {},
                  btnOkOnPress: () {},
                )..show();
              },
              child: SizedBox(
                width: MediaQuery.of(context).size.width / 2 - 8.0,
                child: Card(
                  elevation: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 250,
                        width: 200,
                        child: Image.memory(
                          product.imageData,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Price: \$${product.price}',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Count: ${product.count}',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 4),
                            ElevatedButton(
                              onPressed: () {
                                addToCart(product); // Call the function to add product to cart
                              },
                              child: Center(
                                child: Text('Add to Cart'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
),















    );
  }
}
