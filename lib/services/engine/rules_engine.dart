import '../../models/models.dart';
import '../../repositories/rule_repository.dart';
import 'rule_execution_result.dart';
import 'rule_processor/processors.dart';

/// Engine de regras de negócio genérica
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

/// Processador para regras de preço
