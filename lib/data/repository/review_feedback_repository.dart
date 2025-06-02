import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constant/strings.dart';
import '../models/review.dart';

class ReviewFeedbackRepository {
  Future<ReviewFeedbackResponse?> fetchReviewFeedback(int productId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');
      if (token == null) {
        // Token tidak ditemukan, bisa handle error atau return null
        return null;
      }

      Uri url = Uri.parse('$baseUrl/products/$productId/reviews');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return ReviewFeedbackResponse.fromJson(jsonData);
      } else {
        // handle error sesuai kebutuhan
        print('Failed to load review feedback: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception in fetchReviewFeedback: $e');
      return null;
    }
  }
}
