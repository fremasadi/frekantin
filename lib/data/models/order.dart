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
  String customerId;
  String sellerId;
  String orderStatus;
  String totalAmount;
  String tableNumber;
  String estimatedDeliveryTime;
  String createdAt;
  String updatedAt;
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

  factory Order.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw Exception('Order JSON is null');
    }

    return Order(
      id: json['id'] ?? 0,
      orderId: json['order_id'] ?? '',
      customerId: json['customer_id'] ?? '',
      sellerId: json['seller_id'] ?? '',
      orderStatus: json['order_status'] ?? '',
      totalAmount: json['total_amount']?.toString() ?? '0',
      tableNumber: json['table_number'] ?? '',
      estimatedDeliveryTime: json['estimated_delivery_time'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      // FIX: Parse payment object properly
      payment: Payment.fromJson(json['payment'] ?? {}),
      orderItems: (json['order_items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "order_id": orderId,
        "customer_id": customerId,
        "seller_id": sellerId,
        "order_status": orderStatus,
        "total_amount": totalAmount,
        "table_number": tableNumber,
        "estimated_delivery_time": estimatedDeliveryTime,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "order_items": List<dynamic>.from(orderItems.map((x) => x.toJson())),
        "payment": payment.toJson(),
      };
}

class OrderItem {
  int id;
  String orderId;
  String productId;
  String quantity;
  String price;
  String notes;
  String createdAt;
  String updatedAt;
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
        id: json["id"] ?? 0,
        orderId: json["order_id"] ?? '',
        productId: json["product_id"] ?? '',
        quantity: json["quantity"]?.toString() ?? '0',
        price: json["price"]?.toString() ?? '0',
        notes: json["notes"] ?? '',
        createdAt: json["created_at"] ?? '',
        updatedAt: json["updated_at"] ?? '',
        product: Product.fromJson(json["product"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "order_id": orderId,
        "product_id": productId,
        "quantity": quantity,
        "price": price,
        "notes": notes,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "product": product.toJson(),
      };
}

class Product {
  int id;
  String sellerId;
  String categoryId;
  String name;
  String description;
  String price;
  String image;
  String stock;
  String isActive;
  String createdAt;
  String updatedAt;

  Product({
    required this.id,
    required this.sellerId,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.stock,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json["id"] ?? 0,
        sellerId: json["seller_id"]?.toString() ?? '',
        categoryId: json["category_id"]?.toString() ?? '',
        name: json["name"] ?? '',
        description: json["description"] ?? '',
        price: json["price"]?.toString() ?? '0',
        image: json["image"] ?? '',
        stock: json["stock"]?.toString() ?? '0',
        isActive: json["is_active"]?.toString() ?? "0",
        createdAt: json["created_at"] ?? '',
        updatedAt: json["updated_at"] ?? '',
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
        "is_active": isActive,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}

class Payment {
  int id;
  String orderId;
  String paymentStatus;
  String paymentType;
  String paymentGateway;
  String paymentGatewayReferenceId;
  String paymentGatewayResponse;
  String? paymentVaName;
  String? paymentVaNumber;
  String? paymentEwallet;
  String grossAmount;
  String? paymentProof;
  String paymentDate;
  String expiredAt;
  String createdAt;
  String updatedAt;
  String? paymentQrUrl; // Added missing field
  String? paymentDeeplink; // Added missing field
  String? snapToken;
  String? snapUrl;

  Payment({
    required this.id,
    required this.orderId,
    required this.paymentStatus,
    required this.paymentType,
    required this.paymentGateway,
    required this.paymentGatewayReferenceId,
    required this.paymentGatewayResponse,
    this.paymentVaName,
    this.paymentVaNumber,
    this.paymentEwallet,
    required this.grossAmount,
    this.paymentProof,
    required this.paymentDate,
    required this.expiredAt,
    required this.createdAt,
    required this.updatedAt,
    this.paymentQrUrl,
    this.paymentDeeplink,
    this.snapToken,
    this.snapUrl,
  });

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
      id: json["id"] ?? 0,
      orderId: json["order_id"]?.toString() ?? '',
      paymentStatus: json["payment_status"] ?? '',
      paymentType: json["payment_type"] ?? '',
      paymentGateway: json["payment_gateway"] ?? '',
      paymentGatewayReferenceId: json["payment_gateway_reference_id"] ?? '',
      paymentGatewayResponse: json["payment_gateway_response"] ?? '',
      paymentVaName: json["payment_va_name"],
      paymentVaNumber: json["payment_va_number"],
      paymentEwallet: json["payment_ewallet"],
      grossAmount: json["gross_amount"]?.toString() ?? '0',
      paymentProof: json["payment_proof"],
      paymentDate: json["payment_date"] ?? '',
      expiredAt: json["expired_at"] ?? '',
      createdAt: json["created_at"] ?? '',
      updatedAt: json["updated_at"] ?? '',
      paymentQrUrl: json["payment_qr_url"],
      paymentDeeplink: json["payment_deeplink"],
      snapToken: json["snap_token"],
      snapUrl: json["snap_url"]);

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
        "payment_date": paymentDate,
        "expired_at": expiredAt,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "payment_qr_url": paymentQrUrl,
        "payment_deeplink": paymentDeeplink,
        "snap_token": snapToken,
        "snap_url": snapUrl
      };
}
