import '../models.dart';

/// Campo de data
class DateFormField extends FormField {
  final DateTime? minDate;
  final DateTime? maxDate;
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
