import 'package:flutter/material.dart';

import '../../../controllers/controllers.dart';
import '../../../models/models.dart' as model;

class DynamicDropdownWidget extends StatelessWidget {
  final model.DropdownFormField field;
  final FormController controller;

  const DynamicDropdownWidget({
    super.key,
    required this.field,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final value = controller.getFieldValue(field.name);
    final errors = controller.getFieldErrors(field.name);
    final hasError = errors.isNotEmpty;

    return DropdownButtonFormField<dynamic>(
      value: value,
      decoration: InputDecoration(
        labelText: field.label,
        helperText: field.helpText,
        errorText: hasError ? errors.first : null,
        border: const OutlineInputBorder(),
        suffixIcon: field.isRequired ? const Icon(Icons.star, color: Colors.red, size: 12) : null,
      ),
      items: field.options
          .where((option) => option.isEnabled)
          .map(
            (option) => DropdownMenuItem<dynamic>(
              value: option.value,
              child: Text(option.label),
            ),
          )
          .toList(),
      onChanged: field.isEnabled ? (value) => controller.updateField(field.name, value) : null,
      validator: (value) {
        final fieldErrors = field.validate(value);
        return fieldErrors.isNotEmpty ? fieldErrors.first : null;
      },
    );
  }
}
