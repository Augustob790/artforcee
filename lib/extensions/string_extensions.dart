/// Extensions para strings
/// Implementa funcionalidades adicionais para manipulação de texto
extension StringExtensions on String {
  String get capitalized {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  /// Converte para título (primeira letra de cada palavra maiúscula)
  String get titleCase {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalized).join(' ');
  }

  /// Remove acentos da string
  String get withoutAccents {
    const accents = 'ÀÁÂÃÄÅàáâãäåÒÓÔÕÖØòóôõöøÈÉÊËèéêëÇçÌÍÎÏìíîïÙÚÛÜùúûüÿÑñ';
    const withoutAccents = 'AAAAAAaaaaaaOOOOOOooooooEEEEeeeeeCcIIIIiiiiUUUUuuuuyNn';

    String result = this;
    for (int i = 0; i < accents.length; i++) {
      result = result.replaceAll(accents[i], withoutAccents[i]);
    }
    return result;
  }

  /// Verifica se é um email válido
  bool get isValidEmail {
    const pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    return RegExp(pattern).hasMatch(this);
  }

  /// Verifica se é um CPF válido (formato)
  bool get isValidCPFFormat {
    const pattern = r'^\d{3}\.\d{3}\.\d{3}-\d{2}$';
    return RegExp(pattern).hasMatch(this);
  }

  /// Verifica se é um CNPJ válido (formato)
  bool get isValidCNPJFormat {
    const pattern = r'^\d{2}\.\d{3}\.\d{3}\/\d{4}-\d{2}$';
    return RegExp(pattern).hasMatch(this);
  }

  /// Verifica se é um telefone brasileiro válido (formato)
  bool get isValidPhoneFormat {
    const pattern = r'^\(\d{2}\) \d{4,5}-\d{4}$';
    return RegExp(pattern).hasMatch(this);
  }

  /// Verifica se contém apenas números
  bool get isNumeric {
    return RegExp(r'^\d+$').hasMatch(this);
  }

  /// Verifica se contém apenas letras
  bool get isAlpha {
    return RegExp(r'^[a-zA-ZÀ-ÿ]+$').hasMatch(this);
  }

  /// Verifica se contém apenas letras e números
  bool get isAlphanumeric {
    return RegExp(r'^[a-zA-Z0-9À-ÿ]+$').hasMatch(this);
  }

  /// Remove todos os caracteres não numéricos
  String get numbersOnly {
    return replaceAll(RegExp(r'[^0-9]'), '');
  }

  /// Remove todos os caracteres não alfabéticos
  String get lettersOnly {
    return replaceAll(RegExp(r'[^a-zA-ZÀ-ÿ]'), '');
  }

  /// Remove todos os caracteres não alfanuméricos
  String get alphanumericOnly {
    return replaceAll(RegExp(r'[^a-zA-Z0-9À-ÿ]'), '');
  }

  /// Trunca a string para um tamanho máximo
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return substring(0, maxLength - suffix.length) + suffix;
  }

  /// Repete a string n vezes
  String repeat(int times) {
    if (times <= 0) return '';
    return List.filled(times, this).join();
  }

  /// Inverte a string
  String get reversed {
    return split('').reversed.join('');
  }

  /// Conta quantas vezes uma substring aparece
  int countOccurrences(String substring) {
    if (substring.isEmpty) return 0;

    int count = 0;
    int index = 0;

    while ((index = indexOf(substring, index)) != -1) {
      count++;
      index += substring.length;
    }

    return count;
  }

  /// Extrai números da string
  List<int> get extractNumbers {
    final matches = RegExp(r'\d+').allMatches(this);
    return matches.map((match) => int.parse(match.group(0)!)).toList();
  }

  /// Extrai números decimais da string
  List<double> get extractDecimals {
    final matches = RegExp(r'\d+\.?\d*').allMatches(this);
    return matches.map((match) => double.parse(match.group(0)!)).toList();
  }

  /// Converte string para int com valor padrão
  int toInt([int defaultValue = 0]) {
    return int.tryParse(this) ?? defaultValue;
  }

  /// Converte string para double com valor padrão
  double toDouble([double defaultValue = 0.0]) {
    return double.tryParse(this) ?? defaultValue;
  }

  /// Converte string para bool
  bool get toBool {
    final lower = toLowerCase().trim();
    return lower == 'true' || lower == '1' || lower == 'yes' || lower == 'sim';
  }

  /// Verifica se a string corresponde a um padrão regex
  bool matches(String pattern) {
    return RegExp(pattern).hasMatch(this);
  }

  /// Substitui múltiplos padrões de uma vez
  String replaceMultiple(Map<String, String> replacements) {
    String result = this;
    replacements.forEach((pattern, replacement) {
      result = result.replaceAll(pattern, replacement);
    });
    return result;
  }

  /// Quebra a string em linhas de tamanho máximo
  List<String> wrapLines(int maxLength) {
    if (maxLength <= 0) throw ArgumentError('Tamanho máximo deve ser maior que zero');

    final lines = <String>[];
    final words = split(' ');
    String currentLine = '';

    for (final word in words) {
      if (currentLine.isEmpty) {
        currentLine = word;
      } else if (('$currentLine $word').length <= maxLength) {
        currentLine += ' $word';
      } else {
        lines.add(currentLine);
        currentLine = word;
      }
    }

    if (currentLine.isNotEmpty) {
      lines.add(currentLine);
    }

    return lines;
  }
}
