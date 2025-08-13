import 'product.dart';

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