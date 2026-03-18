import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_data.dart';

class CartManager extends ChangeNotifier {
  static final CartManager instance = CartManager._internal();
  factory CartManager() => instance;
  CartManager._internal();

  final Map<Dish, int> items = {};
  Restaurant? currentRestaurant;

  Future<void> _saveToCache() async {
    final prefs = await SharedPreferences.getInstance();
    if (items.isEmpty) {
      prefs.remove('cart_items');
      prefs.remove('cart_restaurant');
      return;
    }

    final itemsList = items.entries.map((e) => {
      'dish': e.key.toJson(),
      'quantity': e.value,
    }).toList();

    prefs.setString('cart_items', jsonEncode(itemsList));
    if (currentRestaurant != null) {
      prefs.setString('cart_restaurant', jsonEncode(currentRestaurant!.toJson()));
    }
  }

  Future<void> loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final itemsStr = prefs.getString('cart_items');
    final restaurantStr = prefs.getString('cart_restaurant');

    if (itemsStr != null && restaurantStr != null) {
      try {
        final List<dynamic> itemsJson = jsonDecode(itemsStr);
        final Map<String, dynamic> restaurantJson = jsonDecode(restaurantStr);

        currentRestaurant = Restaurant.fromJson(restaurantJson);
        items.clear();
        for (var item in itemsJson) {
          final dish = Dish.fromJson(item['dish'] as Map<String, dynamic>);
          final qty = item['quantity'] as int;
          items[dish] = qty;
        }
        notifyListeners();
      } catch (e) {
        debugPrint('Error loading cart from cache: $e');
      }
    }
  }

  void updateQuantity(Dish dish, int delta, Restaurant restaurant) {
    if (currentRestaurant == null) {
      currentRestaurant = restaurant;
    }

    final current = items[dish] ?? 0;
    final next = current + delta;
    if (next <= 0) {
      items.remove(dish);
    } else {
      items[dish] = next;
    }

    if (items.isEmpty) {
      currentRestaurant = null;
    }
    notifyListeners();
    _saveToCache();
  }

  void clear() {
    items.clear();
    currentRestaurant = null;
    notifyListeners();
    _saveToCache();
  }

  double get subTotal {
    double total = 0;
    items.forEach((dish, quantity) {
      total += dish.price * quantity;
    });
    return total;
  }

  double get gst => subTotal * 0.05; // 5% GST
  double get deliveryCharge => 30.0;
  double get platformFee => 5.0;
  double get discountAmount => 45.0; // Hardcoded discount

  double get totalBill {
    if (items.isEmpty) return 0;
    return subTotal + gst + deliveryCharge + platformFee - discountAmount;
  }

  int get totalItems {
    int total = 0;
    for (var quantity in items.values) {
      total += quantity;
    }
    return total;
  }
}

final cartManager = CartManager.instance;
