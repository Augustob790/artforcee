import 'package:flutter/foundation.dart';

import '../mixins/calculator_mixin.dart';
import '../mixins/validator_mixin.dart';
import '../models/fields/form_field.dart';
import '../models/products/product.dart';
import '../models/rules/business_rule.dart';
import '../repositories/product_repository.dart';
import '../repositories/repository.dart';
import '../services/rules_engine.dart';

/// Controller genérico para formulários dinâmicos
/// Implementa estados interdependentes e reatividade
class FormController<T extends Product> extends ChangeNotifier with ValidatorMixin, CalculatorMixin {
  final FormFieldRepository _fieldRepository;
  final RulesEngine<BusinessRule> _rulesEngine;
  final ProductRepository _productRepository;

  // Estado do formulário
  final Map<String, dynamic> _formData = {};
  final Map<String, List<String>> _fieldErrors = {};
  final Map<String, bool> _fieldVisibility = {};
  final List<FormField> _fields = [];

  // Estado do produto e preço
  T? _selectedProduct;
  DateTime? _deliveryDate;
  double _currentPrice = 0.0;
  bool _isLoading = false;
  bool _hasChanges = false;

  FormController(this._fieldRepository, this._rulesEngine, this._productRepository);

  // Getters
  DateTime? get deliveryDate => _deliveryDate;
  Map<String, dynamic> get formData => Map.unmodifiable(_formData);
  Map<String, List<String>> get fieldErrors => Map.unmodifiable(_fieldErrors);
  Map<String, bool> get fieldVisibility => Map.unmodifiable(_fieldVisibility);
  List<FormField> get fields => List.unmodifiable(_fields);
  T? get selectedProduct => _selectedProduct;
  double get currentPrice => _currentPrice;
  bool get isLoading => _isLoading;
  bool get hasChanges => _hasChanges;
  bool get isValid => _fieldErrors.values.every((errors) => errors.isEmpty);

  /// Inicializa o formulário com um produto específico
  Future<void> initializeForm(T product) async {
    _setLoading(true);

    try {
      _selectedProduct = product;
      _currentPrice = product.basePrice;

      // Carrega os campos necessários para este tipo de produto
      await _loadFieldsForProduct(product);

      // Inicializa os dados do formulário com valores padrão
      _initializeFormData();

      // Aplica regras iniciais
      await _applyRules();

      _hasChanges = false;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Atualiza o valor de um campo
  Future<void> updateField(String fieldName, dynamic value) async {
    if (fieldName == "deliveryDate") {
      _deliveryDate = value;
    }

    if (_formData[fieldName] == value) return;

    _formData[fieldName] = value;
    _hasChanges = true;

    // Limpa erros do campo
    _fieldErrors[fieldName] = [];

    // Valida o campo específico
    await _validateField(fieldName, value);

    // Aplica regras que podem ser afetadas por esta mudança
    await _applyRules();

    notifyListeners();
  }

  /// Valida todo o formulário
  Future<bool> validateForm() async {
    _fieldErrors.clear();

    // Valida cada campo individualmente
    for (final field in _fields) {
      if (field.isVisible) {
        final value = _formData[field.name];
        await _validateField(field.name, value);
      }
    }

    // Aplica regras de validação
    final context = _buildRuleContext();
    final result = await _rulesEngine.processRulesByType(RuleType.validation, context);

    // Adiciona erros de validação das regras
    for (final error in result.validationErrors) {
      _addGlobalError(error);
    }

    notifyListeners();
    return isValid;
  }

  /// Calcula o preço final baseado nos dados atuais
  Future<double> calculateFinalPrice() async {
    if (_selectedProduct == null) return 0.0;

    final quantity = _formData['quantity'] as int? ?? 1;
    final context = _buildRuleContext();
    context['currentPrice'] = calculateTotalPrice(context['basePrice'], quantity);

    // Aplica regras de preço
    final result = await _rulesEngine.processRulesByType(RuleType.pricing, context);

    _currentPrice = result.finalPrice ?? context['currentPrice'] as double;
    notifyListeners();

    return _currentPrice;
  }

  /// Reseta o formulário
  void resetForm() {
    _formData.clear();
    _fieldErrors.clear();
    _fieldVisibility.clear();
    _selectedProduct = null;
    _currentPrice = 0.0;
    _hasChanges = false;
    _deliveryDate = null;
    notifyListeners();
  }

  /// Carrega os campos necessários para um produto
  Future<void> _loadFieldsForProduct(T product) async {
    final requiredFieldNames = product.getRequiredFields();
    _fields.clear();

    // Carrega campos específicos do produto
    final productFields = await _fieldRepository.findByNames(requiredFieldNames);
    _fields.addAll(productFields);

    // Carrega campos comuns se não existirem
    await _ensureCommonFields();

    // Ordena campos por ordem de exibição
    _fields.sort((a, b) => a.order.compareTo(b.order));

    // Inicializa visibilidade dos campos
    for (final field in _fields) {
      _fieldVisibility[field.name] = field.isVisible;
    }
  }

  /// Garante que campos comuns existam
  Future<void> _ensureCommonFields() async {
    final commonFieldNames = ['quantity', 'deliveryDate'];

    for (final fieldName in commonFieldNames) {
      if (!_fields.any((field) => field.name == fieldName)) {
        final field = await _createCommonField(fieldName);
        if (field != null) {
          _fields.add(field);
        }
      }
    }
  }

  /// Cria campos comuns se não existirem
  Future<FormField?> _createCommonField(String fieldName) async {
    switch (fieldName) {
      case 'quantity':
        final field = NumberFormField(
          id: 'quantity',
          name: 'quantity',
          label: 'Quantidade',
          isRequired: true,
          minValue: 1,
          isInteger: true,
          defaultValue: 1,
          order: 100,
        );
        await _fieldRepository.save(field);
        return field;

      case 'deliveryDate':
        final field = DateFormField(
          id: 'deliveryDate',
          name: 'deliveryDate',
          label: 'Data de Entrega',
          isRequired: true,
          minDate: DateTime.now(),
          defaultValue: DateTime.now().add(const Duration(days: 30)),
          order: 200,
        );
        await _fieldRepository.save(field);
        return field;

      default:
        return null;
    }
  }

  /// Inicializa os dados do formulário com valores padrão
  void _initializeFormData() {
    for (final field in _fields) {
      if (field.defaultValue != null) {
        _formData[field.name] = field.defaultValue;
      }
    }
  }

  /// Valida um campo específico
  Future<void> _validateField(String fieldName, dynamic value) async {
    final field = _fields.firstWhere(
      (f) => f.name == fieldName,
      orElse: () => throw ArgumentError('Campo não encontrado: $fieldName'),
    );

    final errors = field.validate(value);
    _fieldErrors[fieldName] = errors;
  }

  /// Aplica todas as regras relevantes
  Future<void> _applyRules() async {
    final context = _buildRuleContext();
    final result = await _rulesEngine.processRules(context);

    // Atualiza preço se houver resultado de preço
    if (result.finalPrice != null) {
      _currentPrice = result.finalPrice!;
    }

    // Atualiza visibilidade dos campos
    final visibility = result.fieldVisibility;
    for (final entry in visibility.entries) {
      _fieldVisibility[entry.key] = entry.value;

      // Atualiza o campo correspondente
      final field = _fields.where((f) => f.name == entry.key).firstOrNull;
      if (field != null) {
        field.isVisible = entry.value;
      }
    }

    // Adiciona erros de validação
    for (final error in result.validationErrors) {
      _addGlobalError(error);
    }
  }

  /// Constrói o contexto para as regras
  Map<String, dynamic> _buildRuleContext() {
    final context = Map<String, dynamic>.from(_formData);

    if (_selectedProduct != null) {
      context['product'] = _selectedProduct!;
      context['productType'] = _selectedProduct!.type.name;
      context['basePrice'] = _selectedProduct!.basePrice;
      context['currentPrice'] = _currentPrice;
    }

    // Adiciona informações calculadas
    final quantity = _formData['quantity'] as int? ?? 1;
    context['quantity'] = quantity;

    final deliveryDate = _formData['deliveryDate'] as DateTime?;
    if (deliveryDate != null) {
      final deliveryDays = deliveryDate.difference(DateTime.now()).inDays;
      context['deliveryDays'] = deliveryDays;
    }

    return context;
  }

  /// Adiciona um erro global
  void _addGlobalError(String error) {
    const globalKey = '_global';
    _fieldErrors.putIfAbsent(globalKey, () => []).add(error);
  }

  /// Define o estado de carregamento
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  /// Obtém todos os erros como uma lista plana
  List<String> get allErrors {
    final errors = <String>[];
    for (final fieldErrors in _fieldErrors.values) {
      errors.addAll(fieldErrors);
    }
    return errors;
  }

  /// Verifica se um campo específico tem erros
  bool hasFieldError(String fieldName) {
    return _fieldErrors[fieldName]?.isNotEmpty ?? false;
  }

  /// Obtém os erros de um campo específico
  List<String> getFieldErrors(String fieldName) {
    return _fieldErrors[fieldName] ?? [];
  }

  /// Verifica se um campo está visível
  bool isFieldVisible(String fieldName) {
    return _fieldVisibility[fieldName] ?? true;
  }

  /// Obtém o valor de um campo
  T? getFieldValue<T>(String fieldName) {
    final value = _formData[fieldName];
    return value is T ? value : null;
  }

  /// Verifica se o formulário pode ser submetido
  bool get canSubmit => !_isLoading && isValid && _selectedProduct != null;
}
