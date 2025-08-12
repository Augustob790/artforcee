import '../base_model.dart';

/// Enumeração dos tipos de campo de formulário
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

/// Classe abstrata base para campos de formulário dinâmico
abstract class FormField extends BaseModel {
  /// Nome do campo (usado como chave)
  final String name;
  
  /// Label exibido para o usuário
  final String label;
  
  /// Tipo do campo
  final FieldType type;
  
  /// Se o campo é obrigatório
  final bool isRequired;
  
  /// Se o campo está visível
  bool isVisible;
  
  /// Se o campo está habilitado
  bool isEnabled;
  
  /// Valor padrão do campo
  final dynamic defaultValue;
  
  /// Texto de ajuda/dica
  final String? helpText;
  
  /// Ordem de exibição no formulário
  final int order;

  FormField({
    required super.id,
    required this.name,
    required this.label,
    required this.type,
    this.isRequired = false,
    this.isVisible = true,
    this.isEnabled = true,
    this.defaultValue,
    this.helpText,
    this.order = 0,
    super.createdAt,
    super.updatedAt,
  });

  /// Valida o valor do campo
  List<String> validate(dynamic value);
  
  /// Renderiza o widget apropriado para este campo
  /// Retorna um Map com as propriedades necessárias para o widget
  Map<String, dynamic> getWidgetProperties();

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'label': label,
      'type': type.name,
      'isRequired': isRequired,
      'isVisible': isVisible,
      'isEnabled': isEnabled,
      'defaultValue': defaultValue,
      'helpText': helpText,
      'order': order,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

/// Campo de texto
class TextFormField extends FormField {
  /// Número máximo de caracteres
  final int? maxLength;
  
  /// Número mínimo de caracteres
  final int? minLength;
  
  /// Padrão regex para validação
  final String? pattern;
  
  /// Máximo de linhas (para textarea)
  final int maxLines;

  TextFormField({
    required super.id,
    required super.name,
    required super.label,
    super.isRequired,
    super.isVisible,
    super.isEnabled,
    super.defaultValue,
    super.helpText,
    super.order,
    super.createdAt,
    super.updatedAt,
    this.maxLength,
    this.minLength,
    this.pattern,
    this.maxLines = 1,
  }) : super(type: FieldType.text);

  @override
  List<String> validate(dynamic value) {
    List<String> errors = [];
    final stringValue = value?.toString() ?? '';
    
    if (isRequired && stringValue.isEmpty) {
      errors.add('$label é obrigatório');
    }
    
    if (stringValue.isNotEmpty) {
      if (minLength != null && stringValue.length < minLength!) {
        errors.add('$label deve ter pelo menos $minLength caracteres');
      }
      
      if (maxLength != null && stringValue.length > maxLength!) {
        errors.add('$label deve ter no máximo $maxLength caracteres');
      }
      
      if (pattern != null) {
        final regex = RegExp(pattern!);
        if (!regex.hasMatch(stringValue)) {
          errors.add('$label não atende ao formato esperado');
        }
      }
    }
    
    return errors;
  }

  @override
  Map<String, dynamic> getWidgetProperties() {
    return {
      'name': name,
      'label': label,
      'isRequired': isRequired,
      'isVisible': isVisible,
      'isEnabled': isEnabled,
      'defaultValue': defaultValue,
      'helpText': helpText,
      'maxLength': maxLength,
      'minLength': minLength,
      'pattern': pattern,
      'maxLines': maxLines,
    };
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll({
      'maxLength': maxLength,
      'minLength': minLength,
      'pattern': pattern,
      'maxLines': maxLines,
    });
    return map;
  }
}

/// Campo numérico
class NumberFormField extends FormField {
  /// Valor mínimo
  final num? minValue;
  
  /// Valor máximo
  final num? maxValue;
  
  /// Número de casas decimais
  final int decimalPlaces;
  
  /// Se aceita apenas números inteiros
  final bool isInteger;

  NumberFormField({
    required super.id,
    required super.name,
    required super.label,
    super.isRequired,
    super.isVisible,
    super.isEnabled,
    super.defaultValue,
    super.helpText,
    super.order,
    super.createdAt,
    super.updatedAt,
    this.minValue,
    this.maxValue,
    this.decimalPlaces = 2,
    this.isInteger = false,
  }) : super(type: FieldType.number);

  @override
  List<String> validate(dynamic value) {
    List<String> errors = [];
    
    if (isRequired && (value == null || value.toString().isEmpty)) {
      errors.add('$label é obrigatório');
      return errors;
    }
    
    if (value != null && value.toString().isNotEmpty) {
      final numValue = num.tryParse(value.toString());
      
      if (numValue == null) {
        errors.add('$label deve ser um número válido');
        return errors;
      }
      
      if (isInteger && numValue != numValue.toInt()) {
        errors.add('$label deve ser um número inteiro');
      }
      
      if (minValue != null && numValue < minValue!) {
        errors.add('$label deve ser maior ou igual a $minValue');
      }
      
      if (maxValue != null && numValue > maxValue!) {
        errors.add('$label deve ser menor ou igual a $maxValue');
      }
    }
    
    return errors;
  }

  @override
  Map<String, dynamic> getWidgetProperties() {
    return {
      'name': name,
      'label': label,
      'isRequired': isRequired,
      'isVisible': isVisible,
      'isEnabled': isEnabled,
      'defaultValue': defaultValue,
      'helpText': helpText,
      'minValue': minValue,
      'maxValue': maxValue,
      'decimalPlaces': decimalPlaces,
      'isInteger': isInteger,
    };
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll({
      'minValue': minValue,
      'maxValue': maxValue,
      'decimalPlaces': decimalPlaces,
      'isInteger': isInteger,
    });
    return map;
  }
}

/// Campo de lista suspensa (dropdown)
class DropdownFormField extends FormField {
  /// Opções disponíveis
  final List<DropdownOption> options;
  
  /// Se permite múltipla seleção
  final bool allowMultiple;

  DropdownFormField({
    required super.id,
    required super.name,
    required super.label,
    super.isRequired,
    super.isVisible,
    super.isEnabled,
    super.defaultValue,
    super.helpText,
    super.order,
    super.createdAt,
    super.updatedAt,
    required this.options,
    this.allowMultiple = false,
  }) : super(type: FieldType.dropdown);

  @override
  List<String> validate(dynamic value) {
    List<String> errors = [];
    
    if (isRequired && (value == null || (value is List && value.isEmpty) || value.toString().isEmpty)) {
      errors.add('$label é obrigatório');
      return errors;
    }
    
    if (value != null) {
      if (allowMultiple && value is List) {
        for (final item in value) {
          if (!options.any((option) => option.value == item)) {
            errors.add('Valor inválido selecionado em $label');
            break;
          }
        }
      } else if (!allowMultiple) {
        if (!options.any((option) => option.value == value)) {
          errors.add('Valor inválido selecionado em $label');
        }
      }
    }
    
    return errors;
  }

  @override
  Map<String, dynamic> getWidgetProperties() {
    return {
      'name': name,
      'label': label,
      'isRequired': isRequired,
      'isVisible': isVisible,
      'isEnabled': isEnabled,
      'defaultValue': defaultValue,
      'helpText': helpText,
      'options': options.map((option) => option.toMap()).toList(),
      'allowMultiple': allowMultiple,
    };
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll({
      'options': options.map((option) => option.toMap()).toList(),
      'allowMultiple': allowMultiple,
    });
    return map;
  }
}

/// Opção para campo dropdown
class DropdownOption {
  /// Valor da opção
  final dynamic value;
  
  /// Texto exibido para o usuário
  final String label;
  
  /// Se a opção está habilitada
  final bool isEnabled;

  DropdownOption({
    required this.value,
    required this.label,
    this.isEnabled = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'value': value,
      'label': label,
      'isEnabled': isEnabled,
    };
  }
}

/// Campo de data
class DateFormField extends FormField {
  /// Data mínima permitida
  final DateTime? minDate;
  
  /// Data máxima permitida
  final DateTime? maxDate;
  
  /// Formato de exibição da data
  final String dateFormat;

  DateFormField({
    required super.id,
    required super.name,
    required super.label,
    super.isRequired,
    super.isVisible,
    super.isEnabled,
    super.defaultValue,
    super.helpText,
    super.order,
    super.createdAt,
    super.updatedAt,
    this.minDate,
    this.maxDate,
    this.dateFormat = 'dd/MM/yyyy',
  }) : super(type: FieldType.date);

  @override
  List<String> validate(dynamic value) {
    List<String> errors = [];
    
    if (isRequired && value == null) {
      errors.add('$label é obrigatório');
      return errors;
    }
    
    if (value != null) {
      DateTime? dateValue;
      
      if (value is DateTime) {
        dateValue = value;
      } else if (value is String) {
        dateValue = DateTime.tryParse(value);
      }
      
      if (dateValue == null) {
        errors.add('$label deve ser uma data válida');
        return errors;
      }
      
      if (minDate != null && dateValue.isBefore(minDate!)) {
        errors.add('$label deve ser posterior a ${minDate!.day}/${minDate!.month}/${minDate!.year}');
      }
      
      if (maxDate != null && dateValue.isAfter(maxDate!)) {
        errors.add('$label deve ser anterior a ${maxDate!.day}/${maxDate!.month}/${maxDate!.year}');
      }
    }
    
    return errors;
  }

  @override
  Map<String, dynamic> getWidgetProperties() {
    return {
      'name': name,
      'label': label,
      'isRequired': isRequired,
      'isVisible': isVisible,
      'isEnabled': isEnabled,
      'defaultValue': defaultValue,
      'helpText': helpText,
      'minDate': minDate?.toIso8601String(),
      'maxDate': maxDate?.toIso8601String(),
      'dateFormat': dateFormat,
    };
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll({
      'minDate': minDate?.toIso8601String(),
      'maxDate': maxDate?.toIso8601String(),
      'dateFormat': dateFormat,
    });
    return map;
  }
}

