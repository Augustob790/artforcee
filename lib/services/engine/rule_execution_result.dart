/// Resultado da execução de regras
class RuleExecutionResult {
  final Map<String, dynamic> _results = {};
  final Map<String, String> _errors = {};

  /// Adiciona o resultado de uma regra
  void addRuleResult(String ruleId, dynamic result) {
    _results[ruleId] = result;
  }

  /// Adiciona um erro de processamento
  void addError(String ruleId, String error) {
    _errors[ruleId] = error;
  }

  /// Obtém o resultado de uma regra específica
  T? getResult<T>(String ruleId) {
    final result = _results[ruleId];
    return result is T ? result : null;
  }

  /// Obtém todos os resultados
  Map<String, dynamic> get results => Map.unmodifiable(_results);

  /// Obtém todos os erros
  Map<String, String> get errors => Map.unmodifiable(_errors);

  /// Verifica se houve erros
  bool get hasErrors => _errors.isNotEmpty;

  /// Verifica se a execução foi bem-sucedida
  bool get isSuccess => _errors.isEmpty;

  /// Obtém o número total de regras processadas
  int get totalRulesProcessed => _results.length + _errors.length;

  /// Obtém uma lista de todos os erros de validação
  List<String> get validationErrors {
    final errors = <String>[];

    for (final result in _results.values) {
      if (result is List<String>) {
        errors.addAll(result);
      }
    }

    return errors;
  }

  /// Obtém o preço final calculado
  double? get finalPrice {
    // Procura pelo último resultado de preço
    for (final result in _results.values.toList().reversed) {
      if (result is double) {
        return result;
      }
    }
    return null;
  }

  /// Obtém a visibilidade dos campos
  Map<String, bool> get fieldVisibility {
    final visibility = <String, bool>{};

    for (final result in _results.values) {
      if (result is Map<String, bool>) {
        visibility.addAll(result);
      }
    }

    return visibility;
  }

  @override
  String toString() {
    return 'RuleExecutionResult(results: ${_results.length}, errors: ${_errors.length})';
  }
}