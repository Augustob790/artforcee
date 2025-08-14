import '../../../models/models.dart';
import 'rule_processor.dart';

/// Processador para regras de validação
class ValidationRuleProcessor implements IRuleProcessor {
  @override
  bool canProcess(BusinessRule rule) => rule is ValidationRule;

  @override
  dynamic processRule(BusinessRule rule, Map<String, dynamic> context) {
    if (rule is ValidationRule) {
      return rule.execute(context);
    }
    throw ArgumentError('Regra deve ser do tipo ValidationRule');
  }
}
