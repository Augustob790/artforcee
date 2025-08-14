/// Mixin que fornece funcionalidades de formatação reutilizáveis
mixin FormatterMixin {
  /// Formata um valor monetário para exibição
  String formatCurrency(double value, {String symbol = 'R\$', int decimalPlaces = 2}) {
    final formattedValue = value.toStringAsFixed(decimalPlaces);
    final parts = formattedValue.split('.');

    final integerPart = parts[0];
    final formattedInteger = _addThousandsSeparator(integerPart);

    if (decimalPlaces > 0) {
      return '$symbol $formattedInteger,${parts[1]}';
    } else {
      return '$symbol $formattedInteger';
    }
  }

  /// Formata um número com separadores de milhares
  String formatNumber(num value, {int decimalPlaces = 0}) {
    final formattedValue = value.toStringAsFixed(decimalPlaces);
    final parts = formattedValue.split('.');

    final integerPart = parts[0];
    final formattedInteger = _addThousandsSeparator(integerPart);

    if (decimalPlaces > 0 && parts.length > 1) {
      return '$formattedInteger,${parts[1]}';
    } else {
      return formattedInteger;
    }
  }

  /// Formata uma porcentagem
  String formatPercentage(double value, {int decimalPlaces = 1}) {
    return '${value.toStringAsFixed(decimalPlaces)}%';
  }

  /// Formata uma data no formato brasileiro
  String formatDate(DateTime date, {String format = 'dd/MM/yyyy'}) {
    switch (format) {
      case 'dd/MM/yyyy':
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      case 'dd/MM/yyyy HH:mm':
        return '${formatDate(date)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      case 'yyyy-MM-dd':
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      case 'dd de MMMM de yyyy':
        return '${date.day} de ${getMonthName(date.month)} de ${date.year}';
      default:
        return formatDate(date);
    }
  }

  /// Formata um período de tempo em dias
  String formatDays(int days) {
    if (days == 1) {
      return '1 dia';
    } else if (days < 7) {
      return '$days dias';
    } else if (days < 30) {
      final weeks = (days / 7).floor();
      final remainingDays = days % 7;

      String result = weeks == 1 ? '1 semana' : '$weeks semanas';
      if (remainingDays > 0) {
        result += remainingDays == 1 ? ' e 1 dia' : ' e $remainingDays dias';
      }
      return result;
    } else {
      final months = (days / 30).floor();
      final remainingDays = days % 30;

      String result = months == 1 ? '1 mês' : '$months meses';
      if (remainingDays > 0) {
        result += remainingDays == 1 ? ' e 1 dia' : ' e $remainingDays dias';
      }
      return result;
    }
  }

  String formatFieldValue(String fieldName, dynamic value) {
    if (value == null) return 'Não informado';
    dynamic formattedValue = value;
    if (fieldName == 'deliveryDate') {
      if (value is String) {
        formattedValue = DateTime.tryParse(value);
      }
    }

    switch (fieldName) {
      case 'quantity':
        return formatNumber(formattedValue as num);
      case 'deliveryDate':
        if (formattedValue is DateTime) {
          return formatDate(formattedValue);
        }
        return 'Data inválida';
      case 'voltage':
        return '${formattedValue}V';
      case 'powerConsumption':
        return '${formattedValue}kW';
      case 'warranty':
        return formatDays((formattedValue as int) * 30);
      case 'maxUsers':
        return formatNumber(formattedValue as num);
      default:
        return formattedValue.toString();
    }
  }

  String getFieldLabel(String fieldName) {
    switch (fieldName) {
      case 'quantity':
        return 'Quantidade';
      case 'deliveryDate':
        return 'Data de Entrega';
      case 'voltage':
        return 'Voltagem';
      case 'certification':
        return 'Certificação';
      case 'powerConsumption':
        return 'Consumo de Energia';
      case 'discountCode':
        return 'Desconto adicional';
      case 'color':
        return 'Cor';
      case 'warranty':
        return 'Garantia';
      case 'energyRating':
        return 'Classificação Energética';
      case 'licenseType':
        return 'Tipo de Licença';
      case 'supportLevel':
        return 'Nível de Suporte';
      case 'maxUsers':
        return 'Máximo de Usuários';
      default:
        return fieldName;
    }
  }

  /// Formata um texto para nome próprio (cada palavra com primeira letra maiúscula)
  String formatProperName(String text) {
    if (text.isEmpty) return text;

    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Formata um número de telefone brasileiro
  String formatPhoneNumber(String phoneNumber) {
    // Remove todos os caracteres não numéricos
    final numbers = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');

    if (numbers.length == 11) {
      // Celular: (XX) 9XXXX-XXXX
      return '(${numbers.substring(0, 2)}) ${numbers.substring(2, 7)}-${numbers.substring(7)}';
    } else if (numbers.length == 10) {
      // Fixo: (XX) XXXX-XXXX
      return '(${numbers.substring(0, 2)}) ${numbers.substring(2, 6)}-${numbers.substring(6)}';
    } else {
      return phoneNumber; // Retorna original se não conseguir formatar
    }
  }

  /// Formata um CPF
  String formatCPF(String cpf) {
    final numbers = cpf.replaceAll(RegExp(r'[^0-9]'), '');

    if (numbers.length == 11) {
      return '${numbers.substring(0, 3)}.${numbers.substring(3, 6)}.${numbers.substring(6, 9)}-${numbers.substring(9)}';
    } else {
      return cpf; // Retorna original se não conseguir formatar
    }
  }

  /// Formata um CNPJ
  String formatCNPJ(String cnpj) {
    final numbers = cnpj.replaceAll(RegExp(r'[^0-9]'), '');

    if (numbers.length == 14) {
      return '${numbers.substring(0, 2)}.${numbers.substring(2, 5)}.${numbers.substring(5, 8)}/${numbers.substring(8, 12)}-${numbers.substring(12)}';
    } else {
      return cnpj; // Retorna original se não conseguir formatar
    }
  }

  /// Formata um texto limitando o número de caracteres
  String formatTruncate(String text, int maxLength, {String suffix = '...'}) {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength - suffix.length) + suffix;
  }

  /// Formata um tamanho de arquivo
  String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  /// Adiciona separadores de milhares a um número
  String _addThousandsSeparator(String number) {
    final reversed = number.split('').reversed.toList();
    final result = <String>[];

    for (int i = 0; i < reversed.length; i++) {
      if (i > 0 && i % 3 == 0) {
        result.add('.');
      }
      result.add(reversed[i]);
    }

    return result.reversed.join('');
  }

  /// Retorna o nome do mês em português
  String getMonthName(int month) {
    const months = [
      '',
      'janeiro',
      'fevereiro',
      'março',
      'abril',
      'maio',
      'junho',
      'julho',
      'agosto',
      'setembro',
      'outubro',
      'novembro',
      'dezembro'
    ];
    return months[month];
  }
}
