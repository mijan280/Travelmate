import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travelmate/models/api_response.dart';
import 'package:travelmate/models/destination.dart';
import 'package:travelmate/models/user.dart';
import 'package:travelmate/services/api/api_config.dart';

void main() {
  group('TravelMate Model & Configuration Unit Tests', () {
    test('User model serializes and deserializes correctly', () {
      final json = {
        'id': '101',
        'name': 'Test Traveler',
        'email': 'traveler@test.com',
        'role': 'traveler',
        'createdAt': '2026-11-09T00:00:00.000Z',
      };

      final user = User.fromJson(json);
      expect(user.id, '101');
      expect(user.name, 'Test Traveler');
      expect(user.email, 'traveler@test.com');
      expect(user.role, 'traveler');

      final serialized = user.toJson();
      expect(serialized['id'], '101');
      expect(serialized['name'], 'Test Traveler');
      expect(serialized['email'], 'traveler@test.com');
    });

    test('Destination model parses json and maps icons properly', () {
      final json = {
        'id': '1',
        'name': 'Cox’s Bazar',
        'country': 'Bangladesh',
        'subtitle': 'Sea and sunsets',
        'description': 'Enjoy a long sandy beach.',
        'icon': 'beach_access',
        'isPopular': true,
      };

      final destination = Destination.fromJson(json);
      expect(destination.id, '1');
      expect(destination.name, 'Cox’s Bazar');
      expect(destination.isPopular, true);
      expect(destination.iconData, Icons.beach_access_rounded);

      const landscapeDest = Destination(
        id: '2',
        name: 'Sajek',
        country: 'BD',
        subtitle: 'Hills',
        description: 'Green hills',
        iconName: 'landscape',
      );
      expect(landscapeDest.iconData, Icons.landscape_rounded);

      const forestDest = Destination(
        id: '3',
        name: 'Sundarbans',
        country: 'BD',
        subtitle: 'Mangrove',
        description: 'Forest',
        iconName: 'forest',
      );
      expect(forestDest.iconData, Icons.forest_rounded);

      const floristDest = Destination(
        id: '4',
        name: 'Sreemangal',
        country: 'BD',
        subtitle: 'Tea',
        description: 'Gardens',
        iconName: 'local_florist',
      );
      expect(floristDest.iconData, Icons.local_florist_rounded);

      const sailingDest = Destination(
        id: '5',
        name: 'St Martin',
        country: 'BD',
        subtitle: 'Island',
        description: 'Coral',
        iconName: 'sailing',
      );
      expect(sailingDest.iconData, Icons.sailing_rounded);
    });

    test('ApiResponse deserializes payload correctly', () {
      final json = {
        'success': true,
        'message': 'Data loaded',
        'data': {'id': '99', 'name': 'Sample', 'email': 'sample@test.com', 'role': 'traveler'},
      };

      final response = ApiResponse<User>.fromJson(
        json,
        (data) => User.fromJson(data as Map<String, dynamic>),
      );

      expect(response.success, true);
      expect(response.message, 'Data loaded');
      expect(response.data?.name, 'Sample');
    });

    test('ApiConfig provides expected routes and configuration', () {
      expect(ApiConfig.port, 3000);
      expect(ApiConfig.customHostIp, '192.168.0.106');
      expect(ApiConfig.emulatorBaseUrl, 'http://10.0.2.2:3000/api');
      expect(ApiConfig.physicalDeviceBaseUrl, 'http://192.168.0.106:3000/api');
      expect(ApiConfig.timeout, const Duration(seconds: 10));
    });
  });
}
