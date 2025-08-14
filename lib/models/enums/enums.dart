/// Enumeração dos tipos de regra de negócio
enum RuleType {
  pricing('Preço'),
  validation('Validação'),
  visibility('Visibilidade');

  const RuleType(this.displayName);
  final String displayName;
}

/// Enumeração das prioridades das regras
enum RulePriority {
  low(1, 'Baixa'),
  medium(2, 'Média'),
  high(3, 'Alta'),
  critical(4, 'Crítica');

  const RulePriority(this.value, this.displayName);
  final int value;
  final String displayName;
}

/// Tipos de modificação de preço
enum PricingModificationType {
  discount('Desconto'),
  surcharge('Taxa Adicional'),
  multiplier('Multiplicador'),
  fixed('Preço Fixo');

  const PricingModificationType(this.displayName);
  final String displayName;
}

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

enum FieldType {
  text('Texto'),
  number('Número'),
  dropdown('Lista Suspensa'),
  date('Data'),
  checkbox('Checkbox'),
  radio('Radio Button');
  
  const FieldType(this.displayName);
  final String displayName;
}