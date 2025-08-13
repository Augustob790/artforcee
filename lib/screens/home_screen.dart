// ignore_for_file: unused_field
import 'package:flutter/material.dart';
import '../controllers/quote_controller.dart';
import '../widgets/dynamic_form_widget.dart';
import '../widgets/product_selector_widget.dart';
import '../widgets/quote_summary_widget.dart';
import 'quotes_list_screen.dart';

class HomeScreen extends StatefulWidget {
  final QuoteController quoteController;

  const HomeScreen({
    super.key,
    required this.quoteController,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    widget.quoteController.addListener(_onQuoteControllerChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    widget.quoteController.removeListener(_onQuoteControllerChanged);
    super.dispose();
  }

  void _onQuoteControllerChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Orçamentos Dinâmicos'),
            Text('AltForce - Teste Prático', style: TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _showQuotesList,
            icon: Badge(
              label: Text('${widget.quoteController.quotes.length}'),
              child: const Icon(Icons.receipt_long),
            ),
            tooltip: 'Ver Orçamentos',
          ),
          IconButton(
            onPressed: _showStatistics,
            icon: const Icon(Icons.analytics),
            tooltip: 'Estatísticas',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.shopping_cart),
              text: 'Criar Orçamento',
            ),
            Tab(
              icon: Icon(Icons.list),
              text: 'Meus Orçamentos',
            ),
          ],
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCreateQuoteTab(),
          _buildQuotesListTab(),
        ],
      ),
    );
  }

  Widget _buildCreateQuoteTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProductSelectorWidget(
            quoteController: widget.quoteController,
            onProductSelected: (product) {
            },
          ),

          const SizedBox(height: 16),

          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 800) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildFormSection(),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: _buildSummarySection(),
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildFormSection(),
                    const SizedBox(height: 16),
                    _buildSummarySection(),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    final formController = widget.quoteController.currentFormController;

    if (formController == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(
                Icons.assignment_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'Selecione um produto',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Escolha um produto acima para configurar o orçamento',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.settings,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Configuração do Produto',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            DynamicFormWidget(
              formController: formController,
              onChanged: () {
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection() {
    return QuoteSummaryWidget(
      quoteController: widget.quoteController,
      onCreateQuote: () {
        _tabController.animateTo(1);
      },
    );
  }

  Widget _buildQuotesListTab() {
    return QuotesListScreen(
      quoteController: widget.quoteController,
    );
  }

  void _showQuotesList() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QuotesListScreen(
          quoteController: widget.quoteController,
        ),
      ),
    );
  }

  void _showStatistics() {
    final stats = widget.quoteController.getQuoteStatistics();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Estatísticas dos Orçamentos'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatRow('Total de Orçamentos:', '${stats['totalQuotes']}'),
              _buildStatRow('Valor Total:', 'R\$ ${stats['totalValue'].toStringAsFixed(2)}'),
              _buildStatRow('Valor Médio:', 'R\$ ${stats['averageValue'].toStringAsFixed(2)}'),
              if (stats['mostUsedProduct'] != null) _buildStatRow('Produto Mais Usado:', '${stats['mostUsedProduct']}'),
              const SizedBox(height: 16),
              Text(
                'Distribuição por Tipo:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              ...((stats['productTypeDistribution'] as Map<String, int>).entries.map(
                    (entry) => _buildStatRow('${entry.key}:', '${entry.value}'),
                  )),
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

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: Text(label),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
