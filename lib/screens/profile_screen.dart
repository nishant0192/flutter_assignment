import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_constants.dart';
import '../widgets/profile/action_buttons.dart';
import '../widgets/profile/profile_card.dart';
import '../widgets/profile/profile_list_item.dart';
import '../widgets/profile/profile_section.dart';
import 'audio_call_screen.dart';
import '../utils/theme_manager.dart';
import '../widgets/primary_button.dart';
import 'payment_screen.dart';
import 'orders_screen.dart';
import 'collections_screen.dart';
import 'add_edit_address_screen.dart';
import '../models/address_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _showPersonalizedRatings = false;
  bool _isVegModeAllDays = true;
  List<int> _selectedVegDays = [0, 1, 2, 3, 4, 5, 6]; // Store indices

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showPersonalizedRatings = prefs.getBool('showPersonalizedRatings') ?? false;
      _isVegModeAllDays = prefs.getBool('isVegModeAllDays') ?? true;
      final savedIndices = prefs.getStringList('selectedVegDays');
      if (savedIndices != null) {
        try {
          _selectedVegDays = savedIndices.map((e) => int.tryParse(e) ?? -1).where((e) => e != -1).toList();
        } catch (e) {
          _selectedVegDays = [0, 1, 2, 3, 4, 5, 6]; // Fallback
        }
      }
    });
  }

  Future<void> _savePreference(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is List<int>) {
      await prefs.setStringList(key, value.map((i) => i.toString()).toList());
    }
  }

  void _showAppearanceBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final currentMode = themeManager.themeMode;
        ThemeMode selectedMode = currentMode;
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {

            return Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 50),
                  decoration: BoxDecoration(
                    color: AppColors.card(context),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Appearance',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, thickness: 1),

                      // Options
                      _buildThemeOption('Light theme', ThemeMode.light, selectedMode, (val) {
                        setModalState(() => selectedMode = val!);
                      }),
                      _buildThemeOption('Dark theme', ThemeMode.dark, selectedMode, (val) {
                        setModalState(() => selectedMode = val!);
                      }),
                      _buildThemeOption('Use device theme', ThemeMode.system, selectedMode, (val) {
                        setModalState(() => selectedMode = val!);
                      }),

                      // Save Button
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: PrimaryButton(
                          label: 'Save preference',
                          onPressed: selectedMode != currentMode
                              ? () {
                                  themeManager.setThemeMode(selectedMode);
                                  Navigator.pop(context);
                                }
                              : null,
                          backgroundColor: selectedMode != currentMode 
                              ? AppColors.primary 
                              : Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white12 : Colors.black87,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildThemeOption(String title, ThemeMode mode, ThemeMode groupValue, ValueChanged<ThemeMode?> onChanged) {
    final isSelected = mode == groupValue;
    return InkWell(
      onTap: () => onChanged(mode),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.primary : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  String _getThemeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  void _showAddressBookBottomSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            color: AppColors.scaffold(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.expand_more,
                        color: isDark ? Colors.white : Colors.black,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'My Addresses',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // Add Address Card
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddEditAddressScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.card(context),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.add, color: Color(0xFF1F803A), size: 24),
                            const SizedBox(width: 16),
                            const Text(
                              'Add Address',
                              style: TextStyle(
                                color: Color(0xFF1F803A),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Icon(Icons.chevron_right, color: isDark ? Colors.white24 : Colors.grey),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    Text(
                      'SAVED ADDRESSES',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white38 : Colors.grey,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),

                    ValueListenableBuilder<List<AddressModel>>(
                      valueListenable: savedAddressesNotifier,
                      builder: (context, addresses, _) {
                        return Column(
                          children: addresses.map((addr) => _buildAddressItem(context, addr)).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddressItem(BuildContext context, AddressModel address) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isHome = address.type.toLowerCase() == 'home';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Icon(
                    isHome ? Icons.home_outlined : Icons.location_on_outlined,
                    color: isDark ? Colors.white70 : Colors.black87,
                    size: 28,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address.id == '1' ? '0 m' : '16.2 km', // Mock distance based on ID
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? Colors.white38 : Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address.subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white60 : Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),
                    if (address.phone != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Phone number: +91-${address.phone}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white38 : Colors.grey,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildSmallActionIcon(Icons.more_horiz),
                        const SizedBox(width: 12),
                        _buildSmallActionIcon(Icons.share_outlined, isGreen: true),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: isDark ? Colors.white24 : Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallActionIcon(IconData icon, {bool isGreen = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
      ),
      child: Icon(
        icon,
        size: 16,
        color: isGreen ? const Color(0xFF1F803A) : (isDark ? Colors.white70 : Colors.black54),
      ),
    );
  }

  void _showVegModeBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        String vegDishesFrom = 'All restaurants';
        String vegModeDays = _isVegModeAllDays ? 'All days' : 'Select days of the week';
        List<int> localSelectedDays = List<int>.from(_selectedVegDays);

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final isAllDays = vegModeDays == 'All days';
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 60),
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
                  decoration: BoxDecoration(
                    color: AppColors.card(context),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Fit content
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                        child: Text(
                          'Veg Mode',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // See veg dishes from
                            _buildVegSection(
                              context,
                              'See veg dishes from',
                              [
                                _buildVegOption('All restaurants', vegDishesFrom, (val) => setModalState(() => vegDishesFrom = val)),
                                _buildVegOption('Pure Veg restaurants only', vegDishesFrom, (val) => setModalState(() => vegDishesFrom = val)),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Select Veg Mode days
                            _buildVegSection(
                              context,
                              'Select Veg Mode days',
                              [
                                _buildVegOption('All days', vegModeDays, (val) => setModalState(() => vegModeDays = val)),
                                _buildVegOption('Select days of the week', vegModeDays, (val) => setModalState(() => vegModeDays = val)),
                                const SizedBox(height: 12),
                                Opacity(
                                  opacity: isAllDays ? 0.4 : 1.0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: List.generate(7, (index) {
                                      final dayLetters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                                      final isSelected = !isAllDays && localSelectedDays.contains(index);
                                      return _buildDayCircle(
                                        dayLetters[index],
                                        isSelected: isSelected,
                                        onTap: isAllDays ? null : () {
                                          setModalState(() {
                                            if (isSelected) {
                                              localSelectedDays.remove(index);
                                            } else {
                                              localSelectedDays.add(index);
                                            }
                                          });
                                        },
                                      );
                                    }),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),

                      // Footer
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.card(context),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              offset: const Offset(0, -2),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            PrimaryButton(
                              label: 'Save changes',
                              onPressed: () {
                                setState(() {
                                  _selectedVegDays = List.from(localSelectedDays);
                                  _isVegModeAllDays = vegModeDays == 'All days';
                                });
                                _savePreference('selectedVegDays', localSelectedDays);
                                _savePreference('isVegModeAllDays', vegModeDays == 'All days');
                                Navigator.pop(context);
                              },
                              backgroundColor: const Color(0xFF008037),
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'Switch off Veg Mode',
                                style: TextStyle(
                                  color: Color(0xFF008037),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF202126) : Colors.black87,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildVegSection(BuildContext context, String title, List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: isDark ? Colors.white10 : Colors.grey.shade200),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildVegOption(String title, String groupValue, ValueChanged<String> onChanged) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = title == groupValue;
    return InkWell(
      onTap: () => onChanged(title),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF008037) : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFF008037),
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayCircle(String day, {bool isSelected = false, VoidCallback? onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF008037) : (isDark ? const Color(0xFF262626) : Colors.grey.shade100),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            day,
            style: TextStyle(
              color: isSelected ? Colors.white : (isDark ? Colors.white24 : Colors.grey.shade400),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: Theme.of(context).iconTheme,
      ),
      body: CustomScrollView(
        slivers: [
          // Sticky Profile Card Header
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyProfileCardDelegate(
              minHeight: 180,
              maxHeight: 180,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: ProfileCard(),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
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
                        onTap: () => _showVegModeBottomSheet(context),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'On',
                              style: TextStyle(
                                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6) ?? Colors.black54),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.chevron_right, color: Colors.grey.shade400),
                          ],
                        ),
                      ),
                      ProfileListItem(
                        icon: Icons.star_border,
                        title: 'Show personalised ratings',
                        trailing: Switch(
                          value: _showPersonalizedRatings,
                          onChanged: (val) {
                            setState(() => _showPersonalizedRatings = val);
                            _savePreference('showPersonalizedRatings', val);
                          },
                          activeTrackColor: Colors.deepOrange,
                        ),
                      ),
                      ListenableBuilder(
                        listenable: themeManager,
                        builder: (context, _) {
                          return ProfileListItem(
                            icon: Icons.palette_outlined,
                            title: 'Appearance',
                            onTap: () => _showAppearanceBottomSheet(context),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _getThemeText(themeManager.themeMode),
                                  style: TextStyle(
                                      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6) ?? Colors.black54),
                                ),
                                const SizedBox(width: 8),
                                Icon(Icons.chevron_right, color: Colors.grey.shade400),
                              ],
                            ),
                          );
                        },
                      ),
                      ProfileListItem(
                        icon: Icons.credit_card_outlined,
                        title: 'Payment methods',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PaymentScreen(totalBill: 0)),
                          );
                        },
                        showDivider: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ProfileSectionContainer(
                    title: 'Food delivery',
                    children: [
                      ProfileListItem(
                        icon: Icons.receipt_long_outlined,
                        title: 'Your orders',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const OrdersScreen()),
                          );
                        },
                      ),
                      ProfileListItem(
                        icon: Icons.library_books_outlined,
                        title: 'Address book',
                        onTap: () => _showAddressBookBottomSheet(context),
                      ),
                      ProfileListItem(
                        icon: Icons.bookmark_border,
                        title: 'Your collections',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CollectionsScreen()),
                          );
                        },
                      ),
                      ProfileListItem(icon: Icons.volunteer_activism_outlined, title: 'Manage recommendations'),
                      ProfileListItem(icon: Icons.train_outlined, title: 'Order on train'),
                      ProfileListItem(icon: Icons.chat_outlined, title: 'Online ordering help'),
                      ProfileListItem(icon: Icons.visibility_off_outlined, title: 'Hidden Restaurants'),
                      ProfileListItem(icon: Icons.storefront_outlined, title: 'Hear from restaurants', showDivider: false),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ProfileSectionContainer(
                    title: 'Dining & experiences',
                    children: [
                      const ProfileListItem(icon: Icons.history, title: 'Your dining transactions'),
                      const ProfileListItem(icon: Icons.card_giftcard, title: 'Your dining rewards'),
                      const ProfileListItem(icon: Icons.table_restaurant_outlined, title: 'Your bookings'),
                      const ProfileListItem(icon: Icons.bookmark_border, title: 'Your collections'),
                      const ProfileListItem(icon: Icons.chat_bubble_outline, title: 'Dining help'),
                      const ProfileListItem(icon: Icons.redeem, title: 'Claim invite code', showDivider: true),
                      ProfileListItem(
                        icon: Icons.call_outlined,
                        title: 'Start Audio Call',
                        showDivider: false,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AudioCallScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StickyProfileCardDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _StickyProfileCardDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      alignment: Alignment.center,
      child: child,
    );
  }

  @override
  bool shouldRebuild(_StickyProfileCardDelegate oldDelegate) {
    return true; // Always rebuild so theme changes reflect immediately
  }
}
