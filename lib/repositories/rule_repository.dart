import '../models/models.dart';
import 'repository.dart';

/// Repositório específico para regras de negócio
class BusinessRuleRepository extends InMemoryRepository<BusinessRule> {
  /// Busca regras por tipo
  Future<List<BusinessRule>> findByType(RuleType type) async {
    return findWhere({'type': type.name});
  }
  
  /// Busca regras ativas
  Future<List<BusinessRule>> findActive() async {
    return findWhere({'isActive': true});
  }
  
  /// Busca regras por prioridade
  Future<List<BusinessRule>> findByPriority(RulePriority priority) async {
    return findWhere({'priority': priority.value});
  }
  
  /// Busca regras ordenadas por prioridade (maior prioridade primeiro)
  Future<List<BusinessRule>> findAllOrderedByPriority() async {
    final rules = await findAll();
    rules.sort((a, b) => b.priority.value.compareTo(a.priority.value));
    return rules;
  }
  
  /// Busca regras aplicáveis a um contexto específico
  Future<List<BusinessRule>> findApplicableRules(Map<String, dynamic> context) async {
    final activeRules = await findActive();
    return activeRules.where((rule) => rule.shouldApply(context)).toList();
  }
}