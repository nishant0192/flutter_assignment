import 'dart:convert';
import 'package:flutter/material.dart';
import '../utils/app_constants.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/app_data.dart';
import '../screens/restaurant_details_screen.dart';
import 'shimmer_widgets.dart';

class CategoryList extends StatefulWidget {
  const CategoryList({super.key});

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  int _selectedIndex = 1; // Default to 'All' which is now at index 1
  List<Map<String, dynamic>> _allCategories = [];
  List<Map<String, dynamic>> _displayCategories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final results = await Future.wait([
        rootBundle.loadString('assets/data/search_categories.json'),
        Future.delayed(const Duration(milliseconds: 1500)),
      ]);
      final String catResponse = results[0] as String;
      final List<dynamic> catData = json.decode(catResponse);
      final allCats = List<Map<String, dynamic>>.from(catData);

      if (mounted) {
        setState(() {
          _allCategories = allCats;
          _displayCategories = allCats.take(10).toList();

          if (_displayCategories.isNotEmpty) {
            _displayCategories.insert(0, {
              'name': 'Under ₹250',
              'imageUrl':
                  'https://images.unsplash.com/photo-1541592106381-b31e9677c0e5?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
            });
          }

          _displayCategories.add({'name': 'See all', 'imageUrl': ''});
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading categories: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showAllCategoriesBottomSheet() {
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.black87,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 24),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.card(context),
                    borderRadius: const BorderRadius.all(Radius.circular(24)),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 16.0,
                          top: 24.0,
                          bottom: 12.0,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "What's on your mind?",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: _allCategories.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CategoryListSkeleton(),
                              )
                            : GridView.builder(
                                padding: const EdgeInsets.only(
                                  left: 16,
                                  right: 16,
                                  top: 8,
                                  bottom: 24,
                                ),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 4,
                                      childAspectRatio: 0.65,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                    ),
                                itemCount: _allCategories.length,
                                itemBuilder: (context, index) {
                                  final cat = _allCategories[index];
                                  return Column(
                                    children: [
                                      AspectRatio(
                                        aspectRatio: 1,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AppColors.card(context),
                                          ),
                                          clipBehavior: Clip.antiAlias,
                                          child: CachedNetworkImage(
                                            imageUrl: cat['imageUrl'],
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => Container(
                                              color: Colors.grey.shade200,
                                            ),
                                            errorWidget: (context, url, error) => CachedNetworkImage(
                                              imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Expanded(
                                        child: Text(
                                          cat['name'],
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Theme.of(context).textTheme.bodyMedium?.color,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const CategoryListSkeleton();
    }

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 100,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                  color: isDark ? Colors.white10 : Colors.grey.shade300,
                  width: 1.0),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: List.generate(_displayCategories.length, (index) {
              final cat = _displayCategories[index];
              final isSelected = _selectedIndex == index;

              return GestureDetector(
                onTap: () {
                  if (cat['name'] == 'See all') {
                    _showAllCategoriesBottomSheet();
                  } else if (cat['name'] == 'Under ₹250' ||
                      cat['name'] == 'Under â‚¹250') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RestaurantDetailsScreen(
                          restaurant: const Restaurant(
                            name: 'Under ₹250 Delights',
                            imageUrl:
                                'https://images.unsplash.com/photo-1541592106381-b31e9677c0e5?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80',
                            rating: 4.5,
                            time: '20-30 mins',
                            offer: 'Every item under ₹250!',
                            isPromoted: true,
                            isVeg: false,
                            dishes: [
                              Dish(
                                id: 'u1',
                                name: 'Budget Burger',
                                price: 149,
                                description:
                                    'A massive burger that fits your budget.',
                                imageUrl:
                                    'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
                              ),
                              Dish(
                                id: 'u2',
                                name: 'Pocket Pizza',
                                price: 249,
                                description: 'Delicious personal size pizza.',
                                imageUrl:
                                    'https://images.unsplash.com/photo-1513104890138-7c749659a591?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  } else {
                    setState(() {
                      _selectedIndex = index;
                    });
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isSelected ? AppColors.primary : Colors.transparent,
                        width: isSelected ? 3.0 : 0.0,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (cat['name'] == 'See all')
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: isDark
                              ? AppColors.primary.withOpacity(0.15)
                              : Colors.green.shade50,
                          child: Icon(
                            Icons.restaurant,
                            color: AppColors.primary,
                          ),
                        )
                      else
                        Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: CachedNetworkImage(
                            imageUrl: cat['imageUrl'],
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey.shade200,
                            ),
                            errorWidget: (context, url, error) => CachedNetworkImage(
                              imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        cat['name'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: isSelected
                              ? Theme.of(context).textTheme.bodyLarge?.color
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
