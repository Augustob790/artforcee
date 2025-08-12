import 'dart:math' as math;

/// Extensions genéricas para listas
/// Implementa funcionalidades reutilizáveis para qualquer tipo de lista
extension ListExtensions<T> on List<T> {
  /// Verifica se a lista não está vazia
  bool get isNotEmpty => !isEmpty;
  
  /// Retorna o primeiro elemento ou null se a lista estiver vazia
  T? get firstOrNull => isEmpty ? null : first;
  
  /// Retorna o último elemento ou null se a lista estiver vazia
  T? get lastOrNull => isEmpty ? null : last;
  
  /// Retorna um elemento aleatório da lista
  T? get random {
    if (isEmpty) return null;
    final randomIndex = DateTime.now().millisecondsSinceEpoch % length;
    return this[randomIndex];
  }
  
  /// Divide a lista em chunks de tamanho específico
  List<List<T>> chunk(int size) {
    if (size <= 0) throw ArgumentError('Tamanho do chunk deve ser maior que zero');
    
    final chunks = <List<T>>[];
    for (int i = 0; i < length; i += size) {
      final end = (i + size < length) ? i + size : length;
      chunks.add(sublist(i, end));
    }
    return chunks;
  }
  
  /// Remove duplicatas mantendo a ordem original
  List<T> get distinct {
    final seen = <T>{};
    return where((element) => seen.add(element)).toList();
  }
  
  /// Remove duplicatas baseado em uma função de comparação
  List<T> distinctBy<K>(K Function(T) keySelector) {
    final seen = <K>{};
    return where((element) => seen.add(keySelector(element))).toList();
  }
  
  /// Agrupa elementos por uma chave
  Map<K, List<T>> groupBy<K>(K Function(T) keySelector) {
    final groups = <K, List<T>>{};
    for (final element in this) {
      final key = keySelector(element);
      groups.putIfAbsent(key, () => <T>[]).add(element);
    }
    return groups;
  }
  
  /// Encontra o elemento com o valor máximo baseado em uma função
  T? maxBy<K extends Comparable<K>>(K Function(T) selector) {
    if (isEmpty) return null;
    
    T maxElement = first;
    K maxValue = selector(maxElement);
    
    for (int i = 1; i < length; i++) {
      final currentValue = selector(this[i]);
      if (currentValue.compareTo(maxValue) > 0) {
        maxElement = this[i];
        maxValue = currentValue;
      }
    }
    
    return maxElement;
  }
  
  /// Encontra o elemento com o valor mínimo baseado em uma função
  T? minBy<K extends Comparable<K>>(K Function(T) selector) {
    if (isEmpty) return null;
    
    T minElement = first;
    K minValue = selector(minElement);
    
    for (int i = 1; i < length; i++) {
      final currentValue = selector(this[i]);
      if (currentValue.compareTo(minValue) < 0) {
        minElement = this[i];
        minValue = currentValue;
      }
    }
    
    return minElement;
  }
  
  /// Ordena a lista por uma função de seleção
  List<T> sortedBy<K extends Comparable<K>>(K Function(T) selector) {
    final sorted = List<T>.from(this);
    sorted.sort((a, b) => selector(a).compareTo(selector(b)));
    return sorted;
  }
  
  /// Ordena a lista por uma função de seleção em ordem decrescente
  List<T> sortedByDescending<K extends Comparable<K>>(K Function(T) selector) {
    final sorted = List<T>.from(this);
    sorted.sort((a, b) => selector(b).compareTo(selector(a)));
    return sorted;
  }
  
  /// Pega os primeiros n elementos
  List<T> take(int count) {
    if (count <= 0) return <T>[];
    if (count >= length) return List<T>.from(this);
    return sublist(0, count);
  }
  
  /// Pula os primeiros n elementos
  List<T> skip(int count) {
    if (count <= 0) return List<T>.from(this);
    if (count >= length) return <T>[];
    return sublist(count);
  }
  
  /// Pega elementos enquanto a condição for verdadeira
  List<T> takeWhile(bool Function(T) test) {
    final result = <T>[];
    for (final element in this) {
      if (!test(element)) break;
      result.add(element);
    }
    return result;
  }
  
  /// Pula elementos enquanto a condição for verdadeira
  List<T> skipWhile(bool Function(T) test) {
    int index = 0;
    while (index < length && test(this[index])) {
      index++;
    }
    return sublist(index);
  }
  
  /// Verifica se todos os elementos atendem a uma condição
  bool all(bool Function(T) test) {
    return every(test);
  }
  
  /// Verifica se pelo menos um elemento atende a uma condição
  bool anyElement(bool Function(T) test) {
    return any(test);
  }
  
  /// Conta quantos elementos atendem a uma condição
  int count([bool Function(T)? test]) {
    if (test == null) return length;
    return where(test).length;
  }
  
  /// Encontra o índice do primeiro elemento que atende a uma condição
  int indexWhere(bool Function(T) test, [int start = 0]) {
    for (int i = start; i < length; i++) {
      if (test(this[i])) return i;
    }
    return -1;
  }
  
  /// Encontra o índice do último elemento que atende a uma condição
  int lastIndexWhere(bool Function(T) test, [int? start]) {
    start ??= length - 1;
    for (int i = start; i >= 0; i--) {
      if (test(this[i])) return i;
    }
    return -1;
  }
  
  /// Intercala elementos de duas listas
  List<T> interleave(List<T> other) {
    final result = <T>[];
    final maxLength = length > other.length ? length : other.length;
    
    for (int i = 0; i < maxLength; i++) {
      if (i < length) result.add(this[i]);
      if (i < other.length) result.add(other[i]);
    }
    
    return result;
  }
  
  /// Aplica uma função a cada elemento e retorna uma nova lista
  List<R> mapIndexed<R>(R Function(int index, T element) transform) {
    final result = <R>[];
    for (int i = 0; i < length; i++) {
      result.add(transform(i, this[i]));
    }
    return result;
  }
  
  /// Executa uma ação para cada elemento com seu índice
  void forEachIndexed(void Function(int index, T element) action) {
    for (int i = 0; i < length; i++) {
      action(i, this[i]);
    }
  }
  
  /// Verifica se a lista contém todos os elementos de outra lista
  bool containsAll(Iterable<T> other) {
    return other.every((element) => contains(element));
  }
  
  /// Verifica se a lista contém algum elemento de outra lista
  bool containsAny(Iterable<T> other) {
    return other.any((element) => contains(element));
  }
  
  /// Remove todos os elementos que atendem a uma condição
  void removeWhere(bool Function(T) test) {
    removeWhere(test);
  }
  
  /// Mantém apenas os elementos que atendem a uma condição
  void retainWhere(bool Function(T) test) {
    retainWhere(test);
  }
}

/// Extensions específicas para listas de números
extension NumListExtensions<T extends num> on List<T> {
  /// Calcula a soma de todos os elementos
  T get sum {
    if (isEmpty) return 0 as T;
    return reduce((a, b) => (a + b) as T);
  }
  
  /// Calcula a média dos elementos
  double get average {
    if (isEmpty) return 0.0;
    return sum / length;
  }
  
  /// Encontra o valor máximo
  T get max {
    if (isEmpty) throw StateError('Lista vazia');
    return reduce((a, b) => a > b ? a : b);
  }
  
  /// Encontra o valor mínimo
  T get min {
    if (isEmpty) throw StateError('Lista vazia');
    return reduce((a, b) => a < b ? a : b);
  }
  
  /// Calcula a mediana
  double get median {
    if (isEmpty) return 0.0;
    
    final sorted = List<T>.from(this)..sort();
    final middle = sorted.length ~/ 2;
    
    if (sorted.length % 2 == 1) {
      return sorted[middle].toDouble();
    } else {
      return (sorted[middle - 1] + sorted[middle]) / 2;
    }
  }
  
  /// Calcula o desvio padrão
  double get standardDeviation {
    if (isEmpty) return 0.0;
    
    final avg = average;
    final squaredDiffs = map((x) => (x - avg) * (x - avg));
    final variance = squaredDiffs.reduce((a, b) => a + b) / length;
    return math.sqrt(variance);
  }
}

/// Extensions específicas para listas de strings
extension StringListExtensions on List<String> {
  /// Junta todos os elementos com um separador
  String join([String separator = '']) {
    return join(separator);
  }
  
  /// Filtra strings não vazias
  List<String> get nonEmpty => where((s) => s.isNotEmpty).toList();
  
  /// Converte todas as strings para minúsculas
  List<String> get toLowerCase => map((s) => s.toLowerCase()).toList();
  
  /// Converte todas as strings para maiúsculas
  List<String> get toUpperCase => map((s) => s.toUpperCase()).toList();
  
  /// Remove espaços em branco de todas as strings
  List<String> get trimmed => map((s) => s.trim()).toList();
  
  /// Encontra strings que contêm um termo de busca
  List<String> containing(String searchTerm, {bool caseSensitive = false}) {
    final term = caseSensitive ? searchTerm : searchTerm.toLowerCase();
    return where((s) {
      final text = caseSensitive ? s : s.toLowerCase();
      return text.contains(term);
    }).toList();
  }
  
  /// Encontra strings que começam com um prefixo
  List<String> startingWith(String prefix, {bool caseSensitive = false}) {
    final prefixToCheck = caseSensitive ? prefix : prefix.toLowerCase();
    return where((s) {
      final text = caseSensitive ? s : s.toLowerCase();
      return text.startsWith(prefixToCheck);
    }).toList();
  }
  
  /// Encontra strings que terminam com um sufixo
  List<String> endingWith(String suffix, {bool caseSensitive = false}) {
    final suffixToCheck = caseSensitive ? suffix : suffix.toLowerCase();
    return where((s) {
      final text = caseSensitive ? s : s.toLowerCase();
      return text.endsWith(suffixToCheck);
    }).toList();
  }
}

