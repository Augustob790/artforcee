// ignore_for_file: avoid_shadowing_type_parameters, unused_field, depend_on_referenced_packages

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

import '../mixins/calculator_mixin.dart';
import '../mixins/validator_mixin.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';
import '../services/services.dart';

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
  double _currentPrice = 0.0;
  bool _isLoading = false;
  bool _hasChanges = false;

  FormController(this._fieldRepository, this._rulesEngine, this._productRepository);

  // Getters
  DateTime? get deliveryDate => getFieldValue<DateTime>('deliveryDate');
  Map<String, dynamic> get formData => Map.unmodifiable(_formData);
  Map<String, List<String>> get fieldErrors => Map.unmodifiable(_fieldErrors);
  Map<String, bool> get fieldVisibility => Map.unmodifiable(_fieldVisibility);
  List<FormField> get fields => List.unmodifiable(_fields);
  T? get selectedProduct => _selectedProduct;
  double get currentPrice => _currentPrice;
  bool get isLoading => _isLoading;
  bool get hasChanges => _hasChanges;
  bool get isValid => _fieldErrors.values.every((errors) => errors.isEmpty);
  bool get canSubmit => !_isLoading && isValid && _selectedProduct != null;

  /// Inicializa o formulário com um produto específico
  Future<void> initializeForm(T product) async {
    _setLoading(true);
    _selectedProduct = product;
    _currentPrice = product.basePrice;

    try {
      await _loadAllFields(product);
      _initializeFormData();
      await _applyRules();
    } finally {
      _hasChanges = false;
      _setLoading(false);
    }
    notifyListeners();
  }

  /// Atualiza o valor de um campo
  Future<void> updateField(String fieldName, dynamic value) async {
    if (_formData[fieldName] == value) return;

    _formData[fieldName] = value;
    _hasChanges = true;

    await _validateField(fieldName, value);
    await _applyRules();
    notifyListeners();
  }

  /// Valida todo o formulário
  Future<bool> validateForm() async {
    _fieldErrors.clear();

    for (final field in _fields) {
      if (field.isVisible) {
        final value = _formData[field.name];
        await _validateField(field.name, value);
      }
    }

    final context = _buildRuleContext();
    final result = await _rulesEngine.processRulesByType(RuleType.validation, context);

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

  /// Carrega todos os campos necessários para um produto (campos do produto + campos comuns)
  Future<void> _loadAllFields(T product) async {
    final allRequiredFieldNames = product.getRequiredFields();
    _fields.clear();
    final allFields = await _fieldRepository.findByNames(allRequiredFieldNames);
    _fields.addAll(allFields);
    _fields.sort((a, b) => a.order.compareTo(b.order));
    for (final field in _fields) {
      _fieldVisibility[field.name] = field.isVisible;
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
    final field = _fields.firstWhereOrNull((f) => f.name == fieldName);
    if (field != null) {
      final errors = field.validate(value);
      _fieldErrors[fieldName] = errors;
    }
  }

  /// Aplica todas as regras relevantes, incluindo as de preço
  Future<void> _applyRules() async {
    _fieldErrors.clear();

    final context = _buildRuleContext();

    final validationResult = await _rulesEngine.processRulesByType(RuleType.validation, context);
    for (final error in validationResult.validationErrors) {
      _addGlobalError(error);
    }
    final visibilityResult = await _rulesEngine.processRulesByType(RuleType.visibility, context);
    for (final entry in visibilityResult.fieldVisibility.entries) {
      _fieldVisibility[entry.key] = entry.value;
      final field = _fields.where((f) => f.name == entry.key).firstOrNull;
      if (field != null) {
        field.isVisible = entry.value;
      }
    }

    // Aplica as regras de preço
    final pricingResult = await _rulesEngine.processRulesByType(RuleType.pricing, context);
    if (pricingResult.finalPrice != null) {
      _currentPrice = pricingResult.finalPrice!;
    }
    for (final error in validationResult.validationErrors) {
      _addGlobalError(error);
    }

    calculateFinalPrice();
  }

  /// Constrói o contexto para as regras
  Map<String, dynamic> _buildRuleContext() {
    final context = Map<String, dynamic>.from(_formData);
    if (_selectedProduct != null) {
      context['product'] = _selectedProduct!;
      context['productType'] = _selectedProduct!.type.name;
      context['basePrice'] = _selectedProduct!.basePrice;
      final quantity = context['quantity'] as int? ?? 1;
      context['currentPrice'] = calculateTotalPrice(context['basePrice'], quantity);
    }

    final deliveryDate = context['deliveryDate'] as DateTime?;
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
    if (value is T) {
      return value;
    }
    if (T == DateTime && value is String) {
      return DateTime.tryParse(value) as T?;
    }
    return null;
  }

  /// Reseta o formulário
  void resetForm() {


    _formData.clear();
    _fieldErrors.clear();
    _fieldVisibility.clear();
    _selectedProduct = null;
    _currentPrice = 0.0;
    _hasChanges = false;
    notifyListeners();
  }
}
