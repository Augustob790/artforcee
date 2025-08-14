import '../models.dart';

/// Campo de texto
class TextFormField extends FormField {
  final int? maxLength;
  final int? minLength;
  final String? pattern;
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