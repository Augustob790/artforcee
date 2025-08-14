import '../models.dart';

/// Regra de visibilidade - controla quais campos são visíveis
class VisibilityRule extends BusinessRule {
  final List<String> targetFields;
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
