import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constant/strings.dart';
import '../models/review.dart';

class ReviewRepository {
  Future<Map<String, dynamic>> checkReview(
      int orderItemId, int productId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('No authentication token found');
    }

    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/check-review?order_item_id=$orderItemId&product_id=$productId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data; // Kembalikan data lengkap (status, rating, comment)
      }

      throw Exception('Failed to check review status: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to check review status: $e');
    }
  }

  Future<void> submitReview(Review review) async {
    final url = Uri.parse('$baseUrl/orders/${review.orderId}/reviews');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('No authentication token found');
    }

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'product_id': review.productId,
          'rating': review.rating,
          'comment': review.comment,
          'image': review.image,
        }),
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Failed to submit review: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to submit review: $e');
    }
  }

  Future<AverageRating> fetchAverageRating(int productId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    final response = await http.get(
      Uri.parse('$baseUrl/products/$productId/average-rating'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return AverageRating.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load average rating');
    }
  }
}
