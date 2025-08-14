// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import '../controllers/controllers.dart';
import '../mixins/mixins.dart';
import 'products/products.dart';
import 'utils/quote_utils.dart';

class QuoteSummaryWidget extends StatefulWidget {
  final QuoteController quoteController;
  final VoidCallback? onCreateQuote;

  const QuoteSummaryWidget({
    super.key,
    required this.quoteController,
    this.onCreateQuote,
  });

  @override
  State<QuoteSummaryWidget> createState() => _QuoteSummaryWidgetState();
}

class _QuoteSummaryWidgetState extends State<QuoteSummaryWidget> with FormatterMixin {
  @override
  void initState() {
    super.initState();
    widget.quoteController.addListener(_onControllerChanged);
    widget.quoteController.currentFormController?.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    widget.quoteController.removeListener(_onControllerChanged);
    widget.quoteController.currentFormController?.removeListener(_onFormChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    setState(() {});

    // Atualiza listener do form controller se mudou
    final newController = widget.quoteController.currentFormController;
    if (newController != null) {
      newController.addListener(_onFormChanged);
    }
  }

  void _onFormChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final selectedProduct = widget.quoteController.selectedProduct;
    final formController = widget.quoteController.currentFormController;

    if (selectedProduct == null || formController == null) {
      return const HeaderCard(isEmpty: true);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildProductInfo(selectedProduct),
            const SizedBox(height: 16),
            _buildFormSummary(formController),
            const SizedBox(height: 16),
            _buildPricingDetails(selectedProduct, formController),
            const SizedBox(height: 24),
            _buildActionButtons(formController),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          Icons.receipt_long,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(width: 8),
        Text(
          'Resumo do Orçamento',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ],
    );
  }

  Widget _buildProductInfo(dynamic product) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Produto Selecionado',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            product.name,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            product.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Chip(
                label: Text(product.type.displayName),
                backgroundColor: QuoteUtils.getTypeColor(product.type).withOpacity(0.1),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              const SizedBox(width: 8),
              Chip(
                label: Text(product.category),
                backgroundColor: Colors.grey.shade200,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormSummary(FormController formController) {
    final formData = formController.formData;
    final visibleFields = formController.fields
        .where((field) => formController.isFieldVisible(field.name))
        .where((field) => formData.containsKey(field.name) && formData[field.name] != null)
        .toList();

    if (visibleFields.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Configurações',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        ...visibleFields.map((field) {
          final value = formData[field.name];
          final displayValue = formatFieldValue(field.name, value);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    '${field.label}:',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    displayValue,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPricingDetails(dynamic product, FormController formController) {
    final quantity = formController.getFieldValue<int>('quantity') ?? 1;
    final basePrice = product.basePrice;
    final totalBasePrice = basePrice * quantity;
    final finalPrice = formController.currentPrice;
    final discount = totalBasePrice - finalPrice;
    final hasDiscount = discount > 0;
    final hasSurcharge = discount < 0;

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detalhes do Preço',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),

          // Preço unitário
          _buildPriceRow(
            'Preço unitário:',
            formatCurrency(basePrice),
            isSubtotal: true,
          ),

          // Quantidade
          _buildPriceRow(
            'Quantidade:',
            formatNumber(quantity),
            isSubtotal: true,
          ),

          // Subtotal
          _buildPriceRow(
            'Subtotal:',
            formatCurrency(totalBasePrice),
            isSubtotal: true,
          ),

          // Desconto ou taxa adicional
          if (hasDiscount)
            _buildPriceRow(
              'Desconto:',
              '- ${formatCurrency(discount)}',
              color: Colors.green.shade700,
              isSubtotal: true,
            ),

          if (hasSurcharge)
            _buildPriceRow(
              'Taxa adicional:',
              '+ ${formatCurrency(-discount)}',
              color: Colors.orange.shade700,
              isSubtotal: true,
            ),

          const Divider(),

          // Total final
          _buildPriceRow(
            'Total Final:',
            formatCurrency(finalPrice),
            isFinal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    String value, {
    Color? color,
    bool isSubtotal = false,
    bool isFinal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: isFinal ? FontWeight.bold : FontWeight.normal,
                    fontSize: isFinal ? 16 : null,
                  ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: isFinal ? FontWeight.bold : FontWeight.w500,
                  fontSize: isFinal ? 16 : null,
                  color: color ?? (isFinal ? Colors.green.shade700 : null),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(FormController formController) {
    final canSubmit = formController.canSubmit;
    final hasErrors = !formController.isValid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hasErrors)
          Container(
            padding: const EdgeInsets.all(8.0),
            margin: const EdgeInsets.only(bottom: 16.0),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(4.0),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.warning, color: Colors.red.shade700, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Corrija os erros antes de criar o orçamento',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ElevatedButton.icon(
          onPressed: canSubmit ? _createQuote : null,
          icon: const Icon(Icons.add_shopping_cart),
          label: const Text('Criar Orçamento'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _recalculatePrice(formController),
          icon: const Icon(Icons.refresh),
          label: const Text('Recalcular Preço'),
        ),
      ],
    );
  }

  Future<void> _createQuote() async {
    final quote = await widget.quoteController.createQuote();

    if (quote != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Orçamento criado com sucesso! Total: ${formatCurrency(quote.finalPrice)}'),
          backgroundColor: Colors.green,
          action: widget.onCreateQuote != null
              ? SnackBarAction(
                  label: 'Ver Orçamentos',
                  onPressed: widget.onCreateQuote!,
                )
              : null,
        ),
      );
    }
  }

  Future<void> _recalculatePrice(FormController formController) async {
    await formController.calculateFinalPrice();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preço recalculado com sucesso!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
