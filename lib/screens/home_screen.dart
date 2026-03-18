import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import '../widgets/top_bar.dart';
import '../widgets/search_area.dart';
import '../widgets/category_list.dart';
import '../widgets/filter_bar.dart';
import '../widgets/app_tab_bar.dart';
import '../widgets/restaurant_list_section.dart';
import '../widgets/restaurant_carousel_section.dart';
import '../widgets/explore_more_section.dart';
import '../widgets/promo_banner.dart';
import 'search_screen.dart';
import '../models/app_data.dart';
import '../models/filter_options.dart';
import '../models/cart_manager.dart';
import '../utils/responsive.dart';
import '../utils/app_constants.dart';
import 'checkout_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Restaurant> _restaurants = [];
  bool _isLoading = true;
  FilterOptions _filterOptions = FilterOptions();
  String _searchQuery = '';
  bool _isBottomNavVisible = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadRestaurants();
  }

  Future<void> _loadRestaurants() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/data/restaurants.json',
      );
      final List<dynamic> data = json.decode(response);
      setState(() {
        _restaurants = data.map((json) => Restaurant.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading restaurants: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showHealthyModeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Healthy Mode'),
        content: const Text('you clicked healthy mode'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Okay'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: cartManager,
      builder: (context, _) {
        final hasCartItems = cartManager.items.isNotEmpty;

        return Scaffold(
          extendBodyBehindAppBar: true,
          extendBody: true,
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              NotificationListener<UserScrollNotification>(
                onNotification: (notification) {
                  if (notification.direction == ScrollDirection.reverse) {
                    if (_isBottomNavVisible)
                      setState(() => _isBottomNavVisible = false);
                  } else if (notification.direction ==
                      ScrollDirection.forward) {
                    if (!_isBottomNavVisible)
                      setState(() => _isBottomNavVisible = true);
                  }
                  return false;
                },
                child: SafeArea(
                  top: false,
                  child: TabBarView(
                    controller: _tabController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildHomeTab(),
                      _buildDealsTab(),
                      _buildDiningTab(),
                    ],
                  ),
                ),
              ),

              if (!hasCartItems) ...[
                // Custom Bottom Navigation Layer - White Pill
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  bottom: _isBottomNavVisible
                      ? 36
                      : -100, // Slides down out of screen
                  left: 16,
                  right: 112 + 12, // 112 green pill + 12 gap
                  child: AnimatedOpacity(
                    opacity: _isBottomNavVisible ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: AppTabBar(
                      controller: _tabController,
                      tabs: const [
                        Tab(icon: Icon(Icons.home_outlined), text: 'Home'),
                        Tab(
                          icon: Icon(Icons.local_offer_outlined),
                          text: 'Under ₹250',
                        ),
                        Tab(icon: Icon(Icons.restaurant_menu), text: 'Dining'),
                      ],
                    ),
                  ),
                ),

                // Custom Bottom Navigation Layer - Healthy Mode Pill
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  bottom: 36, // Consistent with White Pill
                  right: 0, // Attaches to right edge always
                  child: GestureDetector(
                    onTap: _showHealthyModeDialog,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 64, // Matching apptabbar height
                      width: _isBottomNavVisible
                          ? 115.0
                          : 64.0, // Fixed width for consistent alignment
                      decoration: BoxDecoration(
                        color: const Color(0xFF385E3D), // Healthy dark green
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(32),
                          bottomLeft: Radius.circular(32),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons
                                  .volunteer_activism, // Heart being held, UI visual match
                              color: Colors.white,
                              size: 22,
                            ),
                            if (_isBottomNavVisible) ...[
                              const SizedBox(height: 4),
                              const Text(
                                'Healthy Mode',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                  letterSpacing:
                                      -0.2, // Tighter letter spacing to fit beautifully
                                  height: 1.1,
                                ),
                                maxLines: 1,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],

              if (hasCartItems)
                Positioned(
                  bottom: 36,
                  left: 16,
                  right: 16,
                  child: GestureDetector(
                    onTap: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      if (cartManager.currentRestaurant != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CheckoutScreen(
                              restaurant: cartManager.currentRestaurant!,
                            ),
                          ),
                        ).then((_) => setState(() {}));
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F803A),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          _buildCartSmallImages(),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '${cartManager.totalItems} item${cartManager.totalItems > 1 ? 's' : ''} added',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Row(
                            children: const [
                              Text(
                                'View cart',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.chevron_right,
                                color: Colors.white,
                                size: 20,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCartSmallImages() {
    final uniqueDishes = cartManager.items.keys.toList();
    final displayCount = uniqueDishes.length > 3 ? 3 : uniqueDishes.length;

    return SizedBox(
      height: 36,
      width: 36.0 + (displayCount - 1) * 20.0,
      child: Stack(
        children: List.generate(displayCount, (index) {
          final dish = uniqueDishes[index];
          return Positioned(
            left: index * 20.0,
            child: Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF1F803A), width: 2),
                color: Colors.white,
              ),
              child: ClipOval(
                child: Image.network(
                  dish.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.network(
                      'https://images.unsplash.com/photo-1544025162-811afe52fa31?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80',
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            ),
          );
        }).reversed.toList(),
      ),
    );
  }

  Widget _buildHomeTab() {
    // Apply filters
    List<Restaurant> filteredRestaurants = _getFilteredAndSortedRestaurants();

    return CustomScrollView(
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: _StickyHeaderDelegate(
            topInset: MediaQuery.of(context).padding.top,
            topBar: const TopBar(isDarkBackground: true),
            searchArea: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.0),
              child: SearchArea(
                isVegOnly: _filterOptions.isPureVeg,
                onSearchChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SearchScreen(),
                    ),
                  );
                },
                onVegToggle: (val) {
                  setState(() {
                    _filterOptions = _filterOptions.copyWith(isPureVeg: val);
                  });
                },
              ),
            ),
            promoBanner: Padding(
              padding: EdgeInsets.zero,
              child: PromoBanner(
                topPadding: 100 + MediaQuery.of(context).padding.top,
              ),
            ),
            categoriesAndFilters: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: AppSpacing.sm), // Added top margin
                CategoryList(),
                // SizedBox(height: AppSpacing.xs), // Reduced bottom margin
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal:
                      Responsive.getResponsivePadding(context).horizontal / 2,
                ),
                child: FilterBar(
                  currentFilters: _filterOptions,
                  onApplyFilters: (newFilters) {
                    setState(() {
                      _filterOptions = newFilters;
                    });
                  },
                ),
              ),
              AppSpacing.vXl,
            ],
          ),
        ),
        if (_isLoading)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          )
        else ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 0.0),
              child: RestaurantCarouselSection(
                restaurants: filteredRestaurants,
                isLoading: _isLoading,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16.0),
              child: const ExploreMoreSection(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: Responsive.getResponsivePadding(
                context,
              ).copyWith(top: 0),
              child: RestaurantListSection(
                restaurants: filteredRestaurants,
                isLoading: _isLoading,
                title: 'All Restaurants',
              ),
            ),
          ),
        ],
        const SliverToBoxAdapter(
          child: SizedBox(height: 150), // Extra space for floating bar
        ),
      ],
    );
  }

  Widget _buildDealsTab() {
    final dealsRestaurants = _restaurants
        .where((r) => r.offer.isNotEmpty)
        .toList();

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: Responsive.getResponsivePadding(context),
            child: RestaurantListSection(
              restaurants: dealsRestaurants,
              isLoading: _isLoading,
              title: 'Deals of the Day',
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildDiningTab() {
    final diningRestaurants = _restaurants
        .where((r) => r.rating >= 4.0)
        .toList();

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: Responsive.getResponsivePadding(context),
            child: RestaurantListSection(
              restaurants: diningRestaurants,
              isLoading: _isLoading,
              title: 'Top Rated Restaurants',
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  List<Restaurant> _getFilteredAndSortedRestaurants() {
    List<Restaurant> filteredRestaurants = _restaurants;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filteredRestaurants = filteredRestaurants.where((r) {
        // Search in restaurant name
        if (r.name.toLowerCase().contains(query)) return true;
        // Search in dishes
        if (r.dishes.any((d) => d.name.toLowerCase().contains(query)))
          return true;
        return false;
      }).toList();
    }

    // Apply pure veg filter
    if (_filterOptions.isPureVeg) {
      filteredRestaurants = filteredRestaurants.where((r) => r.isVeg).toList();
    }

    // Apply delivery time filter
    if (_filterOptions.maxDeliveryTime != null &&
        _filterOptions.maxDeliveryTime! > 0) {
      filteredRestaurants = filteredRestaurants.where((r) {
        final time = int.tryParse(r.time.split(' ').first);
        if (time != null && time > _filterOptions.maxDeliveryTime!) {
          return false;
        }
        return true;
      }).toList();
    }

    // Apply offers filter
    if (_filterOptions.activeOffers.isNotEmpty) {
      filteredRestaurants = filteredRestaurants.where((r) {
        bool match = false;
        for (final offer in _filterOptions.activeOffers) {
          if (offer == 'Buy 1 Get 1 and more' &&
              (r.offer.contains('Buy 1 Get 1') || r.offer.contains('BOGO'))) {
            match = true;
          } else if (offer == 'Gold offers' && r.isPromoted) {
            match = true;
          } else if (offer == 'Deals of the Day' && r.offer.isNotEmpty) {
            match = true;
          }
        }
        return match;
      }).toList();
    }

    // Apply sorting
    if (_filterOptions.sortBy == 'Rating') {
      filteredRestaurants.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (_filterOptions.sortBy == 'Delivery Time') {
      filteredRestaurants.sort((a, b) {
        final timeA = int.tryParse(a.time.split(' ').first) ?? 0;
        final timeB = int.tryParse(b.time.split(' ').first) ?? 0;
        return timeA.compareTo(timeB);
      });
    }

    return filteredRestaurants;
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget topBar;
  final Widget searchArea;
  final Widget promoBanner;
  final Widget categoriesAndFilters;
  final double topInset;

  late final double topBarHeight;
  final double searchHeight = 85.0;
  final double promoHeight = 280.0; // Taller for full screen behind
  final double bottomHeight = 116.0;

  _StickyHeaderDelegate({
    required this.topBar,
    required this.searchArea,
    required this.promoBanner,
    required this.categoriesAndFilters,
    required this.topInset,
  }) {
    topBarHeight = 60.0 + topInset;
  }

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    // Determine opacity of promo banner
    final double maxShrink = promoHeight;
    final double fadeOutProgress = (shrinkOffset / maxShrink).clamp(0.0, 1.0);

    // Background changes from transparent to white as it shrinks
    final Color bgColor = Color.lerp(
      Colors.transparent,
      Colors.white,
      fadeOutProgress,
    )!;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: fadeOutProgress < 0.5
          ? SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.dark,
            )
          : SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.light,
            ),
      child: Container(
        color: Colors
            .transparent, // Changed from White so status bar matches banner underneath
        child: ClipRect(
          child: Stack(
            children: [
              // Middle Area (Promo Banner) - Starts at very top, fades out
              Positioned(
                top: -shrinkOffset * 0.5,
                left: 0,
                right: 0,
                height:
                    promoHeight +
                    topBarHeight, // Tall enough to sit behind top bar
                child: Opacity(
                  opacity: 1.0 - fadeOutProgress,
                  child: promoBanner,
                ),
              ),
              // Persistent background for search/topbar when scrolled
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height:
                    (topBarHeight - shrinkOffset > topInset
                        ? topBarHeight - shrinkOffset
                        : topInset) +
                    searchHeight,
                child: Container(color: bgColor),
              ),
              // Bottom Area (Categories + Filters - anchors to bottom)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: bottomHeight,
                child: Container(
                  color: Colors.white,
                  child: categoriesAndFilters,
                ),
              ),
              // Search Area (stays fixed below Top Bar)
              Positioned(
                top: topBarHeight - shrinkOffset > topInset
                    ? topBarHeight - shrinkOffset
                    : topInset,
                left: 0,
                right: 0,
                height: searchHeight,
                child: Container(
                  alignment: Alignment.center,
                  child: searchArea,
                ),
              ),
              // Top Area (Top Bar - ALWAYS FIXED AT TOP)
              Positioned(
                top: topInset - shrinkOffset,
                left: 0,
                right: 0,
                height: topBarHeight - topInset,
                child: Container(
                  alignment: Alignment.center,
                  // TopBar dynamically adjusts its color text based on scroll position by replacing widget dynamically or using transparency threshold
                  child: TopBar(isDarkBackground: fadeOutProgress < 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => topBarHeight + promoHeight + bottomHeight;

  @override
  double get minExtent => topInset + searchHeight + bottomHeight;

  @override
  bool shouldRebuild(covariant _StickyHeaderDelegate oldDelegate) {
    return true;
  }
}
