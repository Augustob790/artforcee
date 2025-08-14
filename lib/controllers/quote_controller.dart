import 'package:flutter/foundation.dart';

import '../data/initial_data.dart';
import '../mixins/mixins.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';
import '../services/services.dart';
import 'controllers.dart';

/// Controller principal para gerenciar orçamentos
/// Coordena FormControllers e gerencia o estado global da aplicação
class QuoteController extends ChangeNotifier with CalculatorMixin, FormatterMixin {
  final ProductRepository _productRepository;
  final BusinessRuleRepository _ruleRepository;
  final FormFieldRepository _fieldRepository;
  final RulesEngine<BusinessRule> _rulesEngine;

  // Controllers de formulário para diferentes tipos de produto
  late final FormController<IndustrialProduct> _industrialFormController;
  late final FormController<ResidentialProduct> _residentialFormController;
  late final FormController<CorporateProduct> _corporateFormController;

  // Estado da aplicação
  final List<Product> _availableProducts = [];
  final List<Quote> _quotes = [];
  Product? _selectedProduct;
  FormController? _currentFormController;
  bool _isLoading = false;

  QuoteController(
    this._productRepository,
    this._ruleRepository,
    this._fieldRepository,
    this._rulesEngine,
  ) {
    _initializeControllers();
  }

  @override
  void dispose() {
    _industrialFormController.dispose();
    _residentialFormController.dispose();
    _corporateFormController.dispose();
    super.dispose();
  }

  // Getters
  List<Product> get availableProducts => List.unmodifiable(_availableProducts);
  List<Quote> get quotes => List.unmodifiable(_quotes);
  Product? get selectedProduct => _selectedProduct;
  FormController? get currentFormController => _currentFormController;
  bool get isLoading => _isLoading;
  bool get hasSelectedProduct => _selectedProduct != null;
  bool get canCreateQuote => _currentFormController?.canSubmit ?? false;

  /// Inicializa a aplicação
  Future<void> initialize() async {
    _setLoading(true);

    try {
      await _loadProducts();
      await _initializeBusinessRules();
      await _initializeFormFields();
    } finally {
      _setLoading(false);
    }
  }

  /// Seleciona um produto e inicializa o formulário correspondente
  Future<void> selectProduct(Product product) async {
    if (_selectedProduct == product) return;

    _selectedProduct = product;
    _currentFormController = _getFormControllerForProduct(product);

    if (_currentFormController != null) {
      await _currentFormController!.initializeForm(product as dynamic);
    }

    notifyListeners();
  }

  /// Cria um novo orçamento baseado no formulário atual
  Future<Quote?> createQuote() async {
    if (_currentFormController == null || _selectedProduct == null) {
      return null;
    }

    final isValid = await _currentFormController!.validateForm();
    if (!isValid) {
      return null;
    }

    final finalPrice = await _currentFormController!.calculateFinalPrice();

    final quote = Quote(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      product: _selectedProduct!,
      formData: _currentFormController!.formData,
      finalPrice: finalPrice,
      createdAt: DateTime.now(),
    );

    _quotes.add(quote);
    if (_currentFormController != null) {
      _currentFormController!.resetForm();
    }

    notifyListeners();

    return quote;
  }

  /// Remove um orçamento
  void removeQuote(String quoteId) {
    _quotes.removeWhere((quote) => quote.id == quoteId);
    notifyListeners();
  }

  /// Limpa todos os orçamentos
  void clearQuotes() {
    _quotes.clear();
    notifyListeners();
  }

  /// Obtém produtos por tipo
  List<Product> getProductsByType(ProductType type) {
    return _availableProducts.where((product) => product.type == type).toList();
  }

  /// Obtém produtos por categoria
  List<Product> getProductsByCategory(String category) {
    return _availableProducts.where((product) => product.category == category).toList();
  }

  /// Busca produtos por termo
  List<Product> searchProducts(String searchTerm) {
    if (searchTerm.isEmpty) return _availableProducts;

    return _availableProducts.where((product) {
      return product.name.toLowerCase().contains(searchTerm.toLowerCase()) ||
          product.description.toLowerCase().contains(searchTerm.toLowerCase()) ||
          product.category.toLowerCase().contains(searchTerm.toLowerCase());
    }).toList();
  }

  /// Obtém estatísticas dos orçamentos
  Map<String, dynamic> getQuoteStatistics() {
    if (_quotes.isEmpty) {
      return {
        'totalQuotes': 0,
        'totalValue': 0.0,
        'averageValue': 0.0,
        'mostUsedProduct': null,
        'productTypeDistribution': <String, int>{},
      };
    }

    final totalValue = _quotes.fold<double>(0.0, (sum, quote) => sum + quote.finalPrice);
    final averageValue = totalValue / _quotes.length;

    // Conta produtos mais usados
    final productCount = <String, int>{};
    final typeCount = <String, int>{};

    for (final quote in _quotes) {
      productCount[quote.product.name] = (productCount[quote.product.name] ?? 0) + 1;
      typeCount[quote.product.type.displayName] = (typeCount[quote.product.type.displayName] ?? 0) + 1;
    }

    final mostUsedProduct = productCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    return {
      'totalQuotes': _quotes.length,
      'totalValue': totalValue,
      'averageValue': averageValue,
      'mostUsedProduct': mostUsedProduct,
      'productTypeDistribution': typeCount,
    };
  }

  /// Exporta orçamentos como JSON
  List<Map<String, dynamic>> exportQuotes() {
    return _quotes.map((quote) => quote.toMap()).toList();
  }

  /// Inicializa os controllers de formulário
  void _initializeControllers() {
    _industrialFormController = FormController<IndustrialProduct>(
      _fieldRepository,
      _rulesEngine,
      _productRepository,
    );

    _residentialFormController = FormController<ResidentialProduct>(
      _fieldRepository,
      _rulesEngine,
      _productRepository,
    );

    _corporateFormController = FormController<CorporateProduct>(
      _fieldRepository,
      _rulesEngine,
      _productRepository,
    );
  }

  /// Obtém o controller apropriado para um produto
  FormController? _getFormControllerForProduct(Product product) {
    switch (product.type) {
      case ProductType.industrial:
        return _industrialFormController;
      case ProductType.residential:
        return _residentialFormController;
      case ProductType.corporate:
        return _corporateFormController;
    }
  }

  /// Carrega produtos de exemplo
  Future<void> _loadProducts() async {
    final factory = ProductFactory();

    final products = factory.createMultiple(initialProductsData);

    await _productRepository.saveAll(products);

    _availableProducts.clear();
    _availableProducts.addAll(products);
  }

  /// Carrega as regras
  Future<void> _initializeBusinessRules() async {
    final factory = BusinessRuleFactory();

    final rules = factory.createMultiple(initialRulesData);

    await _ruleRepository.saveAll(rules);
  }

  /// Inicializa campos de formulário de exemplo
  Future<void> _initializeFormFields() async {
    final factory = FormFieldFactory();
    final fields = factory.createMultiple(initialFormFieldsData);
    await _fieldRepository.saveAll(fields);
  }

  /// Define o estado de carregamento
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }
}
