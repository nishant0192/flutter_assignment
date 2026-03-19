import 'package:flutter/material.dart';
import '../models/app_data.dart';
import '../screens/restaurant_details_screen.dart';
import 'restaurant_card.dart';

class AllRestaurantsSection extends StatelessWidget {
  final List<Restaurant> restaurants;
  final bool isLoading;

  const AllRestaurantsSection({
    super.key,
    required this.restaurants,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'ALL RESTAURANTS',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              ),
          ),
        ),
        ListView.builder(
          physics:
              const NeverScrollableScrollPhysics(), // Disable scrolling for this internal list
          shrinkWrap: true, // Allow it to take necessary height
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: restaurants.length,
          itemBuilder: (context, index) {
            final restaurant = restaurants[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          RestaurantDetailsScreen(restaurant: restaurant),
                    ),
                  );
                },
                child: RestaurantCard(
                  width: double.infinity, // Full width for vertical list
                  name: restaurant.name,
                  imageUrl: restaurant.imageUrl,
                  rating: restaurant.rating,
                  deliveryTime: restaurant.time,
                  startingPrice: "Free",
                  offer: restaurant.offer,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
