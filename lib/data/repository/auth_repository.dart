import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constant/strings.dart';

import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  Future<String?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login/customer'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);

      return token;
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<bool> logout() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('No token found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Clear token dari SharedPreferences
        await prefs.remove('auth_token');
        return true;
      } else {
        throw Exception('Failed to logout');
      }
    } catch (e) {
      // Tetap clear token jika terjadi error
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      throw Exception('Logout error: $e');
    }
  }

  Future<void> sendOtp(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send OTP: ${response.body}');
    }
  }

  Future<void> verifyOtp(String email, String otp) async {
    final response = await http.post(
      Uri.parse('$baseUrl/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'otp': otp}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to verify OTP: ${response.body}');
    }
  }

  Future<void> resetPassword(String email, String newPassword) async {
    final body = {
      'email': email,
      'new_password': newPassword, // Perhatikan nama field
    };

    final headers = {'Content-Type': 'application/json'};

    final response = await http.post(
      Uri.parse('$baseUrl/reset-password'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to reset password: ${response.body}');
    }
  }
}
