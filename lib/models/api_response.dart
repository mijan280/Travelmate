class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;

  ApiResponse({required this.success, required this.message, this.data});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic rawData)? fromDataJson,
  ) {
    return ApiResponse<T>(
      success: json['success'] == true,
      message: json['message'] as String? ?? '',
      data: json['data'] != null && fromDataJson != null
          ? fromDataJson(json['data'])
          : json['data'] as T?,
    );
  }
}
