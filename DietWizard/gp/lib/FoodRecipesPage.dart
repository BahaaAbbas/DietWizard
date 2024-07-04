// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:gp/Cart.dart';
// import 'package:http/http.dart' as http;
// // import 'CategoryPage.dart';
// import 'package:awesome_dialog/awesome_dialog.dart';

// class Recipe {
//   final String name;
//   final String description;
//   final String imageUrl;
//   final double price;

//   Recipe({
//     required this.name,
//     required this.description,
//     required this.imageUrl,
//     required this.price,
//   });
// }

// class FoodRecipesPage extends StatefulWidget {
//   final String baseUrl;
//   final String category;
//   final List<Recipe> recipes;

//   const FoodRecipesPage({
//     Key? key,
//     required this.baseUrl,
//     required this.category,
//     required this.recipes,
//   }) : super(key: key);

//   @override
//   _FoodRecipesPageState createState() => _FoodRecipesPageState();
// }

// class _FoodRecipesPageState extends State<FoodRecipesPage> {
//   late List<Recipe> filteredRecipes;
//   TextEditingController _searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     filteredRecipes = List.from(widget.recipes);
//   }

//   void filterRecipes(String query) {
//     setState(() {
//       filteredRecipes = widget.recipes
//           .where((recipe) =>
//               recipe.name.toLowerCase().contains(query.toLowerCase()))
//           .toList();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Food Recipes',
//           style:
//               TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold),
//         ),
//         actions: [
//           IconButton(
//             onPressed: () {
//                 Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => Cart(
//               baseUrl: widget.baseUrl,
//             ),
//           ),
//         );
//             },
//             icon: Icon(Icons.shopping_cart_outlined),
//             iconSize: 40,
//             color: Colors.blue[800],
//           ),
//         ],
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           iconSize: 40,
//           color: Colors.blue[800],
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//         ),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: TextField(
//               controller: _searchController,
//               decoration: InputDecoration(
//                 labelText: 'Search Food Recipes',
//                 suffixIcon: IconButton(
//                   icon: Icon(Icons.clear),
//                   onPressed: () {
//                     _searchController.clear();
//                     filterRecipes('');
//                   },
//                 ),
//               ),
//               onChanged: (value) {
//                 filterRecipes(value);
//               },
//             ),
//           ),
//           Expanded(
//             child: filteredRecipes.isEmpty
//                 ? Center(
//                     child: CircularProgressIndicator(),
//                   )
//                 : ListView.builder(
//                     itemCount: filteredRecipes.length,
//                     itemBuilder: (context, index) {
//                       final recipe = filteredRecipes[index];
//                       return GestureDetector(
//                         onTap: () {
//                           _showDescriptionDialog(context, recipe);
//                         },
//                         child: Card(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Image.network(
//                                 recipe.imageUrl,
//                                 height: 150,
//                                 width: double.infinity,
//                                 fit: BoxFit.cover,
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       recipe.name,
//                                       style: TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 16,
//                                       ),
//                                     ),
//                                     SizedBox(height: 5),
//                                     Text(
//                                       'Price: \$${recipe.price}',
//                                       style: TextStyle(fontSize: 14),
//                                     ),
//                                     SizedBox(height: 10),
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         ElevatedButton(
//                                           onPressed: () {
//                                             _getCalories(context, recipe);
//                                           },
//                                           child: Text('Nutrition Data'),
//                                         ),
//                                         ElevatedButton(
//                                           onPressed: () {
//                                             // Add to cart functionality

//                                           },
//                                           child: Text('Add to Cart'),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showDescriptionDialog(BuildContext context, Recipe recipe) {
//     AwesomeDialog(
//       context: context,
//       dialogType: DialogType.info,
//       animType: AnimType.rightSlide,
//       // title: recipe.name,
//       width: 500,
//       body: Container(
//         height: 400, // Set your desired height here
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(" " + recipe.name,
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//               SizedBox(height: 20),
//               Text(recipe.description),
//               // SizedBox(height: 20),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               ),
//             ],
//           ),
//         ),
//       ),
//       btnCancelText: 'Close',
//       btnCancelOnPress: () {},
//     )..show();
//   }

//   void _getCalories(BuildContext context, Recipe recipe) async {
//     try {
//       final response = await http
//           .get(Uri.parse('${widget.baseUrl}/nutrition?query=${recipe.name}'));
//       if (response.statusCode == 200) {
//         // Parse the response and extract the calorie information
//         final List<dynamic> dataList = jsonDecode(response.body);
//         if (dataList.isNotEmpty) {
//           final List<Widget> nutritionalInfoWidgets = dataList.map((data) {
//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text('Name: ${data['name']}'),
//                 Text('Calories: ${data['calories']}'),
//                 Text('Serving Size: ${data['serving_size_g']}g'),
//                 Text('Total Fat: ${data['fat_total_g']}g'),
//                 Text('Saturated Fat: ${data['fat_saturated_g']}g'),
//                 Text('Protein: ${data['protein_g']}g'),
//                 Text('Sodium: ${data['sodium_mg']}mg'),
//                 Text('Potassium: ${data['potassium_mg']}mg'),
//                 Text('Cholesterol: ${data['cholesterol_mg']}mg'),
//                 Text('Total Carbohydrates: ${data['carbohydrates_total_g']}g'),
//                 Text('Fiber: ${data['fiber_g']}g'),
//                 Text('Sugar: ${data['sugar_g']}g'),
//                 SizedBox(height: 20),
//               ],
//             );
//           }).toList();

//           AwesomeDialog(
//             context: context,
//             dialogType: DialogType.info,
//             animType: AnimType.rightSlide,
//             width: nutritionalInfoWidgets.length * 500.0,
//             title: 'Nutrition Data',
//             body: Container(
//               height: 260, // Set your desired height here
//               child: SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisSize: MainAxisSize.min,
//                   children: nutritionalInfoWidgets,
//                 ),
//               ),
//             ),
//             btnCancelText: 'Close',
//             btnCancelOnPress: () {},
//           )..show();

// //
//         } else {
//           print('No data found');
//         }
//       } else {
//         // Handle error response
//         print('Error: ${response.statusCode}');
//       }
//     } catch (error) {
//       // Handle network error
//       print('Error: $error');
//     }
//   }
// }

////////////////////////////////////
//////////////////////////////////
///
///
///
///
///
///
///
///







import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_dialog/awesome_dialog.dart';

import 'Cart.dart';

class Recipe {
  final String name;
  final String description;
  final String imageUrl;
  final double price;

  Recipe({
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
  });
}

class CartItem {
  final String name;
  final String imageUrl;
  final double price;
  final int quantity;

  CartItem({
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.quantity,
  });
}

class FoodRecipesPage extends StatefulWidget {
  final String baseUrl;
  final String category;
  final String nameuser;
  final List<Recipe> recipes;

  const FoodRecipesPage({
    Key? key,
    required this.baseUrl,
    required this.category,
    required this.recipes,
    required this.nameuser,
  }) : super(key: key);

  @override
  _FoodRecipesPageState createState() => _FoodRecipesPageState();
}

class _FoodRecipesPageState extends State<FoodRecipesPage> {
  late List<Recipe> filteredRecipes;
  List<CartItem> cartItems = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredRecipes = List.from(widget.recipes);
    fetchCartItems();
  }

  void filterRecipes(String query) {
    setState(() {
      filteredRecipes = widget.recipes
          .where((recipe) =>
              recipe.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _addToCart(BuildContext context, Recipe recipe) async {
    try {
      // fetchCartItems();
      // print(widget.nameuser);
      final response = await http.post(
        Uri.parse('${widget.baseUrl}/cart/add'),
        body: jsonEncode({
          'name': recipe.name,
          // 'description': recipe.description,
          'imageUrl': recipe.imageUrl,
          'price': recipe.price,
          'user': widget.nameuser
        }),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        // Item added to cart successfully
        // You can update the UI or show a message if needed
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Item added to cart successfully')),
        // );
        fetchCartItems();

        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.rightSlide,
          title: recipe.name + ' Added Successfully',
          desc: 'Your item has been added successfully.',
          btnOkOnPress: () {
            // setState(() {
            //   _image = null;
            //   _titleController.clear();
            //   _contentController.clear();
            // });
            fetchCartItems();
          },
        )..show();
      } else {
        // Handle error
        print('Error adding item to cart: ${response.body}');
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Failed to add item to cart')),
        // );
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.rightSlide,
          title: recipe.name + ' not Added Successfully',
          desc: 'Your item has existed in cart.',
          btnOkOnPress: () {},
        )..show();
      }
    } catch (error) {
      print('Error adding item to cart: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred')),
      );
    }
  }

  Future<void> fetchCartItems() async {
    try {
      final response = await http
          .get(Uri.parse('${widget.baseUrl}/cart/${widget.nameuser}'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<CartItem> fetchedItems = data
            .map((item) => CartItem(
                  name: item['name'], // Modify to match your backend response
                  imageUrl:
                      item['imageUrl'], // Modify to match your backend response
                  price: item['price']
                      .toDouble(), // Modify to match your backend response
                  quantity: item['quantity'],
                ))
            .toList();
        setState(() {
          cartItems = fetchedItems;
        });
      } else {
        print('Failed to fetch cart items: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching cart items: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Food Recipes',
          style:
              TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // fetchCartItems();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Cart(
                    cartItems: cartItems,
                    deleteCartItem: _deleteCartItem,
                  ),
                ),
              );
            },
            icon: Icon(Icons.shopping_cart_outlined),
            iconSize: 40,
            color: Colors.blue[800],
          ),
        ],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          iconSize: 40,
          color: Colors.blue[800],
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Food Recipes',
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    filterRecipes('');
                  },
                ),
              ),
              onChanged: (value) {
                filterRecipes(value);
              },
            ),
          ),
          Expanded(
            child: filteredRecipes.isEmpty
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView.builder(
                    itemCount: filteredRecipes.length,
                    itemBuilder: (context, index) {
                      final recipe = filteredRecipes[index];
                      return GestureDetector(
                        onTap: () {
                          _showDescriptionDialog(context, recipe);
                        },
                        child: Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.network(
                                recipe.imageUrl,
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      recipe.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      'Price: \$${recipe.price}',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            _getCalories(context, recipe);
                                          },
                                          child: Text('Nutrition Data'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            // Add to cart functionality
                                            // setState(() {
                                            //   cartItems.add(recipe);
                                            // });
                                            _addToCart(context, recipe);
                                          },
                                          child: Text('Add to Cart'),
                                        ),
                                      ],
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

  void _showDescriptionDialog(BuildContext context, Recipe recipe) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.rightSlide,
      width: 500,
      body: Container(
        height: 400, // Set your desired height here
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(" " + recipe.name,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              Text(recipe.description),
            ],
          ),
        ),
      ),
      btnCancelText: 'Close',
      btnCancelOnPress: () {},
    )..show();
  }

  void _getCalories(BuildContext context, Recipe recipe) async {
    try {
      final response = await http
          .get(Uri.parse('${widget.baseUrl}/nutrition?query=${recipe.name}'));
      if (response.statusCode == 200) {
        final List<dynamic> dataList = jsonDecode(response.body);
        if (dataList.isNotEmpty) {
          final List<Widget> nutritionalInfoWidgets = dataList.map((data) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: ${data['name']}'),
                Text('Calories: ${data['calories']}'),
                Text('Serving Size: ${data['serving_size_g']}g'),
                Text('Total Fat: ${data['fat_total_g']}g'),
                Text('Saturated Fat: ${data['fat_saturated_g']}g'),
                Text('Protein: ${data['protein_g']}g'),
                Text('Sodium: ${data['sodium_mg']}mg'),
                Text('Potassium: ${data['potassium_mg']}mg'),
                Text('Cholesterol: ${data['cholesterol_mg']}mg'),
                Text('Total Carbohydrates: ${data['carbohydrates_total_g']}g'),
                Text('Fiber: ${data['fiber_g']}g'),
                Text('Sugar: ${data['sugar_g']}g'),
                SizedBox(height: 20),
              ],
            );
          }).toList();

          AwesomeDialog(
            context: context,
            dialogType: DialogType.info,
            animType: AnimType.rightSlide,
            width: nutritionalInfoWidgets.length * 500.0,
            title: 'Nutrition Data',
            body: Container(
              height: 260,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: nutritionalInfoWidgets,
                ),
              ),
            ),
            btnCancelText: 'Close',
            btnCancelOnPress: () {},
          )..show();
        } else {
          print('No data found');
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> _deleteCartItem(BuildContext context, int index) async {
    try {
      final response = await http.delete(
        Uri.parse(
            '${widget.baseUrl}/cart/delete/${widget.nameuser}/${cartItems[index].name}'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        fetchCartItems();

        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.rightSlide,
          title: cartItems[index].name + ' Delete from Cart',
          desc: 'Item Deleted From Cart',
          btnOkOnPress: () {
            fetchCartItems();
            Navigator.of(context).pop(); // Dismiss the dialog
            
          },
        )..show();

        setState(() {
          cartItems.removeAt(index);
        });
      } else {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.rightSlide,

          title: cartItems[index].name + ' Delete from Cart',
          desc: 'Failed to delete item from cart',
          // btnCancelText: 'Close',
          // btnOkText: "ok",
          btnOkOnPress: () {
            fetchCartItems();
          },
        )..show();
      }
    } catch (error) {
      print('Error deleting item from cart: $error');

      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,

        title: 'Delete from Cart',
        desc: 'Failed to delete item from cart Is It Already Deleted ',
        // btnCancelText: 'Close',
        // btnOkText: "ok",
        btnOkOnPress: () {
          // fetchCartItems();
        },
      )..show();
    }
  }

 







}

// class Cart extends StatefulWidget {
//   final List<CartItem> cartItems;
//   final Function(BuildContext context, int index) deleteCartItem;

//   const Cart({Key? key, required this.cartItems, required this.deleteCartItem})
//       : super(key: key);

//   @override
//   _CartState createState() => _CartState();
// }

// class _CartState extends State<Cart> {
//   @override
//   Widget build(BuildContext context) {
//     // print("Cart Items Length: ${widget.cartItems.length}"); // Add this line
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Cart',
//           style:
//               TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold),
//         ),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           iconSize: 40,
//           color: Colors.blue[800],
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//         ),
//       ),
//       body: widget.cartItems.isEmpty
//           ? Center(
//               child: Text('Your cart is empty.'),
//             )
//           : ListView.builder(
//               itemCount: widget.cartItems.length,
//               itemBuilder: (context, index) {
//                 // print("Index: $index"); // Add this line
//                 final cartItem = widget.cartItems[index];
//                 return Container(
//                   margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
//                   padding: EdgeInsets.all(10.0),
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey),
//                     borderRadius: BorderRadius.circular(10.0),
//                   ),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: ListTile(
//                           title: Text(cartItem.name),
//                           subtitle: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text('Price: \$${cartItem.price}'),
//                               Text('Quantity: ${cartItem.quantity}'),
                              
//                             ],
//                           ),
//                           leading: Image.network(
//                             cartItem.imageUrl,
//                             width: 100,
//                             height: 100,
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                       ),
//                       IconButton(
//                         icon: Icon(Icons.delete),
//                         onPressed: () {
//                           widget.deleteCartItem(context, index);
//                         },
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }
