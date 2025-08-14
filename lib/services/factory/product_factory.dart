import '../../models/products/product.dart';
import 'factory_service.dart';

/// Fábrica para produtos
class ProductFactory extends FactoryService<Product> {
  @override
  Product create(Map<String, dynamic> data) {
    final errors = validateData(data);
    if (errors.isNotEmpty) {
      throw ArgumentError('Dados inválidos para criação do produto: ${errors.join(', ')}');
    }

    final typeString = data['type'] as String;
    final type = ProductType.values.firstWhere(
      (t) => t.name == typeString,
      orElse: () => throw ArgumentError('Tipo de produto inválido: $typeString'),
    );

    return Product.createProduct(
      id: data['id'] as String,
      name: data['name'] as String,
      description: data['description'] as String,
      basePrice: (data['basePrice'] as num).toDouble(),
      type: type,
      category: data['category'] as String,
      isActive: data['isActive'] as bool? ?? true,
      specificData: data['specificData'] as Map<String, dynamic>?,
    );
  }

  @override
  bool canCreate(Map<String, dynamic> data) {
    final errors = validateData(data);
    return errors.isEmpty;
  }

  @override
  List<String> getRequiredFields() {
    return ['id', 'name', 'description', 'basePrice', 'type', 'category'];
  }
}
