import 'package:flutter/material.dart';
import '../utils/app_constants.dart';

class AppTabBar extends StatelessWidget {
  final TabController controller;
  final List<Widget> tabs;
  final Color indicatorColor;
  final Color labelColor;
  final Color unselectedLabelColor;

  const AppTabBar({
    super.key,
    required this.controller,
    required this.tabs,
    this.indicatorColor = AppColors.primary,
    this.labelColor = AppColors.primary,
    this.unselectedLabelColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.round),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: SizedBox(
          height: 56, // Reduced height to look wider
          child: TabBar(
            controller: controller,
            labelPadding: EdgeInsets.zero,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding: EdgeInsets.zero,
            indicator: BoxDecoration(
              color: Colors.green.shade800,
              borderRadius: BorderRadius.circular(AppRadius.round),
            ),
            dividerColor: Colors.transparent,
            labelColor: Colors.white,
            labelStyle: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: const TextStyle(fontSize: 10),
            unselectedLabelColor: unselectedLabelColor,
            tabs: tabs,
          ),
        ),
      ),
    );
  }
}
