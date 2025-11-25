import 'package:latres/models/amiibo_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://www.amiiboapi.com/api/amiibo";

  // Get all data
  static Future<List<Amiibo>> fetchAmiiboList() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List amiiboList = data['amiibo'];
      return amiiboList.map((json) => Amiibo.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load amiibo list');
    }
  }

  // Get Head
  static Future<Amiibo> fetchAmiiboByHead(String head) async {
    final response = await http.get(Uri.parse("$baseUrl?head=$head"));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final amiiboList = data['amiibo'] as List;
      return Amiibo.fromJson(amiiboList.first);
    } else {
      throw Exception('Failed to load amiibo list');
    }
  }
}
