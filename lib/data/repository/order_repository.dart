import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constant/strings.dart';
import '../models/order.dart';

class OrderRepository {
  Future<http.Response> postOrder(OrderRequest orderRequest) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception("Token tidak ditemukan");
      }

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      String url = '$baseUrl/order';

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(orderRequest.toJson()),
      );

      return response;
    } catch (e) {
      throw Exception("Gagal memposting data: $e");
    }
  }

  Future<List<Order>> fetchOrders() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception("Token tidak ditemukan");
      }

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      String url = '$baseUrl/order';

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        if (jsonData['orders'] is List) {
          return (jsonData['orders'] as List)
              .map<Order>((orderJson) => Order.fromJson(orderJson))
              .toList();
        } else {
          throw Exception("Orders tidak dalam format list");
        }
      } else {
        throw Exception('Gagal mengambil data pesanan');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<int, String>> getAllProductNotes(List<int> productIds) async {
    final prefs = await SharedPreferences.getInstance();
    Map<int, String> notes = {};

    for (var id in productIds) {
      String? note = prefs.getString('note_$id');
      if (note != null && note.isNotEmpty) {
        notes[id] = note;
      }
    }

    return notes;
  }

  Future<void> clearProductNotes(List<int> productIds) async {
    final prefs = await SharedPreferences.getInstance();
    for (var id in productIds) {
      await prefs.remove('note_$id');
    }
  }
}

class OrderRequest {
  final String tableNumber;
  final String paymentType;
  final String? bank;
  final List<OrderItemRequest> items;

  OrderRequest({
    required this.tableNumber,
    required this.paymentType,
    this.bank,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    final map = {
      'table_number': tableNumber,
      'payment_type': paymentType,
      'items': items.map((item) => item.toJson()).toList(),
    };
    if (bank != null) {
      map['bank'] = bank!;
    }
    return map;
  }

  Future<void> clearProductNotes(List<int> productIds) async {
    final prefs = await SharedPreferences.getInstance();
    for (var id in productIds) {
      await prefs.remove('note_$id');
    }
  }
}

class OrderItemRequest {
  final int productId;
  final int quantity;
  final String notes;

  OrderItemRequest({
    required this.productId,
    required this.quantity,
    this.notes = '',
  });

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'quantity': quantity,
        'notes': notes,
      };
}
