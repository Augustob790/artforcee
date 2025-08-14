import 'package:flutter/material.dart';

import '../controllers/controllers.dart';
import '../mixins/mixins.dart';
import '../models/models.dart' as model;
import 'forms/forms.dart';

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
