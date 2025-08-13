import 'package:flutter/foundation.dart';

import '../mixins/calculator_mixin.dart';
import '../mixins/formatter_mixin.dart';
import '../models/products/corporate_product.dart';
import '../models/products/industrial_product.dart';
import '../models/products/product.dart';
import '../models/products/residential_product.dart';
import '../models/rules/business_rule.dart';
import '../repositories/product_repository.dart';
import '../repositories/repository.dart';
import '../repositories/rule_repository.dart';
import '../services/factory_service.dart';
import '../services/rules_engine.dart';
import 'form_controller.dart';

/// Modelo para representar um orçamento
class Quote {
  final String id;
  final Product product;
  final Map<String, dynamic> formData;
  final double finalPrice;
  final DateTime createdAt;
  //final List<String> appliedRules;

  Quote({
    required this.id,
    required this.product,
    required this.formData,
    required this.finalPrice,
    required this.createdAt,
    // required this.appliedRules,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product': product.toMap(),
      'formData': formData,
      'finalPrice': finalPrice,
      'createdAt': createdAt.toIso8601String(),
      // 'appliedRules': appliedRules,
    };
  }
}

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

    // Produtos industriais
    final industrial1 = factory.createIndustrialProduct(
      id: 'ind_001',
      name: 'Motor Elétrico Industrial',
      description: 'Motor elétrico trifásico para uso industrial',
      basePrice: 2500.00,
      category: 'Motores',
      voltage: 380,
      certification: 'ISO 9001',
      powerConsumption: 15.0,
    );

    final industrial2 = factory.createIndustrialProduct(
      id: 'ind_002',
      name: 'Compressor Industrial',
      description: 'Compressor de ar para aplicações industriais',
      basePrice: 8500.00,
      category: 'Compressores',
      voltage: 220,
      certification: '',
      powerConsumption: 25.0,
    );

    // Produtos residenciais
    final residential1 = factory.createResidentialProduct(
      id: 'res_001',
      name: 'Ar Condicionado Split',
      description: 'Ar condicionado split 12000 BTUs',
      basePrice: 1200.00,
      category: 'Climatização',
      color: 'Branco',
      warranty: 24,
      energyRating: 'A',
    );

    final residential2 = factory.createResidentialProduct(
      id: 'res_002',
      name: 'Geladeira Frost Free',
      description: 'Geladeira duplex frost free 400L',
      basePrice: 1800.00,
      category: 'Eletrodomésticos',
      color: 'Inox',
      warranty: 12,
      energyRating: 'B',
    );

    // Produtos corporativos
    final corporate1 = factory.createCorporateProduct(
      id: 'corp_001',
      name: 'Sistema ERP',
      description: 'Sistema de gestão empresarial completo',
      basePrice: 5000.00,
      category: 'Software',
      licenseType: 'Professional',
      supportLevel: 'Advanced',
      maxUsers: 50,
    );

    final corporate2 = factory.createCorporateProduct(
      id: 'corp_002',
      name: 'Plataforma CRM',
      description: 'Sistema de gestão de relacionamento com cliente',
      basePrice: 3000.00,
      category: 'Software',
      licenseType: 'Standard',
      supportLevel: 'Basic',
      maxUsers: 25,
    );

    // Salva produtos no repositório
    final products = [industrial1, industrial2, residential1, residential2, corporate1, corporate2];
    await _productRepository.saveAll(products);

    _availableProducts.clear();
    _availableProducts.addAll(products);
  }

  /// Inicializa regras de negócio de exemplo
  Future<void> _initializeBusinessRules() async {
    final factory = BusinessRuleFactory();

    // Regra de desconto por volume
    final volumeDiscountRule = factory.create({
      'id': 'volume_discount',
      'name': 'Desconto por Volume',
      'description': 'Desconto de 15% para pedidos com 50 ou mais unidades',
      'type': 'pricing',
      'priority': 2,
      'isActive': true,
      'conditions': {
        'quantity': {'operator': '>=', 'value': 50}
      },
      'modificationType': 'discount',
      'value': 15.0,
      'isPercentage': true,
    });

    // Regra de taxa de urgência
    final urgencyFeeRule = factory.create({
      'id': 'urgency_fee',
      'name': 'Taxa de Urgência',
      'description': 'Taxa adicional de 20% para entregas em menos de 7 dias',
      'type': 'pricing',
      'priority': 3,
      'isActive': true,
      'conditions': {
        'deliveryDays': {'operator': '<', 'value': 7}
      },
      'modificationType': 'surcharge',
      'value': 20.0,
      'isPercentage': true,
    });

    // Regra de certificação obrigatória
    final certificationRule = factory.create({
      'id': 'certification_required',
      'name': 'Certificação Obrigatória',
      'description': 'Certificação é obrigatória para produtos industriais com voltagem > 220V',
      'type': 'validation',
      'priority': 4,
      'isActive': true,
      'conditions': {
        'productType': 'industrial',
        'voltage': {'operator': '>', 'value': 220}
      },
      'targetFields': ['certification'],
      'validationType': 'required',
      'validationParams': {},
    });

    // Regra de visibilidade para campos industriais
    final industrialFieldsRule = factory.create({
      'id': 'industrial_fields_visibility',
      'name': 'Campos Industriais',
      'description': 'Mostra campos específicos para produtos industriais',
      'type': 'visibility',
      'priority': 1,
      'isActive': true,
      'conditions': {'productType': 'industrial'},
      'targetFields': ['voltage', 'certification', 'powerConsumption'],
      'showFields': true,
    });

    final rules = [volumeDiscountRule, urgencyFeeRule, certificationRule, industrialFieldsRule];
    await _ruleRepository.saveAll(rules);
  }

  /// Inicializa campos de formulário de exemplo
  Future<void> _initializeFormFields() async {
    final factory = FormFieldFactory();

    // Campos para produtos industriais
    final voltageField = factory.create({
      'id': 'voltage',
      'name': 'voltage',
      'label': 'Voltagem (V)',
      'type': 'number',
      'isRequired': true,
      'isVisible': false,
      'defaultValue': 220,
      'minValue': 110,
      'maxValue': 440,
      'isInteger': true,
      'order': 10,
    });

    final certificationField = factory.create({
      'id': 'certification',
      'name': 'certification',
      'label': 'Certificação',
      'type': 'text',
      'isRequired': false,
      'isVisible': false,
      'maxLength': 100,
      'order': 11,
    });

    final powerField = factory.create({
      'id': 'powerConsumption',
      'name': 'powerConsumption',
      'label': 'Consumo de Energia (kW)',
      'type': 'number',
      'isRequired': true,
      'isVisible': false,
      'defaultValue': 10.0,
      'minValue': 0.1,
      'decimalPlaces': 1,
      'order': 12,
    });

    // Campos para produtos residenciais
    final colorField = factory.create({
      'id': 'color',
      'name': 'color',
      'label': 'Cor',
      'type': 'dropdown',
      'isRequired': true,
      'isVisible': false,
      'defaultValue': 'Branco',
      'options': [
        {'value': 'Branco', 'label': 'Branco', 'isEnabled': true},
        {'value': 'Preto', 'label': 'Preto', 'isEnabled': true},
        {'value': 'Inox', 'label': 'Inox', 'isEnabled': true},
        {'value': 'Prata', 'label': 'Prata', 'isEnabled': true},
      ],
      'order': 20,
    });

    final warrantyField = factory.create({
      'id': 'warranty',
      'name': 'warranty',
      'label': 'Garantia (meses)',
      'type': 'number',
      'isRequired': true,
      'isVisible': false,
      'defaultValue': 12,
      'minValue': 6,
      'maxValue': 60,
      'isInteger': true,
      'order': 21,
    });

    final energyRatingField = factory.create({
      'id': 'energyRating',
      'name': 'energyRating',
      'label': 'Classificação Energética',
      'type': 'dropdown',
      'isRequired': true,
      'isVisible': false,
      'defaultValue': 'A',
      'options': [
        {'value': 'A', 'label': 'A', 'isEnabled': true},
        {'value': 'B', 'label': 'B', 'isEnabled': true},
        {'value': 'C', 'label': 'C', 'isEnabled': true},
        {'value': 'D', 'label': 'D', 'isEnabled': true},
        {'value': 'E', 'label': 'E', 'isEnabled': true},
      ],
      'order': 22,
    });

    final fields = [voltageField, certificationField, powerField, colorField, warrantyField, energyRatingField];
    await _fieldRepository.saveAll(fields);
  }

  /// Obtém nomes das regras aplicadas no contexto atual
  Future<List<String>> _getAppliedRuleNames() async {
    if (_currentFormController == null) return [];

    final context = {
      ..._currentFormController!.formData,
      'product': _selectedProduct,
      'productType': _selectedProduct?.type.name,
      'currentPrice': _currentFormController!.currentPrice,
    };

    final applicableRules = await _ruleRepository.findApplicableRules(context);
    return applicableRules.map((rule) => rule.name).toList();
  }

  /// Define o estado de carregamento
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _industrialFormController.dispose();
    _residentialFormController.dispose();
    _corporateFormController.dispose();
    super.dispose();
  }
}
