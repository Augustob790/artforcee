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
  bool shouldApply(Map<String, dynamic> context);
  
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

/// Regra de preço - modifica o preço do produto
class PricingRule extends BusinessRule {
  /// Tipo de modificação (multiplicador, desconto, taxa adicional)
  final PricingModificationType modificationType;
  
  /// Valor da modificação
  final double value;
  
  /// Se o valor é percentual ou absoluto
  final bool isPercentage;

  PricingRule({
    required super.id,
    required super.name,
    required super.description,
    required super.priority,
    super.isActive,
    super.conditions,
    super.createdAt,
    super.updatedAt,
    required this.modificationType,
    required this.value,
    this.isPercentage = true,
  }) : super(type: RuleType.pricing);

  @override
  bool shouldApply(Map<String, dynamic> context) {
    if (!isActive) return false;
    
    // Verificar todas as condições
    for (final entry in conditions.entries) {
      final contextValue = context[entry.key];
      final conditionValue = entry.value;
      
      if (!_evaluateCondition(contextValue, conditionValue)) {
        return false;
      }
    }
    
    return true;
  }

  @override
  double execute(Map<String, dynamic> context) {
    final currentPrice = context['currentPrice'] as double? ?? 0.0;
    
    switch (modificationType) {
      case PricingModificationType.discount:
        if (isPercentage) {
          return currentPrice * (1 - value / 100);
        } else {
          return currentPrice - value;
        }
      case PricingModificationType.surcharge:
        if (isPercentage) {
          return currentPrice * (1 + value / 100);
        } else {
          return currentPrice + value;
        }
      case PricingModificationType.multiplier:
        return currentPrice * value;
      case PricingModificationType.fixed:
        return value;
    }
  }

  @override
  List<String> validateRule() {
    List<String> errors = [];
    
    if (value < 0) {
      errors.add('Valor da regra não pode ser negativo');
    }
    
    if (isPercentage && value > 100 && modificationType == PricingModificationType.discount) {
      errors.add('Desconto percentual não pode ser maior que 100%');
    }
    
    return errors;
  }

  bool _evaluateCondition(dynamic contextValue, dynamic conditionValue) {
    if (conditionValue is Map) {
      // Condições complexas como >= 50
      final operator = conditionValue['operator'] as String?;
      final value = conditionValue['value'];
      
      switch (operator) {
        case '>=':
          return (contextValue as num) >= (value as num);
        case '<=':
          return (contextValue as num) <= (value as num);
        case '>':
          return (contextValue as num) > (value as num);
        case '<':
          return (contextValue as num) < (value as num);
        case '==':
          return contextValue == value;
        case '!=':
          return contextValue != value;
        default:
          return contextValue == value;
      }
    } else {
      // Condição simples de igualdade
      return contextValue == conditionValue;
    }
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll({
      'modificationType': modificationType.name,
      'value': value,
      'isPercentage': isPercentage,
    });
    return map;
  }
}

/// Tipos de modificação de preço
enum PricingModificationType {
  discount('Desconto'),
  surcharge('Taxa Adicional'),
  multiplier('Multiplicador'),
  fixed('Preço Fixo');
  
  const PricingModificationType(this.displayName);
  final String displayName;
}

/// Regra de validação - valida dados do formulário
class ValidationRule extends BusinessRule {
  /// Campos que devem ser validados
  final List<String> targetFields;
  
  /// Tipo de validação
  final ValidationType validationType;
  
  /// Parâmetros específicos da validação
  final Map<String, dynamic> validationParams;

  ValidationRule({
    required super.id,
    required super.name,
    required super.description,
    required super.priority,
    super.isActive,
    super.conditions,
    super.createdAt,
    super.updatedAt,
    required this.targetFields,
    required this.validationType,
    this.validationParams = const {},
  }) : super(type: RuleType.validation);

  @override
  bool shouldApply(Map<String, dynamic> context) {
    if (!isActive) return false;
    
    // Verificar se algum dos campos alvo está presente no contexto
    bool hasTargetField = targetFields.any((field) => context.containsKey(field));
    if (!hasTargetField) return false;
    
    // Verificar condições específicas
    for (final entry in conditions.entries) {
      final contextValue = context[entry.key];
      final conditionValue = entry.value;
      
      if (contextValue != conditionValue) {
        return false;
      }
    }
    
    return true;
  }

  @override
  List<String> execute(Map<String, dynamic> context) {
    List<String> errors = [];
    
    for (final field in targetFields) {
      final value = context[field];
      
      switch (validationType) {
        case ValidationType.required:
          if (value == null || value.toString().isEmpty) {
            errors.add('$field é obrigatório');
          }
          break;
        case ValidationType.minValue:
          final minValue = validationParams['minValue'] as num?;
          if (minValue != null && (value as num?) != null && (value as num) < minValue) {
            errors.add('$field deve ser maior ou igual a $minValue');
          }
          break;
        case ValidationType.maxValue:
          final maxValue = validationParams['maxValue'] as num?;
          if (maxValue != null && (value as num?) != null && (value as num) > maxValue) {
            errors.add('$field deve ser menor ou igual a $maxValue');
          }
          break;
        case ValidationType.pattern:
          final pattern = validationParams['pattern'] as String?;
          if (pattern != null && value != null) {
            final regex = RegExp(pattern);
            if (!regex.hasMatch(value.toString())) {
              errors.add('$field não atende ao formato esperado');
            }
          }
          break;
        case ValidationType.custom:
          // Validação customizada baseada em função
          final customValidator = validationParams['validator'] as Function?;
          if (customValidator != null) {
            final result = customValidator(value, context);
            if (result is String && result.isNotEmpty) {
              errors.add(result);
            }
          }
          break;
      }
    }
    
    return errors;
  }

  @override
  List<String> validateRule() {
    List<String> errors = [];
    
    if (targetFields.isEmpty) {
      errors.add('Regra de validação deve ter pelo menos um campo alvo');
    }
    
    return errors;
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll({
      'targetFields': targetFields,
      'validationType': validationType.name,
      'validationParams': validationParams,
    });
    return map;
  }
}

/// Tipos de validação
enum ValidationType {
  required('Obrigatório'),
  minValue('Valor Mínimo'),
  maxValue('Valor Máximo'),
  pattern('Padrão'),
  custom('Customizada');
  
  const ValidationType(this.displayName);
  final String displayName;
}

/// Regra de visibilidade - controla quais campos são visíveis
class VisibilityRule extends BusinessRule {
  /// Campos que devem ter a visibilidade controlada
  final List<String> targetFields;
  
  /// Se os campos devem ser mostrados ou escondidos quando a regra se aplica
  final bool showFields;

  VisibilityRule({
    required super.id,
    required super.name,
    required super.description,
    required super.priority,
    super.isActive,
    super.conditions,
    super.createdAt,
    super.updatedAt,
    required this.targetFields,
    this.showFields = true,
  }) : super(type: RuleType.visibility);

  @override
  bool shouldApply(Map<String, dynamic> context) {
    if (!isActive) return false;
    
    // Verificar todas as condições
    for (final entry in conditions.entries) {
      final contextValue = context[entry.key];
      final conditionValue = entry.value;
      
      if (contextValue != conditionValue) {
        return false;
      }
    }
    
    return true;
  }

  @override
  Map<String, bool> execute(Map<String, dynamic> context) {
    Map<String, bool> visibility = {};
    
    for (final field in targetFields) {
      visibility[field] = showFields;
    }
    
    return visibility;
  }

  @override
  List<String> validateRule() {
    List<String> errors = [];
    
    if (targetFields.isEmpty) {
      errors.add('Regra de visibilidade deve ter pelo menos um campo alvo');
    }
    
    return errors;
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll({
      'targetFields': targetFields,
      'showFields': showFields,
    });
    return map;
  }
}

