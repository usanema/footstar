import 'package:flutter_test/flutter_test.dart';
import 'package:footstars/features/common/services/city_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CityService', () {
    late CityService cityService;

    setUp(() {
      cityService = CityService();
    });

    test('searchCities returns empty list for empty query', () async {
      final results = await cityService.searchCities('');
      expect(results, isEmpty);
    });
  });
}
