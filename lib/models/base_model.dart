/// Classe base abstrata para todos os modelos do sistema
abstract class BaseModel {
  final String id;
  final DateTime createdAt;
  DateTime updatedAt;

  BaseModel({
    required this.id,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Converte o modelo para um Map para serialização
  Map<String, dynamic> toMap();

  /// Cria uma instância do modelo a partir de um Map
  static BaseModel fromMap(Map<String, dynamic> map) {
    throw UnimplementedError('fromMap deve ser implementado pelas classes filhas');
  }

  /// Atualiza o timestamp de modificação
  void touch() {
    updatedAt = DateTime.now();
  }

  /// Compara dois modelos baseado no ID
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BaseModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => '$runtimeType(id: $id)';
}
