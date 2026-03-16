import 'package:flutter/material.dart';
import '../widgets/profile/action_buttons.dart';
import '../widgets/profile/profile_card.dart';
import '../widgets/profile/profile_list_item.dart';
import '../widgets/profile/profile_section.dart';
import 'audio_call_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB), // Very light greyish blue
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const ProfileCard(),
            const SizedBox(height: 16),
            const TwoActionButtons(),
            const SizedBox(height: 16),

            ProfileSectionContainer(
              title: 'Your preferences',
              children: [
                ProfileListItem(
                  icon: Icons.eco_outlined,
                  iconColor: Colors.green,
                  title: 'Veg Mode',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('On', style: TextStyle(color: Colors.black54)),
                      const SizedBox(width: 8),
                      Icon(Icons.chevron_right, color: Colors.grey.shade400),
                    ],
                  ),
                ),
                ProfileListItem(
                  icon: Icons.star_border,
                  title: 'Show personalised ratings',
                  trailing: Switch(
                    value: false,
                    onChanged: (val) {},
                    activeTrackColor:
                        Colors.deepOrange, // Updated to fix deprecation warning
                  ),
                ),
                ProfileListItem(
                  icon: Icons.palette_outlined,
                  title: 'Appearance',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Light',
                        style: TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.chevron_right, color: Colors.grey.shade400),
                    ],
                  ),
                ),
                const ProfileListItem(
                  icon: Icons.credit_card_outlined,
                  title: 'Payment methods',
                  showDivider: false,
                ),
              ],
            ),
            const SizedBox(height: 16),

            ProfileSectionContainer(
              title: 'Food delivery',
              children: [
                const ProfileListItem(
                  icon: Icons.receipt_long_outlined,
                  title: 'Your orders',
                ),
                const ProfileListItem(
                  icon: Icons.library_books_outlined, // Address book
                  title: 'Address book',
                ),
                const ProfileListItem(
                  icon: Icons.bookmark_border,
                  title: 'Your collections',
                ),
                const ProfileListItem(
                  icon: Icons.volunteer_activism_outlined,
                  title: 'Manage recommendations',
                ),
                const ProfileListItem(
                  icon: Icons.train_outlined,
                  title: 'Order on train',
                ),
                const ProfileListItem(
                  icon: Icons.chat_outlined,
                  title: 'Online ordering help',
                ),
                const ProfileListItem(
                  icon: Icons.visibility_off_outlined,
                  title: 'Hidden Restaurants',
                ),
                const ProfileListItem(
                  icon: Icons.storefront_outlined,
                  title: 'Hear from restaurants',
                  showDivider: false,
                ),
              ],
            ),
            const SizedBox(height: 16),

            ProfileSectionContainer(
              title: 'Dining & experiences',
              children: [
                const ProfileListItem(
                  icon: Icons.history, // history or receipt for transactions
                  title: 'Your dining transactions',
                ),
                const ProfileListItem(
                  icon: Icons.card_giftcard,
                  title: 'Your dining rewards',
                ),
                const ProfileListItem(
                  icon: Icons.table_restaurant_outlined,
                  title: 'Your bookings',
                ),
                const ProfileListItem(
                  icon: Icons.bookmark_border,
                  title: 'Your collections',
                ),
                const ProfileListItem(
                  icon: Icons.chat_bubble_outline,
                  title: 'Dining help',
                ),
                const ProfileListItem(
                  icon: Icons.redeem,
                  title: 'Claim invite code',
                  showDivider: true,
                ),
                ProfileListItem(
                  icon: Icons.call_outlined,
                  title: 'Start Audio Call',
                  showDivider: false,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AudioCallScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
