import 'product.dart';

class IndustrialProduct extends Product {
  final int voltage;
  final String certification;
  final double powerConsumption;

  IndustrialProduct({
    required super.id,
    required super.name,
    required super.description,
    required super.basePrice,
    required super.category,
    required super.discountVip,
    super.isActive,
    super.createdAt,
    super.updatedAt,
    required this.voltage,
    required this.certification,
    required this.powerConsumption,
  }) : super(type: ProductType.industrial);

  @override
  List<String> getRequiredFields() {
    return ['voltage', 'certification', 'powerConsumption', 'quantity', 'discountCode', 'deliveryDate'];
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
    return ['volume_discount', 'show_discount_code_field', 'urgency_fee', 'certification_required', 'high_voltage_fee'];
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
