import '../models.dart';

/// Campo numérico
class NumberFormField extends FormField {
  final num? minValue;
  final num? maxValue;
  final int decimalPlaces;
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
