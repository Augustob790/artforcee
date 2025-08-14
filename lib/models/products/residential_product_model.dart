import 'product.dart';

class ResidentialProduct extends Product {
  final int warranty;
  final String color;
  final String energyRating;

  ResidentialProduct({
    required super.id,
    required super.name,
    required super.description,
    required super.basePrice,
    required super.category,
    super.isActive,
    super.createdAt,
    super.updatedAt,
    required this.color,
    required this.warranty,
    required this.energyRating,
  }) : super(type: ProductType.residential);

  @override
  List<String> getRequiredFields() {
    return ['color', 'warranty', 'energyRating', 'quantity', 'deliveryDate'];
  }

  @override
  List<String> validate(Map<String, dynamic> formData) {
    List<String> errors = [];

    // Validar garantia
    final inputWarranty = formData['warranty'] as int?;
    if (inputWarranty != null && inputWarranty < 6) {
      errors.add('Garantia mínima é de 6 meses');
    }

    // Validar classificação energética
    final inputRating = formData['energyRating'] as String?;
    if (inputRating != null && !['A', 'B', 'C', 'D', 'E'].contains(inputRating)) {
      errors.add('Classificação energética deve ser A, B, C, D ou E');
    }

    return errors;
  }

  @override
  List<String> getApplicableRules() {
    return ['volume_discount', 'urgency_fee', 'energy_rating_discount'];
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll({
      'color': color,
      'warranty': warranty,
      'energyRating': energyRating,
    });
    return map;
  }
}
