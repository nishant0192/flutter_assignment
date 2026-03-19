import 'package:flutter/material.dart';
import '../utils/app_constants.dart' ;
import '../models/filter_options.dart';
import 'primary_button.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({Key? key}) : super(key: key);

  @override
  _FilterBottomSheetState createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  int _selectedIndex = 0;

  final ScrollController _scrollController = ScrollController();
  final ScrollController _leftScrollController = ScrollController();
  final GlobalKey _scrollContainerKey = GlobalKey();
  late List<GlobalKey> _sectionKeys;
  bool _isAutoScrolling = false;
  bool _isSortExpanded = false;

  final List<String> _filterCategories = [
    'Sort By',
    'Time',
    'Rating',
    'Offers',
    'Dish Price',
    'Trust Markers',
    'Collections',
  ];

  String _sortBy = 'relevance';
  final Set<String> _selectedTimes = {};
  final Set<String> _selectedRatings = {};
  final Set<String> _selectedOffers = {};
  final Set<String> _selectedPrices = {};
  final Set<String> _selectedTrustMarkers = {};
  final Set<String> _selectedCollections = {};

  @override
  void initState() {
    super.initState();
    _sectionKeys = List.generate(_filterCategories.length, (_) => GlobalKey());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _leftScrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isAutoScrolling) return;

    if (_scrollController.hasClients) {
      // Check if we are at the bottom
      if (_scrollController.offset >= _scrollController.position.maxScrollExtent - 20) {
        if (_selectedIndex != _filterCategories.length - 1) {
          setState(() {
            _selectedIndex = _filterCategories.length - 1;
            _syncLeftRail(6);
          });
        }
        return;
      }

      if (_scrollController.offset <= 10) {
        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
            _syncLeftRail(0);
          });
        }
        return;
      }

      final scrollBox =
          _scrollContainerKey.currentContext?.findRenderObject() as RenderBox?;
      if (scrollBox == null) return;

      for (int i = _sectionKeys.length - 1; i >= 0; i--) {
        final key = _sectionKeys[i];
        if (key.currentContext != null) {
          final RenderBox box =
              key.currentContext!.findRenderObject() as RenderBox;
          final offset = box.localToGlobal(Offset.zero, ancestor: scrollBox);
          if (offset.dy <= 120) {
            if (_selectedIndex != i) {
              setState(() {
                _selectedIndex = i;
                _syncLeftRail(i);
              });
            }
            break;
          }
        }
      }
    }
  }

  void _syncLeftRail(int index) {
    if (_leftScrollController.hasClients) {
      final itemHeight = 72.0; // Approximation of item height
      final viewHeight = MediaQuery.of(context).size.height * 0.6;
      final targetOffset = (index * itemHeight) - (viewHeight / 3);
      
      _leftScrollController.animateTo(
        targetOffset.clamp(0.0, _leftScrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  void _scrollToIndex(int index) async {
    setState(() {
      _selectedIndex = index;
    });

    _isAutoScrolling = true;
    final context = _sectionKeys[index].currentContext;
    if (context != null) {
      await Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.0,
      );
    }
    // slight delay to prevent onScroll from reverting index immediately
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) {
        _isAutoScrolling = false;
      }
    });
  }

  void _clearAll() {
    setState(() {
      _sortBy = 'relevance';
      _selectedTimes.clear();
      _selectedRatings.clear();
      _selectedOffers.clear();
      _selectedPrices.clear();
      _selectedTrustMarkers.clear();
      _selectedCollections.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 16.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filters and sorting',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                    ),
                ),
                GestureDetector(
                  onTap: _clearAll,
                  child: const Text(
                    'Clear all',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          // Body (Left Rail + Right Content)
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Rail
                Container(
                  width: 90,
                  decoration: BoxDecoration(
                    color: AppColors.card(context),
                    border: Border(
                      right: BorderSide(
                        color: isDark ? Colors.white10 : Colors.grey.shade300,
                        width: 1.0,
                      ),
                    ),
                  ),
                  child: ListView.builder(
                    controller: _leftScrollController,
                    itemCount: _filterCategories.length,
                    itemBuilder: (context, index) {
                      final isSelected = _selectedIndex == index;
                      return InkWell(
                        onTap: () => _scrollToIndex(index),
                        child: Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1FDF5))
                                    : Colors.transparent,
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 16.0,
                                horizontal: 6.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  if (index == 0)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 4.0,
                                      ),
                                      child: Icon(
                                        Icons.sort,
                                        size: 16,
                                        color: isSelected
                                            ? Colors.green
                                            : (isDark ? Colors.white38 : Colors.grey),
                                      ),
                                    ),
                                  if (index == 1)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 4.0,
                                      ),
                                      child: Icon(
                                        Icons.timer_outlined,
                                        size: 16,
                                        color: isSelected
                                            ? Colors.green
                                            : (isDark ? Colors.white38 : Colors.grey),
                                      ),
                                    ),
                                  if (index == 2)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 4.0,
                                      ),
                                      child: Icon(
                                        Icons.star_border,
                                        size: 16,
                                        color: isSelected
                                            ? Colors.green
                                            : (isDark ? Colors.white38 : Colors.grey),
                                      ),
                                    ),
                                  if (index == 3)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 4.0,
                                      ),
                                      child: Icon(
                                        Icons.local_offer_outlined,
                                        size: 16,
                                        color: isSelected
                                            ? Colors.green
                                            : (isDark ? Colors.white38 : Colors.grey),
                                      ),
                                    ),
                                  if (index == 4)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 4.0,
                                      ),
                                      child: Icon(
                                        Icons.currency_rupee,
                                        size: 16,
                                        color: isSelected
                                            ? Colors.green
                                            : (isDark ? Colors.white38 : Colors.grey),
                                      ),
                                    ),
                                  if (index == 5)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 4.0,
                                      ),
                                      child: Icon(
                                        Icons.verified_user_outlined,
                                        size: 16,
                                        color: isSelected
                                            ? Colors.green
                                            : (isDark ? Colors.white38 : Colors.grey),
                                      ),
                                    ),
                                  if (index == 6)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 4.0,
                                      ),
                                      child: Icon(
                                        Icons.collections_bookmark_outlined,
                                        size: 16,
                                        color: isSelected
                                            ? Colors.green
                                            : (isDark ? Colors.white38 : Colors.grey),
                                      ),
                                    ),
                                  Text(
                                    _filterCategories[index],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? Colors.green
                                          : (isDark ? Colors.white70 : Colors.black87),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Positioned(
                                right: 0,
                                top: 0,
                                bottom: 0,
                                child: Container(
                                  width: 3.0,
                                  color: Colors.green,
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                // Right Content
                Expanded(
                  child: Container(
                    key: _scrollContainerKey,
                    color: AppColors.card(context),
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(
                        left: 12,
                        right: 8,
                        top: 16,
                        bottom: 80,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSortBySection(0),
                          const SizedBox(height: 24),
                          _buildGridSection(1, 'Time', [
                            _OptionItem('Schedule', icon: Icons.calendar_today),
                            _OptionItem(
                              'Near & Fast',
                              icon: Icons.bolt,
                              iconColor: Colors.green,
                            ),
                          ], _selectedTimes),
                          const SizedBox(height: 24),
                          _buildGridSection(2, 'Restaurant Rating', [
                            _OptionItem(
                              'Rated 3.5+',
                              icon: Icons.star,
                              iconColor: Colors.green,
                            ),
                            _OptionItem(
                              'Rated 4.0+',
                              icon: Icons.star,
                              iconColor: Colors.green,
                            ),
                          ], _selectedRatings),
                          const SizedBox(height: 24),
                          _buildChipSection(3, 'Offers', [
                            _OptionItem('Buy 1 Get 1 and more'),
                            _OptionItem('Deals of the Day'),
                            _OptionItem(
                              'Gold offers',
                              icon: Icons.workspace_premium,
                              iconColor: Colors.amber,
                            ),
                          ], _selectedOffers),
                          const SizedBox(height: 24),
                          _buildGridSection(4, 'Dish Price', [
                            _OptionItem(
                              'Under ₹200',
                              icon: Icons.currency_rupee,
                              iconColor: Colors.green,
                            ),
                            _OptionItem(
                              '₹200 - ₹350',
                              icon: Icons.currency_rupee,
                              iconColor: Colors.green,
                            ),
                            _OptionItem(
                              'Above ₹350',
                              icon: Icons.currency_rupee,
                              iconColor: Colors.green,
                            ),
                          ], _selectedPrices),
                          const SizedBox(height: 24),
                          _buildGridSection(5, 'Trust Markers', [
                            _OptionItem(
                              'Pure Veg',
                              icon: Icons.eco,
                              iconColor: Colors.green,
                            ),
                            _OptionItem(
                              'No Packaging charges',
                              icon: Icons.money_off,
                              iconColor: Colors.green,
                            ),
                            _OptionItem(
                              'Low plastic packaging',
                              icon: Icons.shopping_bag,
                              iconColor: Colors.green,
                            ),
                          ], _selectedTrustMarkers),
                          const SizedBox(height: 24),
                          _buildChipSection(6, 'Collections', [
                            _OptionItem('Previously ordered'),
                            _OptionItem('Gourmet'),
                            _OptionItem('New to you'),
                          ], _selectedCollections),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Footer
          const Divider(height: 1, color: AppColors.border),
          Container(
            color: AppColors.card(context),
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 16.0,
              bottom: 36.0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: isDark ? Colors.white70 : Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade300),
                      ),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: PrimaryButton(
                    onPressed: () {
                      Navigator.pop(context, FilterOptions());
                    },
                    label: 'Show results',
                    borderRadius: 12,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortBySection(int index) {
    final sortOptions = [
      {'val': 'relevance', 'label': 'Relevance'},
      {'val': 'distance', 'label': 'Distance: Low to High'},
      {'val': 'rating_htl', 'label': 'Rating: High to Low'},
      {'val': 'delivery_time', 'label': 'Delivery Time: Low to High'},
      {'val': 'cost_lth', 'label': 'Cost for one: Low to High'},
      {'val': 'cost_htl', 'label': 'Cost for one: High to Low'},
    ];

    String currentLabel = sortOptions.firstWhere(
      (opt) => opt['val'] == _sortBy,
    )['label']!;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      key: _sectionKeys[index],
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.03) : const Color(0xFFF5F6F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isSortExpanded = !_isSortExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sort by',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                      ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!_isSortExpanded)
                        Text(
                          currentLabel,
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      if (!_isSortExpanded) const SizedBox(width: 4),
                      Icon(
                        _isSortExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Colors.green,
                        size: 22,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_isSortExpanded)
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  color: AppColors.card(context),
                  child: Column(
                    children: [
                      for (int i = 0; i < sortOptions.length; i++) ...[
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _sortBy = sortOptions[i]['val']!;
                            });
                          },
                          child: Container(
                            color: _sortBy == sortOptions[i]['val']
                                ? (isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1FDF5))
                                : Colors.transparent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  sortOptions[i]['label']!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: _sortBy == sortOptions[i]['val']
                                        ? FontWeight.w500
                                        : FontWeight.w400,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                Icon(
                                  _sortBy == sortOptions[i]['val']
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_off,
                                  color: _sortBy == sortOptions[i]['val']
                                      ? Colors.green
                                      : (isDark ? Colors.white24 : Colors.grey.shade400),
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (i < sortOptions.length - 1)
                          Divider(height: 1, color: isDark ? Colors.white10 : const Color(0xFFF0F0F0)),
                      ],
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGridSection(
    int index,
    String title,
    List<_OptionItem> options,
    Set<String> selectedSet,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      key: _sectionKeys[index],
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.03) : const Color(0xFFF5F6F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
              ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final double tileWidth = (constraints.maxWidth - 12) / 2;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: options.map((opt) {
                  final isSelected = selectedSet.contains(opt.label);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedSet.remove(opt.label);
                        } else {
                          selectedSet.add(opt.label);
                        }
                      });
                    },
                    child: Container(
                      width: tileWidth,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.card(context),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? Colors.green : Colors.transparent,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (opt.icon != null) ...[
                            Icon(opt.icon, color: opt.iconColor, size: 24),
                            const SizedBox(height: 8),
                          ],
                          Text(
                            opt.label,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected ? Colors.green : (isDark ? Colors.white70 : Colors.black87),
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChipSection(
    int index,
    String title,
    List<_OptionItem> options,
    Set<String> selectedSet,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      key: _sectionKeys[index],
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.03) : const Color(0xFFF5F6F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
              ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: options.map((opt) {
              final isSelected = selectedSet.contains(opt.label);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      selectedSet.remove(opt.label);
                    } else {
                      selectedSet.add(opt.label);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.card(context),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? Colors.green : (isDark ? Colors.white10 : Colors.grey.shade300),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (opt.icon != null) ...[
                        Icon(opt.icon, color: opt.iconColor, size: 16),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        opt.label,
                        style: TextStyle(
                          fontSize: 13,
                          color: isSelected ? Colors.green : (isDark ? Colors.white70 : Colors.black87),
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _OptionItem {
  final String label;
  final IconData? icon;
  final Color? iconColor;

  _OptionItem(this.label, {this.icon, this.iconColor});
}
