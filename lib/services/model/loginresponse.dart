class AuthResponse {
  final int statusCode;

  AuthResponse({required this.statusCode});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(statusCode: json['statusCode']);
  }
}
