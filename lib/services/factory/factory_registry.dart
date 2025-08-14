import '../../models/base_model.dart';
import '../../models/fields/form_field.dart';
import '../../models/products/product.dart';
import '../../models/rules/business_rule.dart';
import 'business_rule_factory.dart';
import 'factory_service.dart';
import 'form_field_factory.dart';
import 'product_factory.dart';

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