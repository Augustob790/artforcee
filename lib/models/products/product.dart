import '../base_model.dart';

/// Enumeração dos tipos de produto disponíveis
enum ProductType {
  industrial('Industrial'),
  residential('Residencial'),
  corporate('Corporativo');
  
  const ProductType(this.displayName);
  final String displayName;
}

/// Classe abstrata base para todos os produtos
/// Implementa polimorfismo para diferentes tipos de produto
abstract class Product extends BaseModel {
  /// Nome do produto
  final String name;
  
  /// Descrição do produto
  final String description;
  
  /// Preço base do produto
  final double basePrice;
  
  /// Tipo do produto
  final ProductType type;
  
  /// Categoria do produto
  final String category;
  
  /// Se o produto está ativo
  final bool isActive;

  Product({
    required super.id,
    required this.name,
    required this.description,
    required this.basePrice,
    required this.type,
    required this.category,
    this.isActive = true,
    super.createdAt,
    super.updatedAt,
  });

  /// Calcula o preço final do produto baseado na quantidade e regras específicas
  /// Deve ser implementado pelas classes filhas para aplicar lógicas específicas
  double calculatePrice(int quantity, {Map<String, dynamic>? context});
  
  /// Retorna os campos específicos que devem aparecer no formulário
  /// para este tipo de produto
  List<String> getRequiredFields();
  
  /// Valida se o produto está configurado corretamente
  /// Cada tipo de produto pode ter suas próprias validações
  List<String> validate(Map<String, dynamic> formData);
  
  /// Retorna as regras de negócio específicas para este tipo de produto
  List<String> getApplicableRules();

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'basePrice': basePrice,
      'type': type.name,
      'category': category,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
  
  /// Factory method para criar produtos baseado no tipo
  static Product createProduct({
    required String id,
    required String name,
    required String description,
    required double basePrice,
    required ProductType type,
    required String category,
    bool isActive = true,
    Map<String, dynamic>? specificData,
  }) {
    switch (type) {
      case ProductType.industrial:
        return IndustrialProduct(
          id: id,
          name: name,
          description: description,
          basePrice: basePrice,
          category: category,
          isActive: isActive,
          voltage: specificData?['voltage'] ?? 220,
          certification: specificData?['certification'] ?? '',
          powerConsumption: specificData?['powerConsumption'] ?? 0.0,
        );
      case ProductType.residential:
        return ResidentialProduct(
          id: id,
          name: name,
          description: description,
          basePrice: basePrice,
          category: category,
          isActive: isActive,
          color: specificData?['color'] ?? 'Branco',
          warranty: specificData?['warranty'] ?? 12,
          energyRating: specificData?['energyRating'] ?? 'A',
        );
      case ProductType.corporate:
        return CorporateProduct(
          id: id,
          name: name,
          description: description,
          basePrice: basePrice,
          category: category,
          isActive: isActive,
          licenseType: specificData?['licenseType'] ?? 'Standard',
          supportLevel: specificData?['supportLevel'] ?? 'Basic',
          maxUsers: specificData?['maxUsers'] ?? 10,
        );
    }
  }
}

/// Produto Industrial com características específicas
class IndustrialProduct extends Product {
  /// Voltagem do produto industrial
  final int voltage;
  
  /// Certificação necessária
  final String certification;
  
  /// Consumo de energia
  final double powerConsumption;

  IndustrialProduct({
    required super.id,
    required super.name,
    required super.description,
    required super.basePrice,
    required super.category,
    super.isActive,
    super.createdAt,
    super.updatedAt,
    required this.voltage,
    required this.certification,
    required this.powerConsumption,
  }) : super(type: ProductType.industrial);

  @override
  double calculatePrice(int quantity, {Map<String, dynamic>? context}) {
    double price = basePrice * quantity;
    
    // Aplicar desconto por volume (≥50 unidades = 15%)
    if (quantity >= 50) {
      price *= 0.85; // 15% de desconto
    }
    
    // Taxa de urgência para produtos industriais
    final deliveryDays = context?['deliveryDays'] as int? ?? 30;
    if (deliveryDays < 7) {
      price *= 1.20; // 20% de taxa de urgência
    }
    
    // Taxa adicional para alta voltagem
    if (voltage > 220) {
      price *= 1.10; // 10% adicional para alta voltagem
    }
    
    return price;
  }

  @override
  List<String> getRequiredFields() {
    return ['voltage', 'certification', 'powerConsumption', 'quantity', 'deliveryDate'];
  }

  @override
  List<String> validate(Map<String, dynamic> formData) {
    List<String> errors = [];
    
    // Certificação obrigatória para voltagem > 220V
    if (voltage > 220 && (certification.isEmpty || formData['certification']?.toString().isEmpty == true)) {
      errors.add('Certificação é obrigatória para produtos com voltagem superior a 220V');
    }
    
    // Validar voltagem
    final inputVoltage = formData['voltage'] as int?;
    if (inputVoltage != null && inputVoltage <= 0) {
      errors.add('Voltagem deve ser maior que zero');
    }
    
    return errors;
  }

  @override
  List<String> getApplicableRules() {
    return ['volume_discount', 'urgency_fee', 'certification_required', 'high_voltage_fee'];
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll({
      'voltage': voltage,
      'certification': certification,
      'powerConsumption': powerConsumption,
    });
    return map;
  }
}

/// Produto Residencial com características específicas
class ResidentialProduct extends Product {
  /// Cor do produto
  final String color;
  
  /// Garantia em meses
  final int warranty;
  
  /// Classificação energética
  final String energyRating;

  ResidentialProduct({
    required super.id,
    required super.name,
    required super.description,
    required super.basePrice,
    required super.category,
    super.isActive,
    super.createdAt,
    super.updatedAt,
    required this.color,
    required this.warranty,
    required this.energyRating,
  }) : super(type: ProductType.residential);

  @override
  double calculatePrice(int quantity, {Map<String, dynamic>? context}) {
    double price = basePrice * quantity;
    
    // Aplicar desconto por volume (≥50 unidades = 15%)
    if (quantity >= 50) {
      price *= 0.85; // 15% de desconto
    }
    
    // Desconto para classificação energética A
    if (energyRating == 'A') {
      price *= 0.95; // 5% de desconto
    }
    
    // Taxa de urgência
    final deliveryDays = context?['deliveryDays'] as int? ?? 30;
    if (deliveryDays < 7) {
      price *= 1.20; // 20% de taxa de urgência
    }
    
    return price;
  }

  @override
  List<String> getRequiredFields() {
    return ['color', 'warranty', 'energyRating', 'quantity', 'deliveryDate'];
  }

  @override
  List<String> validate(Map<String, dynamic> formData) {
    List<String> errors = [];
    
    // Validar garantia
    final inputWarranty = formData['warranty'] as int?;
    if (inputWarranty != null && inputWarranty < 6) {
      errors.add('Garantia mínima é de 6 meses');
    }
    
    // Validar classificação energética
    final inputRating = formData['energyRating'] as String?;
    if (inputRating != null && !['A', 'B', 'C', 'D', 'E'].contains(inputRating)) {
      errors.add('Classificação energética deve ser A, B, C, D ou E');
    }
    
    return errors;
  }

  @override
  List<String> getApplicableRules() {
    return ['volume_discount', 'urgency_fee', 'energy_rating_discount'];
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll({
      'color': color,
      'warranty': warranty,
      'energyRating': energyRating,
    });
    return map;
  }
}

/// Produto Corporativo com características específicas
class CorporateProduct extends Product {
  /// Tipo de licença
  final String licenseType;
  
  /// Nível de suporte
  final String supportLevel;
  
  /// Número máximo de usuários
  final int maxUsers;

  CorporateProduct({
    required super.id,
    required super.name,
    required super.description,
    required super.basePrice,
    required super.category,
    super.isActive,
    super.createdAt,
    super.updatedAt,
    required this.licenseType,
    required this.supportLevel,
    required this.maxUsers,
  }) : super(type: ProductType.corporate);

  @override
  double calculatePrice(int quantity, {Map<String, dynamic>? context}) {
    double price = basePrice * quantity;
    
    // Aplicar desconto por volume (≥50 unidades = 15%)
    if (quantity >= 50) {
      price *= 0.85; // 15% de desconto
    }
    
    // Taxa adicional para suporte premium
    if (supportLevel == 'Premium') {
      price *= 1.25; // 25% adicional
    } else if (supportLevel == 'Advanced') {
      price *= 1.15; // 15% adicional
    }
    
    // Taxa de urgência
    final deliveryDays = context?['deliveryDays'] as int? ?? 30;
    if (deliveryDays < 7) {
      price *= 1.20; // 20% de taxa de urgência
    }
    
    return price;
  }

  @override
  List<String> getRequiredFields() {
    return ['licenseType', 'supportLevel', 'maxUsers', 'quantity', 'deliveryDate'];
  }

  @override
  List<String> validate(Map<String, dynamic> formData) {
    List<String> errors = [];
    
    // Validar número de usuários
    final inputUsers = formData['maxUsers'] as int?;
    if (inputUsers != null && inputUsers <= 0) {
      errors.add('Número de usuários deve ser maior que zero');
    }
    
    // Validar tipo de licença
    final inputLicense = formData['licenseType'] as String?;
    if (inputLicense != null && !['Standard', 'Professional', 'Enterprise'].contains(inputLicense)) {
      errors.add('Tipo de licença deve ser Standard, Professional ou Enterprise');
    }
    
    return errors;
  }

  @override
  List<String> getApplicableRules() {
    return ['volume_discount', 'urgency_fee', 'support_level_fee'];
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll({
      'licenseType': licenseType,
      'supportLevel': supportLevel,
      'maxUsers': maxUsers,
    });
    return map;
  }
}

