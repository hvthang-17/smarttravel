import 'package:flutter_test/flutter_test.dart';
import 'package:smarttravel_mobile/features/destination/data/models/destination_model.dart';

void main() {
  group('DestinationModel Test', () {
    test('fromJson parses JSON correctly with full fields', () {
      final json = {
        'id': 1,
        'name': 'Bà Nà Hills',
        'category': 'Tham quan',
        'description': 'Khu du lịch nổi tiếng',
        'latitude': 15.9988,
        'longitude': 107.9881,
        'priceMinVnd': 700000,
        'priceMaxVnd': 1000000,
        'status': 'ACTIVE',
      };

      final model = DestinationModel.fromJson(json);

      expect(model.id, equals(1));
      expect(model.name, equals('Bà Nà Hills'));
      expect(model.category, equals('Tham quan'));
      expect(model.description, equals('Khu du lịch nổi tiếng'));
      expect(model.latitude, equals(15.9988));
      expect(model.longitude, equals(107.9881));
      expect(model.priceMinVnd, equals(700000));
      expect(model.priceMaxVnd, equals(1000000));
      expect(model.status, equals('ACTIVE'));
    });

    test('fromJson handles null values with safe defaults', () {
      final json = <String, dynamic>{};

      final model = DestinationModel.fromJson(json);

      expect(model.id, equals(0));
      expect(model.name, isEmpty);
      expect(model.category, isEmpty);
      expect(model.description, isNull);
      expect(model.latitude, equals(0.0));
      expect(model.longitude, equals(0.0));
      expect(model.status, equals('ACTIVE'));
    });
  });
}
