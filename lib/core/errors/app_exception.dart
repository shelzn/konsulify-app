class AppException implements Exception {
  AppException(this.message, {this.statusCode, this.errors});

  final String message;
  final int? statusCode;
  final Object? errors;

  @override
  String toString() => message;
}
