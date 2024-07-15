class RValidation {
  final String message;
  final bool registered;
  final String jwt;
  final int statusCode;

  RValidation(
      {required this.message,
      required this.statusCode,
      required this.registered,
      required this.jwt});

  factory RValidation.fromJson(Map<String, dynamic> json, int statusCode) {
    return RValidation(
      message: json['message'],
      registered: json['registered'],
      jwt: json['jwt'],
      statusCode: statusCode,
    );
  }
}
