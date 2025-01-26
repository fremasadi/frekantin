import 'dart:convert';

Welcome welcomeFromJson(String str) => Welcome.fromJson(json.decode(str));

String welcomeToJson(Welcome data) => json.encode(data.toJson());

class Welcome {
  bool status;
  String message;
  List<Order> orders;

  Welcome({
    required this.status,
    required this.message,
    required this.orders,
  });

  factory Welcome.fromJson(Map<String, dynamic> json) => Welcome(
        status: json["status"],
        message: json["message"],
        orders: List<Order>.from(json["orders"].map((x) => Order.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "orders": List<dynamic>.from(orders.map((x) => x.toJson())),
      };
}

class Order {
  int id;
  String orderId;
  int customerId;
  int sellerId;
  String orderStatus;
  String totalAmount;
  String tableNumber;
  DateTime estimatedDeliveryTime;
  DateTime createdAt;
  DateTime updatedAt;
  List<OrderItem> orderItems;
  Payment payment;

  Order({
    required this.id,
    required this.orderId,
    required this.customerId,
    required this.sellerId,
    required this.orderStatus,
    required this.totalAmount,
    required this.tableNumber,
    required this.estimatedDeliveryTime,
    required this.createdAt,
    required this.updatedAt,
    required this.orderItems,
    required this.payment,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json["id"],
        orderId: json["order_id"],
        customerId: json["customer_id"],
        sellerId: json["seller_id"],
        orderStatus: json["order_status"],
        totalAmount: json["total_amount"],
        tableNumber: json["table_number"],
        estimatedDeliveryTime: DateTime.parse(json["estimated_delivery_time"]),
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        orderItems: List<OrderItem>.from(
            json["order_items"].map((x) => OrderItem.fromJson(x))),
        payment: json["payment"] != null
            ? Payment.fromJson(json["payment"])
            : Payment(
                id: 0,
                orderId: json["id"],
                paymentStatus: '',
                paymentType: '',
                paymentGateway: '',
                paymentGatewayReferenceId: '',
                paymentGatewayResponse: '',
                paymentVaName: '',
                paymentVaNumber: '',
                grossAmount: '',
                paymentDate: DateTime.now(),
                expiredAt: DateTime.now(),
                createdAt: DateTime.now(),
                updatedAt: DateTime.now()),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "order_id": orderId,
        "customer_id": customerId,
        "seller_id": sellerId,
        "order_status": orderStatus,
        "total_amount": totalAmount,
        "table_number": tableNumber,
        "estimated_delivery_time": estimatedDeliveryTime.toIso8601String(),
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "order_items": List<dynamic>.from(orderItems.map((x) => x.toJson())),
        "payment": payment.toJson(),
      };
}

class OrderItem {
  int id;
  int orderId;
  int productId;
  int quantity;
  String price;
  String notes;
  DateTime createdAt;
  DateTime updatedAt;
  Product product;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.price,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.product,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        id: json["id"],
        orderId: json["order_id"],
        productId: json["product_id"],
        quantity: json["quantity"],
        price: json["price"],
        notes: json["notes"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        product: Product.fromJson(json["product"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "order_id": orderId,
        "product_id": productId,
        "quantity": quantity,
        "price": price,
        "notes": notes,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "product": product.toJson(),
      };
}

class Product {
  int id;
  int sellerId;
  int categoryId;
  String name;
  String description;
  String price;
  String image;
  int stock;
  DateTime createdAt;
  DateTime updatedAt;

  Product({
    required this.id,
    required this.sellerId,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.stock,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json["id"],
        sellerId: json["seller_id"],
        categoryId: json["category_id"],
        name: json["name"],
        description: json["description"],
        price: json["price"],
        image: json["image"],
        stock: json["stock"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "seller_id": sellerId,
        "category_id": categoryId,
        "name": name,
        "description": description,
        "price": price,
        "image": image,
        "stock": stock,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}

class Payment {
  int id;
  int orderId;
  String paymentStatus;
  String paymentType;
  String paymentGateway;
  String paymentGatewayReferenceId;
  String paymentGatewayResponse;
  String paymentVaName;
  String paymentVaNumber;
  String? paymentEwallet;
  String grossAmount;
  String? paymentProof;
  DateTime paymentDate;
  DateTime expiredAt;
  DateTime createdAt;
  DateTime updatedAt;

  Payment({
    required this.id,
    required this.orderId,
    required this.paymentStatus,
    required this.paymentType,
    required this.paymentGateway,
    required this.paymentGatewayReferenceId,
    required this.paymentGatewayResponse,
    required this.paymentVaName,
    required this.paymentVaNumber,
    this.paymentEwallet = '',
    required this.grossAmount,
    this.paymentProof = '',
    required this.paymentDate,
    required this.expiredAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
        id: json["id"] ?? 0,
        orderId: json["order_id"] ?? 0,
        paymentStatus: json["payment_status"] ?? '',
        paymentType: json["payment_type"] ?? '',
        paymentGateway: json["payment_gateway"] ?? '',
        paymentGatewayReferenceId: json["payment_gateway_reference_id"] ?? '',
        paymentGatewayResponse: json["payment_gateway_response"] ?? '',
        paymentVaName: json["payment_va_name"] ?? '',
        paymentVaNumber: json["payment_va_number"] ?? '',
        paymentEwallet: json["payment_ewallet"] ?? '',
        grossAmount: json["gross_amount"] ?? '',
        paymentProof: json["payment_proof"] ?? '',
        paymentDate: json["payment_date"] != null
            ? DateTime.parse(json["payment_date"])
            : DateTime.now(),
        expiredAt: json["expired_at"] != null
            ? DateTime.parse(json["expired_at"])
            : DateTime.now(),
        createdAt: json["created_at"] != null
            ? DateTime.parse(json["created_at"])
            : DateTime.now(),
        updatedAt: json["updated_at"] != null
            ? DateTime.parse(json["updated_at"])
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "order_id": orderId,
        "payment_status": paymentStatus,
        "payment_type": paymentType,
        "payment_gateway": paymentGateway,
        "payment_gateway_reference_id": paymentGatewayReferenceId,
        "payment_gateway_response": paymentGatewayResponse,
        "payment_va_name": paymentVaName,
        "payment_va_number": paymentVaNumber,
        "payment_ewallet": paymentEwallet,
        "gross_amount": grossAmount,
        "payment_proof": paymentProof,
        "payment_date": paymentDate.toIso8601String(),
        "expired_at": expiredAt.toIso8601String(),
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}
