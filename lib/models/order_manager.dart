import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'order.dart';

class OrderManager extends ChangeNotifier {
  static final OrderManager instance = OrderManager._internal();
  factory OrderManager() => instance;
  OrderManager._internal();

  List<Order> _orders = [];
  List<Order> get orders => List.unmodifiable(_orders);

  Future<void> init() async {
    await loadOrders();
    if (_orders.isEmpty) {
      _addDummyOrders();
    }
  }

  Future<void> loadOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final ordersStr = prefs.getString('past_orders');
    
    if (ordersStr != null) {
      try {
        final List<dynamic> ordersJson = jsonDecode(ordersStr);
        _orders = ordersJson.map((json) => Order.fromJson(json as Map<String, dynamic>)).toList();
        // Sort by date descending (most recent first)
        _orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
        notifyListeners();
      } catch (e) {
        debugPrint('Error loading orders: $e');
      }
    }
  }

  Future<void> addOrder(Order order) async {
    _orders.insert(0, order); // Add to beginning
    await _saveOrders();
    notifyListeners();
  }

  Future<void> _saveOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final ordersJson = _orders.map((o) => o.toJson()).toList();
    await prefs.setString('past_orders', jsonEncode(ordersJson));
  }

  void _addDummyOrders() {
    _orders = [
      Order(
        id: '1',
        restaurantName: 'Parivar Veg Restaurant',
        restaurantAddress: 'Mira Road, Mumbai',
        restaurantImageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=200&h=200&fit=crop',
        items: [
          OrderItem(name: 'Veg Kolhapuri', quantity: 1, isVeg: true, price: 296),
        ],
        orderDate: DateTime.now().subtract(const Duration(days: 60)),
        totalPrice: 296.0,
      ),
      Order(
        id: '2',
        restaurantName: '99 China Town',
        restaurantAddress: 'Mira Road, Mumbai',
        restaurantImageUrl: 'https://images.unsplash.com/photo-1512058560566-42724afbc2db?w=200&h=200&fit=crop',
        items: [
          OrderItem(name: 'Veg Schezwan Fried Rice', quantity: 1, isVeg: true, price: 159),
        ],
        orderDate: DateTime.now().subtract(const Duration(days: 90)),
        totalPrice: 159.0,
      ),
      Order(
        id: '3',
        restaurantName: 'Madhuram Sweets',
        restaurantAddress: 'Dahisar East, Mumbai',
        restaurantImageUrl: 'https://images.unsplash.com/photo-1547928576-965306631627?w=200&h=200&fit=crop',
        items: [
          OrderItem(name: 'Vada Pav [2 Pieces]', quantity: 1, isVeg: true, price: 40),
        ],
        orderDate: DateTime.now().subtract(const Duration(days: 120)),
        totalPrice: 40.0,
      ),
    ];
    _saveOrders();
    notifyListeners();
  }
}

final orderManager = OrderManager.instance;
