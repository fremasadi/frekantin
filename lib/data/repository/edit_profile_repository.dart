import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constant/strings.dart';

class EditProfileRepository {
  // Method untuk update profile tanpa gambar
  Future<Map<String, dynamic>> updateProfile({
    required String username,
    required String email,
    File? imageFile,
    String? phone,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('Token tidak ditemukan, silakan login kembali');
    }

    try {
      // Jika tidak ada file gambar, gunakan PUT request dengan JSON body
      if (imageFile == null) {
        final response = await http.put(
          Uri.parse('$baseUrl/user'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'name': username,
            'email': email,
            if (phone != null && phone.isNotEmpty) 'phone': phone,
          }),
        );

        print('Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');

        if (response.statusCode == 200) {
          return jsonDecode(response.body);
        } else {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['message'] ?? 'Gagal update profile');
        }
      }
      // Jika ada file gambar, gunakan multipart request
      else {
        var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/user'));

        // Tambahkan headers
        request.headers['Authorization'] = 'Bearer $token';
        request.headers['Accept'] = 'application/json';

        // Tambahkan text fields
        request.fields['name'] = username;
        request.fields['email'] = email;
        if (phone != null && phone.isNotEmpty) {
          request.fields['phone'] = phone;
        }

        // Tambahkan file gambar
        final fileStream = http.ByteStream(imageFile.openRead());
        final fileLength = await imageFile.length();

        final multipartFile = http.MultipartFile(
            'image', fileStream, fileLength,
            filename: imageFile.path.split('/').last);

        request.files.add(multipartFile);

        // Kirim request
        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        print('Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');

        if (response.statusCode == 200) {
          return jsonDecode(response.body);
        } else {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['message'] ?? 'Gagal update profile');
        }
      }
    } catch (e) {
      print('Error updating profile: $e');
      throw Exception('Gagal update profile: $e');
    }
  }
}
