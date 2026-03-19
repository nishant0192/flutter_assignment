
class OrderItem {
  final String name;
  final int quantity;
  final bool isVeg;
  final int price;

  OrderItem({
    required this.name,
    required this.quantity,
    required this.isVeg,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      name: json['name'] as String,
      quantity: json['quantity'] as int,
      isVeg: json['isVeg'] as bool? ?? true,
      price: json['price'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'isVeg': isVeg,
      'price': price,
    };
  }
}

class Order {
  final String id;
  final String restaurantName;
  final String? restaurantSlug;
  final String restaurantAddress;
  final String restaurantImageUrl;
  final List<OrderItem> items;
  final DateTime orderDate;
  final double totalPrice;
  final String status;

  Order({
    required this.id,
    required this.restaurantName,
    this.restaurantSlug,
    required this.restaurantAddress,
    required this.restaurantImageUrl,
    required this.items,
    required this.orderDate,
    required this.totalPrice,
    this.status = 'Delivered',
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      restaurantName: json['restaurantName'] as String,
      restaurantSlug: json['restaurantSlug'] as String?,
      restaurantAddress: json['restaurantAddress'] as String? ?? 'Mira Road, Mumbai',
      restaurantImageUrl: json['restaurantImageUrl'] as String,
      items: (json['items'] as List)
          .map((i) => OrderItem.fromJson(i as Map<String, dynamic>))
          .toList(),
      orderDate: DateTime.parse(json['orderDate'] as String),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      status: json['status'] as String? ?? 'Delivered',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurantName': restaurantName,
      'restaurantSlug': restaurantSlug,
      'restaurantAddress': restaurantAddress,
      'restaurantImageUrl': restaurantImageUrl,
      'items': items.map((i) => i.toJson()).toList(),
      'orderDate': orderDate.toIso8601String(),
      'totalPrice': totalPrice,
      'status': status,
    };
  }
}
