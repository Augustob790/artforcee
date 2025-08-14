import '../models.dart';

/// Campo de lista suspensa (dropdown)
class DropdownFormField extends FormField {
  final List<DropdownOption> options;
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