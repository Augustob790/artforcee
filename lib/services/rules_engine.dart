import '../models/rules/business_rule.dart';
import '../models/rules/princing_rule.dart';
import '../models/rules/validation_rule.dart';
import '../models/rules/visibility_rule.dart';
import '../repositories/rule_repository.dart';

/// Engine de regras de negócio genérica
/// Implementa o padrão Strategy para processamento de regras configuráveis
class RulesEngine<T extends BusinessRule> {
  final BusinessRuleRepository _ruleRepository;
  final List<IRuleProcessor> _processors;

  RulesEngine(this._ruleRepository)
      : _processors = [
          PricingRuleProcessor(),
          ValidationRuleProcessor(),
          VisibilityRuleProcessor(),
        ];

  /// Processa todas as regras aplicáveis a um contexto
  Future<RuleExecutionResult> processRules(Map<String, dynamic> context) async {
    final rules = await _ruleRepository.findApplicableRules(context);
    return _processAndSortRules(rules, context);
  }

  /// Processa apenas regras de um tipo específico
  Future<RuleExecutionResult> processRulesByType(RuleType type, Map<String, dynamic> context) async {
    final rules = await _ruleRepository.findByType(type);
    final applicableRules = rules.where((rule) => rule.shouldApply(context)).toList();
    return _processAndSortRules(applicableRules, context);
  }

  /// Lógica comum de processamento de regras
  Future<RuleExecutionResult> _processAndSortRules(List<BusinessRule> rules, Map<String, dynamic> context) async {
    rules.sort((a, b) => b.priority.value.compareTo(a.priority.value));

    final result = RuleExecutionResult();

    for (final rule in rules) {
      try {
        final processor = _getProcessorForRule(rule);
        if (processor != null) {
          final ruleResult = processor.processRule(rule, context);
          result.addRuleResult(rule.id, ruleResult);
          _updateContextWithResult(context, rule, ruleResult);
        }
      } catch (e) {
        result.addError(rule.id, 'Erro ao processar regra ${rule.name}: $e');
      }
    }
    return result;
  }

  /// Valida todas as regras ativas
  Future<List<String>> validateAllRules() async {
    final rules = await _ruleRepository.findActive();
    final errors = <String>[];

    for (final rule in rules) {
      final ruleErrors = rule.validateRule();
      errors.addAll(ruleErrors);
    }

    return errors;
  }

  /// Adiciona um processador customizado
  void addProcessor(IRuleProcessor processor) {
    _processors.add(processor);
  }

  /// Remove um processador
  void removeProcessor(Type processorType) {
    _processors.removeWhere((processor) => processor.runtimeType == processorType);
  }

  /// Encontra o processador apropriado para uma regra
  IRuleProcessor? _getProcessorForRule(BusinessRule rule) {
    return _processors.firstWhere(
      (processor) => processor.canProcess(rule),
      orElse: () => throw UnsupportedError('Nenhum processador encontrado para o tipo de regra ${rule.type}'),
    );
  }

  /// Atualiza o contexto com o resultado de uma regra
  void _updateContextWithResult(Map<String, dynamic> context, BusinessRule rule, dynamic result) {
    switch (rule.type) {
      case RuleType.pricing:
        if (result is double) {
          context['currentPrice'] = result;
        }
        break;
      case RuleType.validation:
        if (result is List<String>) {
          final existingErrors = context['validationErrors'] as List<String>? ?? [];
          existingErrors.addAll(result);
          context['validationErrors'] = existingErrors;
        }
        break;
      case RuleType.visibility:
        if (result is Map<String, bool>) {
          final existingVisibility = context['fieldVisibility'] as Map<String, bool>? ?? {};
          existingVisibility.addAll(result);
          context['fieldVisibility'] = existingVisibility;
        }
        break;
    }
  }
}

/// Interface para processadores de regras específicos
abstract class IRuleProcessor {
  /// Verifica se este processador pode processar a regra
  bool canProcess(BusinessRule rule);

  /// Processa a regra e retorna o resultado
  dynamic processRule(BusinessRule rule, Map<String, dynamic> context);
}

/// Processador para regras de preço
class PricingRuleProcessor implements IRuleProcessor {
  @override
  bool canProcess(BusinessRule rule) => rule is PricingRule;

  @override
  dynamic processRule(BusinessRule rule, Map<String, dynamic> context) {
    if (rule is PricingRule) {
      return rule.execute(context);
    }
    throw ArgumentError('Regra deve ser do tipo PricingRule');
  }
}

/// Processador para regras de validação
class ValidationRuleProcessor implements IRuleProcessor {
  @override
  bool canProcess(BusinessRule rule) => rule is ValidationRule;

  @override
  dynamic processRule(BusinessRule rule, Map<String, dynamic> context) {
    if (rule is ValidationRule) {
      return rule.execute(context);
    }
    throw ArgumentError('Regra deve ser do tipo ValidationRule');
  }
}

/// Processador para regras de visibilidade
class VisibilityRuleProcessor implements IRuleProcessor {
  @override
  bool canProcess(BusinessRule rule) => rule is VisibilityRule;

  @override
  dynamic processRule(BusinessRule rule, Map<String, dynamic> context) {
    if (rule is VisibilityRule) {
      return rule.execute(context);
    }
    throw ArgumentError('Regra deve ser do tipo VisibilityRule');
  }
}

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
