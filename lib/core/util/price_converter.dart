import 'package:intl/intl.dart';

String formatPrice(double price) {
  final formatter = NumberFormat('#,###', 'id_ID'); // Format Indonesia
  return formatter.format(price);
}
