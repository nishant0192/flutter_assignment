import 'package:flutter/material.dart';
import '../models/bookmark_manager.dart';
import '../utils/app_constants.dart';
import 'bookmarks_detail_screen.dart';

class CollectionsScreen extends StatefulWidget {
  const CollectionsScreen({super.key});

  @override
  State<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.scaffold(context),
      body: Column(
        children: [
          // Header Banner
          Container(
            width: double.infinity,
            height: 240,
            color: const Color(0xFF13151A),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Opacity(
                    opacity: 1,
                    child: Image.asset(
                      'assets/images/collections_banner.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Custom Back Button
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  left: 16,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // TabBar
          Container(
            width: double.infinity,
            color: AppColors.scaffold(context),
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.label,
              labelColor: isDark ? Colors.white : Colors.black,
              unselectedLabelColor: isDark ? Colors.white38 : Colors.grey.shade500,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              tabs: const [
                Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text('Delivery'))),
                Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text('Dining'))),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: isDark ? Colors.white10 : Colors.grey.shade200),

          // TabBarView
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCollectionsGrid(context),
                _buildCollectionsGrid(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionsGrid(BuildContext context) {
    return ListenableBuilder(
      listenable: bookmarkManager,
      builder: (context, _) {
        return GridView.count(
          padding: const EdgeInsets.all(20),
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: 0.82,
          children: [
            // Bookmarks Card
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BookmarksDetailScreen()),
                );
              },
              child: _buildBookmarkCard(context),
            ),
            
            // Create New Collection Card
            _buildCreateCard(context),
          ],
        );
      },
    );
  }

  Widget _buildBookmarkCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF5E62),
            Color(0xFFFF3333),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Minimal Polaroad Illustration
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Icon(Icons.fastfood_outlined, color: Colors.white, size: 48),
                  ),
                ),
                const Spacer(),
                const Text(
                  'Bookmarks',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${bookmarkManager.dishCount} dish • ${bookmarkManager.restaurantCount} restaurant',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),

          // Share Icon (Top Right)
          Positioned(
            top: 16,
            right: 16,
            child: Transform.rotate(
              angle: -0.4,
              child: Icon(Icons.send_outlined, color: Colors.white.withOpacity(0.8), size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200, width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
              border: Border.all(color: const Color(0xFF1F803A).withOpacity(0.5), width: 1.5),
            ),
            child: const Icon(Icons.add, color: Color(0xFF1F803A), size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            'Create a new\nCollection',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
