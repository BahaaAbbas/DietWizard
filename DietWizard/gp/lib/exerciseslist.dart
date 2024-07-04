import 'package:flutter/material.dart';
import 'showexercises.dart';

class Products {
  final String name;
  final String imageUrl;

  Products({
    required this.name,
    required this.imageUrl,
  });
}

class ExercisesListPage extends StatefulWidget {
  final String baseUrl;
  const ExercisesListPage({Key? key, required this.baseUrl}) : super(key: key);

  @override
  _ExercisesListPageState createState() => _ExercisesListPageState();
}

class _ExercisesListPageState extends State<ExercisesListPage> {
  final List<Products> products = [
    Products(
      name: 'Abs',
      imageUrl:
          'https://www.shutterstock.com/image-vector/human-abs-vector-cartoon-illustration-600w-2128378241.jpg',
    ),
    Products(
      name: 'Arms',
      imageUrl:
          'https://st2.depositphotos.com/3259223/8570/v/450/depositphotos_85705396-stock-illustration-body-builder-athlete-figure.jpg',
    ),
    Products(
      name: 'Back',
      imageUrl:
          'https://bonytobeastly.com/wp-content/uploads/2022/12/how-to-build-bigger-back-muscles-stretch-mediated-hypertrophy-1.jpg',
    ),
    // Products(
    //   name: 'Cardio',
    //   imageUrl:
    //       'https://www.planetware.com/wpimages/2020/02/france-in-pictures-beautiful-places-to-photograph-eiffel-tower.jpg',
    // ),
    Products(
      name: 'Chest',
      imageUrl:
          'https://cdn.muscleandstrength.com/sites/default/files/taxonomy/image/videos/chest_0.jpg',
    ),
    Products(
      name: 'Legs',
      imageUrl:
          'https://play-lh.googleusercontent.com/3rA3XaTEMaaNNWnSx2dAxUqLZPHPKKU9DTLnAAERG6kTwwBd-gDvN10F6bH_w_mxAioM',
    ),
    Products(
      name: 'Shoulders',
      imageUrl:
          'https://cdn.muscleandstrength.com/sites/default/files/taxonomy/image/videos/shoulders_0.jpg',
    ),
  ];

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
                //   onPressed: () {},
                //   icon: Icon(Icons.menu),
                //   iconSize: 40,
                //   color: Colors.blue[800],
                // ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              "Exercises List",
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
                    (products.length / 2).ceil(),
                    (rowIndex) {
                      int startIndex = rowIndex * 2;
                      int endIndex = startIndex + 2 <= products.length
                          ? startIndex + 2
                          : products.length;
                      return Row(
                        children: List.generate(
                          endIndex - startIndex,
                          (indexInRow) {
                            int index = startIndex + indexInRow;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ExerciseListPage(
                                        baseUrl: widget.baseUrl,
                                        category: products[index].name,
                                      ),
                                    ),
                                  );
                                },
                                child: Card(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Image.network(
                                        products[index].imageUrl,
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
                                                products[index].name,
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
