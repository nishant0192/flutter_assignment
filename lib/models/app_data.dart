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
}

class Restaurant {
  final String name;
  final String imageUrl;
  final double rating;
  final String time;
  final String offer;
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
}

class Category {
  final String name;
  final String imageUrl;
  final String? promoUrl;

  const Category({required this.name, required this.imageUrl, this.promoUrl});
}
