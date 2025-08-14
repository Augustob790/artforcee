import 'package:flutter/material.dart';

import '../../../controllers/controllers.dart';
import '../../../models/models.dart' as model;

class DynamicNumberFieldWidget extends StatelessWidget {
  final model.NumberFormField field;
  final FormController controller;

  const DynamicNumberFieldWidget({
    super.key,
    required this.field,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final value = controller.getFieldValue<num>(field.name);
    final errors = controller.getFieldErrors(field.name);
    final hasError = errors.isNotEmpty;

    return TextFormField(
      initialValue: value?.toString() ?? '',
      enabled: field.isEnabled,
      keyboardType: field.isInteger ? TextInputType.number : const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: field.label,
        helperText: field.helpText,
        errorText: hasError ? errors.first : null,
        border: const OutlineInputBorder(),
        suffixIcon: field.isRequired ? const Icon(Icons.star, color: Colors.red, size: 12) : null,
      ),
      onChanged: (value) {
        final numValue = field.isInteger ? int.tryParse(value) : double.tryParse(value);
        controller.updateField(field.name, numValue);
      },
      validator: (value) {
        final numValue = field.isInteger ? int.tryParse(value ?? '') : double.tryParse(value ?? '');
        final fieldErrors = field.validate(numValue);
        return fieldErrors.isNotEmpty ? fieldErrors.first : null;
      },
    );
  }
}
