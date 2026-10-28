import 'package:flutter_test/flutter_test.dart';
import 'package:smarttravel_mobile/features/destination/data/models/destination_model.dart';

void main() {
  group('DestinationModel Test', () {
    test('fromJson parses JSON correctly with full fields including new API fields', () {
      final json = {
        'id': 1,
        'name': 'Bà Nà Hills',
        'category': 'Tham quan',
        'categoryId': 2,
        'description': 'Khu du lịch nổi tiếng',
        'address': 'Hòa Vang, Đà Nẵng',
        'openingHours': '07:00 - 21:00',
        'phone': '0901234567',
        'website': 'https://banahills.sunworld.vn',
        'imageUrl': 'https://example.com/banner.jpg',
        'subImages': ['https://example.com/sub1.jpg', 'https://example.com/sub2.jpg'],
        'rating': 4.7,
        'reviewCount': 520,
        'osmId': 'node/123456',
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
      expect(model.categoryId, equals(2));
      expect(model.description, equals('Khu du lịch nổi tiếng'));
      expect(model.address, equals('Hòa Vang, Đà Nẵng'));
      expect(model.openingHours, equals('07:00 - 21:00'));
      expect(model.phone, equals('0901234567'));
      expect(model.website, equals('https://banahills.sunworld.vn'));
      expect(model.imageUrl, equals('https://example.com/banner.jpg'));
      expect(model.subImages.length, equals(2));
      expect(model.subImages[0], equals('https://example.com/sub1.jpg'));
      expect(model.rating, equals(4.7));
      expect(model.reviewCount, equals(520));
      expect(model.osmId, equals('node/123456'));
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
      expect(model.address, isNull);
      expect(model.imageUrl, isNull);
      expect(model.subImages, isEmpty);
      expect(model.rating, equals(0.0));
      expect(model.reviewCount, equals(0));
      expect(model.latitude, equals(0.0));
      expect(model.longitude, equals(0.0));
      expect(model.status, equals('ACTIVE'));
    });
  });
}
