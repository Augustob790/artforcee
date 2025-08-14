import '../models.dart';

/// Classe abstrata base para campos de formulário dinâmico
abstract class FormField extends BaseModel {
  final String name;
  final String label;
  final FieldType type;
  final bool isRequired;
  bool isVisible;
  bool isEnabled;
  final dynamic defaultValue;
  final String? helpText;
  final int order;

  FormField({
    required super.id,
    required this.name,
    required this.label,
    required this.type,
    this.isRequired = false,
    this.isVisible = true,
    this.isEnabled = true,
    this.defaultValue,
    this.helpText,
    this.order = 0,
    super.createdAt,
    super.updatedAt,
  });

  /// Valida o valor do campo
  List<String> validate(dynamic value);

  /// Renderiza o widget apropriado para este campo
  /// Retorna um Map com as propriedades necessárias para o widget
  Map<String, dynamic> getWidgetProperties();

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'label': label,
      'type': type.name,
      'isRequired': isRequired,
      'isVisible': isVisible,
      'isEnabled': isEnabled,
      'defaultValue': defaultValue,
      'helpText': helpText,
      'order': order,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
