import 'package:flutter/material.dart';
import 'FoodRecipesPage.dart';
// import 'package:http/http.dart' as http;

class Cart extends StatefulWidget {
  final List<CartItem> cartItems;
  final Function(BuildContext context, int index) deleteCartItem;

  const Cart({Key? key, required this.cartItems, required this.deleteCartItem})
      : super(key: key);

  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  
  @override
  Widget build(BuildContext context) {
    // print("Cart Items Length: ${widget.cartItems.length}"); // Add this line
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
      body: widget.cartItems.isEmpty
          ? Center(
              child: Text('Your cart is empty.'),
            )
          : ListView.builder(
              itemCount: widget.cartItems.length,
              itemBuilder: (context, index) {
                // print("Index: $index"); // Add this line
                final cartItem = widget.cartItems[index];
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
                              Text('Quantity: ${cartItem.quantity}'),
                              
                            ],
                          ),
                          leading: Image.network(
                            cartItem.imageUrl,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          widget.deleteCartItem(context, index);
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

