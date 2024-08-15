class AndroidPromptInfo {
  String title;
  String subtitle;
  String? description;
  String negativeButton;
  bool invalidatedByBiometricEnrollment;

  AndroidPromptInfo({
    required this.title,
    required this.subtitle,
    this.description,
    required this.negativeButton,
    this.invalidatedByBiometricEnrollment = false,
  });
}
