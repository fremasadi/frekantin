import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  // Fetch data berdasarkan order_id
  Future<Map<String, dynamic>?> fetchOrderById(String orderId) async {
    final snapshot = await _dbRef.child('notifications/orders').get();

    if (snapshot.exists) {
      final orders = snapshot.value as Map<dynamic, dynamic>;
      for (var key in orders.keys) {
        final order = orders[key] as Map<dynamic, dynamic>;
        if (order['order_id'] == orderId) {
          return {
            'id': key,
            ...order, // Menggabungkan ID dengan data lainnya
          };
        }
      }
    }
    return null; // Jika tidak ditemukan
  }

  // Listen ke perubahan data berdasarkan order_id
  void listenToOrder(String orderId, Function(Map<String, dynamic>?) onData) {
    _dbRef.child('notifications/orders').onValue.listen((event) {
      if (event.snapshot.exists) {
        final orders = event.snapshot.value as Map<dynamic, dynamic>;
        for (var key in orders.keys) {
          final order = orders[key] as Map<dynamic, dynamic>;
          if (order['order_id'] == orderId) {
            onData({
              'id': key,
              ...order,
            });
            return;
          }
        }
      }
      onData(null); // Jika data tidak ditemukan
    });
  }
}
