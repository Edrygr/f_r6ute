import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rider/constants/key.dart';

class RegisterService {
  RegisterService();

  Future<Map<String, dynamic>> register({
    required String fullName,
    required String emailAddress,
    required String phoneNumber,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl + '/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullName': fullName,
          'email': emailAddress,
          'phoneNumber': phoneNumber,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to register: ${response.body}');
        throw Exception('Failed to register');
      }
    } catch (error) {
      print('Error during registration: $error');
      throw Exception('Failed to register');
    }
  }
}
