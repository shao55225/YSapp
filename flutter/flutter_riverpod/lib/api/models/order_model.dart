class Order {
  final String id;
  final int status;
  final int amount;
  final String? createdAt;

  Order({required this.id, required this.status, required this.amount, this.createdAt});

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'].toString(),
      status: json['status'] ?? 0,
      amount: json['amount'] ?? 0,
      createdAt: json['createdAt'],
    );
  }
} 