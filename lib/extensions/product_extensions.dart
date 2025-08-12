import '../models/products/product.dart';

/// Extensions para produtos
/// Implementa funcionalidades adicionais para manipulação de produtos
extension ProductExtensions on Product {
  /// Verifica se o produto é de alta voltagem (apenas para produtos industriais)
  bool get isHighVoltage {
    if (this is IndustrialProduct) {
      final industrial = this as IndustrialProduct;
      return industrial.voltage > 220;
    }
    return false;
  }
  
  /// Verifica se o produto requer certificação
  bool get requiresCertification {
    if (this is IndustrialProduct) {
      final industrial = this as IndustrialProduct;
      return industrial.voltage > 220;
    }
    return false;
  }
  
  /// Retorna uma descrição formatada do produto
  String get formattedDescription {
    final buffer = StringBuffer();
    buffer.writeln('$name - $category');
    buffer.writeln('Preço: ${formatCurrency(basePrice)}');
    buffer.writeln('Tipo: ${type.displayName}');
    
    if (this is IndustrialProduct) {
      final industrial = this as IndustrialProduct;
      buffer.writeln('Voltagem: ${industrial.voltage}V');
      buffer.writeln('Consumo: ${industrial.powerConsumption}kW');
      if (industrial.certification.isNotEmpty) {
        buffer.writeln('Certificação: ${industrial.certification}');
      }
    } else if (this is ResidentialProduct) {
      final residential = this as ResidentialProduct;
      buffer.writeln('Cor: ${residential.color}');
      buffer.writeln('Garantia: ${residential.warranty} meses');
      buffer.writeln('Classificação Energética: ${residential.energyRating}');
    } else if (this is CorporateProduct) {
      final corporate = this as CorporateProduct;
      buffer.writeln('Licença: ${corporate.licenseType}');
      buffer.writeln('Suporte: ${corporate.supportLevel}');
      buffer.writeln('Máx. Usuários: ${corporate.maxUsers}');
    }
    
    return buffer.toString().trim();
  }
  
  /// Retorna um resumo curto do produto
  String get shortSummary {
    return '$name (${type.displayName}) - ${formatCurrency(basePrice)}';
  }
  
  /// Verifica se o produto está em uma categoria específica
  bool isInCategory(String categoryName) {
    return category.toLowerCase() == categoryName.toLowerCase();
  }
  
  /// Formata o preço como moeda brasileira
  String formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }
  
  /// Verifica se o produto tem desconto disponível
  bool get hasDiscountAvailable {
    // Lógica para verificar se há desconto disponível
    return basePrice > 1000.0; // Exemplo: produtos acima de R$ 1000 têm desconto
  }
  
  /// Calcula o preço com desconto baseado na quantidade
  double calculateDiscountedPrice(int quantity) {
    double totalPrice = basePrice * quantity;
    
    // Desconto por volume (15% para 50+ unidades)
    if (quantity >= 50) {
      totalPrice *= 0.85; // 15% de desconto
    }
    
    return totalPrice;
  }
  
  /// Verifica se o produto é elegível para entrega expressa
  bool get isExpressDeliveryEligible {
    // Produtos industriais pesados não são elegíveis para entrega expressa
    if (this is IndustrialProduct) {
      final industrial = this as IndustrialProduct;
      return industrial.powerConsumption < 20.0; // Menos de 20kW
    }
    return true;
  }
  
  /// Retorna as especificações técnicas do produto
  Map<String, String> get technicalSpecs {
    final specs = <String, String>{
      'Nome': name,
      'Categoria': category,
      'Tipo': type.displayName,
      'Preço Base': formatCurrency(basePrice),
    };
    
    if (this is IndustrialProduct) {
      final industrial = this as IndustrialProduct;
      specs['Voltagem'] = '${industrial.voltage}V';
      specs['Consumo de Energia'] = '${industrial.powerConsumption}kW';
      if (industrial.certification.isNotEmpty) {
        specs['Certificação'] = industrial.certification;
      }
    } else if (this is ResidentialProduct) {
      final residential = this as ResidentialProduct;
      specs['Cor'] = residential.color;
      specs['Garantia'] = '${residential.warranty} meses';
      specs['Classificação Energética'] = residential.energyRating;
    } else if (this is CorporateProduct) {
      final corporate = this as CorporateProduct;
      specs['Tipo de Licença'] = corporate.licenseType;
      specs['Nível de Suporte'] = corporate.supportLevel;
      specs['Máximo de Usuários'] = '${corporate.maxUsers}';
    }
    
    return specs;
  }
}

