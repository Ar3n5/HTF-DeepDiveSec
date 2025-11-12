import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Favorite item model
class FavoriteItem {
  final String id;
  final String query;
  final String response;
  final DateTime timestamp;

  FavoriteItem({
    required this.id,
    required this.query,
    required this.response,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'query': query,
    'response': response,
    'timestamp': timestamp.toIso8601String(),
  };

  factory FavoriteItem.fromJson(Map<String, dynamic> json) => FavoriteItem(
    id: json['id'] as String,
    query: json['query'] as String,
    response: json['response'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
  );
}

/// Manages favorite ocean queries and responses
class Favorites {
  static const String _key = 'ocean_favorites';
    final String id;
    final String query;
    final String response;
    final DateTime timestamp;

    FavoriteItem({
      required this.id,
      required this.query,
      required this.response,
      required this.timestamp,
    });

    Map<String, dynamic> toJson() => {
      'id': id,
      'query': query,
      'response': response,
      'timestamp': timestamp.toIso8601String(),
    };

    factory FavoriteItem.fromJson(Map<String, dynamic> json) => FavoriteItem(
      id: json['id'] as String,
      query: json['query'] as String,
      response: json['response'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// Add a favorite
  static Future<void> addFavorite({
    required String query,
    required String response,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    
    final item = FavoriteItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      query: query,
      response: response,
      timestamp: DateTime.now(),
    );
    
    favorites.insert(0, item);
    
    final jsonList = favorites.map((f) => jsonEncode(f.toJson())).toList();
    await prefs.setStringList(_key, jsonList);
  }

  /// Get all favorites
  static Future<List<FavoriteItem>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key) ?? [];
    
    return jsonList
        .map((json) => FavoriteItem.fromJson(jsonDecode(json)))
        .toList();
  }

  /// Remove a favorite
  static Future<void> removeFavorite(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    
    favorites.removeWhere((f) => f.id == id);
    
    final jsonList = favorites.map((f) => jsonEncode(f.toJson())).toList();
    await prefs.setStringList(_key, jsonList);
  }

  /// Check if a query is favorited
  static Future<bool> isFavorited(String query) async {
    final favorites = await getFavorites();
    return favorites.any((f) => f.query == query);
  }

  /// Clear all favorites
  static Future<void> clearFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

