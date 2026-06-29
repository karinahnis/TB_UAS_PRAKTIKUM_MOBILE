class AppException implements Exception {
  final String message;
  final int? statusCode;

  AppException({required this.message, this.statusCode});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException({String? message})
      : super(message: message ?? 'Tidak ada koneksi internet');
}

class UnauthorizedException extends AppException {
  UnauthorizedException({String? message})
      : super(message: message ?? 'Sesi habis, silakan login ulang', statusCode: 401);
}

class ValidationException extends AppException {
  final Map<String, dynamic>? errors;

  ValidationException({String? message, this.errors})
      : super(message: message ?? 'Validasi gagal', statusCode: 422);
}

class ServerException extends AppException {
  ServerException({String? message, super.statusCode})
      : super(message: message ?? 'Terjadi kesalahan server');
}
