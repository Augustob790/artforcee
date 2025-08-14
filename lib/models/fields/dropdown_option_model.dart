/// Opção para campo dropdown
class DropdownOption {
  final dynamic value;
  final String label;
  final bool isEnabled;

  DropdownOption({
    required this.value,
    required this.label,
    this.isEnabled = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'value': value,
      'label': label,
      'isEnabled': isEnabled,
    };
  }
}
