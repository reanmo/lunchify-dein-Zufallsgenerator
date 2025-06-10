import 'package:flutter/material.dart';
import 'package:lunchify/models/database.dart';

void showFavoritesModal(
  BuildContext context,
  List<Restaurant> restaurantsList,
) async {
  // Filter the list to include only favorite restaurants
  final favoriteRestaurants =
      restaurantsList.where((restaurant) => restaurant.isFavorite).toList();

  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Favoriten Restaurants',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child:
                  favoriteRestaurants.isNotEmpty
                      ? ListView.builder(
                        itemCount: favoriteRestaurants.length,
                        itemBuilder: (context, index) {
                          final restaurant = favoriteRestaurants[index];
                          return ListTile(
                            leading: Image.asset(
                              restaurant.imagePath,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                            title: Text(restaurant.name),
                          );
                        },
                      )
                      : Center(
                        child: Text(
                          'Keine Favoriten hinzugefügt.',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
            ),
          ],
        ),
      );
    },
  );
}
