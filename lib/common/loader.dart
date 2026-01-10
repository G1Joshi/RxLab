import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

class DataLoader {
  static final Map<String, dynamic> _cache = {};

  static Future<List<T>> loadList<T>({
    required String path,
    required String rootKey,
    required T Function(Map<String, dynamic>) fromJson,
    bool useCache = true,
  }) async {
    if (useCache && _cache.containsKey(path)) {
      return (_cache[path] as List).cast<T>();
    }

    final jsonString = await rootBundle.loadString(path);
    final data = jsonDecode(jsonString) as Map<String, dynamic>;

    final List<T> result = (data[rootKey] as List)
        .map((item) => fromJson(item as Map<String, dynamic>))
        .toList();

    if (useCache) {
      _cache[path] = result;
    }

    return result;
  }

  static Future<Map<String, dynamic>?> loadMap({
    required String path,
    bool useCache = true,
  }) async {
    if (useCache && _cache.containsKey(path)) {
      return _cache[path] as Map<String, dynamic>?;
    }

    final jsonString = await rootBundle.loadString(path);
    final data = jsonDecode(jsonString) as Map<String, dynamic>;

    if (useCache) {
      _cache[path] = data;
    }

    return data;
  }

  static void clearCache() {
    _cache.clear();
  }
}
