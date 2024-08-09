class AndroidPromptInfo {
  String? title;
  String? subtitle;
  String? description;
  String? negativeButton;
  bool invalidatedByBiometricEnrollment;

  AndroidPromptInfo({
    this.title,
    this.subtitle,
    this.description,
    this.negativeButton,
    this.invalidatedByBiometricEnrollment = false,
  });
}
