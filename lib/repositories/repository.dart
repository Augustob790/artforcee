import '../models/base_model.dart';
import '../models/products/product.dart';
import '../models/rules/business_rule.dart';
import '../models/fields/form_field.dart';

/// Interface genérica para repositórios
/// Implementa o padrão Repository com type safety completa
abstract class IRepository<T extends BaseModel> {
  /// Busca um item por ID
  Future<T?> findById(String id);
  
  /// Busca todos os itens
  Future<List<T>> findAll();
  
  /// Busca itens baseado em critérios
  Future<List<T>> findWhere(Map<String, dynamic> criteria);
  
  /// Salva um item (create ou update)
  Future<T> save(T item);
  
  /// Salva múltiplos itens
  Future<List<T>> saveAll(List<T> items);
  
  /// Remove um item por ID
  Future<bool> deleteById(String id);
  
  /// Remove um item
  Future<bool> delete(T item);
  
  /// Conta o número total de itens
  Future<int> count();
  
  /// Verifica se existe um item com o ID especificado
  Future<bool> exists(String id);
  
  /// Limpa todos os itens do repositório
  Future<void> clear();
}

/// Implementação em memória do repositório genérico
/// Útil para desenvolvimento e testes
class InMemoryRepository<T extends BaseModel> implements IRepository<T> {
  final Map<String, T> _storage = {};
  
  @override
  Future<T?> findById(String id) async {
    return _storage[id];
  }
  
  @override
  Future<List<T>> findAll() async {
    return _storage.values.toList();
  }
  
  @override
  Future<List<T>> findWhere(Map<String, dynamic> criteria) async {
    return _storage.values.where((item) {
      final itemMap = item.toMap();
      
      for (final entry in criteria.entries) {
        final key = entry.key;
        final expectedValue = entry.value;
        final actualValue = itemMap[key];
        
        if (expectedValue is Map && expectedValue.containsKey('operator')) {
          // Critério com operador (ex: {'operator': '>=', 'value': 50})
          final operator = expectedValue['operator'] as String;
          final value = expectedValue['value'];
          
          if (!_evaluateCondition(actualValue, operator, value)) {
            return false;
          }
        } else {
          // Critério simples de igualdade
          if (actualValue != expectedValue) {
            return false;
          }
        }
      }
      
      return true;
    }).toList();
  }
  
  @override
  Future<T> save(T item) async {
    item.touch(); // Atualiza o timestamp
    _storage[item.id] = item;
    return item;
  }
  
  @override
  Future<List<T>> saveAll(List<T> items) async {
    final savedItems = <T>[];
    
    for (final item in items) {
      savedItems.add(await save(item));
    }
    
    return savedItems;
  }
  
  @override
  Future<bool> deleteById(String id) async {
    return _storage.remove(id) != null;
  }
  
  @override
  Future<bool> delete(T item) async {
    return deleteById(item.id);
  }
  
  @override
  Future<int> count() async {
    return _storage.length;
  }
  
  @override
  Future<bool> exists(String id) async {
    return _storage.containsKey(id);
  }
  
  @override
  Future<void> clear() async {
    _storage.clear();
  }
  
  /// Avalia uma condição com operador
  bool _evaluateCondition(dynamic actualValue, String operator, dynamic expectedValue) {
    if (actualValue == null) return false;
    
    switch (operator) {
      case '==':
        return actualValue == expectedValue;
      case '!=':
        return actualValue != expectedValue;
      case '>':
        return (actualValue as num) > (expectedValue as num);
      case '>=':
        return (actualValue as num) >= (expectedValue as num);
      case '<':
        return (actualValue as num) < (expectedValue as num);
      case '<=':
        return (actualValue as num) <= (expectedValue as num);
      case 'contains':
        return actualValue.toString().contains(expectedValue.toString());
      case 'startsWith':
        return actualValue.toString().startsWith(expectedValue.toString());
      case 'endsWith':
        return actualValue.toString().endsWith(expectedValue.toString());
      default:
        return actualValue == expectedValue;
    }
  }
}

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

/// Repositório específico para regras de negócio
class BusinessRuleRepository extends InMemoryRepository<BusinessRule> {
  /// Busca regras por tipo
  Future<List<BusinessRule>> findByType(RuleType type) async {
    return findWhere({'type': type.name});
  }
  
  /// Busca regras ativas
  Future<List<BusinessRule>> findActive() async {
    return findWhere({'isActive': true});
  }
  
  /// Busca regras por prioridade
  Future<List<BusinessRule>> findByPriority(RulePriority priority) async {
    return findWhere({'priority': priority.value});
  }
  
  /// Busca regras ordenadas por prioridade (maior prioridade primeiro)
  Future<List<BusinessRule>> findAllOrderedByPriority() async {
    final rules = await findAll();
    rules.sort((a, b) => b.priority.value.compareTo(a.priority.value));
    return rules;
  }
  
  /// Busca regras aplicáveis a um contexto específico
  Future<List<BusinessRule>> findApplicableRules(Map<String, dynamic> context) async {
    final activeRules = await findActive();
    return activeRules.where((rule) => rule.shouldApply(context)).toList();
  }
}

/// Repositório específico para campos de formulário
class FormFieldRepository extends InMemoryRepository<FormField> {
  /// Busca campos por tipo
  Future<List<FormField>> findByType(FieldType type) async {
    return findWhere({'type': type.name});
  }
  
  /// Busca campos visíveis
  Future<List<FormField>> findVisible() async {
    return findWhere({'isVisible': true});
  }
  
  /// Busca campos obrigatórios
  Future<List<FormField>> findRequired() async {
    return findWhere({'isRequired': true});
  }
  
  /// Busca campos ordenados por ordem de exibição
  Future<List<FormField>> findAllOrdered() async {
    final fields = await findAll();
    fields.sort((a, b) => a.order.compareTo(b.order));
    return fields;
  }
  
  /// Busca campos por lista de nomes
  Future<List<FormField>> findByNames(List<String> names) async {
    final allFields = await findAll();
    return allFields.where((field) => names.contains(field.name)).toList();
  }
}

