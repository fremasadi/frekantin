import 'dart:convert';
import 'package:e_kantin/core/constant/strings.dart';
import 'package:e_kantin/data/models/user.dart';
import 'package:http/http.dart' as http;

class UserRepository {
  Future<User> fetchUser() async {
    final url = Uri.parse('$baseUrl/user');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          return User.fromJson(data['data']);
        } else {
          throw Exception(
              'Failed to fetch user data: ${data['message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('Failed to fetch user data: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
