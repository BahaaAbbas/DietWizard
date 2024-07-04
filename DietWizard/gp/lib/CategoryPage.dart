import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:gp/FoodRecipesPage.dart';

import 'Cart.dart';

class Foods {
  final String name;
  final String imageUrl;

  Foods({
    required this.name,
    required this.imageUrl,
  });
}

class CategoryPage extends StatefulWidget {
  final String baseUrl;
  final String nameuser;
  const CategoryPage({Key? key, required this.baseUrl, required this.nameuser}) : super(key: key);

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final List<Foods> food = [
    Foods(
      name: 'Beef',
      imageUrl: 'https://www.themealdb.com/images/category/beef.png',
    ),
    Foods(
      name: 'Chicken',
      imageUrl: 'https://www.themealdb.com/images/category/chicken.png',
    ),
    Foods(
      name: 'Dessert',
      imageUrl: 'https://www.themealdb.com/images/category/dessert.png',
    ),
    Foods(
      name: 'Lamb',
      imageUrl: 'https://www.themealdb.com/images/category/lamb.png',
    ),
    Foods(
      name: 'Miscellaneous',
      imageUrl: 'https://www.themealdb.com/images/category/miscellaneous.png',
    ),
    Foods(
      name: 'Pasta',
      imageUrl: 'https://www.themealdb.com/images/category/pasta.png',
    ),
    Foods(
      name: 'Seafood',
      imageUrl: 'https://www.themealdb.com/images/category/seafood.png',
    ),
    Foods(
      name: 'Side',
      imageUrl: 'https://www.themealdb.com/images/category/side.png',
    ),
    // Foods(
    //   name: 'Starter',
    //   imageUrl: 'https://www.themealdb.com/images/category/starter.png',
    // ),
    Foods(
      name: 'Vegan',
      imageUrl: 'https://www.themealdb.com/images/category/vegan.png',
    ),
    Foods(
      name: 'Vegetarian',
      imageUrl: 'https://www.themealdb.com/images/category/vegetarian.png',
    ),
    Foods(
      name: 'Breakfast',
      imageUrl: 'https://www.themealdb.com/images/category/breakfast.png',
    ),
    Foods(
      name: 'Goat',
      imageUrl: 'https://www.themealdb.com/images/category/goat.png',
    ),
  ];

  Future<void> fetchRecipes(String category) async {
    try {
      final response = await http.get(
        Uri.parse('${widget.baseUrl}/recipesmobile?foodName=$category'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> recipesData = jsonDecode(response.body);
        List<Recipe> recipes = recipesData.map((recipeData) {
          return Recipe(
            name: recipeData['name'],
            description: recipeData['description'],
            imageUrl: recipeData['imageUrl'],
            price: recipeData['price'].toDouble(),
          );
        }).toList();

        // Navigate to FoodRecipesPage passing the fetched recipes
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FoodRecipesPage(
              baseUrl: widget.baseUrl,
              category: category,
              recipes: recipes,
              nameuser: widget.nameuser,
            ),
          ),
        );
      } else {
        print('Failed to fetch recipes. Status code: ${response.statusCode}');
        // Handle error
      }
    } catch (error) {
      print('Error fetching recipes: $error');
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  iconSize: 40,
                  color: Colors.blue[800],
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                Spacer(),
                // IconButton(
                //   onPressed: () {
                //     // Navigator.push(
                //     //   context,
                //     //   MaterialPageRoute(
                //     //     builder: (context) => Cart(
                //     //       baseUrl: widget.baseUrl,
                //     //     ),
                //     //   ),
                //     // );
                //   },
                //   icon: Icon(Icons.shopping_cart_outlined),
                //   iconSize: 40,
                //   color: Colors.blue[800],
                // ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              "Categories Foods",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            SizedBox(height: 5),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: List.generate(
                    (food.length / 2).ceil(),
                    (rowIndex) {
                      int startIndex = rowIndex * 2;
                      int endIndex = startIndex + 2 <= food.length
                          ? startIndex + 2
                          : food.length;
                      return Row(
                        children: List.generate(
                          endIndex - startIndex,
                          (indexInRow) {
                            int index = startIndex + indexInRow;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  fetchRecipes(food[index].name);
                                },
                                child: Card(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Image.network(
                                        food[index].imageUrl,
                                        height: 150,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Center(
                                          child: Column(
                                            children: [
                                              Text(
                                                food[index].name,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
