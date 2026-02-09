import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class CityService {
  List<String> _cities = [];

  /// Loads the city list from assets if not already loaded.
  Future<void> _loadCities() async {
    if (_cities.isNotEmpty) return;

    try {
      final String response = await rootBundle.loadString(
        'assets/pl_cities.json',
      );
      final List<dynamic> data = json.decode(response);
      _cities = data.map((e) => e.toString()).toList()
        ..sort((a, b) => a.compareTo(b));
    } catch (e) {
      // Handle error or log it
      debugPrint('Error loading cities: $e');
      _cities = [];
    }
  }

  /// Returns a list of cities matching the query.
  Future<List<String>> searchCities(String query) async {
    await _loadCities();

    if (query.isEmpty) return const [];

    final normalizedQuery = query.toLowerCase();
    return _cities.where((city) {
      return city.toLowerCase().contains(normalizedQuery);
    }).toList();
  }
}
