import 'package:expendly/core/models/notification_payload.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotificationActionPayload Tests', () {
    test('parses standard action and action_type payload correctly', () {
      final map = {
        'action': 'view_transaction',
        'action_type': 'navigation',
        'target': '12345',
        'image': 'https://example.com/image.jpg',
      };

      final payload = NotificationActionPayload.fromMap(map, title: 'Test Title', body: 'Test Body');

      expect(payload.action, equals('view_transaction'));
      expect(payload.actionType, equals('navigation'));
      expect(payload.target, equals('12345'));
      expect(payload.imageUrl, equals('https://example.com/image.jpg'));
      expect(payload.title, equals('Test Title'));
      expect(payload.body, equals('Test Body'));
      expect(payload.isNavigationAction, isTrue);
      expect(payload.isUrlAction, isFalse);
    });

    test('parses camelCase actionType and image_url payload correctly', () {
      final map = {
        'action_name': 'open_url',
        'actionType': 'url',
        'url': 'https://expendly.app/insight',
        'image_url': 'https://example.com/banner.png',
      };

      final payload = NotificationActionPayload.fromMap(map);

      expect(payload.action, equals('open_url'));
      expect(payload.actionType, equals('url'));
      expect(payload.target, equals('https://expendly.app/insight'));
      expect(payload.imageUrl, equals('https://example.com/banner.png'));
      expect(payload.isUrlAction, isTrue);
      expect(payload.isNavigationAction, isFalse);
    });

    test('prioritizes explicitly passed notificationImageUrl over data image', () {
      final map = {
        'action': 'add_transaction',
        'action_type': 'navigation',
        'image': 'https://example.com/data_image.jpg',
      };

      final payload = NotificationActionPayload.fromMap(
        map,
        notificationImageUrl: 'https://example.com/notification_image.jpg',
      );

      expect(payload.imageUrl, equals('https://example.com/notification_image.jpg'));
    });

    test('parses actionType externalUrl with action containing link correctly', () {
      final map = {
        'action_type': 'externalUrl',
        'action': 'https://expendly.app/promo',
      };

      final payload = NotificationActionPayload.fromMap(map);

      expect(payload.actionType, equals('externalUrl'));
      expect(payload.action, equals('https://expendly.app/promo'));
      expect(payload.isUrlAction, isTrue);
      expect(payload.urlToOpen, equals('https://expendly.app/promo'));
      expect(payload.isNavigationAction, isFalse);
    });

    test('handles empty or missing payload fields gracefully', () {
      final map = <String, dynamic>{};

      final payload = NotificationActionPayload.fromMap(map);

      expect(payload.action, isNull);
      expect(payload.actionType, isNull);
      expect(payload.target, isNull);
      expect(payload.imageUrl, isNull);
      expect(payload.isNavigationAction, isFalse);
      expect(payload.isUrlAction, isFalse);
    });
  });
}
