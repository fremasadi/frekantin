import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constant/strings.dart';
import '../models/review.dart';

class ReviewRepository {
  static const String _cachePrefix = 'rating_cache_';
  static const String _cacheTimestampPrefix = 'rating_timestamp_';
  static const Duration _cacheExpiration =
      Duration(hours: 1); // Cache selama 1 jam

  Future<AverageRating> fetchAverageRating(int productId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Cek cache dulu
    final cachedRating = await _getCachedRating(productId, prefs);
    if (cachedRating != null) {
      return cachedRating;
    }

    try {
      final rating = await _fetchFromApi(productId, prefs);
      await _cacheRating(productId, rating, prefs);
      return rating;
    } catch (e) {
      final expiredCache = await _getExpiredCache(productId, prefs);
      if (expiredCache != null) {
        return expiredCache;
      }
      rethrow;
    }
  }

  Future<AverageRating?> _getCachedRating(
      int productId, SharedPreferences prefs) async {
    final cacheKey = _cachePrefix + productId.toString();
    final timestampKey = _cacheTimestampPrefix + productId.toString();

    final cachedData = prefs.getString(cacheKey);
    final timestamp = prefs.getInt(timestampKey);

    if (cachedData != null && timestamp != null) {
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();

      // Cek apakah cache masih valid
      if (now.difference(cacheTime) < _cacheExpiration) {
        return AverageRating.fromJson(jsonDecode(cachedData));
      }
    }
    return null;
  }

  Future<AverageRating?> _getExpiredCache(
      int productId, SharedPreferences prefs) async {
    final cacheKey = _cachePrefix + productId.toString();
    final cachedData = prefs.getString(cacheKey);

    if (cachedData != null) {
      return AverageRating.fromJson(jsonDecode(cachedData));
    }
    return null;
  }

  Future<void> _cacheRating(
      int productId, AverageRating rating, SharedPreferences prefs) async {
    final cacheKey = _cachePrefix + productId.toString();
    final timestampKey = _cacheTimestampPrefix + productId.toString();

    await prefs.setString(
        cacheKey,
        jsonEncode({
          'averageRating': rating.averageRating,
        }));
    await prefs.setInt(timestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<AverageRating> _fetchFromApi(
      int productId, SharedPreferences prefs) async {
    String? token = prefs.getString('auth_token');

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final response = await http.get(
      Uri.parse('$baseUrl/products/$productId/average-rating'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return AverageRating.fromJson(data);
    } else {
      throw Exception('Failed to load average rating');
    }
  }

  // Method untuk manual clear cache jika diperlukan
  Future<void> clearCache(int productId) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = _cachePrefix + productId.toString();
    final timestampKey = _cacheTimestampPrefix + productId.toString();

    await prefs.remove(cacheKey);
    await prefs.remove(timestampKey);
  }

  // Method untuk clear semua cache
  Future<void> clearAllCache() async {
    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys();

    for (final key in allKeys) {
      if (key.startsWith(_cachePrefix) ||
          key.startsWith(_cacheTimestampPrefix)) {
        await prefs.remove(key);
      }
    }
  }
}
