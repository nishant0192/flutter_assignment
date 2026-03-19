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
import '../widgets/shimmer_widgets.dart';
import 'search_screen.dart';
import '../models/app_data.dart';
import '../models/filter_options.dart';
import '../models/cart_manager.dart';
import '../utils/responsive.dart';
import '../utils/app_constants.dart';
import 'checkout_screen.dart';
import 'restaurant_details_screen.dart';
import '../widgets/primary_button.dart';

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
  bool _showRemoveCart = false;
  static bool _hasLoadedOnce = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRestaurants();
    });
  }
  Future<void> _loadRestaurants() async {
    try {
      // Only show skeleton for at least 1500ms on the FIRST load
      if (!_hasLoadedOnce) {
        final results = await Future.wait([
          rootBundle.loadString('assets/data/restaurants.json'),
          Future.delayed(const Duration(milliseconds: 1500)),
        ]);
        final String response = results[0] as String;
        final List<dynamic> data = json.decode(response);
        setState(() {
          _restaurants = data.map((json) => Restaurant.fromJson(json)).toList();
          _isLoading = false;
          _hasLoadedOnce = true;
        });
      } else {
        final String response = await rootBundle.loadString('assets/data/restaurants.json');
        final List<dynamic> data = json.decode(response);
        setState(() {
          _restaurants = data.map((json) => Restaurant.fromJson(json)).toList();
          _isLoading = false;
        });
      }
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
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                bottom: 36, // Always stays at bottom: 36
                right: 0, // Attaches to right edge always
                child: GestureDetector(
                  onTap: _showHealthyModeDialog,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 56, // Matching apptabbar height
                    width: _isBottomNavVisible
                        ? 100.0
                        : 56.0, // Shrinks to a circle when scrolling down
                    decoration: BoxDecoration(
                      color: const Color(0xFF385E3D), // Healthy dark green
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(28),
                        bottomLeft: Radius.circular(28),
                      ),
                      boxShadow: Theme.of(context).brightness == Brightness.dark
                          ? null
                          : [
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
                                fontSize: 9,
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

              if (hasCartItems && cartManager.currentRestaurant != null)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  bottom: _isBottomNavVisible
                      ? 102
                      : 36, // Lowered slightly due to shorter nav
                  left: _showRemoveCart
                      ? 16.0 - (MediaQuery.of(context).size.width * 0.28)
                      : 16.0,
                  right: _isBottomNavVisible
                      ? 16
                      : 72, // Leave space for Healthy Mode circle when bottom nav hidden
                  child: GestureDetector(
                    onTap: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CheckoutScreen(
                            restaurant: cartManager.currentRestaurant!,
                          ),
                        ),
                      ).then((_) => setState(() {}));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: _showRemoveCart ? Colors.red.shade50 : AppColors.card(context),
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: Theme.of(context).brightness == Brightness.dark
                            ? null
                            : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.12),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                      ),
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.only(left: 10, right: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.card(context),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      child: CircleAvatar(
                                        radius: 20, // Reduced from 24
                                        backgroundColor: Colors.grey[200],
                                        child: ClipOval(
                                          child: Image.network(
                                            cartManager.currentRestaurant!.imageUrl,
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
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        child: GestureDetector(
                                          behavior: HitTestBehavior.opaque,
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    RestaurantDetailsScreen(
                                                      restaurant:
                                                          cartManager.currentRestaurant!,
                                                    ),
                                              ),
                                            );
                                          },
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                cartManager.currentRestaurant!.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 14,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Row(
                                                children: const [
                                                  Text(
                                                    'View Menu',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                  SizedBox(width: 2),
                                                  Icon(
                                                    Icons.arrow_right,
                                                    color: AppColors.primary,
                                                    size: 14,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Center(
                                      child: PrimaryButton(
                                        label: 'View Cart',
                                        subtitle: '${cartManager.totalItems} item${cartManager.totalItems > 1 ? 's' : ''}',
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => CheckoutScreen(
                                                restaurant: cartManager.currentRestaurant!,
                                              ),
                                            ),
                                          );
                                        },
                                        width: null, // Content fit
                                        borderRadius: 100,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 6,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Center(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _showRemoveCart = !_showRemoveCart;
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.black54,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (!_showRemoveCart) const SizedBox(width: 2),
                                  ],
                                ),
                              ),
                            ),
                            AnimatedSize(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                              child: _showRemoveCart
                                  ? GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () {
                                        cartManager.clear();
                                        setState(() {
                                          _showRemoveCart = false;
                                        });
                                      },
                                      child: Container(
                                        width: MediaQuery.of(context).size.width * 0.22,
                                        alignment: Alignment.center,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        child: const Text(
                                          'Remove',
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    )
                                  : const SizedBox(width: 0),
                            ),
                          ],
                        ),
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

  // Remove _buildCartSmallImages since it's no longer used

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
                onMicTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const SearchScreen(autoFocusMic: true),
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
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: 16,
                  left: Responsive.getResponsivePadding(context).horizontal / 2,
                  right: Responsive.getResponsivePadding(context).horizontal / 2,
                  bottom: 8,
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
            child: HomeSkeletonLoading(),
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

    // Background changes from transparent to scaffold color as it shrinks
    final Color scaffoldColor = Theme.of(context).scaffoldBackgroundColor;
    final Color bgColor = Color.lerp(
      Colors.transparent,
      scaffoldColor,
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
                  color: scaffoldColor,
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
