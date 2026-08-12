import 'package:url_launcher/url_launcher.dart';

import 'app_logger.dart';

/// Utility class for formatting, normalizing, and launching URLs cleanly across all platforms.
abstract class UrlUtils {
  /// Normalizes any raw URL string to ensure it has a valid protocol
  /// and handles known domain variations (such as Firebase default domain www. fixes).
  static String normalizeUrl(String rawUrl) {
    String formatted = rawUrl.trim();
    if (formatted.isEmpty) return formatted;

    // Fix scheme if missing
    final lower = formatted.toLowerCase();
    if (!lower.startsWith('http://') &&
        !lower.startsWith('https://') &&
        !lower.startsWith('mailto:') &&
        !lower.startsWith('tel:') &&
        !lower.startsWith('sms:')) {
      formatted = 'https://$formatted';
    }

    // Replace uppercase scheme (e.g. HTTP:// -> https://)
    if (formatted.toLowerCase().startsWith('http://')) {
      formatted = 'http://${formatted.substring(7)}';
    } else if (formatted.toLowerCase().startsWith('https://')) {
      formatted = 'https://${formatted.substring(8)}';
    }

    // Firebase Hosting default subdomains (*.web.app & *.firebaseapp.com) do NOT
    // support www. subdomains (e.g. https://www.expendly.web.app fails SSL handshakes).
    // Automatically normalize www.<app>.web.app -> <app>.web.app
    formatted = formatted.replaceAll(
      '://www.expendly.web.app',
      '://expendly.web.app',
    );
    formatted = formatted.replaceAll(
      '://www.expendly.firebaseapp.com',
      '://expendly.firebaseapp.com',
    );

    return formatted;
  }

  /// Parses and launches an external URL with automatic fallback strategies.
  /// Works for URLs with or without http(s)://, www., or trailing paths.
  static Future<bool> launchExternalUrl(String rawUrl) async {
    try {
      final formattedUrl = normalizeUrl(rawUrl);
      final uri = Uri.parse(formattedUrl);

      // Attempt 1: Open in external application (system default browser)
      try {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (launched) {
          AppLogger.i('Launched external URL: $formattedUrl');
          return true;
        }
      } catch (e) {
        AppLogger.w(
            'LaunchMode.externalApplication failed for $formattedUrl, retrying platformDefault...',
            e);
      }

      // Attempt 2: Fallback to platform default launch mode
      if (await canLaunchUrl(uri)) {
        final launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
        if (launched) {
          AppLogger.i('Launched external URL (platformDefault): $formattedUrl');
          return true;
        }
      }

      AppLogger.w('Could not launch URL: $formattedUrl');
      return false;
    } catch (e, stackTrace) {
      AppLogger.e('Error launching external URL: $rawUrl', e, stackTrace);
      return false;
    }
  }
}
