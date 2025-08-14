import '../../models/models.dart';
import 'factory_service.dart';

/// Fábrica para regras de negócio
class BusinessRuleFactory extends FactoryService<BusinessRule> {
  @override
  BusinessRule create(Map<String, dynamic> data) {
    final errors = validateData(data);
    if (errors.isNotEmpty) {
      throw ArgumentError('Dados inválidos para criação da regra: ${errors.join(', ')}');
    }

    final typeString = data['type'] as String;
    final type = RuleType.values.firstWhere(
      (t) => t.name == typeString,
      orElse: () => throw ArgumentError('Tipo de regra inválido: $typeString'),
    );

    final priorityValue = data['priority'] as int;
    final priority = RulePriority.values.firstWhere(
      (p) => p.value == priorityValue,
      orElse: () => throw ArgumentError('Prioridade inválida: $priorityValue'),
    );

    switch (type) {
      case RuleType.pricing:
        return _createPricingRule(data, priority);
      case RuleType.validation:
        return _createValidationRule(data, priority);
      case RuleType.visibility:
        return _createVisibilityRule(data, priority);
    }
  }

  @override
  bool canCreate(Map<String, dynamic> data) {
    final errors = validateData(data);
    return errors.isEmpty;
  }

  @override
  List<String> getRequiredFields() {
    return ['id', 'name', 'description', 'type', 'priority'];
  }

  PricingRule _createPricingRule(Map<String, dynamic> data, RulePriority priority) {
    final modificationTypeString = data['modificationType'] as String;
    final modificationType = PricingModificationType.values.firstWhere(
      (t) => t.name == modificationTypeString,
      orElse: () => throw ArgumentError('Tipo de modificação inválido: $modificationTypeString'),
    );

    return PricingRule(
      id: data['id'] as String,
      name: data['name'] as String,
      description: data['description'] as String,
      priority: priority,
      isActive: data['isActive'] as bool? ?? true,
      conditions: data['conditions'] as Map<String, dynamic>? ?? {},
      modificationType: modificationType,
      value: (data['value'] as num).toDouble(),
      isPercentage: data['isPercentage'] as bool? ?? true,
    );
  }

// DENTRO DE BusinessRuleFactory
  ValidationRule _createValidationRule(Map<String, dynamic> data, RulePriority priority) {
    final validationTypeString = data['validationType'] as String;
    final validationType = ValidationType.values.firstWhere(
      (t) => t.name == validationTypeString,
      orElse: () => throw ArgumentError('Tipo de validação inválido: $validationTypeString'),
    );

    final rawParams = data['validationParams'];
    Map<String, dynamic> safeValidationParams = {};
    if (rawParams is Map) {
      safeValidationParams = rawParams.map(
        (key, value) => MapEntry(key.toString(), value),
      );
    }

    return ValidationRule(
      id: data['id'] as String,
      name: data['name'] as String,
      description: data['description'] as String,
      priority: priority,
      isActive: data['isActive'] as bool? ?? true,
      conditions: data['conditions'] as Map<String, dynamic>? ?? {},
      targetFields: List<String>.from(data['targetFields'] as List),
      validationType: validationType,
      validationParams: safeValidationParams,
    );
  }

  VisibilityRule _createVisibilityRule(Map<String, dynamic> data, RulePriority priority) {
    return VisibilityRule(
      id: data['id'] as String,
      name: data['name'] as String,
      description: data['description'] as String,
      priority: priority,
      isActive: data['isActive'] as bool? ?? true,
      conditions: data['conditions'] as Map<String, dynamic>? ?? {},
      targetFields: List<String>.from(data['targetFields'] as List),
      showFields: data['showFields'] as bool? ?? true,
    );
  }
}
