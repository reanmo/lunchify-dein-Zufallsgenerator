import 'dart:math';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:lunchify/helper/database_db_helper.dart';
import 'package:lunchify/models/database.dart';
import 'package:provider/provider.dart';

import 'helper/modal_helper.dart';

void initializeDatabase(Database db) async {
  final existingRestaurants = await db.getAllRestaurants();
  if (existingRestaurants.isEmpty) {
    final initialRestaurants = [
      RestaurantsCompanion(
        id: Value(1),
        name: Value('Kawaii'),
        imagePath: Value('assets/images/Kawaii.jpg'),
      ),
      RestaurantsCompanion(
        id: Value(2),
        name: Value('Roadhouse'),
        imagePath: Value('assets/images/Roadhouse.jpg'),
      ),
      RestaurantsCompanion(
        id: Value(3),
        name: Value('Mammas Simple Food'),
        imagePath: Value('assets/images/Mammas_simple_food.jpg'),
      ),
      RestaurantsCompanion(
        id: Value(4),
        name: Value('Burger Nerd'),
        imagePath: Value('assets/images/Burger_Nerd.jpg'),
      ),
      RestaurantsCompanion(
        id: Value(5),
        name: Value('MC Donald\'s'),
        imagePath: Value('assets/images/MC_Donalds.jpg'),
      ),
      RestaurantsCompanion(
        id: Value(6),
        name: Value('Subway'),
        imagePath: Value('assets/images/Subway.jpg'),
      ),
      RestaurantsCompanion(
        id: Value(7),
        name: Value('Vesuvio'),
        imagePath: Value('assets/images/Vesuvio.jpg'),
      ),
    ];

    for (var restaurant in initialRestaurants) {
      await db.insertRestaurant(restaurant);
    }
    print('Initial restaurant list loaded into the database.');
  } else {
    print('Restaurants already exist in the database.');
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final db = Database();
  initializeDatabase(db);
  runApp(Provider<Database>(create: (_) => db, child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lunchify - Zufallsgenerator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Lunchify'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Restaurant? selectedRestaurant;
  void pickRandom(List<Restaurant> restaurants) {
    final random = Random();
    final newPick = restaurants[random.nextInt(restaurants.length)];
    setState(() {
      selectedRestaurant = newPick;
    });
  }

  Future<void> updateSelectedRestaurantFavoriteStatus() async {
    if (selectedRestaurant != null) {
      final updatedRestaurant = await DatabaseHelper().getAllRestaurants();
      final matchingRestaurant = updatedRestaurant.firstWhere(
        (restaurant) => restaurant.id == selectedRestaurant!.id,
        orElse: () => selectedRestaurant!,
      );
      setState(() {
        selectedRestaurant = matchingRestaurant;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Selected Restaurant: ${selectedRestaurant?.isFavorite}");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300]!,
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: DatabaseHelper().getAllRestaurants(),
        builder: (context, restaurants) {
          if (restaurants.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (restaurants.hasError) {
            return Center(
              child: Text(
                'Fehler beim Laden der Restaurants: ${restaurants.error}',
              ),
            );
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () async {
                      if (restaurants.hasData) {
                        final restaurantsList = restaurants.data!;
                        if (restaurantsList.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Keine Favoriten vorhanden.'),
                            ),
                          );
                          return;
                        }
                        showFavoritesModal(context, restaurantsList);
                      } else if (restaurants.hasError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Fehler beim Laden der Restaurants.'),
                          ),
                        );
                      }
                    },
                    icon: Icon(Icons.list, size: 50, color: Colors.grey[500]),
                  ),
                  IconButton(
                    onPressed: () {
                      if (selectedRestaurant != null) {
                        DatabaseHelper().toggleFavorite(
                          selectedRestaurant!.id,
                          !selectedRestaurant!.isFavorite,
                        );

                        updateSelectedRestaurantFavoriteStatus();
                      }
                    },
                    icon: Icon(
                      Icons.star,
                      size: 50,
                      color:
                          selectedRestaurant != null &&
                                  selectedRestaurant!.isFavorite
                              ? Colors.amber[100]
                              : Colors.grey[500],
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: 30),
                    SizedBox(
                      width: 500,
                      child:
                          selectedRestaurant != null
                              ? Image(
                                image: AssetImage(
                                  selectedRestaurant!.imagePath,
                                ),
                              )
                              : const Center(
                                child: Placeholder(
                                  color: Colors.white,
                                  strokeWidth: 2.0,
                                ),
                              ),
                    ),
                    selectedRestaurant != null
                        ? Text(selectedRestaurant!.name)
                        : Container(),
                    Padding(
                      padding: const EdgeInsets.only(top: 40.0),
                      child: TextButton(
                        onPressed: () {
                          pickRandom(restaurants.data!);
                        },
                        style: ButtonStyle(
                          padding: WidgetStateProperty.all<EdgeInsets>(
                            const EdgeInsets.all(16.0),
                          ),
                          shape:
                              WidgetStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                          backgroundColor: WidgetStateProperty.all<Color>(
                            Colors.amber[100]!,
                          ),
                        ),
                        child: Text(
                          'Nochmal',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
