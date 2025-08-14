import '../models/products/industrial_product_model.dart';
import '../models/products/product.dart';

/// Extensions para produtos
/// Implementa funcionalidades adicionais para manipulação de produtos
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

  /// Retorna um resumo curto do produto
  String get shortSummary {
    return '$name (${type.displayName}) - ${formatCurrency(basePrice)}';
  }

  /// Verifica se o produto está em uma categoria específica
  bool isInCategory(String categoryName) {
    return category.toLowerCase() == categoryName.toLowerCase();
  }

  /// Formata o preço como moeda brasileira
  String formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /// Calcula o preço com desconto baseado na quantidade
  double calculateDiscountedPrice(int quantity) {
    double totalPrice = basePrice * quantity;

    // Desconto por volume (15% para 50+ unidades)
    if (quantity >= 50) {
      totalPrice *= 0.85; // 15% de desconto
    }

    return totalPrice;
  }

}
