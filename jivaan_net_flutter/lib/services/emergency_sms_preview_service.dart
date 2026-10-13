import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Helper service for constructing and launching user-confirmed test emergency SMS previews.
///
/// NOTE: This service opens the native system SMS application in interactive mode.
/// It NEVER sends background SMS, initiates phone calls, or contacts emergency responders.
class EmergencySmsPreviewService {
  /// Builds the prefilled emergency test drill message text.
  static String buildTestEmergencyMessage({
    String? incidentId,
    double? latitude,
    double? longitude,
    String? categoryLabel,
    String? description,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('[TEST DRILL — DO NOT DISPATCH]');
    buffer.writeln(
      'This is an emergency preparedness test via JivaanNet. '
      'This is NOT a real emergency. Do not contact emergency services.',
    );
    buffer.writeln();

    if (incidentId != null && incidentId.isNotEmpty) {
      final shortId = incidentId.replaceAll('-', '');
      final displayId = shortId.length > 8
          ? shortId.substring(0, 8).toUpperCase()
          : incidentId;
      buffer.writeln('Incident ID: #$displayId');
    }

    if (categoryLabel != null && categoryLabel.isNotEmpty) {
      buffer.writeln('Emergency Type: $categoryLabel');
    }

    if (description != null && description.isNotEmpty) {
      buffer.writeln('Details: $description');
    }

    if (latitude != null && longitude != null) {
      final latDir = latitude >= 0 ? 'N' : 'S';
      final lngDir = longitude >= 0 ? 'E' : 'W';
      final formattedCoords =
          '${latitude.abs().toStringAsFixed(4)}° $latDir, ${longitude.abs().toStringAsFixed(4)}° $lngDir';
      buffer.writeln('GPS Coordinates: $formattedCoords');
      buffer.writeln(
        'Map Location: https://maps.google.com/?q=$latitude,$longitude',
      );
    } else {
      buffer.writeln('GPS Coordinates: Location unavailable (test drill mode)');
    }

    return buffer.toString().trim();
  }

  /// Constructs the standard SMS URI for the recipient and message body.
  static Uri createSmsUri(String phoneNumber, String messageBody) {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final encodedBody = Uri.encodeComponent(messageBody);
    return Uri.parse('sms:$cleanPhone?body=$encodedBody');
  }

  /// Opens the native system SMS composer prefilled with the test alert.
  ///
  /// Returns `true` if the system handed off to an SMS app, or `false` on failure.
  static Future<bool> openSmsComposer({
    required String phoneNumber,
    required String messageBody,
  }) async {
    try {
      final uri = createSmsUri(phoneNumber, messageBody);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      return launched;
    } catch (e) {
      debugPrint(
        'EmergencySmsPreviewService: Failed to launch SMS composer: $e',
      );
      return false;
    }
  }
}
