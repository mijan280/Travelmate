class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final bool isNetworkError;

  ApiException({
    required this.message,
    this.statusCode,
    this.isNetworkError = false,
  });

  @override
  String toString() => message;
}
