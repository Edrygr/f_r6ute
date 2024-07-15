import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rider/constants/key.dart';

import 'model/recent.dart';

class RecentService {
  Future<List<RRecent>> getRecent(String jwt) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/location/recents'),
        headers: {
          'Authorization': 'Bearer $jwt',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return RRecent.fromJsonList(data);
      } else {
        return [];
      }
    } catch (error) {
      return [];
    }
  }
}
