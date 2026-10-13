import 'package:geolocator/geolocator.dart';
import 'package:jivaan_net_client/jivaan_net_client.dart';

class SosService {
  SosService(this.client);

  final Client client;
  final Uuid _uuid = const Uuid();

  /// Gets the device's real GPS coordinates.
  /// Throws an exception if location cannot be obtained.
  Future<Position> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception('Please enable GPS/location services.');
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception('Location permission was denied.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permission is permanently denied. '
        'Enable it in your device settings.',
      );
    }

    return Geolocator.getCurrentPosition();
  }

  /// Submits an SOS using an existing incident ID and timestamp.
  /// Reuse both values when retrying the same incident.
  Future<SosSubmissionResponse> submitSos({
    required String incidentId,
    required double latitude,
    required double longitude,
    required DateTime createdAt,
    required String description,
    String? sourceDeviceId,
    int relayCount = 0,
  }) async {
    final payload = SosSubmissionPayload(
      incidentId: incidentId,
      latitude: latitude,
      longitude: longitude,
      createdAt: createdAt,
      description: description,
      sourceDeviceId: sourceDeviceId,
      relayCount: relayCount,
    );

    return client.incident.submitSos(payload);
  }

  /// Generates an ID for a brand-new SOS.
  String createIncidentId() => _uuid.v4();
}
