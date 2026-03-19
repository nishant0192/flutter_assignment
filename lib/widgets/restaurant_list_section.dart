import 'package:flutter/material.dart';
import '../models/app_data.dart';
import '../utils/app_constants.dart';
import '../utils/responsive.dart';
import 'shimmer_widgets.dart';
import 'restaurant_card_item.dart';

class RestaurantListSection extends StatelessWidget {
  final List<Restaurant> restaurants;
  final bool isLoading;
  final String title;
  final bool showCarousel;
  final ScrollController? scrollController;

  const RestaurantListSection({
    super.key,
    required this.restaurants,
    required this.isLoading,
    this.title = 'Restaurants',
    this.showCarousel = false,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: List.generate(
            3,
            (index) => const Padding(
              padding: EdgeInsets.only(bottom: 24),
              child: RestaurantCardSkeleton(),
            ),
          ),
        ),
      );
    }

    if (restaurants.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.restaurant_menu,
                size: 64,
                color: Colors.grey.shade300,
              ),
              AppSpacing.vLg,
              Text(
                'No restaurants found',
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: Colors.grey),
              ),
              AppSpacing.vMd,
              Text(
                'Try adjusting your filters',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(top: 0, bottom: 5),
              child: Text(
                '${restaurants.length} RESTAURANTS DELIVERING TO YOU',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.grey.shade600,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (title == 'All Restaurants')
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  'Featured',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            // Removed SizedBox gap completely
          ],
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = Responsive.getGridColumns(context);
              if (columns == 1) {
                return ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: restaurants.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppSpacing.xl),
                  itemBuilder: (context, index) {
                    return _buildRestaurantCard(context, restaurants[index]);
                  },
                );
              } else {
                return GridView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: AppSpacing.lg,
                    mainAxisSpacing: AppSpacing.lg,
                  ),
                  itemCount: restaurants.length,
                  itemBuilder: (context, index) {
                    return _buildRestaurantCard(context, restaurants[index]);
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantCard(BuildContext context, Restaurant restaurant) {
    return RestaurantCardItem(restaurant: restaurant);
  }
}

// _RestaurantCardItem has been moved to RestaurantCardItem in restaurant_card_item.dart
