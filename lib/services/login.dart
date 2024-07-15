import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rider/constants/key.dart';

import 'model/loginresponse.dart';
import 'model/rvalidation.dart';

class LoginService {
  LoginService();

  Future<AuthResponse> validate(String phoneNumber) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl + '/auth/pin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': phoneNumber}),
      );

      if (response.statusCode == 200) {
        return AuthResponse(statusCode: response.statusCode);
      } else {
        return AuthResponse(statusCode: response.statusCode);
      }
    } catch (error) {
      print('Error during login: $error');
      throw Exception('Failed to login');
    }
  }

  Future<RValidation> validatePin(String phoneNumber, pin) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/authenticate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': phoneNumber, "pin": pin}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return RValidation.fromJson(jsonResponse, response.statusCode);
      } else {
        throw Exception('Failed to login');
      }
    } catch (error) {
      throw Exception('Failed to login');
    }
  }

  Future<RValidation> register(phoneNumber, fullName, email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
            {'phoneNumber': phoneNumber, "fullName": fullName, "email": email}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return RValidation.fromJson(jsonResponse, response.statusCode);
      } else {
        throw Exception('Failed to login');
      }
    } catch (error) {
      throw Exception('Failed to login');
    }
  }
}
