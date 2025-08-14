import '../../../models/models.dart';
import 'rule_processor.dart';

/// Processador para regras de visibilidade
class VisibilityRuleProcessor implements IRuleProcessor {
  @override
  bool canProcess(BusinessRule rule) => rule is VisibilityRule;

  @override
  dynamic processRule(BusinessRule rule, Map<String, dynamic> context) {
    if (rule is VisibilityRule) {
      return rule.execute(context);
    }
    throw ArgumentError('Regra deve ser do tipo VisibilityRule');
  }
}
