import '../base_model.dart';
import 'corporate_product.dart';
import 'industrial_product.dart';
import 'residential_product.dart';

enum ProductType {
  industrial('Industrial'),
  residential('Residencial'),
  corporate('Corporativo');

  const ProductType(this.displayName);
  final String displayName;
}

abstract class Product extends BaseModel {
  final String name;
  final String description;
  final String category;
  final double basePrice;
  final ProductType type;
  final bool isActive;

  Product({
    required super.id,
    required this.name,
    required this.description,
    required this.basePrice,
    required this.type,
    required this.category,
    this.isActive = true,
    super.createdAt,
    super.updatedAt,
  });
  /// Retorna os campos específicos que devem aparecer no formulário
  /// para este tipo de produto
  List<String> getRequiredFields();

  /// Valida se o produto está configurado corretamente
  /// Cada tipo de produto pode ter suas próprias validações
  List<String> validate(Map<String, dynamic> formData);

  /// Retorna as regras de negócio específicas para este tipo de produto
  List<String> getApplicableRules();

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'basePrice': basePrice,
      'type': type.name,
      'category': category,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Factory method para criar produtos baseado no tipo
  static Product createProduct({
    required String id,
    required String name,
    required String description,
    required double basePrice,
    required ProductType type,
    required String category,
    bool isActive = true,
    Map<String, dynamic>? specificData,
  }) {
    switch (type) {
      case ProductType.industrial:
        return IndustrialProduct(
          id: id,
          name: name,
          description: description,
          basePrice: basePrice,
          category: category,
          isActive: isActive,
          voltage: specificData?['voltage'] ?? 220,
          certification: specificData?['certification'] ?? '',
          powerConsumption: specificData?['powerConsumption'] ?? 0.0,
        );
      case ProductType.residential:
        return ResidentialProduct(
          id: id,
          name: name,
          description: description,
          basePrice: basePrice,
          category: category,
          isActive: isActive,
          color: specificData?['color'] ?? 'Branco',
          warranty: specificData?['warranty'] ?? 12,
          energyRating: specificData?['energyRating'] ?? 'A',
        );
      case ProductType.corporate:
        return CorporateProduct(
          id: id,
          name: name,
          description: description,
          basePrice: basePrice,
          category: category,
          isActive: isActive,
          licenseType: specificData?['licenseType'] ?? 'Standard',
          supportLevel: specificData?['supportLevel'] ?? 'Basic',
          maxUsers: specificData?['maxUsers'] ?? 10,
        );
    }
  }
}
