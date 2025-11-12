import 'package:shared_preferences/shared_preferences.dart';

/// Manages query history for quick access to recent questions
class QueryHistory {
  static const String _key = 'ocean_query_history';
  static const int _maxHistory = 5;

  /// Save a query to history
  static Future<void> addQuery(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();
    
    // Remove if already exists (to move to top)
    history.remove(query);
    
    // Add to beginning
    history.insert(0, query);
    
    // Keep only last 5
    if (history.length > _maxHistory) {
      history.removeRange(_maxHistory, history.length);
    }
    
    await prefs.setStringList(_key, history);
  }

  /// Get query history
  static Future<List<String>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  /// Clear all history
  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

