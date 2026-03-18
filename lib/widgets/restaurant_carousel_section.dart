import 'package:flutter/material.dart';
import '../models/app_data.dart';
import '../screens/restaurant_details_screen.dart';
import 'restaurant_card.dart';

class RestaurantCarouselSection extends StatelessWidget {
  final List<Restaurant> restaurants;
  final bool isLoading;

  const RestaurantCarouselSection({
    super.key,
    required this.restaurants,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (restaurants.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'RECOMMENDED FOR YOU',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.700,
              letterSpacing: 1.2,
              color: Colors.grey,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 410, // Tuned to perfectly fit 2 rows without overflow
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: restaurants.length,
            itemBuilder: (context, index) {
              final restaurant = restaurants[index];
              final reversedIndex = restaurants.length - 1 - index;
              final bottomRestaurant = restaurants[reversedIndex];

              return Column(
                children: [
                  Container(
                    width: 140, // Smaller card width
                    margin: const EdgeInsets.only(right: 8), // Minimal gap
                    child: GestureDetector(
                      onTap: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                RestaurantDetailsScreen(restaurant: restaurant),
                          ),
                        );
                      },
                      child: RestaurantCard(
                        width: 140,
                        imageHeight: 140, // Square image (height = width)
                        titleSize: 12, // Smaller title size
                        margin: EdgeInsets
                            .zero, // Remove inner margin to reduce gap
                        name: restaurant.name,
                        imageUrl: restaurant.imageUrl,
                        rating: restaurant.rating,
                        deliveryTime: restaurant.time,
                        startingPrice: "Free",
                        offer: restaurant.offer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 140, // Smaller card width
                    margin: const EdgeInsets.only(right: 8), // Minimal gap
                    child: GestureDetector(
                      onTap: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RestaurantDetailsScreen(
                              restaurant: bottomRestaurant,
                            ),
                          ),
                        );
                      },
                      child: RestaurantCard(
                        width: 140,
                        imageHeight: 140, // Square image (height = width)
                        titleSize: 12, // Smaller title size
                        margin: EdgeInsets
                            .zero, // Remove inner margin to reduce gap
                        name: bottomRestaurant.name,
                        imageUrl: bottomRestaurant.imageUrl,
                        rating: bottomRestaurant.rating,
                        deliveryTime: bottomRestaurant.time,
                        startingPrice: "Free",
                        offer: bottomRestaurant.offer,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
