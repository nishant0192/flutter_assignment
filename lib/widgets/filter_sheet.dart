import 'package:flutter/material.dart';
import '../utils/app_constants.dart' ;
import '../models/filter_options.dart';
import 'selectable_box_option.dart';
import 'schedule_bottom_sheet.dart';

class FilterSheet extends StatefulWidget {
  final FilterOptions initialFilters;

  const FilterSheet({super.key, required this.initialFilters});

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  int _selectedIndex = 0;
  late FilterOptions _currentFilters;

  @override
  void initState() {
    super.initState();
    _currentFilters = widget.initialFilters.copyWith(
      activeOffers: List.from(widget.initialFilters.activeOffers),
      collections: List.from(widget.initialFilters.collections),
    );
  }

  void _updateFilter(FilterOptions newFilters) {
    setState(() {
      _currentFilters = newFilters;
    });
  }

  final List<String> _categories = [
    'Sort By',
    'Time',
    'Rating',
    'Offers',
    'Dish Price',
    'Trust Markers',
    'Collections',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          const Divider(height: 1),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSidebar(),
                const VerticalDivider(width: 1),
                Expanded(child: _buildContent()),
              ],
            ),
          ),
          const Divider(height: 1),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Filters and sorting',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _currentFilters = FilterOptions(); // Reset to default
              });
            },
            child: const Text(
              'Clear all',
              style: TextStyle(
                color: Colors.deepOrange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 110, // Slightly wider sidebar
      color: Colors.grey[50],
      child: ListView.builder(
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedIndex == index;
          return InkWell(
            onTap: () {
              setState(() {
                _selectedIndex = index;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 24,
                horizontal: 12,
              ), // Increased vertical padding
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.grey[50],
                border: isSelected
                    ? const Border(
                        left: BorderSide(color: Colors.deepOrange, width: 4),
                      )
                    : null,
              ),
              child: Column(
                children: [
                  if (index == 0) ...[
                    Icon(
                      Icons.sort,
                      size: 22,
                      color: isSelected ? Colors.black : Colors.grey,
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (index == 1) ...[
                    Icon(
                      Icons.access_time,
                      size: 22,
                      color: isSelected ? Colors.black : Colors.grey,
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (index == 2) ...[
                    Icon(
                      Icons.star_border,
                      size: 22,
                      color: isSelected ? Colors.black : Colors.grey,
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (index == 3) ...[
                    Icon(
                      Icons.local_offer_outlined,
                      size: 22,
                      color: isSelected ? Colors.black : Colors.grey,
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (index == 4) ...[
                    Icon(
                      Icons.currency_rupee,
                      size: 22,
                      color: isSelected ? Colors.black : Colors.grey,
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (index == 5) ...[
                    Icon(
                      Icons.verified_user_outlined,
                      size: 22,
                      color: isSelected ? Colors.black : Colors.grey,
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (index == 6) ...[
                    Icon(
                      Icons.collections_bookmark_outlined,
                      size: 22,
                      color: isSelected ? Colors.black : Colors.grey,
                    ),
                    const SizedBox(height: 8),
                  ],

                  Text(
                    _categories[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected ? Colors.black : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildSortByContent();
      case 1:
        return _buildTimeContent();
      case 2:
        return _buildRatingContent();
      case 3:
        return _buildOffersContent();
      case 4:
        return _buildDishPriceContent();
      case 5:
        return _buildTrustMarkersContent();
      case 6:
        return _buildCollectionsContent();
      default:
        return const Center(child: Text('Select a category'));
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSortByContent() {
    final options = [
      'Relevance',
      'Rating',
      'Delivery Time',
      'Cost: Low to High',
      'Cost: High to Low',
    ];
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildSectionTitle('Sort by'),
        ...options.map(
          (option) => RadioListTile<String>(
            value: option,
            groupValue: _currentFilters.sortBy,
            onChanged: (val) {
              if (val != null) {
                _updateFilter(_currentFilters.copyWith(sortBy: val));
              }
            },
            title: Text(option),
            activeColor: Colors.deepOrange,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.trailing,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeContent() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildSectionTitle('Time'),
        LayoutBuilder(
          builder: (context, constraints) {
            double maxWidth = constraints.maxWidth;
            final double itemWidth = (maxWidth - 12) / 2;

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: itemWidth,
                  child: SelectableBoxOption(
                    icon: Icons.schedule,
                    text: 'Schedule',
                    isSelected: _currentFilters.isScheduled,
                    showCloseIcon: _currentFilters.isScheduled,
                    onClose: () {
                      _updateFilter(
                        _currentFilters.copyWith(isScheduled: false),
                      );
                    },
                    onTap: () {
                      if (!_currentFilters.isScheduled) {
                        _showScheduleBottomSheet();
                      }
                    },
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: SelectableBoxOption(
                    icon: Icons.flash_on,
                    text: 'Near & Fast',
                    isSelected: _currentFilters.nearAndFast,
                    onTap: () {
                      _updateFilter(
                        _currentFilters.copyWith(
                          nearAndFast: !_currentFilters.nearAndFast,
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildRatingContent() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildSectionTitle('Restaurant Rating'),
        LayoutBuilder(
          builder: (context, constraints) {
            double maxWidth = constraints.maxWidth;
            final double itemWidth = (maxWidth - 12) / 2;

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: itemWidth,
                  child: SelectableBoxOption(
                    icon: Icons.star,
                    text: 'Rated 3.5+',
                    isSelected: _currentFilters.minRating == 3.5,
                    onTap: () {
                      final newVal = _currentFilters.minRating == 3.5
                          ? null
                          : 3.5;
                      _updateFilter(
                        _currentFilters.copyWith(minRating: newVal),
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: SelectableBoxOption(
                    icon: Icons.star,
                    text: 'Rated 4.0+',
                    isSelected: _currentFilters.minRating == 4.0,
                    onTap: () {
                      final newVal = _currentFilters.minRating == 4.0
                          ? null
                          : 4.0;
                      _updateFilter(
                        _currentFilters.copyWith(minRating: newVal),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildOffersContent() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildSectionTitle('Offers'),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildSelectableChipOption('Buy 1 Get 1 and more'),
            _buildSelectableChipOption('Deals of the Day'),
            _buildSelectableChipOption(
              'Gold offers',
              icon: Icons.workspace_premium,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSelectableChipOption(String text, {IconData? icon}) {
    final isSelected = _currentFilters.activeOffers.contains(text);
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: Colors.amber),
            const SizedBox(width: 8),
          ],
          Text(text),
        ],
      ),
      selected: isSelected,
      onSelected: (bool selected) {
        final output = List<String>.from(_currentFilters.activeOffers);
        if (selected) {
          output.add(text);
        } else {
          output.remove(text);
        }
        _updateFilter(_currentFilters.copyWith(activeOffers: output));
      },
      selectedColor: Colors.deepOrange.shade50,
      checkmarkColor: Colors.deepOrange,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? Colors.deepOrange : Colors.grey.shade300,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  Widget _buildDishPriceContent() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildSectionTitle('Dish Price'),
        LayoutBuilder(
          builder: (context, constraints) {
            double maxWidth = constraints.maxWidth;
            // 3 columns: (maxWidth - 2 * spacing) / 3
            final double itemWidth = (maxWidth - 24) / 3;

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: itemWidth,
                  child: _buildPriceBox('Under\n₹200'),
                ),
                SizedBox(
                  width: itemWidth,
                  child: _buildPriceBox('₹200 -\n₹350'),
                ),
                SizedBox(
                  width: itemWidth,
                  child: _buildPriceBox('Above\n₹350'),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildPriceBox(String text) {
    final isSelected =
        _currentFilters.dishPriceRange ==
        text.replaceAll('\n', ' '); // Simple matching
    return SelectableBoxOption(
      icon: Icons.currency_rupee,
      text: text,
      isSelected: isSelected,
      onTap: () {
        final newVal = isSelected ? null : text.replaceAll('\n', ' ');
        _updateFilter(_currentFilters.copyWith(dishPriceRange: newVal));
      },
    );
  }

  Widget _buildTrustMarkersContent() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildSectionTitle('Trust Markers'),
        LayoutBuilder(
          builder: (context, constraints) {
            final double itemWidth =
                (constraints.maxWidth - 24) /
                2; // 2 items per row with 24 spacing/margin account
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: itemWidth,
                  child: SelectableBoxOption(
                    icon: Icons.eco,
                    text: 'Pure Veg',
                    color: Colors.green,
                    isSelected: _currentFilters.isPureVeg,
                    onTap: () {
                      _updateFilter(
                        _currentFilters.copyWith(
                          isPureVeg: !_currentFilters.isPureVeg,
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: _buildBoxOption(
                    Icons.money_off,
                    'No Packaging charges',
                    color: Colors.teal,
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: _buildBoxOption(
                    Icons.shopping_bag_outlined,
                    'Low plastic packaging',
                    color: Colors.green,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildCollectionsContent() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildSectionTitle('Collections'),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildCollectionChip('Previously ordered'),
            _buildCollectionChip('Gourmet'),
            _buildCollectionChip('New to you'),
          ],
        ),
      ],
    );
  }

  Widget _buildCollectionChip(String label) {
    final isSelected = _currentFilters.collections.contains(label);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        final output = List<String>.from(_currentFilters.collections);
        if (selected) {
          output.add(label);
        } else {
          output.remove(label);
        }
        _updateFilter(_currentFilters.copyWith(collections: output));
      },
      selectedColor: Colors.deepOrange.shade50,
      checkmarkColor: Colors.deepOrange,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? Colors.deepOrange : Colors.grey.shade300,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  Widget _buildBoxOption(
    IconData icon,
    String text, {
    Color color = Colors.black87,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 100),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Widget _buildChipOption(String text, {IconData? icon}) {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  //     decoration: BoxDecoration(
  //       border: Border.all(color: Colors.grey.shade300),
  //       borderRadius: BorderRadius.circular(20),
  //     ),
  //     child: Row(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         if (icon != null) ...[
  //           Icon(icon, size: 16, color: Colors.amber),
  //           const SizedBox(width: 8),
  //         ],
  //         Text(
  //           text,
  //           style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Close',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context, _currentFilters);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Show results',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showScheduleBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return const ScheduleBottomSheetContent();
      },
    ).then((selected) {
      if (selected == true) {
        _updateFilter(_currentFilters.copyWith(isScheduled: true));
      }
    });
  }
}
