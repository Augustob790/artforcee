import '../../models/base_model.dart';

/// Serviço de fábrica genérico para criação dinâmica de objetos
/// Implementa o padrão Factory Method com type safety
abstract class FactoryService<T extends BaseModel> {
  /// Cria uma instância do tipo T baseado nos parâmetros fornecidos
  T create(Map<String, dynamic> data);

  /// Cria múltiplas instâncias do tipo T
  List<T> createMultiple(List<Map<String, dynamic>> dataList) {
    return dataList.map((data) => create(data)).toList();
  }

  /// Verifica se pode criar uma instância com os dados fornecidos
  bool canCreate(Map<String, dynamic> data);

  /// Obtém os campos obrigatórios para criação
  List<String> getRequiredFields();

  /// Valida os dados antes da criação
  List<String> validateData(Map<String, dynamic> data) {
    final errors = <String>[];
    final requiredFields = getRequiredFields();

    for (final field in requiredFields) {
      if (!data.containsKey(field) || data[field] == null) {
        errors.add('Campo obrigatório ausente: $field');
      }
    }

    return errors;
  }
}





