import '../../../models/models.dart';
import 'rule_processor.dart';

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