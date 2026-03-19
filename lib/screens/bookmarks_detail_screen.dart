import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/app_data.dart';
import '../models/bookmark_manager.dart';
import '../utils/app_constants.dart';
import '../widgets/restaurant_card_item.dart';

class BookmarksDetailScreen extends StatefulWidget {
  const BookmarksDetailScreen({super.key});

  @override
  State<BookmarksDetailScreen> createState() => _BookmarksDetailScreenState();
}

class _BookmarksDetailScreenState extends State<BookmarksDetailScreen> {
  List<Restaurant> _restaurants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final String response = await rootBundle.loadString('assets/data/restaurants.json');
      final List<dynamic> data = json.decode(response);
      if (mounted) {
        setState(() {
          _restaurants = data.map((json) => Restaurant.fromJson(json)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.scaffold(context),
        appBar: AppBar(
          backgroundColor: AppColors.scaffold(context),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Bookmarks',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.reply, color: isDark ? Colors.white : Colors.black),
              onPressed: () {},
            ),
          ],
          bottom: TabBar(
            indicatorColor: const Color(0xFF1F803A), // Green indicator as per screenshot
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: isDark ? Colors.white : Colors.black,
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            tabs: const [
              Tab(text: 'Dishes'),
              Tab(text: 'Restaurants'),
            ],
          ),
        ),
        body: ListenableBuilder(
          listenable: bookmarkManager,
          builder: (context, _) {
            if (_isLoading) return const Center(child: CircularProgressIndicator());
            return TabBarView(
              children: [
                _buildDishesTab(),
                _buildRestaurantsTab(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDishesTab() {
    final List<Map<String, dynamic>> bookmarkedDishes = [];
    
    for (var rest in _restaurants) {
      for (var dish in rest.dishes) {
        if (bookmarkManager.isDishBookmarked(dish.id)) {
          bookmarkedDishes.add({
            'restaurant': rest,
            'dish': dish,
          });
        }
      }
    }

    if (bookmarkedDishes.isEmpty) {
      return _buildEmptyState('No bookmarked dishes yet');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookmarkedDishes.length,
      itemBuilder: (context, index) {
        final rest = bookmarkedDishes[index]['restaurant'] as Restaurant;
        final dish = bookmarkedDishes[index]['dish'] as Dish;
        return _buildDishCard(rest, dish);
      },
    );
  }

  Widget _buildRestaurantsTab() {
    final bookmarkedRestaurants = _restaurants.where((r) => 
      bookmarkManager.isRestaurantBookmarked(r.slug ?? r.name)).toList();

    if (bookmarkedRestaurants.isEmpty) {
      return _buildEmptyState('No bookmarked restaurants yet');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookmarkedRestaurants.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: RestaurantCardItem(restaurant: bookmarkedRestaurants[index]),
        );
      },
    );
  }

  Widget _buildDishCard(Restaurant rest, Dish dish) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Restaurant Name Header
          Text(
            rest.name,
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 18,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          // Restaurant Stats (Time | Offer)
          Row(
            children: [
              Icon(Icons.timer_outlined, size: 16, color: isDark ? Colors.white70 : Colors.black54),
              const SizedBox(width: 4),
              Text(
                rest.time, 
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54, 
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.verified, size: 16, color: Colors.blue.shade600),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  rest.offer, 
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54, 
                    fontSize: 13, 
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: isDark ? Colors.white10 : Colors.grey.shade100),
          const SizedBox(height: 16),
          
          // Dish Info Section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Veg/Non-veg icon
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        border: Border.all(color: dish.isVeg ? Colors.green.shade700 : Colors.red.shade700, width: 1.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.all(2.5),
                      child: Container(
                        decoration: BoxDecoration(
                          color: dish.isVeg ? Colors.green.shade700 : Colors.red.shade700,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dish.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Highly reordered tag
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 6,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1F803A),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Highly reordered',
                          style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '₹${dish.price}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 18,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Dish Image + Overlays
              Stack(
                alignment: Alignment.bottomCenter,
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      imageUrl: dish.imageUrl,
                      width: 110,
                      height: 110,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: Colors.grey.shade200),
                      errorWidget: (context, url, error) => Container(color: Colors.grey.shade200, child: const Icon(Icons.restaurant)),
                    ),
                  ),
                  // Red Bookmark Ribbon (Simulated)
                  Positioned(
                    top: 0,
                    right: 12,
                    child: Container(
                      width: 14,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF5E62),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(2),
                          bottomRight: Radius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  // ADD Button
                  Positioned(
                    bottom: -15,
                    child: GestureDetector(
                      onTap: () {
                        // Logic to add to cart could go here
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF111111) : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          border: Border.all(color: const Color(0xFF1F803A).withOpacity(0.5), width: 1.5),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'ADD', 
                              style: TextStyle(
                                color: Color(0xFF1F803A), 
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.add, color: Color(0xFF1F803A), size: 14),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.bookmark_border, size: 64, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 20),
          Text(
            message, 
            style: TextStyle(
              color: Colors.grey.shade600, 
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
