import 'dart:convert';
import 'package:flutter/material.dart';
import '../utils/app_constants.dart' ;
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../models/app_data.dart';
import 'restaurant_details_screen.dart';

class SearchScreen extends StatefulWidget {
  final bool autoFocusMic;

  const SearchScreen({super.key, this.autoFocusMic = false});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Restaurant> _restaurants = [];
  List<Map<String, dynamic>> _searchCategories = [];
  bool _isLoading = true;
  String _searchQuery = '';

  stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  List<String> _recentSearches = [
    'Chinese Wok',
    'Natural Ice Cream',
    'MS Franky',
  ];

  @override
  void initState() {
    super.initState();
    _loadData().then((_) {
      if (widget.autoFocusMic) {
        _listen();
      }
    });
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => debugPrint('onStatus: $val'),
        onError: (val) => debugPrint('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _searchController.text = val.recognizedWords;
            _searchQuery = val.recognizedWords;
          }),
        );
      } else {
        setState(() => _isListening = false);
        var status = await Permission.microphone.request();
        if (status == PermissionStatus.granted) {
          _listen();
        }
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<void> _loadData() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/data/restaurants.json',
      );
      final List<dynamic> data = json.decode(response);
      final List<Restaurant> restaurants = data
          .map((json) => Restaurant.fromJson(json))
          .toList();

      final String catResponse = await rootBundle.loadString(
        'assets/data/search_categories.json',
      );
      final List<dynamic> catData = json.decode(catResponse);

      setState(() {
        _restaurants = restaurants;
        _searchCategories = List<Map<String, dynamic>>.from(catData);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading search data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Restaurant> _getSearchResults() {
    if (_searchQuery.isEmpty) return [];
    final query = _searchQuery.toLowerCase();
    return _restaurants.where((r) {
      if (r.name.toLowerCase().contains(query)) return true;
      if (r.dishes.any((d) => d.name.toLowerCase().contains(query)))
        return true;
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final searchResults = _getSearchResults();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Icon(
                  Icons.arrow_back_ios,
                  color: isDark ? Colors.white : Colors.black87,
                  size: 22,
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.card(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? Colors.white10 : Colors.grey.shade300,
                  ),
                  boxShadow: isDark ? null : [
                    BoxShadow(
                      color: Colors.grey.shade100,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Restaurant name or a dish...',
                          hintStyle: TextStyle(
                            color: isDark ? Colors.white38 : Colors.grey.shade500,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Icon(
                            Icons.close,
                            color: isDark ? Colors.white38 : Colors.grey,
                          ),
                        ),
                      ),
                    Container(
                      height: 24,
                      width: 1,
                      color: isDark ? Colors.white10 : Colors.grey.shade300,
                    ),
                    GestureDetector(
                      onTap: _listen,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Icon(
                          _isListening ? Icons.mic : Icons.mic_none_outlined,
                          color: _isListening ? Colors.red : Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: _searchQuery.isEmpty
          ? _buildInitialView()
          : _buildSearchResults(searchResults),
    );
  }

  Widget _buildInitialView() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'YOUR RECENT SEARCHES',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: isDark ? Colors.white60 : Colors.grey.shade600,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _recentSearches.clear();
                    });
                  },
                  child: const Text(
                    'Clear',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _recentSearches.map((search) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.card(context),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? Colors.white10 : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.history,
                        size: 14,
                        color: isDark ? Colors.white60 : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        search,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
          ],
          Text(
            "WHAT'S ON YOUR MIND?",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: isDark ? Colors.white60 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _searchCategories.length,
            itemBuilder: (context, index) {
              final cat = _searchCategories[index];
              return Column(
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.card(context),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.network(
                        cat['imageUrl'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.network(
                            'https://images.unsplash.com/photo-1606491956689-2ea866880c84?auto=format&fit=crop&w=200&q=80',
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cat['name'],
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                      ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(List<Restaurant> results) {
    if (results.isEmpty) {
      return const Center(
        child: Text(
          'No matches found.',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final r = results[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                r.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.network(
                    'https://images.unsplash.com/photo-1544025162-811afe52fa31?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80',
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
          ),
          title: Text(
            r.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text('${r.rating} • ${r.time}'),
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RestaurantDetailsScreen(restaurant: r),
              ),
            );
          },
        );
      },
    );
  }
}
