import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookmarkManager extends ChangeNotifier {
  static final BookmarkManager instance = BookmarkManager._internal();
  factory BookmarkManager() => instance;
  BookmarkManager._internal();

  final Set<String> _bookmarkedRestaurantIds = {};
  final Set<String> _bookmarkedDishIds = {};

  Set<String> get bookmarkedRestaurantIds => _bookmarkedRestaurantIds;
  Set<String> get bookmarkedDishIds => _bookmarkedDishIds;

  int get restaurantCount => _bookmarkedRestaurantIds.length;
  int get dishCount => _bookmarkedDishIds.length;

  Future<void> init() async {
    await loadFromCache();
  }

  Future<void> _saveToCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('bookmarked_restaurants', _bookmarkedRestaurantIds.toList());
    await prefs.setStringList('bookmarked_dishes', _bookmarkedDishIds.toList());
  }

  Future<void> loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final restaurants = prefs.getStringList('bookmarked_restaurants');
    final dishes = prefs.getStringList('bookmarked_dishes');

    if (restaurants != null) {
      _bookmarkedRestaurantIds.clear();
      _bookmarkedRestaurantIds.addAll(restaurants);
    }
    if (dishes != null) {
      _bookmarkedDishIds.clear();
      _bookmarkedDishIds.addAll(dishes);
    }
    notifyListeners();
  }

  bool isRestaurantBookmarked(String id) {
    return _bookmarkedRestaurantIds.contains(id);
  }

  bool isDishBookmarked(String id) {
    return _bookmarkedDishIds.contains(id);
  }

  void toggleRestaurantBookmark(String id) {
    if (_bookmarkedRestaurantIds.contains(id)) {
      _bookmarkedRestaurantIds.remove(id);
    } else {
      _bookmarkedRestaurantIds.add(id);
    }
    notifyListeners();
    _saveToCache();
  }

  void toggleDishBookmark(String id) {
    if (_bookmarkedDishIds.contains(id)) {
      _bookmarkedDishIds.remove(id);
    } else {
      _bookmarkedDishIds.add(id);
    }
    notifyListeners();
    _saveToCache();
  }
}

final bookmarkManager = BookmarkManager.instance;
