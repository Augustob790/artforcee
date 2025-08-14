import '../models/products/industrial_product_model.dart';
import '../models/products/product.dart';

extension ProductExtensions on Product {
  /// Verifica se o produto é de alta voltagem (apenas para produtos industriais)
  bool get isHighVoltage {
    if (this is IndustrialProduct) {
      final industrial = this as IndustrialProduct;
      return industrial.voltage > 220;
    }
    return false;
  }

  /// Verifica se o produto requer certificação
  bool get requiresCertification {
    if (this is IndustrialProduct) {
      final industrial = this as IndustrialProduct;
      return industrial.voltage > 220;
    }
    return false;
  }

  /// Verifica se o produto está em uma categoria específica
  bool isInCategory(String categoryName) {
    return category.toLowerCase() == categoryName.toLowerCase();
  }
}
