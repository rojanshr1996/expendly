import 'package:equatable/equatable.dart';

/// Represents a parsed notification action payload from FCM or Local Notifications.
class NotificationActionPayload extends Equatable {
  final String? action;
  final String? actionType;
  final String? target;
  final String? imageUrl;
  final String? title;
  final String? body;
  final Map<String, dynamic> data;

  const NotificationActionPayload({
    this.action,
    this.actionType,
    this.target,
    this.imageUrl,
    this.title,
    this.body,
    this.data = const {},
  });

  /// Factory constructor to parse map payload from FCM `message.data` or local notification payload
  factory NotificationActionPayload.fromMap(
    Map<String, dynamic> rawMap, {
    String? title,
    String? body,
    String? notificationImageUrl,
  }) {
    // Standardize key lookups (case-insensitive & camel/snake case fallback)
    String? getString(List<String> keys) {
      for (final key in keys) {
        if (rawMap.containsKey(key) && rawMap[key] != null) {
          final value = rawMap[key].toString().trim();
          if (value.isNotEmpty) return value;
        }
      }
      return null;
    }

    final action = getString(['action', 'action_name', 'event']);
    final actionType = getString(['action_type', 'actionType', 'type', 'category']);
    final target = getString(['target', 'route', 'url', 'id', 'transaction_id', 'transactionId']);
    final payloadImageUrl = getString(['image', 'imageUrl', 'image_url', 'picture', 'icon']);
    final payloadTitle = title ?? getString(['title', 'subject']);
    final payloadBody = body ?? getString(['body', 'message']);

    return NotificationActionPayload(
      action: action,
      actionType: actionType,
      target: target,
      imageUrl: notificationImageUrl ?? payloadImageUrl,
      title: payloadTitle,
      body: payloadBody,
      data: rawMap,
    );
  }

  /// Whether this payload specifies an external URL action
  bool get isUrlAction {
    final type = actionType?.toLowerCase();
    final act = action?.toLowerCase();

    final isUrlType = type == 'externalurl' ||
        type == 'external_url' ||
        type == 'url' ||
        act == 'open_url';

    final hasUrl = (action != null && _isLink(action!)) ||
        (target != null && _isLink(target!));

    return isUrlType || hasUrl;
  }

  static bool _isLink(String str) {
    final trimmed = str.trim().toLowerCase();
    return trimmed.startsWith('http://') ||
        trimmed.startsWith('https://') ||
        trimmed.startsWith('www.');
  }

  /// Returns the URL link string to open
  String? get urlToOpen {
    if (action != null && _isLink(action!)) return action;
    if (target != null && _isLink(target!)) return target;
    if (actionType?.toLowerCase() == 'externalurl' ||
        actionType?.toLowerCase() == 'external_url' ||
        actionType?.toLowerCase() == 'url') {
      return action ?? target;
    }
    return target ?? action;
  }

  /// Whether this payload specifies a navigation action
  bool get isNavigationAction =>
      (actionType?.toLowerCase() == 'navigation' ||
          actionType?.toLowerCase() == 'navigate' ||
          (action != null && action != 'open_url')) &&
      !isUrlAction;

  @override
  List<Object?> get props => [
        action,
        actionType,
        target,
        imageUrl,
        title,
        body,
        data,
      ];
}
