  import 'package:flutter/material.dart';

import '../../../controllers/controllers.dart';
import '../../../models/models.dart' as model;

class DynamicTextFieldWidget extends StatelessWidget {
  final model.TextFormField field;
  final FormController controller;

  const DynamicTextFieldWidget({
    super.key,
    required this.field,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final value = controller.getFieldValue<String>(field.name) ?? '';
    final errors = controller.getFieldErrors(field.name);
    final hasError = errors.isNotEmpty;

    return TextFormField(
      initialValue: value,
      enabled: field.isEnabled,
      maxLength: field.maxLength,
      maxLines: field.maxLines,
      decoration: InputDecoration(
        labelText: field.label,
        helperText: field.helpText,
        errorText: hasError ? errors.first : null,
        border: const OutlineInputBorder(),
        suffixIcon: field.isRequired ? const Icon(Icons.star, color: Colors.red, size: 12) : null,
      ),
      onChanged: (value) => controller.updateField(field.name, value),
      validator: (value) {
        final fieldErrors = field.validate(value);
        return fieldErrors.isNotEmpty ? fieldErrors.first : null;
      },
    );
  }
}

