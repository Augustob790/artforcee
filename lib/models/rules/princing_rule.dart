import '../../mixins/calculator_mixin.dart';
import 'business_rule.dart';

/// Tipos de modificação de preço
enum PricingModificationType {
  discount('Desconto'),
  surcharge('Taxa Adicional'),
  multiplier('Multiplicador'),
  fixed('Preço Fixo');

  const PricingModificationType(this.displayName);
  final String displayName;
}

/// Regra de preço - modifica o preço do produto
class PricingRule extends BusinessRule with CalculatorMixin {
  final PricingModificationType modificationType;
  final double value;
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
  double execute(Map<String, dynamic> context) {
    final currentPrice = context['currentPrice'] as double? ?? 0.0;

    switch (modificationType) {
      case PricingModificationType.discount:
        if (isPercentage) {
          return calculatePercentageDiscount(currentPrice, value);
        } else {
          return calculateFixedDiscount(currentPrice, value);
        }
      case PricingModificationType.surcharge:
        if (isPercentage) {
          return calculatePercentageSurcharge(currentPrice, value);
        } else {
          return calculateFixedSurcharge(currentPrice, value);
        }
      case PricingModificationType.multiplier:
        return  currentPrice * value;
      case PricingModificationType.fixed:
        return value;
    }
  }

  // O restante da classe (validateRule e toMap) permanece inalterado
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
