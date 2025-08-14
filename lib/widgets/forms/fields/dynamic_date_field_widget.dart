import 'package:flutter/material.dart';

import '../../../controllers/controllers.dart';
import '../../../mixins/mixins.dart';
import '../../../models/models.dart' as model;

class DynamicDateFieldWidget extends StatelessWidget with FormatterMixin {
  final model.DateFormField field;
  final FormController controller;

  const DynamicDateFieldWidget({
    super.key,
    required this.field,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final value = controller.getFieldValue<DateTime>(field.name);
    final errors = controller.getFieldErrors(field.name);
    final hasError = errors.isNotEmpty;

    return TextFormField(
      enabled: field.isEnabled,
      readOnly: true,
      controller: TextEditingController(
        text: controller.deliveryDate == null ? '' : formatDate(controller.deliveryDate!),
      ),
      decoration: InputDecoration(
        labelText: field.label,
        helperText: field.helpText,
        errorText: hasError ? errors.first : null,
        border: const OutlineInputBorder(),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (field.isRequired) const Icon(Icons.star, color: Colors.red, size: 12),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
      onTap: field.isEnabled ? () => _selectDate(context) : null,
      validator: (value) {
        final fieldErrors = field.validate(value);
        return fieldErrors.isNotEmpty ? fieldErrors.first : null;
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (selectedDate != null) {
      controller.updateField(field.name, selectedDate);
    }
  }
}

