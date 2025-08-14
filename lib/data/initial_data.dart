// lib/data/initial_products_data.dart
import '../models/models.dart'; // Importe para usar ProductType

final List<Map<String, dynamic>> initialProductsData = [
  // Produtos industriais
  {
    'id': 'ind_001',
    'name': 'Motor Elétrico Industrial',
    'description': 'Motor elétrico trifásico para uso industrial',
    'basePrice': 2500.00,
    'category': 'Motores',
    'type': ProductType.industrial.name,
    'specificData': {
      'voltage': 380,
      'certification': 'ISO 9001',
      'powerConsumption': 15.0,
    },
  },
  {
    'id': 'ind_002',
    'name': 'Compressor Industrial',
    'description': 'Compressor de ar para aplicações industriais',
    'basePrice': 8500.00,
    'category': 'Compressores',
    'type': ProductType.industrial.name,
    'specificData': {
      'voltage': 220,
      'certification': '',
      'powerConsumption': 25.0,
    },
  },
  // Produtos residenciais
  {
    'id': 'res_001',
    'name': 'Ar Condicionado Split',
    'description': 'Ar condicionado split 12000 BTUs',
    'basePrice': 1200.00,
    'category': 'Climatização',
    'type': ProductType.residential.name,
    'specificData': {
      'color': 'Branco',
      'warranty': 24,
      'energyRating': 'A',
    },
  },
  {
    'id': 'res_002',
    'name': 'Geladeira Frost Free',
    'description': 'Geladeira duplex frost free 400L',
    'basePrice': 1800.00,
    'category': 'Eletrodomésticos',
    'type': ProductType.residential.name,
    'specificData': {
      'color': 'Inox',
      'warranty': 12,
      'energyRating': 'B',
    },
  },
  // Produtos corporativos
  {
    'id': 'corp_001',
    'name': 'Sistema ERP',
    'description': 'Sistema de gestão empresarial completo',
    'basePrice': 5000.00,
    'category': 'Software',
    'type': ProductType.corporate.name,
    'specificData': {
      'licenseType': 'Professional',
      'supportLevel': 'Advanced',
      'maxUsers': 50,
    },
  },
  {
    'id': 'corp_002',
    'name': 'Plataforma CRM',
    'description': 'Sistema de gestão de relacionamento com cliente',
    'basePrice': 3000.00,
    'category': 'Software',
    'type': ProductType.corporate.name,
    'specificData': {
      'licenseType': 'Standard',
      'supportLevel': 'Basic',
      'maxUsers': 25,
    },
  },
];

final List<Map<String, dynamic>> initialFormFieldsData = [
  // Campos para produtos industriais
  {
    'id': 'voltage',
    'name': 'voltage',
    'label': 'Voltagem (V)',
    'type': FieldType.number.name,
    'isRequired': true,
    'isVisible': false,
    'defaultValue': 220,
    'minValue': 110,
    'maxValue': 440,
    'isInteger': true,
    'order': 10,
  },
  {
    'id': 'certification',
    'name': 'certification',
    'label': 'Certificação',
    'type': FieldType.text.name,
    'isRequired': false,
    'isVisible': false,
    'maxLength': 100,
    'order': 11,
  },
  {
    'id': 'powerConsumption',
    'name': 'powerConsumption',
    'label': 'Consumo de Energia (kW)',
    'type': FieldType.number.name,
    'isRequired': true,
    'isVisible': false,
    'defaultValue': 10.0,
    'minValue': 0.1,
    'decimalPlaces': 1,
    'order': 12,
  },
  // Campos para produtos residenciais
  {
    'id': 'color',
    'name': 'color',
    'label': 'Cor',
    'type': FieldType.dropdown.name,
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
  },
  {
    'id': 'warranty',
    'name': 'warranty',
    'label': 'Garantia (meses)',
    'type': FieldType.number.name,
    'isRequired': true,
    'isVisible': false,
    'defaultValue': 12,
    'minValue': 6,
    'maxValue': 60,
    'isInteger': true,
    'order': 21,
  },
  {
    'id': 'energyRating',
    'name': 'energyRating',
    'label': 'Classificação Energética',
    'type': FieldType.dropdown.name,
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
  },
  // Campos comuns
  {
    'id': 'quantity',
    'name': 'quantity',
    'label': 'Quantidade',
    'type': FieldType.number.name,
    'isRequired': true,
    'isVisible': true, 
    'defaultValue': 1,
    'minValue': 1,
    'isInteger': true,
    'order': 100,
  },
  {
    'id': 'deliveryDate',
    'name': 'deliveryDate',
    'label': 'Data de Entrega',
    'type': FieldType.date.name,
    'isRequired': true,
    'isVisible': true, 
    'defaultValue': null, 
    'minDate': DateTime.now().toIso8601String(),
    'order': 200,
  },
];

final List<Map<String, dynamic>> initialRulesData = [
  // Regra de desconto por volume
  {
    'id': 'volume_discount',
    'name': 'Desconto por Volume',
    'description': 'Desconto de 15% para pedidos com 50 ou mais unidades',
    'type': RuleType.pricing.name,
    'priority': RulePriority.medium.value,
    'isActive': true,
    'conditions': {
      'quantity': {'operator': '>=', 'value': 50}
    },
    'modificationType': 'discount',
    'value': 15.0,
    'isPercentage': true,
  },
  // Regra de taxa de urgência
  {
    'id': 'urgency_fee',
    'name': 'Taxa de Urgência',
    'description': 'Taxa adicional de 20% para entregas em menos de 7 dias',
    'type': RuleType.pricing.name,
    'priority': RulePriority.high.value,
    'isActive': true,
    'conditions': {
      'deliveryDays': {'operator': '<', 'value': 7}
    },
    'modificationType': 'surcharge',
    'value': 20.0,
    'isPercentage': true,
  },
  // Regra de certificação obrigatória
  {
    'id': 'certification_required',
    'name': 'Certificação Obrigatória',
    'description': 'Certificação é obrigatória para produtos industriais com voltagem > 220V',
    'type': RuleType.validation.name,
    'priority': RulePriority.critical.value,
    'isActive': true,
    'conditions': {
      'productType': 'industrial',
      'voltage': {'operator': '>', 'value': 220}
    },
    'targetFields': ['certification'],
    'validationType': 'required',
    'validationParams': {},
  },
  // Regra de visibilidade para campos industriais
  {
    'id': 'industrial_fields_visibility',
    'name': 'Campos Industriais',
    'description': 'Mostra campos específicos para produtos industriais',
    'type': RuleType.visibility.name,
    'priority': RulePriority.low.value,
    'isActive': true,
    'conditions': {'productType': 'industrial'},
    'targetFields': ['voltage', 'certification', 'powerConsumption'],
    'showFields': true,
  },
];
