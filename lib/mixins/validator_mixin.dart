/// Mixin que fornece funcionalidades de validação reutilizáveis
/// Implementa o princípio DRY para validações comuns
mixin ValidatorMixin {
  /// Valida se um valor é obrigatório
  List<String> validateRequired(String fieldName, dynamic value) {
    if (value == null || value.toString().trim().isEmpty) {
      return ['$fieldName é obrigatório'];
    }
    return [];
  }
  
  /// Valida se um valor numérico está dentro de um intervalo
  List<String> validateNumberRange(String fieldName, num? value, {num? min, num? max}) {
    List<String> errors = [];
    
    if (value == null) return errors;
    
    if (min != null && value < min) {
      errors.add('$fieldName deve ser maior ou igual a $min');
    }
    
    if (max != null && value > max) {
      errors.add('$fieldName deve ser menor ou igual a $max');
    }
    
    return errors;
  }
  
  /// Valida se um texto tem o comprimento adequado
  List<String> validateTextLength(String fieldName, String? value, {int? minLength, int? maxLength}) {
    List<String> errors = [];
    
    if (value == null) return errors;
    
    if (minLength != null && value.length < minLength) {
      errors.add('$fieldName deve ter pelo menos $minLength caracteres');
    }
    
    if (maxLength != null && value.length > maxLength) {
      errors.add('$fieldName deve ter no máximo $maxLength caracteres');
    }
    
    return errors;
  }
  
  /// Valida se um valor corresponde a um padrão regex
  List<String> validatePattern(String fieldName, String? value, String pattern, [String? errorMessage]) {
    if (value == null || value.isEmpty) return [];
    
    final regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return [errorMessage ?? '$fieldName não atende ao formato esperado'];
    }
    
    return [];
  }
  
  /// Valida se um email é válido
  List<String> validateEmail(String fieldName, String? value) {
    const emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    return validatePattern(fieldName, value, emailPattern, '$fieldName deve ser um email válido');
  }
  
  /// Valida se uma data está dentro de um intervalo
  List<String> validateDateRange(String fieldName, DateTime? value, {DateTime? minDate, DateTime? maxDate}) {
    List<String> errors = [];
    
    if (value == null) return errors;
    
    if (minDate != null && value.isBefore(minDate)) {
      errors.add('$fieldName deve ser posterior a ${_formatDate(minDate)}');
    }
    
    if (maxDate != null && value.isAfter(maxDate)) {
      errors.add('$fieldName deve ser anterior a ${_formatDate(maxDate)}');
    }
    
    return errors;
  }
  
  /// Valida se um valor está em uma lista de valores permitidos
  List<String> validateInList(String fieldName, dynamic value, List<dynamic> allowedValues) {
    if (value == null) return [];
    
    if (!allowedValues.contains(value)) {
      return ['$fieldName deve ser um dos seguintes valores: ${allowedValues.join(', ')}'];
    }
    
    return [];
  }
  
  /// Valida múltiplos campos de uma vez
  List<String> validateMultiple(Map<String, List<String> Function()> validators) {
    List<String> allErrors = [];
    
    for (final validator in validators.values) {
      allErrors.addAll(validator());
    }
    
    return allErrors;
  }
  
  /// Formata uma data para exibição
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
  
  /// Valida se um número é positivo
  List<String> validatePositiveNumber(String fieldName, num? value) {
    if (value == null) return [];
    
    if (value <= 0) {
      return ['$fieldName deve ser um número positivo'];
    }
    
    return [];
  }
  
  /// Valida se um número é inteiro
  List<String> validateInteger(String fieldName, num? value) {
    if (value == null) return [];
    
    if (value != value.toInt()) {
      return ['$fieldName deve ser um número inteiro'];
    }
    
    return [];
  }
  
  /// Valida se uma string não contém caracteres especiais
  List<String> validateAlphanumeric(String fieldName, String? value) {
    const alphanumericPattern = r'^[a-zA-Z0-9\s]+$';
    return validatePattern(fieldName, value, alphanumericPattern, '$fieldName deve conter apenas letras, números e espaços');
  }
}

