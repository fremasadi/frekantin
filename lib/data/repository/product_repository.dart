import 'dart:convert';
import 'package:e_kantin/data/models/product.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constant/strings.dart';

class ProductRepository {
  Future<List<Product>> getProducts() async {
    try {
      // Ambil token
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('No authentication token found');
      }

      // Kirim request ke API
      final response = await http.get(
        Uri.parse('$baseUrl/products'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['status'] == true && jsonResponse['data'] != null) {
          return (jsonResponse['data'] as List).map((product) {
            return Product.fromJson(product);
          }).toList();
        } else {
          throw Exception('Invalid data structure: $jsonResponse');
        }
      } else {
        throw Exception(
            'HTTP request failed with status: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('Error: $e');
      print('StackTrace: $stackTrace');
      throw Exception('Error fetching products: $e');
    }
  }

  Future<List<Product>> getProductByCategory(String categoryId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/products/category/$categoryId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == true && jsonResponse['data'] != null) {
          return (jsonResponse['data'] as List)
              .map((product) => Product.fromJson(product))
              .toList();
        }
        throw Exception('Failed to parse products');
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }

  Future<List<Product>> searchProducts(String keyword) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/products/search?keyword=$keyword'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['status'] == true && jsonResponse['data'] != null) {
          return (jsonResponse['data'] as List)
              .map((product) => Product.fromJson(product))
              .toList();
        }

        throw Exception('Failed to parse search results');
      } else {
        throw Exception('Failed to search products');
      }
    } catch (e) {
      throw Exception('Error searching products: $e');
    }
  }
}
