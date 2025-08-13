import 'package:flutter/material.dart';

import '../controllers/form_controller.dart';
import '../mixins/formatter_mixin.dart';
import '../models/fields/form_field.dart' as model;

/// Widget de formulário dinâmico que se reconstrói baseado no tipo de produto
/// Implementa Factory Pattern para criação de widgets específicos
class DynamicFormWidget extends StatefulWidget {
  final FormController formController;
  final VoidCallback? onChanged;

  const DynamicFormWidget({
    super.key,
    required this.formController,
    this.onChanged,
  });

  @override
  State<DynamicFormWidget> createState() => _DynamicFormWidgetState();
}

class _DynamicFormWidgetState extends State<DynamicFormWidget> with FormatterMixin {
  @override
  void initState() {
    super.initState();
    widget.formController.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    widget.formController.removeListener(_onFormChanged);
    super.dispose();
  }

  void _onFormChanged() {
    setState(() {});
    widget.onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.formController.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final visibleFields =
        widget.formController.fields.where((field) => widget.formController.isFieldVisible(field.name)).toList();

    if (visibleFields.isEmpty) {
      return const Center(
        child: Text('Nenhum campo disponível'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...visibleFields.map((field) => _buildFieldWidget(field)),
        const SizedBox(height: 16),
        _buildErrorSummary(),
      ],
    );
  }

  /// Constrói o widget apropriado para cada tipo de campo
  Widget _buildFieldWidget(model.FormField field) {
    final factory = FieldWidgetFactory();
    final fieldWidget = factory.createWidget(field, widget.formController);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: fieldWidget,
    );
  }

  /// Constrói um resumo dos erros de validação
  Widget _buildErrorSummary() {
    final errors = widget.formController.allErrors;

    if (errors.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.error, color: Colors.red.shade700),
                const SizedBox(width: 8),
                Text(
                  'Erros de Validação',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...errors.map((error) => Padding(
                  padding: const EdgeInsets.only(left: 32.0, bottom: 4.0),
                  child: Text(
                    '• $error',
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

/// Factory para criação de widgets de campo específicos
class FieldWidgetFactory {
  /// Cria o widget apropriado baseado no tipo de campo
  Widget createWidget(model.FormField field, FormController controller) {
    switch (field.type) {
      case model.FieldType.text:
        return _createTextWidget(field as model.TextFormField, controller);
      case model.FieldType.number:
        return _createNumberWidget(field as model.NumberFormField, controller);
      case model.FieldType.dropdown:
        return _createDropdownWidget(field as model.DropdownFormField, controller);
      case model.FieldType.date:
        return _createDateWidget(field as model.DateFormField, controller);
      case model.FieldType.checkbox:
      case model.FieldType.radio:
        throw UnimplementedError('Tipo de campo ${field.type} ainda não implementado');
    }
  }

  /// Cria widget para campo de texto
  Widget _createTextWidget(model.TextFormField field, FormController controller) {
    return DynamicTextFieldWidget(
      field: field,
      controller: controller,
    );
  }

  /// Cria widget para campo numérico
  Widget _createNumberWidget(model.NumberFormField field, FormController controller) {
    return DynamicNumberFieldWidget(
      field: field,
      controller: controller,
    );
  }

  /// Cria widget para campo dropdown
  Widget _createDropdownWidget(model.DropdownFormField field, FormController controller) {
    return DynamicDropdownWidget(
      field: field,
      controller: controller,
    );
  }

  /// Cria widget para campo de data
  Widget _createDateWidget(model.DateFormField field, FormController controller) {
    return DynamicDateFieldWidget(
      field: field,
      controller: controller,
    );
  }
}

/// Widget para campo de texto dinâmico
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

/// Widget para campo numérico dinâmico
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

/// Widget para dropdown dinâmico
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
          .map((option) => DropdownMenuItem<dynamic>(
                value: option.value,
                child: Text(option.label),
              ))
          .toList(),
      onChanged: field.isEnabled ? (value) => controller.updateField(field.name, value) : null,
      validator: (value) {
        final fieldErrors = field.validate(value);
        return fieldErrors.isNotEmpty ? fieldErrors.first : null;
      },
    );
  }
}

/// Widget para campo de data dinâmico
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
