import '../products/product.dart';

class Quote {
  final String id;
  final Product product;
  final Map<String, dynamic> formData;
  final double finalPrice;
  final DateTime createdAt;

  Quote({
    required this.id,
    required this.product,
    required this.formData,
    required this.finalPrice,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product': product.toMap(),
      'formData': formData,
      'finalPrice': finalPrice,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}