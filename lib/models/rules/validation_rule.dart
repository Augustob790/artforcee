import 'business_rule.dart';

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
