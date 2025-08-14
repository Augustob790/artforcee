import 'package:flutter/material.dart';

import '../controllers/quote_controller.dart';
import '../mixins/mixins.dart';
import '../models/quote/quote_model.dart';
import '../widgets/utils/quote_utils.dart';

class QuotesListScreen extends StatefulWidget {
  final QuoteController quoteController;

  const QuotesListScreen({
    super.key,
    required this.quoteController,
  });

  @override
  State<QuotesListScreen> createState() => _QuotesListScreenState();
}

class _QuotesListScreenState extends State<QuotesListScreen> with FormatterMixin {
  @override
  void initState() {
    super.initState();
    widget.quoteController.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.quoteController.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final quotes = widget.quoteController.quotes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Orçamentos'),
        actions: [
          if (quotes.isNotEmpty)
            PopupMenuButton<String>(
              onSelected: _handleMenuAction,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'export',
                  child: ListTile(
                    leading: Icon(Icons.download),
                    title: Text('Exportar'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'clear',
                  child: ListTile(
                    leading: Icon(Icons.clear_all),
                    title: Text('Limpar Todos'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
        ],
      ),
      body: quotes.isEmpty ? _buildEmptyState() : _buildQuotesList(quotes),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 96,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              'Nenhum orçamento criado',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              'Crie seu primeiro orçamento selecionando um produto e configurando suas opções.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Criar Orçamento'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuotesList(List<Quote> quotes) {
    return Column(
      children: [
        _buildHeader(quotes),

        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: quotes.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final quote = quotes[quotes.length - 1 - index];
              return _buildQuoteCard(quote, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(List<Quote> quotes) {
    final totalValue = quotes.fold<double>(0.0, (sum, quote) => sum + quote.finalPrice);
    final averageValue = totalValue / quotes.length;

    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.blue.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatColumn(
              'Total de Orçamentos',
              '${quotes.length}',
              Icons.receipt_long,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.blue.shade300,
          ),
          Expanded(
            child: _buildStatColumn(
              'Valor Total',
              formatCurrency(totalValue),
              Icons.attach_money,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.blue.shade300,
          ),
          Expanded(
            child: _buildStatColumn(
              'Valor Médio',
              formatCurrency(averageValue),
              Icons.trending_up,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue.shade700),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade700,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.blue.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildQuoteCard(Quote quote, int index) {
    return Card(
      elevation: 2,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: QuoteUtils.getTypeColor(quote.product.type),
          child: Text(
            '${index + 1}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          quote.product.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(quote.product.type.displayName),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  formatDate(quote.createdAt, format: 'dd/MM/yyyy HH:mm'),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              formatCurrency(quote.finalPrice),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (action) => _handleQuoteAction(action, quote),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'details',
                  child: ListTile(
                    leading: Icon(Icons.info),
                    title: Text('Detalhes'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text('Excluir', style: TextStyle(color: Colors.red)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
              child: Icon(Icons.more_vert, color: Colors.grey.shade600),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildQuoteDetails(quote),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteDetails(Quote quote) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detalhes da Configuração',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: quote.formData.entries.map((entry) {
              final displayValue = formatFieldValue(entry.key, entry.value);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        '${getFieldLabel(entry.key)}:',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(displayValue),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'export':
        _exportQuotes();
        break;
      case 'clear':
        _clearAllQuotes();
        break;
    }
  }

  void _handleQuoteAction(String action, Quote quote) {
    switch (action) {
      case 'details':
        _showQuoteDetails(quote);
        break;
      case 'delete':
        _deleteQuote(quote);
        break;
    }
  }

  void _exportQuotes() {
    final data = widget.quoteController.exportQuotes();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exportar Orçamentos'),
        content: Text('${data.length} orçamentos seriam exportados para JSON.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _clearAllQuotes() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar Todos os Orçamentos'),
        content: const Text('Esta ação não pode ser desfeita. Deseja continuar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              widget.quoteController.clearQuotes();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Todos os orçamentos foram removidos'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );
  }

  void _deleteQuote(Quote quote) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Orçamento'),
        content: Text('Deseja excluir o orçamento de "${quote.product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              widget.quoteController.removeQuote(quote.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Orçamento excluído'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _showQuoteDetails(Quote quote) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(quote.product.name),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tipo: ${quote.product.type.displayName}'),
              Text('Categoria: ${quote.product.category}'),
              Text('Criado em: ${formatDate(quote.createdAt, format: 'dd/MM/yyyy HH:mm')}'),
              Text('Valor Final: ${formatCurrency(quote.finalPrice)}'),
              const SizedBox(height: 16),
              const Text('Configurações:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...quote.formData.entries.map(
                (entry) => Text(
                  '${getFieldLabel(entry.key)}: ${formatFieldValue(entry.key, entry.value)}',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}
