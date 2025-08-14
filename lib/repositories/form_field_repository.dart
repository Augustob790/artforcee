import '../models/models.dart';
import 'repository.dart';

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
