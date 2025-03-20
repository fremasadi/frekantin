import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constant/strings.dart';

class TableNumberRepository {
  Future<Map<String, dynamic>> validateTableNumber(String tableNumber) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception("Token tidak ditemukan");
      }

      final response = await http.post(
        Uri.parse('$baseUrl/check-table-number'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'table_number': tableNumber,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'status': false,
          'message': errorData['message'] ?? 'Terjadi kesalahan pada server',
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': e.toString(),
      };
    }
  }
}
