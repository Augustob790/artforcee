import '../models/models.dart';

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

