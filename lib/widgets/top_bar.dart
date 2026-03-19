import 'package:flutter/material.dart';
import '../screens/profile_screen.dart' as profile_screen;
import '../screens/address_screen.dart';
import '../models/user_profile.dart';
import '../models/address_model.dart';

class TopBar extends StatelessWidget {
  final bool isDarkBackground;

  const TopBar({super.key, this.isDarkBackground = false});

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkBackground ? Colors.white : Colors.black87;
    final subtitleColor = isDarkBackground ? Colors.white70 : Colors.grey;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddressScreen(),
                  ),
                );
              },
              child: Row(
                children: [
                  Icon(Icons.location_on, color: textColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ValueListenableBuilder<AddressModel>(
                      valueListenable: currentAddressNotifier,
                      builder: (context, currentAddress, _) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    currentAddress.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: textColor,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 20,
                                  color: textColor,
                                ),
                              ],
                            ),
                            Text(
                              currentAddress.subtitle,
                              style: TextStyle(
                                fontSize: 12,
                                color: subtitleColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/district_logo.jpeg',
                  height: 38,
                  width: 70,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              _buildIconContainer(
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 20,
                  color: isDarkBackground ? Colors.white : Colors.black87,
                ),
                color: isDarkBackground
                    ? Colors.white.withOpacity(0.12)
                    : Colors.white,
                borderColor: isDarkBackground
                    ? Colors.white.withOpacity(0.15)
                    : Colors.grey.shade400,
                width: 38,
                height: 38,
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const profile_screen.ProfileScreen(),
                    ),
                  );
                },
                child: _buildIconContainer(
                  child: ValueListenableBuilder<UserProfile>(
                    valueListenable: currentUserNotifier,
                    builder: (context, userProfile, child) {
                      final initial = userProfile.name.isNotEmpty
                          ? userProfile.name[0].toUpperCase()
                          : '?';
                      return Text(
                        initial,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDarkBackground
                              ? Colors.orange.shade300
                              : Colors.orange.shade900,
                        ),
                      );
                    },
                  ),
                  color: isDarkBackground
                      ? Colors.orange.withOpacity(0.15)
                      : Colors.orange.shade100,
                  borderColor: isDarkBackground
                      ? Colors.orange.withOpacity(0.3)
                      : Colors.orange,
                  width: 38,
                  height: 38,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconContainer({
    required Widget child,
    Color color = Colors.transparent,
    double? width,
    double? height,
    Color? borderColor,
  }) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: borderColor != null
            ? Border.all(color: borderColor, width: 1.5)
            : null,
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}
