import '../models/products/product.dart';
import 'repository.dart';

/// Repositório específico para produtos
/// Demonstra como especializar o repositório genérico
class ProductRepository extends InMemoryRepository<Product> {
  /// Busca produtos por tipo
  Future<List<Product>> findByType(ProductType type) async {
    return findWhere({'type': type.name});
  }
  
  /// Busca produtos ativos
  Future<List<Product>> findActive() async {
    return findWhere({'isActive': true});
  }
  
  /// Busca produtos por categoria
  Future<List<Product>> findByCategory(String category) async {
    return findWhere({'category': category});
  }
  
  /// Busca produtos por faixa de preço
  Future<List<Product>> findByPriceRange(double minPrice, double maxPrice) async {
    final allProducts = await findAll();
    return allProducts.where((product) {
      return product.basePrice >= minPrice && product.basePrice <= maxPrice;
    }).toList();
  }
}
