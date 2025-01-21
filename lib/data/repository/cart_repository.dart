import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constant/strings.dart';
import '../models/cart_item.dart'; // Import baseUrl

class CartRepository {
  Future<List<CartItem>> getCartItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    final response = await http.get(
      Uri.parse('$baseUrl/cart'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      if (responseData['status'] == true) {
        if (responseData['data'] != null && responseData['data'].isEmpty) {
          return [];
        }
        if (responseData['data'] != null) {
          return (responseData['data'] as List)
              .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
      throw Exception('No data available or status is false');
    } else {
      throw Exception('Failed to load cart items');
    }
  }

  Future<void> addItemToCart(int id, int quantity) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    final body = jsonEncode({
      'product_id': id,
      'quantity': quantity,
    });

    final response = await http.post(
      Uri.parse('$baseUrl/cart'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      if (responseData['status'] == true) {
        return; // Item added successfully
      } else {
        throw Exception(
            responseData['message'] ?? 'Failed to add item to cart');
      }
    } else {
      throw Exception('Failed to add item to cart');
    }
  }

  Future<void> updateCartItem(int id, int quantity) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    final body = jsonEncode({'quantity': quantity});

    final response = await http.put(
      Uri.parse('$baseUrl/cart/items/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['status'] != true) {
        throw Exception(
            'Failed to update cart item: ${responseData['message']}');
      }
    } else {
      throw Exception(
          'Failed to update cart item, status code: ${response.statusCode}');
    }
  }

  Future<void> removeCartItem(int itemId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    final response = await http.delete(
      Uri.parse('$baseUrl/cart/items/$itemId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to remove cart item');
    }
  }

  Future<String> getTotalPrice() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    final response = await http.get(
      Uri.parse('$baseUrl/cart/total-price'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['status'] == true) {
        return responseData['total_price'];
      } else {
        throw Exception('Failed to fetch total price');
      }
    } else {
      throw Exception('Failed to fetch total price');
    }
  }
}
