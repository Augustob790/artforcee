/// Extensions para strings
/// Implementa funcionalidades adicionais para manipulação de texto
extension StringExtensions on String {
  /// Verifica se a string não está vazia
  bool get isNotEmpty => !isEmpty;
  
  /// Verifica se a string está vazia ou contém apenas espaços
  bool get isBlank => trim().isEmpty;
  
  /// Verifica se a string não está vazia e não contém apenas espaços
  bool get isNotBlank => !isBlank;
  
  /// Capitaliza a primeira letra da string
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
  
  /// Converte para slug (URL amigável)
  String get toSlug {
    return withoutAccents
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
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
  
  /// Verifica se a string é um palíndromo
  bool get isPalindrome {
    final cleaned = toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    return cleaned == cleaned.reversed;
  }
  
  /// Converte para camelCase
  String get toCamelCase {
    if (isEmpty) return this;
    
    final words = split(RegExp(r'[\s_-]+'));
    if (words.isEmpty) return this;
    
    final first = words.first.toLowerCase();
    final rest = words.skip(1).map((word) => word.capitalized);
    
    return [first, ...rest].join('');
  }
  
  /// Converte para snake_case
  String get toSnakeCase {
    return replaceAllMapped(RegExp(r'[A-Z]'), (match) => '_${match.group(0)!.toLowerCase()}')
        .replaceAll(RegExp(r'[\s-]+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '')
        .toLowerCase();
  }
  
  /// Converte para kebab-case
  String get toKebabCase {
    return replaceAllMapped(RegExp(r'[A-Z]'), (match) => '-${match.group(0)!.toLowerCase()}')
        .replaceAll(RegExp(r'[\s_]+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '')
        .toLowerCase();
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
  
  /// Máscara para CPF
  String get maskAsCPF {
    final numbers = numbersOnly;
    if (numbers.length != 11) return this;
    return '${numbers.substring(0, 3)}.${numbers.substring(3, 6)}.${numbers.substring(6, 9)}-${numbers.substring(9)}';
  }
  
  /// Máscara para CNPJ
  String get maskAsCNPJ {
    final numbers = numbersOnly;
    if (numbers.length != 14) return this;
    return '${numbers.substring(0, 2)}.${numbers.substring(2, 5)}.${numbers.substring(5, 8)}/${numbers.substring(8, 12)}-${numbers.substring(12)}';
  }
  
  /// Máscara para telefone
  String get maskAsPhone {
    final numbers = numbersOnly;
    if (numbers.length == 11) {
      return '(${numbers.substring(0, 2)}) ${numbers.substring(2, 7)}-${numbers.substring(7)}';
    } else if (numbers.length == 10) {
      return '(${numbers.substring(0, 2)}) ${numbers.substring(2, 6)}-${numbers.substring(6)}';
    }
    return this;
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
      } else if ((currentLine + ' ' + word).length <= maxLength) {
        currentLine += ' ' + word;
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
  
  /// Calcula a distância de Levenshtein entre duas strings
  int levenshteinDistance(String other) {
    if (isEmpty) return other.length;
    if (other.isEmpty) return length;
    
    final matrix = List.generate(
      length + 1,
      (i) => List.generate(other.length + 1, (j) => 0),
    );
    
    for (int i = 0; i <= length; i++) {
      matrix[i][0] = i;
    }
    
    for (int j = 0; j <= other.length; j++) {
      matrix[0][j] = j;
    }
    
    for (int i = 1; i <= length; i++) {
      for (int j = 1; j <= other.length; j++) {
        final cost = this[i - 1] == other[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,      // deletion
          matrix[i][j - 1] + 1,      // insertion
          matrix[i - 1][j - 1] + cost // substitution
        ].reduce((a, b) => a < b ? a : b);
      }
    }
    
    return matrix[length][other.length];
  }
  
  /// Calcula a similaridade entre duas strings (0.0 a 1.0)
  double similarity(String other) {
    final maxLength = length > other.length ? length : other.length;
    if (maxLength == 0) return 1.0;
    
    final distance = levenshteinDistance(other);
    return 1.0 - (distance / maxLength);
  }
}

