import 'package:flutter/material.dart';
import '../models/app_data.dart';
import '../models/address_model.dart';
import '../models/user_profile.dart';
import '../models/cart_manager.dart';
import '../models/order.dart';
import '../models/order_manager.dart';
import '../utils/app_constants.dart';
import '../widgets/checkout_widgets.dart';
import 'success_screen.dart';
import 'payment_screen.dart';
import 'add_edit_address_screen.dart';
import 'coupons_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final Restaurant restaurant;

  const CheckoutScreen({super.key, required this.restaurant});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _selectedPaymentMethod = 'Pay on delivery';
  String _selectedFleet = 'Standard';

  void _updateQuantity(Dish dish, int delta) {
    setState(() {
      cartManager.updateQuantity(dish, delta, widget.restaurant);
      if (cartManager.items.isEmpty) {
        // If cart is empty, go back to previous screen
        Navigator.pop(context);
      }
    });
  }

  Future<void> _openPaymentSelection() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(totalBill: cartManager.totalBill),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedPaymentMethod = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    double totalBill = cartManager.totalBill;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context);
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.card(context),
          elevation: 0,
          surfaceTintColor: AppColors.card(context),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              size: 20,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.restaurant.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              ValueListenableBuilder<AddressModel>(
                valueListenable: currentAddressNotifier,
                builder: (context, currentAddress, _) {
                  return Row(
                    children: [
                      Flexible(
                        child: Text(
                          '${widget.restaurant.time}s to ${currentAddress.type} | ${currentAddress.subtitle}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        size: 14,
                        color: Colors.grey,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.share_outlined,
                color: isDark ? Colors.white : Colors.black,
                size: 22,
              ),
              onPressed: () {},
            ),
          ],
        ),
        body: Stack(
          children: [
            Positioned.fill(
              bottom: 80, // Leave space for sticky bottom bar
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CheckoutGoldHeader(),
                    const CheckoutSpecialOffer(),
                    const SizedBox(height: 12),
                    _buildOrderItems(),
                    const SizedBox(height: 12),
                     CheckoutDeliveryDetails(
                      totalBill: totalBill,
                      onAddressTap: () {
                        _showAddressSelectionSheet();
                      },
                      onContactTap: () {
                        _showContactUpdateSheet();
                      },
                    ),
                    const CheckoutCancellationPolicy(),
                    const SizedBox(height: 160), // Extra space to scroll past bottom bar
                  ],
                ),
              ),
            ),
            _buildBottomBar(totalBill),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItems() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: AppColors.card(context),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...cartManager.items.entries.map((entry) {
            final dish = entry.key;
            final quantity = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: dish.isVeg
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: dish.isVeg
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dish.name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Row(
                          children: [
                            Text(
                              'Edit',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Icon(
                              Icons.arrow_right,
                              size: 14,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        height: 36,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.green.withOpacity(0.1) : const Color(0xFFE8F4E9),
                          border: Border.all(color: Colors.green),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            InkWell(
                              onTap: () => _updateQuantity(dish, -1),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Icon(
                                  Icons.remove,
                                  color: Color(0xFF1F803A),
                                  size: 18,
                                ),
                              ),
                            ),
                            Text(
                              '$quantity',
                              style: const TextStyle(
                                color: Color(0xFF1F803A),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            InkWell(
                              onTap: () => _updateQuantity(dish, 1),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Icon(
                                  Icons.add,
                                  color: Color(0xFF1F803A),
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₹${dish.price * quantity}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
          InkWell(
            onTap: () => Navigator.pop(context),
            child: const Row(
              children: [
                Icon(Icons.add, color: Color(0xFF1F803A), size: 18),
                SizedBox(width: 8),
                Text(
                  'Add more items',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildActionChip(
                  Icons.note_add_outlined,
                  'Add a note for the restaurant',
                ),
                const SizedBox(width: 12),
                _buildActionChip(
                  Icons.restaurant_menu,
                  "Don't send cutlery",
                  isSelected: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildDeliverySavingsRow(),
          const Divider(height: 1, color: Colors.white10),
          _buildCouponsRow(),
          const SizedBox(height: 24),
          _buildDeliveryTimeSection(),
          const SizedBox(height: 24),
          _buildFleetSelectionSection(),
        ],
      ),
    );
  }

  Widget _buildActionChip(
    IconData icon,
    String label, {
    bool isSelected = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(double totalBill) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final paymentBg = AppColors.card(context);
    const accentGreen = Color(0xFF008037);

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: paymentBg,
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    offset: const Offset(0, -4),
                    blurRadius: 10,
                  ),
                ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Zomato Money Balance Line
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Zomato Money Balance: ₹0',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text('•', style: TextStyle(color: isDark ? Colors.white54 : Colors.grey, fontSize: 11)),
                  ),
                  InkWell(
                    onTap: () {},
                    child: const Text(
                      'Add Money >',
                      style: TextStyle(
                        color: Color(0xFF1F803A),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: isDark ? Colors.white10 : Colors.grey.shade200),
            
            // Main Payment Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12 + 16), // Extra bottom padding for safe area
              child: Row(
                children: [
                  // Payment Method Info
                  Expanded(
                    child: InkWell(
                      onTap: _openPaymentSelection,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.payments_outlined,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'PAY USING',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade400,
                                      letterSpacing: 0.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_drop_up,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                              Text(
                                _selectedPaymentMethod,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                              if (_selectedPaymentMethod == 'Pay on delivery')
                                Text(
                                  'UPI/Cash',
                                  style: TextStyle(color: isDark ? Colors.white38 : Colors.grey, fontSize: 11),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Place Order Button
                  InkWell(
                    onTap: () {
                      final order = Order(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        restaurantName: widget.restaurant.name,
                        restaurantSlug: widget.restaurant.slug,
                        restaurantAddress: currentAddressNotifier.value.subtitle,
                        restaurantImageUrl: widget.restaurant.imageUrl,
                        items: cartManager.items.entries.map((entry) {
                          return OrderItem(
                            name: entry.key.name,
                            quantity: entry.value,
                            isVeg: entry.key.isVeg,
                            price: entry.key.price,
                          );
                        }).toList(),
                        orderDate: DateTime.now(),
                        totalPrice: totalBill,
                      );
                      orderManager.addOrder(order);

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const SuccessScreen()),
                      );
                      cartManager.clear();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: accentGreen,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '₹${totalBill.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const Text(
                                'TOTAL',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 40),
                          const Text(
                            'Place Order',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_right,
                            color: Colors.white,
                            size: 24,
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
      ),
    );
  }

  void _showAddressSelectionSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
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
                margin: const EdgeInsets.only(top: 80),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                  borderRadius: BorderRadius.circular(28),
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
                          'Select an address',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context); // Close bottom sheet
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AddEditAddressScreen(),
                              ),
                            );
                          },
                          child: Row(
                            children: const [
                              Icon(Icons.add, color: Colors.green),
                              SizedBox(width: 8),
                              Text(
                                'Add Address',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                       Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            Text(
                              'SAVED ADDRESSES',
                              style: TextStyle(
                                fontSize: 12,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white54 : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ValueListenableBuilder<List<AddressModel>>(
                        valueListenable: savedAddressesNotifier,
                        builder: (context, addresses, _) {
                          return ListView.builder(
                            shrinkWrap: true,
                            itemCount: addresses.length,
                            itemBuilder: (context, index) {
                              final addr = addresses[index];
                              return _buildAddressSelectionCard(addr);
                            },
                          );
                        },
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
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

  Widget _buildAddressSelectionCard(AddressModel address) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: () {
        currentAddressNotifier.value = address;
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Icon(
                  address.type.toLowerCase() == 'home' ? Icons.home_outlined : Icons.location_on_outlined,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
                const SizedBox(height: 4),
                Text(
                  '0 m',
                  style: TextStyle(fontSize: 10, color: isDark ? Colors.white38 : Colors.grey),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DELIVERS TO',
                    style: TextStyle(fontSize: 10, color: Colors.blue.shade400, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address.subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white54 : Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade300),
                        ),
                        child: const Icon(Icons.more_horiz, size: 16, color: Colors.green),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade300),
                        ),
                        child: const Icon(Icons.turn_right, size: 16, color: Colors.green),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showContactUpdateSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nameController = TextEditingController(text: currentUserNotifier.value.name);
    final mobileController = TextEditingController(text: currentUserNotifier.value.mobile.isNotEmpty ? currentUserNotifier.value.mobile : '+91 9137173246');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
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
                margin: const EdgeInsets.only(top: 80),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'Update receiver details',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: RichText(
                          text: TextSpan(
                            text: 'Home - ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black,
                              fontSize: 14,
                            ),
                            children: [
                              TextSpan(
                                text: currentAddressNotifier.value.subtitle,
                                style: const TextStyle(fontWeight: FontWeight.normal, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _buildTextField('Receiver\'s name', nameController, Icons.person_outline),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _buildTextField('Receiver\'s mobile number', mobileController, Icons.phone_android_outlined),
                      ),
                      const SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: () {
                              currentUserNotifier.value = UserProfile(
                                name: nameController.text,
                                mobile: mobileController.text,
                                email: currentUserNotifier.value.email,
                              );
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade700,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Submit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
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

  Widget _buildTextField(String label, TextEditingController controller, IconData prefixIcon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.grey),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            prefixIcon: Icon(prefixIcon, color: isDark ? Colors.white54 : Colors.grey, size: 20),
            suffixIcon: Icon(Icons.contact_mail, color: isDark ? Colors.white54 : Colors.grey, size: 20),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade300)),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.green)),
          ),
        ),
      ],
    );
  }

  Widget _buildDeliverySavingsRow() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 10),
          ),
          const SizedBox(width: 12),
          Text(
            'You saved ₹${cartManager.discountAmount.toStringAsFixed(0)} on delivery',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponsRow() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CouponsScreen()),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
             Icon(Icons.percent, color: isDark ? Colors.white70 : Colors.grey, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'View all coupons',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: isDark ? Colors.white38 : Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryTimeSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.bolt, color: Colors.green, size: 18),
            const SizedBox(width: 12),
            RichText(
              text: TextSpan(
                text: 'Delivery in ',
                style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 13),
                children: const [
                  TextSpan(
                    text: '25-30 mins',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 30),
          child: Text(
            'Want this later? Schedule it',
            style: TextStyle(
              color: isDark ? Colors.white38 : Colors.grey,
              fontSize: 12,
              decoration: TextDecoration.underline,
              decorationColor: isDark ? Colors.white24 : Colors.grey.shade400,
              decorationStyle: TextDecorationStyle.dashed,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFleetSelectionSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.pedal_bike, color: isDark ? Colors.white70 : Colors.grey, size: 18),
                const SizedBox(width: 12),
                Text(
                  'Choose delivery fleet type',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            Icon(Icons.keyboard_arrow_up, color: isDark ? Colors.white38 : Colors.grey, size: 18),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildFleetCard(
                'Standard\nFleet',
                'Our standard food delivery experience',
                isSelected: _selectedFleet == 'Standard',
                onTap: () => setState(() => _selectedFleet = 'Standard'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFleetCard(
                'Special\nVeg-only Fleet',
                'Fleet delivering only from Pure Veg restaurants',
                isSelected: _selectedFleet == 'Veg',
                onTap: () => setState(() => _selectedFleet = 'Veg'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFleetCard(String title, String subtitle, {required bool isSelected, required VoidCallback onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        height: 140,
        decoration: BoxDecoration(
          color: isDark ? (isSelected ? const Color(0xFF1E2F26) : const Color(0xFF1E1E1E)) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.green : (isDark ? Colors.white10 : Colors.grey.shade200),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      height: 1.2,
                    ),
                  ),
                ),
                Icon(Icons.delivery_dining, color: isSelected ? Colors.green : Colors.grey, size: 24),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: TextStyle(
                color: isDark ? Colors.white38 : Colors.grey.shade600,
                fontSize: 10,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
