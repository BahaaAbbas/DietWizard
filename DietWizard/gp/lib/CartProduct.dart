import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_dialog/awesome_dialog.dart';

class CartProduct extends StatefulWidget {
  final String baseUrl;
   final String nameuser;
  const CartProduct({Key? key, required this.baseUrl, required this.nameuser}) : super(key: key);

  @override
  _CartProductState createState() => _CartProductState();
}

class _CartProductState extends State<CartProduct> {
  List<ProductCartItems> productItems = [];

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  Future<void> fetchCartItems() async {
    try {
      final response =
          await http.get(Uri.parse('${widget.baseUrl}/products/shopping/${widget.nameuser}'));

      if (response.statusCode == 200) {
        final List<dynamic> cartItemsData = jsonDecode(response.body);

        setState(() {
          productItems = cartItemsData.map((itemData) {
            final List<int> bufferData =
                List<int>.from(itemData['data']['data']);
            final Uint8List imageData = Uint8List.fromList(bufferData);

            return ProductCartItems(
              name: itemData['name'],
              price: itemData['price'].toString(),
              count: itemData['count'].toString(),
              imageData: imageData,
            );
          }).toList();
        });
      } else {
        print(
            'Failed to fetch cart items. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching cart items: $error');
    }
  }

  void _deleteCartItem(String productName) async {
    try {
      // Make a DELETE request to your backend API to delete the item
      final response = await http
          .delete(Uri.parse('${widget.baseUrl}/products/cart/$productName/${widget.nameuser}'));

      if (response.statusCode == 200) {
        // Item deleted successfully from the backend
        // Update the UI to reflect the changes
        setState(() {
          productItems.removeWhere((item) => item.name == productName);
        });
         AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.rightSlide,
          title: productName,
          desc: 'Deleted Item From Cart',
          // btnCancelOnPress: () {},
          btnOkOnPress: () {},
        )..show();
      } else {
        print('Failed to delete item. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error deleting cart item: $error');
    }
  }

  void _decreaseItemCount(ProductCartItems cartItem) async {
    try {
      // Make a POST request to your backend API to decrease the count
      final response = await http.post(Uri.parse(
          '${widget.baseUrl}/products/cart/decrease/${cartItem.name}/${widget.nameuser}'));

      if (response.statusCode == 200) {
        // Item count decreased successfully in the backend
        // Update the UI to reflect the changes
        setState(() {
          final index =
              productItems.indexWhere((item) => item.name == cartItem.name);
          if (index != -1) {
            productItems[index] = ProductCartItems(
              name: cartItem.name,
              price: cartItem.price,
              count: (int.parse(cartItem.count) - 1)
                  .toString(), // Convert count to int, decrement, and convert back to string
              imageData: cartItem.imageData,
            );
          }
        });
         AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.rightSlide,
          title:  cartItem.name,
          desc: 'Deleted Item From Cart',
          // btnCancelOnPress: () {},
          btnOkOnPress: () {},
        )..show();
      } else {
        print(
            'Failed to decrease item count. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error decreasing item count: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cart',
          style:
              TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold),
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
      body: productItems.isEmpty
          ? Center(
              child: CircularProgressIndicator(), // Display a loading indicator
            )
          : ListView.builder(
              itemCount: productItems.length,
              itemBuilder: (context, index) {
                final cartItem = productItems[index];
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          title: Text(cartItem.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Price: \$${cartItem.price}'),
                              Text(
                                  'Count: ${cartItem.count}'), // Changed from quantity to count
                            ],
                          ),
                          leading: cartItem.imageData != null
                              ? Image.memory(cartItem.imageData!)
                              : Placeholder(),
                        ),
                      ),
                      // IconButton(
                      //   icon: Icon(Icons.delete),
                      //   onPressed: () {
                      //     // Implement delete functionality here
                      //         // _deleteCartItem(cartItem.name); // Pass the product name for identification

                      //   },
                      // ),

                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          if (int.parse(cartItem.count) > 1) {
                            _decreaseItemCount(cartItem);
                          } else {
                            _deleteCartItem(cartItem.name);
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class ProductCartItems {
  final String name;
  final String price;
  final String count;
  final Uint8List? imageData;

  ProductCartItems({
    required this.name,
    required this.price,
    required this.count,
    this.imageData,
  });
}
