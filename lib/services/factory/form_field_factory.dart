import '../../models/models.dart';
import 'factory_service.dart';

/// Fábrica para campos de formulário
class FormFieldFactory extends FactoryService<FormField> {
  @override
  FormField create(Map<String, dynamic> data) {
    final errors = validateData(data);
    if (errors.isNotEmpty) {
      throw ArgumentError('Dados inválidos para criação do campo: ${errors.join(', ')}');
    }

    final typeString = data['type'] as String;
    final type = FieldType.values.firstWhere(
      (t) => t.name == typeString,
      orElse: () => throw ArgumentError('Tipo de campo inválido: $typeString'),
    );

    switch (type) {
      case FieldType.text:
        return _createTextField(data);
      case FieldType.number:
        return _createNumberField(data);
      case FieldType.dropdown:
        return _createDropdownField(data);
      case FieldType.date:
        return _createDateField(data);
      case FieldType.checkbox:
      case FieldType.radio:
        throw UnimplementedError('Tipo de campo $type ainda não implementado');
    }
  }

  @override
  bool canCreate(Map<String, dynamic> data) {
    final errors = validateData(data);
    return errors.isEmpty;
  }

  @override
  List<String> getRequiredFields() {
    return ['id', 'name', 'label', 'type'];
  }

  TextFormField _createTextField(Map<String, dynamic> data) {
    return TextFormField(
      id: data['id'] as String,
      name: data['name'] as String,
      label: data['label'] as String,
      isRequired: data['isRequired'] as bool? ?? false,
      isVisible: data['isVisible'] as bool? ?? true,
      isEnabled: data['isEnabled'] as bool? ?? true,
      defaultValue: data['defaultValue'],
      helpText: data['helpText'] as String?,
      order: data['order'] as int? ?? 0,
      maxLength: data['maxLength'] as int?,
      minLength: data['minLength'] as int?,
      pattern: data['pattern'] as String?,
      maxLines: data['maxLines'] as int? ?? 1,
    );
  }

  NumberFormField _createNumberField(Map<String, dynamic> data) {
    return NumberFormField(
      id: data['id'] as String,
      name: data['name'] as String,
      label: data['label'] as String,
      isRequired: data['isRequired'] as bool? ?? false,
      isVisible: data['isVisible'] as bool? ?? true,
      isEnabled: data['isEnabled'] as bool? ?? true,
      defaultValue: data['defaultValue'],
      helpText: data['helpText'] as String?,
      order: data['order'] as int? ?? 0,
      minValue: data['minValue'] as num?,
      maxValue: data['maxValue'] as num?,
      decimalPlaces: data['decimalPlaces'] as int? ?? 2,
      isInteger: data['isInteger'] as bool? ?? false,
    );
  }

  DropdownFormField _createDropdownField(Map<String, dynamic> data) {
    final optionsData = data['options'] as List<Map<String, dynamic>>;
    final options = optionsData
        .map((optionData) => DropdownOption(
              value: optionData['value'],
              label: optionData['label'] as String,
              isEnabled: optionData['isEnabled'] as bool? ?? true,
            ))
        .toList();

    return DropdownFormField(
      id: data['id'] as String,
      name: data['name'] as String,
      label: data['label'] as String,
      isRequired: data['isRequired'] as bool? ?? false,
      isVisible: data['isVisible'] as bool? ?? true,
      isEnabled: data['isEnabled'] as bool? ?? true,
      defaultValue: data['defaultValue'],
      helpText: data['helpText'] as String?,
      order: data['order'] as int? ?? 0,
      options: options,
      allowMultiple: data['allowMultiple'] as bool? ?? false,
    );
  }

  DateFormField _createDateField(Map<String, dynamic> data) {
    DateTime? minDate;
    DateTime? maxDate;

    if (data['minDate'] != null) {
      minDate = DateTime.parse(data['minDate'] as String);
    }

    if (data['maxDate'] != null) {
      maxDate = DateTime.parse(data['maxDate'] as String);
    }

    return DateFormField(
      id: data['id'] as String,
      name: data['name'] as String,
      label: data['label'] as String,
      isRequired: data['isRequired'] as bool? ?? false,
      isVisible: data['isVisible'] as bool? ?? true,
      isEnabled: data['isEnabled'] as bool? ?? true,
      defaultValue: data['defaultValue'],
      helpText: data['helpText'] as String?,
      order: data['order'] as int? ?? 0,
      minDate: minDate,
      maxDate: maxDate,
      dateFormat: data['dateFormat'] as String? ?? 'dd/MM/yyyy',
    );
  }
}
