class CustomError {
  final String code;
  final String plugin;
  final String message;

  CustomError({
    required this.code,
    required this.plugin,
    required this.message,
  });

  @override
  String toString() {
    return 'CustomError(code: $code, plugin: $plugin, message: $message)';
  }
}
