import 'package:flutter/material.dart';
import '../utils/app_constants.dart' ;
import '../models/address_model.dart';
import '../models/user_profile.dart';
import '../models/cart_manager.dart';

class ScallopedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, 0); // Start at top-left

    double waveHeight = 3.0;
    double waveWidth = 8.0;
    int count = (size.width / waveWidth).ceil();

    for (int i = 0; i <= count; i++) {
      path.relativeQuadraticBezierTo(
        waveWidth / 4, 
        waveHeight, 
        waveWidth / 2, 
        0
      );
      path.relativeQuadraticBezierTo(
        waveWidth / 4, 
        -waveHeight, 
        waveWidth / 2, 
        0
      );
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class CheckoutGoldHeader extends StatelessWidget {
  const CheckoutGoldHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        gradient: LinearGradient(
          colors: isDark 
            ? [const Color(0xFF1E1E2C), AppColors.card(context)]
            : [Colors.blue.shade50.withOpacity(0.5), Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          const Text('🎉', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? const Color(0xFF64B5F6) : const Color(0xFF1C64D4),
              ),
              children: const [
                TextSpan(text: 'You saved ₹45 with '),
                TextSpan(
                  text: 'Gold',
                  style: TextStyle(color: Color(0xFFD6A95B)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CheckoutSpecialOffer extends StatelessWidget {
  const CheckoutSpecialOffer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.pink.withOpacity(0.2) : Colors.pink.shade50),
        gradient: RadialGradient(
          colors: isDark 
            ? [const Color(0xFF2D1B1B), AppColors.card(context)]
            : [Colors.orange.shade50.withOpacity(0.3), Colors.white],
          radius: 2,
          center: Alignment.topRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Special offer for you',
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 14,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const Text('🎁', style: TextStyle(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF3B1D6D),
                ),
                child: const Center(
                  child: Text(
                    'OTTplay',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Get 30+ OTTs at ₹149!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Claim voucher after order is placed',
                      style: TextStyle(
                        color: isDark ? const Color(0xFF64B5F6) : const Color(0xFF1C64D4), 
                        fontSize: 12
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.green),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: const [
                        Text(
                          'ADDED',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                        SizedBox(width: 2),
                        Icon(Icons.close, color: Colors.green, size: 12),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'FREE',
                    style: TextStyle(
                      color: isDark ? const Color(0xFF64B5F6) : const Color(0xFF1C64D4),
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CheckoutCancellationPolicy extends StatelessWidget {
  const CheckoutCancellationPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CANCELLATION POLICY',
            style: TextStyle(
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              fontSize: 12,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Help us reduce food waste by avoiding cancellations after placing your order. A 100% cancellation fee will be applied.',
            style: TextStyle(
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class CheckoutDeliveryDetails extends StatelessWidget {
  final double totalBill;
  final VoidCallback? onTotalBillTap;
  final VoidCallback? onAddressTap;
  final VoidCallback? onContactTap;
  
  const CheckoutDeliveryDetails({
    super.key, 
    required this.totalBill,
    this.onTotalBillTap,
    this.onAddressTap,
    this.onContactTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ValueListenableBuilder<AddressModel>(
      valueListenable: currentAddressNotifier,
      builder: (context, currentAddress, _) {
        return ValueListenableBuilder<UserProfile>(
          valueListenable: currentUserNotifier,
          builder: (context, currentUser, _) {
            return Container(
              color: AppColors.card(context),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: onAddressTap,
                    child: _buildDetailRow(
                      context,
                      icon: Icons.location_on_outlined,
                      title: 'Delivery at ',
                      titleSuffix: TextSpan(
                        text: currentAddress.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      subtitle: currentAddress.subtitle,
                      showArrow: true,
                      bottomChild: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Add instructions for delivery partner',
                          style: TextStyle(
                            color: isDark ? Colors.white54 : Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Divider(height: 32, color: isDark ? Colors.white10 : Colors.grey.shade200),
                  GestureDetector(
                    onTap: onContactTap,
                    child: _buildDetailRow(
                      context,
                      icon: Icons.call_outlined,
                      title: '${currentUser.name}, ${currentUser.mobile.isNotEmpty ? currentUser.mobile : '+91-9137173246'}',
                      showArrow: true,
                    ),
                  ),
                  Divider(height: 32, color: isDark ? Colors.white10 : Colors.grey.shade200),
                  GestureDetector(
                    onTap: onTotalBillTap ?? () {
                      _showBillBreakdown(context, totalBill);
                    },
                    child: _buildDetailRow(
                      context,
                      icon: Icons.receipt_long_outlined,
                      title: 'Total Bill ',
                      titleSuffix: TextSpan(
                        children: [
                          TextSpan(
                            text: '₹${(totalBill + cartManager.discountAmount).toStringAsFixed(0)} ',
                            style: const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                              fontWeight: FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                          TextSpan(
                            text: '₹${totalBill.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                      titleTrailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1C64D4).withOpacity(0.2) : const Color(0xFFE8F1FF),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'You saved ₹${cartManager.discountAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Color(0xFF1C64D4),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      subtitle: 'Incl. taxes and charges',
                      showArrow: true,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showBillBreakdown(BuildContext context, double totalBill) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    double subTotal = cartManager.subTotal;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 12,
            right: 12,
          ),
          child: Stack(
            alignment: Alignment.topCenter,
            clipBehavior: Clip.none,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 80), // Increased for consistency
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                  borderRadius: BorderRadius.circular(28), // Rounded at bottom too
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                       const SizedBox(height: 24),
                       Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'Bill Summary',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            _buildBillRow(context, 'Item total', subTotal),
                            const SizedBox(height: 16),
                            _buildBillRow(
                              context, 
                              'Restaurant packaging charges', 
                              cartManager.packagingCharge,
                              subtitle: 'This is decided & charged by the restaurant',
                            ),
                            const SizedBox(height: 16),
                            _buildBillRow(
                              context, 
                              'Delivery partner fee', 
                              cartManager.currentDeliveryCharge,
                              oldAmount: cartManager.originalDeliveryCharge,
                              amountColor: const Color(0xFF1C64D4),
                              subtitle: 'Free with Gold on item total above ₹99',
                            ),
                            const SizedBox(height: 16),
                            _buildBillRow(context, 'Platform fee', cartManager.platformFee),
                            const SizedBox(height: 16),
                            _buildBillRow(context, 'GST (govt. taxes)', cartManager.gst),
                            const SizedBox(height: 32),
                            const Divider(height: 1, thickness: 0.5),
                            const SizedBox(height: 24),
                            _buildBillRow(
                              context, 
                              'Grand Total', 
                              totalBill + 0.07, // Add back roundoff for display
                              isBold: true,
                              fontSize: 16,
                            ),
                            const SizedBox(height: 12),
                            _buildBillRow(
                              context, 
                              'Cash round off', 
                              -0.07,
                              fontSize: 14,
                            ),
                            const SizedBox(height: 12),
                            _buildBillRow(
                              context, 
                              'To pay', 
                              totalBill.roundToDouble(),
                              isBold: true,
                              fontSize: 20,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Wavy Savings Footer
                      ClipPath(
                        clipper: ScallopedClipper(),
                        child: Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Color(0xFF1C64D4),
                          ),
                          padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('🥳', style: TextStyle(fontSize: 18)),
                              const SizedBox(width: 8),
                              Text(
                                'You saved ₹${cartManager.discountAmount.toStringAsFixed(0)} on this order',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Close Button (Fixed above the modal)
              Positioned(
                top: 5,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Color(0xFF333333),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 28),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBillRow(
    BuildContext context, 
    String title, 
    double amount, {
    bool isDiscount = false,
    String? subtitle,
    double? oldAmount,
    Color? amountColor,
    bool isBold = false,
    double fontSize = 14,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: fontSize,
                  color: isDiscount 
                      ? (isDark ? Colors.green.shade400 : Colors.green.shade800) 
                      : (isDark ? Colors.white : Colors.grey.shade900),
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            Row(
              children: [
                if (oldAmount != null) ...[
                  Text(
                    '₹${oldAmount.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: fontSize - 1,
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  isDiscount
                      ? '-₹${amount.abs().toStringAsFixed(0)}'
                      : '₹${amount.toStringAsFixed(amount == amount.toInt() ? 0 : 2)}',
                  style: TextStyle(
                    fontSize: fontSize,
                    color: amountColor ?? (isDiscount 
                        ? (isDark ? Colors.green.shade400 : Colors.green.shade800) 
                        : (isDark ? Colors.white : Colors.grey.shade900)),
                    fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white38 : Colors.grey.shade500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    TextSpan? titleSuffix,
    String? subtitle,
    bool showArrow = false,
    Widget? titleTrailing,
    Widget? bottomChild,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 18, color: isDark ? Colors.white54 : Colors.grey.shade500),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  RichText(
                    text: TextSpan(
                      text: title,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.grey.shade800,
                        fontFamily: 'Inter',
                      ),
                      children: titleSuffix != null ? [titleSuffix] : [],
                    ),
                  ),
                  if (titleTrailing != null) ...[
                    const SizedBox(width: 8),
                    titleTrailing,
                  ],
                ],
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: isDark ? Colors.white38 : Colors.grey.shade500,
                    fontSize: 12,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (bottomChild != null) ...[
                bottomChild,
              ],
            ],
          ),
        ),
        if (showArrow)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(Icons.chevron_right, size: 18, color: isDark ? Colors.white24 : Colors.grey.shade400),
          ),
      ],
    );
  }
}
