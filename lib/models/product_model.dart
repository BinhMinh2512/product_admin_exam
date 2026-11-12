class ProductModel {
  final String? id;
  final String name;
  final double price;
  final int soluong;
  final String image;

  ProductModel({
    this.id,
    required this.name,
    required this.price,
    required this.soluong,
    required this.image,
  });

  Map<String, dynamic> toMap() {
    return {'name': name, 'price': price, 'soluong': soluong, 'image': image};
  }

  factory ProductModel.fromMap(String id, Map<String, dynamic> map) {
    return ProductModel(
      id: id,
      name: map['name'] ?? '',
      price: (map['price'] as num).toDouble(),
      soluong: (map['soluong'] as num).toInt(),
      image: map['image'] ?? '',
    );
  }
}
