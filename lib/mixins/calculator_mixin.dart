import 'dart:math';

/// Mixin que fornece funcionalidades de cálculo reutilizáveis
mixin CalculatorMixin {
  /// Calcula desconto percentual
  double calculatePercentageDiscount(double originalPrice, double discountPercentage) {
    if (discountPercentage < 0 || discountPercentage > 100) {
      throw ArgumentError('Percentual de desconto deve estar entre 0 e 100');
    }
    return originalPrice * (1 - discountPercentage / 100);
  }

  /// Calcula desconto fixo
  double calculateFixedDiscount(double originalPrice, double discountAmount) {
    final result = originalPrice - discountAmount;
    return result < 0 ? 0 : result;
  }

  /// Calcula taxa adicional percentual
  double calculatePercentageSurcharge(double originalPrice, double surchargePercentage) {
    if (surchargePercentage < 0) {
      throw ArgumentError('Percentual de taxa adicional não pode ser negativo');
    }
    return originalPrice * (1 + surchargePercentage / 100);
  }

  /// Calcula taxa adicional fixa
  double calculateFixedSurcharge(double originalPrice, double surchargeAmount) {
    return originalPrice + surchargeAmount;
  }

  /// Calcula preço total baseado na quantidade
  double calculateTotalPrice(double unitPrice, int quantity) {
    if (quantity < 0) {
      throw ArgumentError('Quantidade não pode ser negativa');
    }
    return unitPrice * quantity;
  }

  /// Calcula desconto por volume baseado em faixas
  double calculateVolumeDiscount(double totalPrice, int quantity, List<VolumeDiscountTier> tiers) {
    // Ordena as faixas por quantidade (maior primeiro)
    final sortedTiers = List<VolumeDiscountTier>.from(tiers);
    sortedTiers.sort((a, b) => b.minQuantity.compareTo(a.minQuantity));

    // Encontra a primeira faixa aplicável
    for (final tier in sortedTiers) {
      if (quantity >= tier.minQuantity) {
        return tier.isPercentage
            ? calculatePercentageDiscount(totalPrice, tier.discountValue)
            : calculateFixedDiscount(totalPrice, tier.discountValue);
      }
    }

    return totalPrice; // Nenhuma faixa aplicável
  }

  /// Calcula taxa de urgência baseada no prazo de entrega
  double calculateUrgencyFee(double basePrice, int deliveryDays, List<UrgencyFeeTier> tiers) {
    // Ordena as faixas por dias (menor primeiro)
    final sortedTiers = List<UrgencyFeeTier>.from(tiers);
    sortedTiers.sort((a, b) => a.maxDays.compareTo(b.maxDays));

    // Encontra a primeira faixa aplicável
    for (final tier in sortedTiers) {
      if (deliveryDays <= tier.maxDays) {
        return tier.isPercentage
            ? calculatePercentageSurcharge(basePrice, tier.feeValue)
            : calculateFixedSurcharge(basePrice, tier.feeValue);
      }
    }

    return basePrice; // Nenhuma faixa aplicável
  }


  /// Arredonda um valor para um número específico de casas decimais
  double roundToDecimals(double value, int decimals) {
    final factor = pow(10, decimals);
    return (value * factor).round() / factor;
  }

  /// Calcula a diferença percentual entre dois valores
  double calculatePercentageDifference(double oldValue, double newValue) {
    if (oldValue == 0) return 0;
    return ((newValue - oldValue) / oldValue) * 100;
  }

  /// Calcula o valor médio de uma lista de números
  double calculateAverage(List<num> values) {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a + b) / values.length;
  }
}

/// Classe para representar faixas de desconto por volume
class VolumeDiscountTier {
  final int minQuantity;
  final double discountValue;
  final bool isPercentage;

  VolumeDiscountTier({
    required this.minQuantity,
    required this.discountValue,
    this.isPercentage = true,
  });
}

/// Classe para representar faixas de taxa de urgência
class UrgencyFeeTier {
  final int maxDays;
  final double feeValue;
  final bool isPercentage;

  UrgencyFeeTier({
    required this.maxDays,
    required this.feeValue,
    this.isPercentage = true,
  });
}

/// Classe para representar regras de desconto escalonado
class TieredDiscountRule {
  final int minQuantity;
  final int? maxQuantity;
  final double discountPercentage;

  TieredDiscountRule({
    required this.minQuantity,
    this.maxQuantity,
    required this.discountPercentage,
  });
}
