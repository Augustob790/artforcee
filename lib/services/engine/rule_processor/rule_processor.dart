import '../../../models/models.dart';

abstract class IRuleProcessor {
  /// Verifica se este processador pode processar a regra
  bool canProcess(BusinessRule rule);

  /// Processa a regra e retorna o resultado
  dynamic processRule(BusinessRule rule, Map<String, dynamic> context);
}