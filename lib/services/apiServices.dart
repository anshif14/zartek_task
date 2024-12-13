import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/restaurantData.dart';

class ApiServices {
  static const String _baseUrl =
      'https://run.mocky.io/v3/12493478-d447-4e90-90ef-791352988045';

  Future<RestaurantData> fetchRestaurantData() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));
      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonList = json.decode(response.body);
        if (jsonList.isNotEmpty) {
          final Map<String, dynamic> jsonData = jsonList;
          print('Processing restaurant data...');

          // Create mock data structure that matches our model


          return RestaurantData.fromJson(jsonData);
        } else {
          throw Exception('Empty response from server');
        }
      } else {
        throw Exception(
            'Failed to load restaurant data. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching restaurant data: $e');
      rethrow;
    }
  }
}