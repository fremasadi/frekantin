import 'dart:convert';
import 'package:e_kantin/core/constant/strings.dart';
import 'package:e_kantin/data/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class UserRepository {
  Future<User> fetchUser() async {
    final url = Uri.parse('$baseUrl/user');

    try {
      // Ambil token dari SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      // Pastikan token tersedia
      if (token == null) {
        throw Exception('Token tidak ditemukan. Harap login ulang.');
      }

      // Kirim request dengan Authorization Bearer Token
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          return User.fromJson(data['data']);
        } else {
          throw Exception(
              'Failed to fetch user data: ${data['message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception(
            'Failed to fetch user data: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
