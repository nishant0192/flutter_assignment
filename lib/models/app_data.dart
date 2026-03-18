class Dish {
  final String id;
  final String name;
  final int price;
  final String description;
  final String imageUrl;
  final bool isVeg;
  final bool isBestseller;
  final bool isCustomisable;

  const Dish({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl,
    this.isVeg = true,
    this.isBestseller = false,
    this.isCustomisable = true,
  });

  factory Dish.fromJson(Map<String, dynamic> json) {
    return Dish(
      id: json['id'] as String? ?? '',
      name: json['name'] as String,
      price: json['price'] as int,
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      isVeg: json['isVeg'] as bool? ?? true,
      isBestseller: json['isBestseller'] as bool? ?? false,
      isCustomisable: json['isCustomisable'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'isVeg': isVeg,
      'isBestseller': isBestseller,
      'isCustomisable': isCustomisable,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Dish && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class Restaurant {
  final String name;
  final String imageUrl;
  final double rating;
  final String time;
  final String offer;
  final List<RestaurantOffer> offers;
  final bool isPromoted;
  final bool isVeg;
  final List<Dish> dishes; // new field
  final List<String> imageUrls;

  const Restaurant({
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.time,
    required this.offer,
    this.offers = const [],
    this.isPromoted = false,
    this.isVeg = false,
    this.dishes = const [],
    this.imageUrls = const [],
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
      rating: (json['rating'] as num).toDouble(),
      time: json['time'] as String,
      offer: json['offer'] as String,
      offers: json['offers'] != null
          ? (json['offers'] as List).map((o) => RestaurantOffer.fromJson(o)).toList()
          : [],
      isPromoted: json['isPromoted'] as bool? ?? false,
      isVeg: json['isVeg'] as bool? ?? false,
      dishes: json['dishes'] != null
          ? (json['dishes'] as List).map((d) => Dish.fromJson(d)).toList()
          : (json['categories'] != null
                ? (json['categories'] as List)
                      .expand(
                        (c) =>
                            (c['dishes'] as List).map((d) => Dish.fromJson(d)),
                      )
                      .toList()
                : []),
      imageUrls: json['imageUrls'] != null
          ? List<String>.from(json['imageUrls'])
          : (json['imageUrl'] != null ? [json['imageUrl'] as String] : []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'rating': rating,
      'time': time,
      'offer': offer,
      'offers': offers.map((o) => o.toJson()).toList(),
      'isPromoted': isPromoted,
      'isVeg': isVeg,
      'dishes': dishes.map((d) => d.toJson()).toList(),
      'imageUrls': imageUrls,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Restaurant && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;
}

class Category {
  final String name;
  final String imageUrl;
  final String? promoUrl;

  const Category({required this.name, required this.imageUrl, this.promoUrl});
}

class RestaurantOffer {
  final String type; // 'coupon' or 'gold'
  final String title;
  final String description;
  final String? code;

  const RestaurantOffer({
    required this.type,
    required this.title,
    required this.description,
    this.code,
  });

  factory RestaurantOffer.fromJson(Map<String, dynamic> json) {
    return RestaurantOffer(
      type: json['type'] as String? ?? 'coupon',
      title: json['title'] as String,
      description: json['description'] as String,
      code: json['code'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'title': title,
      'description': description,
      if (code != null) 'code': code,
    };
  }
}
