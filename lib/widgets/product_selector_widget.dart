// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:orcamentos_dinamicos/mixins/formatter_mixin.dart';

import '../controllers/quote_controller.dart';
import '../models/products/product.dart';
import 'utils/quote_utils.dart';

/// Widget para seleção de produtos com filtros e busca
class ProductSelectorWidget extends StatefulWidget {
  final QuoteController quoteController;
  final Function(Product)? onProductSelected;

  const ProductSelectorWidget({
    super.key,
    required this.quoteController,
    this.onProductSelected,
  });

  @override
  State<ProductSelectorWidget> createState() => _ProductSelectorWidgetState();
}

class _ProductSelectorWidgetState extends State<ProductSelectorWidget> {
  final TextEditingController _searchController = TextEditingController();
  ProductType? _selectedType;
  String? _selectedCategory;
  List<Product> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _filteredProducts = widget.quoteController.availableProducts;
    widget.quoteController.addListener(_onQuoteControllerChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    widget.quoteController.removeListener(_onQuoteControllerChanged);
    super.dispose();
  }

  void _onQuoteControllerChanged() {
    setState(() {
      _applyFilters();
    });
  }

  void _applyFilters() {
    var products = widget.quoteController.availableProducts;

    // Filtro por tipo
    if (_selectedType != null) {
      products = products.where((p) => p.type == _selectedType).toList();
    }

    // Filtro por categoria
    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      products = products.where((p) => p.category == _selectedCategory).toList();
    }

    // Filtro por busca
    final searchTerm = _searchController.text.trim();
    if (searchTerm.isNotEmpty) {
      products = widget.quoteController.searchProducts(searchTerm);
    }

    _filteredProducts = products;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(),
        const SizedBox(height: 16),
        _buildFilters(),
        const SizedBox(height: 16),
        _buildProductList(),
      ],
    );
  }

  Widget _buildHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selecionar Produto',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Escolha um produto para criar um orçamento',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    final categories = widget.quoteController.availableProducts.map((p) => p.category).toSet().toList()..sort();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filtros',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            // Campo de busca
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar produtos',
                hintText: 'Digite o nome, descrição ou categoria',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (_) {
                setState(() {
                  _applyFilters();
                });
              },
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<ProductType?>(
                    isExpanded: true,
                    value: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de Produto',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<ProductType?>(
                        value: null,
                        child: Text('Todos os tipos'),
                      ),
                      ...ProductType.values.map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type.displayName),
                          )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value;
                        _applyFilters();
                      });
                    },
                  ),
                ),

                const SizedBox(width: 16),

                // Filtro por categoria
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    isExpanded: true,
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Categoria',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Todas as categorias'),
                      ),
                      ...categories.map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                        _applyFilters();
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Botão limpar filtros
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _selectedType = null;
                  _selectedCategory = null;
                  _applyFilters();
                });
              },
              icon: const Icon(Icons.clear),
              label: const Text('Limpar Filtros'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductList() {
    if (widget.quoteController.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_filteredProducts.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'Nenhum produto encontrado',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Tente ajustar os filtros ou termos de busca',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text(
                  'Produtos Disponíveis',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Text(
                  '${_filteredProducts.length} produto(s)',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _filteredProducts.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final product = _filteredProducts[index];
              return ProductTile(
                product: product,
                isSelected: widget.quoteController.selectedProduct == product,
                onTap: () => _selectProduct(product),
              );
            },
          ),
        ],
      ),
    );
  }

  void _selectProduct(Product product) {
    widget.quoteController.selectProduct(product);
    widget.onProductSelected?.call(product);
  }
}

/// Tile individual para exibir um produto
class ProductTile extends StatelessWidget with FormatterMixin {
  final Product product;
  final bool isSelected;
  final VoidCallback? onTap;

  const ProductTile({
    super.key,
    required this.product,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.all(16.0),
      leading: CircleAvatar(
        backgroundColor: QuoteUtils.getTypeColor(product.type),
        child: Icon(
          QuoteUtils.getTypeIcon(product.type),
          color: Colors.white,
        ),
      ),
      title: Text(
        product.name,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(product.description),
          const SizedBox(height: 4),
          Row(
            children: [
              Flexible(
                child: Chip(
                  label: Text(
                    product.type.displayName,
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: QuoteUtils.getTypeColor(product.type).withOpacity(0.1),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Chip(
                  label: Text(
                    product.category,
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: Colors.grey.shade200,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
            formatCurrency(product.basePrice),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
          ),
          if (isSelected)
            Icon(
              Icons.check_circle,
              color: Colors.green.shade700,
              size: 20,
            ),
        ],
      ),
      selected: isSelected,
      selectedTileColor: Colors.green.shade50,
      onTap: onTap,
    );
  }
}
