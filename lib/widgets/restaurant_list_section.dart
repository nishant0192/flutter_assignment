import 'package:flutter/material.dart';
import '../models/app_data.dart';
import '../screens/restaurant_details_screen.dart';
import '../utils/app_constants.dart';
import '../utils/responsive.dart';

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
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(child: CircularProgressIndicator()),
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
    return _RestaurantCardItem(restaurant: restaurant);
  }
}

class _RestaurantCardItem extends StatefulWidget {
  final Restaurant restaurant;

  const _RestaurantCardItem({required this.restaurant});

  @override
  State<_RestaurantCardItem> createState() => _RestaurantCardItemState();
}

class _RestaurantCardItemState extends State<_RestaurantCardItem> {
  int _currentImageIndex = 0;
  late final List<String> _images;

  @override
  void initState() {
    super.initState();
    // Create a list of images for the slider, starting with the restaurant's image,
    // and appending dish images from the data.
    if (widget.restaurant.imageUrls.isNotEmpty) {
      _images = widget.restaurant.imageUrls;
    } else {
      _images = [
        widget.restaurant.imageUrl,
        ...widget.restaurant.dishes.take(4).map((dish) => dish.imageUrl),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final restaurant = widget.restaurant;
    final String label = restaurant.isVeg
        ? 'Pure Veg • ₹150 for one'
        : 'Best Seller • ₹200 for one';
    final String distance = '1 km';
    final String ratingsCount =
        'By ${((restaurant.rating * 2.1).toStringAsFixed(1))}K+';

    return GestureDetector(
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
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 0,
          vertical: 0,
        ), // Reduced side margin
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Stack
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadius.lg),
                  ),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: PageView.builder(
                      itemCount: _images.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Image.network(
                          _images[index],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.network(
                              'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey.shade200,
                                  child: Center(
                                    child: Icon(
                                      Icons.restaurant,
                                      size: 48,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                // Top Left Overlay (Dish/Veg info)
                Positioned(
                  top: AppSpacing.md,
                  left: AppSpacing.md,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                // Top Right Overlay (Bookmark)
                Positioned(
                  top: AppSpacing.sm,
                  right: AppSpacing.sm,
                  child: IconButton(
                    icon: const Icon(
                      Icons.bookmark_border,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () {},
                  ),
                ),
                // Bottom Right Overlay (Dots)
                Positioned(
                  bottom: AppSpacing.md,
                  right: AppSpacing.md,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      _images.length,
                      (index) => Container(
                        margin: const EdgeInsets.only(left: 4),
                        width: index == _currentImageIndex ? 8 : 6,
                        height: index == _currentImageIndex ? 8 : 6,
                        decoration: BoxDecoration(
                          color: index == _currentImageIndex
                              ? Colors.white
                              : Colors.white.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Details Section
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              restaurant.name,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time_filled,
                                  size: 16,
                                  color: Colors.grey.shade700,
                                ),
                                AppSpacing.hXs,
                                Text(
                                  restaurant.time,
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6.0,
                                  ),
                                  child: Text(
                                    '|',
                                    style: TextStyle(
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                ),
                                Text(
                                  distance,
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6.0,
                                  ),
                                  child: Text(
                                    '|',
                                    style: TextStyle(
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.electric_bike,
                                  size: 16,
                                  color: Colors.grey.shade700,
                                ),
                                AppSpacing.hXs,
                                Text(
                                  'Free',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      AppSpacing.hSm,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade700,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  restaurant.rating.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          AppSpacing.vXs,
                          Text(
                            ratingsCount,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Colors.grey.shade600,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Row 3: Offers
                  if (restaurant.offer.isNotEmpty) ...[
                    const SizedBox(height: 6), // Better spacing above offers
                    Row(
                      children: [
                        Icon(
                          Icons.verified,
                          size: 16,
                          color: Colors.blue.shade700,
                        ),
                        AppSpacing.hXs,
                        Expanded(
                          child: Text(
                            restaurant.offer,
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
