class Product {
  final String id;
  final String name;
  final String? desc;
  final int price;

  Product({required this.id, required this.name, this.desc, required this.price});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      desc: json['desc'],
      price: json['price'] ?? 0,
    );
  }
} 