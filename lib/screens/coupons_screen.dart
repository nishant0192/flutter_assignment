import 'package:flutter/material.dart';

class CouponsScreen extends StatefulWidget {
  const CouponsScreen({super.key});

  @override
  State<CouponsScreen> createState() => _CouponsScreenState();
}

class _CouponsScreenState extends State<CouponsScreen> {
  final TextEditingController _couponController = TextEditingController();
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String? _selectedCouponCode;

  @override
  void initState() {
    super.initState();
  }

  void _applyCoupon() {
    if (_couponController.text.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Coupon "${_couponController.text}" applied successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF18171C) : Colors.grey.shade50;
    final cardColor = isDark ? const Color(0xFF202126) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        surfaceTintColor: bgColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Coupons',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Coupon Input Field
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              color: bgColor,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? cardColor : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _couponController,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Have a coupon code? Type here',
                          hintStyle: TextStyle(
                            color: isDark ? Colors.white30 : Colors.grey,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _applyCoupon,
                      child: Text(
                        'APPLY',
                        style: TextStyle(
                          color: _couponController.text.isNotEmpty 
                              ? (isDark ? Colors.white : const Color(0xFFE23744)) 
                              : (isDark ? Colors.white24 : Colors.grey.shade400),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Promotion Banners (Horizontal PageView)
            SizedBox(
              height: 151, // fixed height to avoid overflow
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildPromoBanner(
                      color: const Color(0xFFFFB74D),
                      title: '3% cashback on all orders',
                      subtitle: 'with Amazon Pay Balance',
                      brand: 'amazon pay',
                      brandColor: const Color(0xFFFEBD69),
                      image: 'amazon',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildPromoBanner(
                      color: const Color(0xFF1C64D4),
                      title: 'Flat ₹100 OFF',
                      subtitle: 'using Yes Bank Cards',
                      brand: 'YES BANK',
                      brandColor: const Color(0xFF1C64D4),
                      image: 'yes',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildPromoBanner(
                      color: const Color(0xFFE23744),
                      title: '₹125 OFF',
                      subtitle: 'on orders above ₹599',
                      brand: 'ZOMPAYS',
                      brandColor: const Color(0xFFE23744),
                      image: 'zomato',
                    ),
                  ),
                ],
              ),
            ),

            // Carousel Dots
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDot(_currentPage == 0),
                _buildDot(_currentPage == 1),
                _buildDot(_currentPage == 2),
              ],
            ),
            const SizedBox(height: 16),

            // Restaurant Coupons Section (Wrapped in Card)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildSectionTitle('Restaurant coupons'),
                    const SizedBox(height: 16),
                    _buildCouponCard(
                      title: 'Flat ₹75 OFF',
                      subtitle: 'Add eligible items worth ₹521.00 more to unlock',
                      code: 'GET75',
                      isUnlocked: false,
                      icon: Icons.percent,
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Payment Coupons Section (Wrapped in Card)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildSectionTitle('Payment coupons'),
                    const SizedBox(height: 16),
                    _buildCouponCard(
                      title: 'Flat ₹30 OFF using Bajaj pay UPI',
                      subtitle: 'Save ₹30.00 with this code',
                      code: 'BAJAJUPI30',
                      logo: 'B',
                      logoBg: const Color(0xFF0055BC),
                      isPayment: true,
                    ),
                    const SizedBox(height: 12),
                    _buildCouponCard(
                      title: '10% OFF up to ₹150 using Standard Chartered DigiSmart Credit Card',
                      subtitle: 'Save ₹12.40 with this code',
                      code: 'DIGISMART',
                      logo: 'SC',
                      logoBg: const Color(0xFF00913F),
                      isPayment: true,
                    ),
                    const SizedBox(height: 12),
                    _buildCouponCard(
                      title: 'Flat 3% cashback using Amazon Pay Balance',
                      subtitle: 'Get ₹3.72 cashback with this code',
                      code: 'AMZNPAY3',
                      logo: 'pay',
                      logoBg: const Color(0xFFFEBD69),
                      isPayment: true,
                    ),
                    const SizedBox(height: 12),
                    _buildCouponCard(
                      title: 'Flat ₹100 OFF using Yes Bank First, Grandeur & Glory Debit Card',
                      subtitle: 'Applicable on transactions above ₹599.00',
                      code: 'YES100',
                      logo: 'YES',
                      logoBg: const Color(0xFFEC1C24),
                    ),
                    const SizedBox(height: 12),
                    _buildCouponCard(
                      title: 'Flat ₹200 OFF using Deutsche Bank Infinite Debit Cards',
                      subtitle: 'Applicable on transactions above ₹799.00',
                      code: 'DBTREAT',
                      logo: 'DB',
                      logoBg: const Color(0xFF1C1C1E),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPromoBanner({
    required Color color,
    required String title,
    required String subtitle,
    required String brand,
    required Color brandColor,
    required String image,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF202126) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
        boxShadow: isDark ? null : [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background design
          Positioned(
            right: -20,
            top: -10,
            bottom: -10,
            child: Container(
              width: 140,
              decoration: BoxDecoration(
                color: color.withOpacity(0.8),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          if (brand == 'amazon pay')
                            const Icon(Icons.payment, size: 12, color: Colors.white70)
                          else
                            const SizedBox.shrink(),
                          const SizedBox(width: 4),
                          Text(
                            brand,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        title,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Know more >',
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFFE23744),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 55,
                          height: 90,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(4, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: 6),
                              Container(
                                width: 20,
                                height: 1.5,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                              const Spacer(),
                              Container(
                                width: 42,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF202126),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.bolt, color: Colors.orange, size: 14),
                                      Text(
                                        brand == 'amazon pay' ? 'pay' : 'YES',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Container(
                                width: 30,
                                height: 2,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                              const SizedBox(height: 6),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildDot(bool isActive) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      width: isActive ? 16 : 8,
      height: 4,
      decoration: BoxDecoration(
        color: isActive 
            ? (isDark ? Colors.white : const Color(0xFFE23744)) 
            : (isDark ? Colors.white24 : Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildCouponCard({
    required String title,
    required String subtitle,
    required String code,
    IconData? icon,
    String? logo,
    Color? logoBg,
    bool isUnlocked = true,
    bool isPayment = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _selectedCouponCode == code;

    return GestureDetector(
      onTap: () {
        if (isUnlocked) {
          setState(() {
            _selectedCouponCode = code;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Coupon "$code" selected!'),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo / Icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: logoBg ?? (isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: logo != null 
                  ? Text(
                      logo, 
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)
                    )
                  : Icon(icon, color: isDark ? Colors.white60 : Colors.grey, size: 18),
              ),
            ),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: title,
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              WidgetSpan(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 6),
                                  child: Icon(
                                    Icons.info_outline, 
                                    size: 14, 
                                    color: isDark ? Colors.white24 : Colors.grey
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected 
                              ? const Color(0xFFE23744) 
                              : (isDark ? Colors.white24 : Colors.grey.shade300), 
                            width: 2,
                          ),
                          color: isSelected ? const Color(0xFFE23744) : Colors.transparent,
                        ),
                        child: isSelected 
                          ? const Center(child: Icon(Icons.check, color: Colors.white, size: 12)) 
                          : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isPayment ? const Color(0xFF5A9CF8) : (isUnlocked ? Colors.grey : Colors.orange.shade700),
                      fontSize: 12,
                      fontWeight: isPayment ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF262626) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade300),
                    ),
                    child: Text(
                      code,
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.grey.shade700,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: Colors.white10),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _couponController.dispose();
    _pageController.dispose();
    super.dispose();
  }
}
