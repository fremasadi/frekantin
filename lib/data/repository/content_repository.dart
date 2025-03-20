import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constant/strings.dart';

class ContentRepository {
  Future<List<dynamic>> getActiveImages() async {
    // Ambil instance SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    // Cek apakah token ada
    if (token == null) {
      throw Exception("Token tidak ditemukan");
    }

    // Set header dengan token
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    // Buat URL endpoint
    String url = '$baseUrl/image-contents';

    try {
      // Kirim permintaan GET ke API
      final response = await http.get(Uri.parse(url), headers: headers);

      // Cek status code
      if (response.statusCode == 200) {
        // Parse response JSON
        final data = jsonDecode(response.body);
        return data['data']; // Ambil data dari response
      } else {
        throw Exception('Gagal mengambil data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }
}
