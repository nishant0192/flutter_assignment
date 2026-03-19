import 'package:flutter/material.dart';
import '../utils/app_constants.dart';
import 'filter_bottom_sheet.dart';
import '../models/filter_options.dart';

class FilterBar extends StatelessWidget {
  final FilterOptions currentFilters;
  final ValueChanged<FilterOptions> onApplyFilters;

  const FilterBar({
    super.key,
    required this.currentFilters,
    required this.onApplyFilters,
  });

  @override
  Widget build(BuildContext context) {
    final filters = ['Near & Fast', 'Gourmet', 'Top Rated'];

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 0),
        children: [
          GestureDetector(
            onTap: () async {
              final result = await showModalBottomSheet<FilterOptions>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const FilterBottomSheet(),
              );

              if (result != null) {
                onApplyFilters(result);
              }
            },
            child: _buildFilterChip(
              context: context,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.tune, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Filters',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Icon(Icons.arrow_drop_down, size: 18),
                ],
              ),
            ),
          ),
          ...filters.map(
            (filter) => Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: _buildFilterChip(
                context: context,
                child: Text(
                  filter,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required BuildContext context,
    required Widget child,
  }) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}
