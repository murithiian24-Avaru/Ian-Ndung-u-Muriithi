class PhoneModel {
  final String id;
  final String brand;
  final String model;
  final String imageUrl;
  final double price;
  final String description;
  final Map<String, String> specs;
  final bool isAvailable;

  PhoneModel({
    required this.id,
    required this.brand,
    required this.model,
    required this.imageUrl,
    required this.price,
    required this.description,
    required this.specs,
    this.isAvailable = true,
  });

  String get fullName => '$brand $model';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'brand': brand,
      'model': model,
      'imageUrl': imageUrl,
      'price': price,
      'description': description,
      'specs': specs,
      'isAvailable': isAvailable,
    };
  }

  factory PhoneModel.fromMap(Map<String, dynamic> map) {
    return PhoneModel(
      id: map['id'] ?? '',
      brand: map['brand'] ?? '',
      model: map['model'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      description: map['description'] ?? '',
      specs: Map<String, String>.from(map['specs'] ?? {}),
      isAvailable: map['isAvailable'] ?? true,
    );
  }
}
