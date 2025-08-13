// business_rule.dart
import '../base_model.dart';

/// Enumeração dos tipos de regra de negócio
enum RuleType {
  pricing('Preço'),
  validation('Validação'),
  visibility('Visibilidade');

  const RuleType(this.displayName);
  final String displayName;
}

/// Enumeração das prioridades das regras
enum RulePriority {
  low(1, 'Baixa'),
  medium(2, 'Média'),
  high(3, 'Alta'),
  critical(4, 'Crítica');

  const RulePriority(this.value, this.displayName);
  final int value;
  final String displayName;
}

/// Classe abstrata base para todas as regras de negócio
/// Implementa o padrão Strategy para diferentes tipos de regras
abstract class BusinessRule extends BaseModel {
  /// Nome da regra
  final String name;

  /// Descrição da regra
  final String description;

  /// Tipo da regra
  final RuleType type;

  /// Prioridade da regra (maior valor = maior prioridade)
  final RulePriority priority;

  /// Se a regra está ativa
  final bool isActive;

  /// Condições que devem ser atendidas para a regra ser aplicada
  final Map<String, dynamic> conditions;

  BusinessRule({
    required super.id,
    required this.name,
    required this.description,
    required this.type,
    required this.priority,
    this.isActive = true,
    this.conditions = const {},
    super.createdAt,
    super.updatedAt,
  });

  /// Verifica se a regra deve ser aplicada baseado no contexto
  bool shouldApply(Map<String, dynamic> context) {
    if (!isActive) return false;

    for (final entry in conditions.entries) {
      final contextValue = context[entry.key];
      final conditionValue = entry.value;

      if (!_evaluateCondition(contextValue, conditionValue)) {
        return false;
      }
    }
    return true;
  }

  /// Método auxiliar para avaliar uma única condição
  bool _evaluateCondition(dynamic contextValue, dynamic conditionValue) {
    if (conditionValue is Map) {
      // Condições complexas como >= 50
      final operator = conditionValue['operator'] as String?;
      final value = conditionValue['value'];

      if (contextValue is num && value is num) {
        switch (operator) {
          case '>=':
            return contextValue >= value;
          case '<=':
            return contextValue <= value;
          case '>':
            return contextValue > value;
          case '<':
            return contextValue < value;
          case '==':
            return contextValue == value;
          case '!=':
            return contextValue != value;
          default:
            return contextValue == value;
        }
      }
    } else {
      // Condição simples de igualdade
      return contextValue == conditionValue;
    }
    return false; // Retorna falso se a condição não puder ser avaliada
  }

  /// Executa a regra e retorna o resultado
  /// O tipo de retorno varia baseado no tipo da regra
  dynamic execute(Map<String, dynamic> context);

  /// Valida se a regra está configurada corretamente
  List<String> validateRule();

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'priority': priority.value,
      'isActive': isActive,
      'conditions': conditions,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
