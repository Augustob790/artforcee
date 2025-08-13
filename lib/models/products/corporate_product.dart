import 'product.dart';

class CorporateProduct extends Product {
  final String licenseType;
  final String supportLevel;
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
