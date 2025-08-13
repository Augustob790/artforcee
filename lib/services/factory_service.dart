import '../models/base_model.dart';
import '../models/fields/form_field.dart';
import '../models/products/corporate_product.dart';
import '../models/products/industrial_product.dart';
import '../models/products/product.dart';
import '../models/products/residential_product.dart';
import '../models/rules/business_rule.dart';
import '../models/rules/princing_rule.dart';
import '../models/rules/validation_rule.dart';
import '../models/rules/visibility_rule.dart';

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

/// Fábrica para produtos
class ProductFactory extends FactoryService<Product> {
  @override
  Product create(Map<String, dynamic> data) {
    final errors = validateData(data);
    if (errors.isNotEmpty) {
      throw ArgumentError('Dados inválidos para criação do produto: ${errors.join(', ')}');
    }
    
    final typeString = data['type'] as String;
    final type = ProductType.values.firstWhere(
      (t) => t.name == typeString,
      orElse: () => throw ArgumentError('Tipo de produto inválido: $typeString'),
    );
    
    return Product.createProduct(
      id: data['id'] as String,
      name: data['name'] as String,
      description: data['description'] as String,
      basePrice: (data['basePrice'] as num).toDouble(),
      type: type,
      category: data['category'] as String,
      isActive: data['isActive'] as bool? ?? true,
      specificData: data['specificData'] as Map<String, dynamic>?,
    );
  }

  @override
  bool canCreate(Map<String, dynamic> data) {
    final errors = validateData(data);
    return errors.isEmpty;
  }

  @override
  List<String> getRequiredFields() {
    return ['id', 'name', 'description', 'basePrice', 'type', 'category'];
  }
  
  /// Cria um produto industrial
  IndustrialProduct createIndustrialProduct({
    required String id,
    required String name,
    required String description,
    required double basePrice,
    required String category,
    bool isActive = true,
    required int voltage,
    required String certification,
    required double powerConsumption,
  }) {
    return IndustrialProduct(
      id: id,
      name: name,
      description: description,
      basePrice: basePrice,
      category: category,
      isActive: isActive,
      voltage: voltage,
      certification: certification,
      powerConsumption: powerConsumption,
    );
  }
  
  /// Cria um produto residencial
  ResidentialProduct createResidentialProduct({
    required String id,
    required String name,
    required String description,
    required double basePrice,
    required String category,
    bool isActive = true,
    required String color,
    required int warranty,
    required String energyRating,
  }) {
    return ResidentialProduct(
      id: id,
      name: name,
      description: description,
      basePrice: basePrice,
      category: category,
      isActive: isActive,
      color: color,
      warranty: warranty,
      energyRating: energyRating,
    );
  }
  
  /// Cria um produto corporativo
  CorporateProduct createCorporateProduct({
    required String id,
    required String name,
    required String description,
    required double basePrice,
    required String category,
    bool isActive = true,
    required String licenseType,
    required String supportLevel,
    required int maxUsers,
  }) {
    return CorporateProduct(
      id: id,
      name: name,
      description: description,
      basePrice: basePrice,
      category: category,
      isActive: isActive,
      licenseType: licenseType,
      supportLevel: supportLevel,
      maxUsers: maxUsers,
    );
  }
}

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

/// Fábrica para campos de formulário
class FormFieldFactory extends FactoryService<FormField> {
  @override
  FormField create(Map<String, dynamic> data) {
    final errors = validateData(data);
    if (errors.isNotEmpty) {
      throw ArgumentError('Dados inválidos para criação do campo: ${errors.join(', ')}');
    }
    
    final typeString = data['type'] as String;
    final type = FieldType.values.firstWhere(
      (t) => t.name == typeString,
      orElse: () => throw ArgumentError('Tipo de campo inválido: $typeString'),
    );
    
    switch (type) {
      case FieldType.text:
        return _createTextField(data);
      case FieldType.number:
        return _createNumberField(data);
      case FieldType.dropdown:
        return _createDropdownField(data);
      case FieldType.date:
        return _createDateField(data);
      case FieldType.checkbox:
      case FieldType.radio:
        throw UnimplementedError('Tipo de campo $type ainda não implementado');
    }
  }

  @override
  bool canCreate(Map<String, dynamic> data) {
    final errors = validateData(data);
    return errors.isEmpty;
  }

  @override
  List<String> getRequiredFields() {
    return ['id', 'name', 'label', 'type'];
  }
  
  TextFormField _createTextField(Map<String, dynamic> data) {
    return TextFormField(
      id: data['id'] as String,
      name: data['name'] as String,
      label: data['label'] as String,
      isRequired: data['isRequired'] as bool? ?? false,
      isVisible: data['isVisible'] as bool? ?? true,
      isEnabled: data['isEnabled'] as bool? ?? true,
      defaultValue: data['defaultValue'],
      helpText: data['helpText'] as String?,
      order: data['order'] as int? ?? 0,
      maxLength: data['maxLength'] as int?,
      minLength: data['minLength'] as int?,
      pattern: data['pattern'] as String?,
      maxLines: data['maxLines'] as int? ?? 1,
    );
  }
  
  NumberFormField _createNumberField(Map<String, dynamic> data) {
    return NumberFormField(
      id: data['id'] as String,
      name: data['name'] as String,
      label: data['label'] as String,
      isRequired: data['isRequired'] as bool? ?? false,
      isVisible: data['isVisible'] as bool? ?? true,
      isEnabled: data['isEnabled'] as bool? ?? true,
      defaultValue: data['defaultValue'],
      helpText: data['helpText'] as String?,
      order: data['order'] as int? ?? 0,
      minValue: data['minValue'] as num?,
      maxValue: data['maxValue'] as num?,
      decimalPlaces: data['decimalPlaces'] as int? ?? 2,
      isInteger: data['isInteger'] as bool? ?? false,
    );
  }
  
  DropdownFormField _createDropdownField(Map<String, dynamic> data) {
    final optionsData = data['options'] as List<Map<String, dynamic>>;
    final options = optionsData.map((optionData) => DropdownOption(
      value: optionData['value'],
      label: optionData['label'] as String,
      isEnabled: optionData['isEnabled'] as bool? ?? true,
    )).toList();
    
    return DropdownFormField(
      id: data['id'] as String,
      name: data['name'] as String,
      label: data['label'] as String,
      isRequired: data['isRequired'] as bool? ?? false,
      isVisible: data['isVisible'] as bool? ?? true,
      isEnabled: data['isEnabled'] as bool? ?? true,
      defaultValue: data['defaultValue'],
      helpText: data['helpText'] as String?,
      order: data['order'] as int? ?? 0,
      options: options,
      allowMultiple: data['allowMultiple'] as bool? ?? false,
    );
  }
  
  DateFormField _createDateField(Map<String, dynamic> data) {
    DateTime? minDate;
    DateTime? maxDate;
    
    if (data['minDate'] != null) {
      minDate = DateTime.parse(data['minDate'] as String);
    }
    
    if (data['maxDate'] != null) {
      maxDate = DateTime.parse(data['maxDate'] as String);
    }
    
    return DateFormField(
      id: data['id'] as String,
      name: data['name'] as String,
      label: data['label'] as String,
      isRequired: data['isRequired'] as bool? ?? false,
      isVisible: data['isVisible'] as bool? ?? true,
      isEnabled: data['isEnabled'] as bool? ?? true,
      defaultValue: data['defaultValue'],
      helpText: data['helpText'] as String?,
      order: data['order'] as int? ?? 0,
      minDate: minDate,
      maxDate: maxDate,
      dateFormat: data['dateFormat'] as String? ?? 'dd/MM/yyyy',
    );
  }
}

/// Registro de fábricas para diferentes tipos
class FactoryRegistry {
  static final Map<Type, FactoryService> _factories = {};
  
  /// Registra uma fábrica para um tipo específico
  static void register<T extends BaseModel>(FactoryService<T> factory) {
    _factories[T] = factory;
  }
  
  /// Obtém a fábrica para um tipo específico
  static FactoryService<T>? getFactory<T extends BaseModel>() {
    return _factories[T] as FactoryService<T>?;
  }
  
  /// Cria uma instância usando a fábrica apropriada
  static T? create<T extends BaseModel>(Map<String, dynamic> data) {
    final factory = getFactory<T>();
    return factory?.create(data);
  }
  
  /// Inicializa as fábricas padrão
  static void initializeDefaultFactories() {
    register<Product>(ProductFactory());
    register<BusinessRule>(BusinessRuleFactory());
    register<FormField>(FormFieldFactory());
  }
}

