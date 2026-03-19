import 'package:flutter/material.dart';
import '../utils/app_constants.dart' ;
import 'package:dotted_border/dotted_border.dart';
import '../models/user_profile.dart'; // To get the savedAmount if needed

class GoldScreen extends StatelessWidget {
  const GoldScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141415), // Dark background
      body: Stack(
        children: [
          // Scrollable Content
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Spacer to prevent content from going under the pinned back button
                  const SizedBox(height: 56),

                  // Hero Section
                  const SizedBox(height: 24),
                  const Center(
                    child: Text(
                      'zomato',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'G',
                        style: TextStyle(
                          color: Color(0xFFD6A95B),
                          fontSize: 64,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          const Text(
                            'O',
                            style: TextStyle(
                              color: Color(0xFFD6A95B),
                              fontSize: 64,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const Icon(
                            Icons.workspace_premium,
                            color: Color(0xFF141415),
                            size: 32,
                          ),
                        ],
                      ),
                      const SizedBox(width: 2),
                      const Text(
                        'LD',
                        style: TextStyle(
                          color: Color(0xFFD6A95B),
                          fontSize: 64,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'MEMBER TILL 17TH APR 2026',
                      style: TextStyle(
                        color: Color(0xFFD6A95B),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Special benefit update banner
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFAE0BA), Color(0xFFF3C082)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.workspace_premium,
                            color: Color(0xFFD6A95B),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Special benefit update!',
                                style: TextStyle(
                                  color: Color(0xFF5E3500),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              RichText(
                                text: const TextSpan(
                                  style: TextStyle(
                                    fontSize: 13,
                                    height: 1.4,
                                    color: Colors.black,
                                  ),
                                  children: [
                                    TextSpan(
                                      text:
                                          'Now enjoy FREE delivery on orders above ',
                                    ),
                                    TextSpan(
                                      text: '₹199',
                                      style: TextStyle(
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' ₹99',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Savings Section
                  const _SectionTitle(title: 'SAVINGS TILL NOW'),
                  const SizedBox(height: 16),
                  ValueListenableBuilder<UserProfile>(
                    valueListenable: currentUserNotifier,
                    builder: (context, userProfile, child) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF232426),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF453B2E),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.electric_scooter,
                                color: Color(0xFFFAAF40),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'On delivery',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Used 10 times',
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '₹${userProfile.savedAmount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // Current Benefits Section
                  const _SectionTitle(title: 'CURRENT BENEFITS'),
                  const SizedBox(height: 16),

                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E20), // slightly lighter than bg
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _buildBenefitItem(
                          icon: Icons.electric_scooter,
                          iconColor: const Color(0xFFFAAF40),
                          iconBgColor: const Color(0xFF453B2E),
                          title: 'Free delivery',
                          description:
                              'Free delivery and high demand surge fee waiver on orders above ₹99, from restaurants within 7 km. May not be applicable at a few restaurants that manage their own delivery.',
                        ),
                        const SizedBox(height: 24),
                        _buildBenefitItem(
                          icon: Icons.local_offer,
                          iconColor: const Color(0xFFE2614B),
                          iconBgColor: const Color(0xFF4A2E2C),
                          title: 'Up to 30% extra off',
                          description:
                              'Above all existing offers at 20,000+ partner restaurants across India',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Coupon code
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DottedBorder(
                      options: const RoundedRectDottedBorderOptions(
                        color: Colors.white24,
                        strokeWidth: 1.5,
                        dashPattern: [6, 4],
                        radius: Radius.circular(24),
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: TextField(
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Have a coupon code?',
                                hintStyle: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Apply',
                            style: TextStyle(
                              color: Color(0xFFD6A95B),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Links List
                  _buildActionTile(
                    Icons.help_outline,
                    'Frequently asked questions',
                  ),
                  _buildActionTile(Icons.info_outline, 'Terms and Conditions'),
                  _buildActionTile(
                    Icons.chat_bubble_outline,
                    'Need help? Chat with us',
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          
          // Pinned Back Button Overlay
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 12, top: 4),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF232426),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: 16),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.star, color: Color(0xFFD6A95B), size: 16),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFFD6A95B),
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.star, color: Color(0xFFD6A95B), size: 16),
      ],
    );
  }
}
