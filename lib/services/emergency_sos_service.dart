import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencySOSService {
  EmergencySOSService._();
  static final EmergencySOSService instance = EmergencySOSService._();

  // Region-to-emergency-number mapping based on coordinate bounding boxes
  // Format: [minLat, maxLat, minLon, maxLon, number, countryName]
  static const List<List<dynamic>> _regionMap = [
    // North America
    [24.0, 72.0, -168.0, -52.0, '911', 'North America'],
    // UK
    [49.0, 61.0, -8.5, 2.0, '999', 'United Kingdom'],
    // Europe (broad)
    [35.0, 72.0, -10.0, 40.0, '112', 'Europe'],
    // Pakistan
    [23.0, 37.5, 60.5, 77.5, '115', 'Pakistan'],
    // India
    [6.0, 37.0, 68.0, 97.5, '112', 'India'],
    // China
    [18.0, 53.5, 73.5, 135.0, '120', 'China'],
    // Australia
    [-44.0, -10.0, 113.0, 154.0, '000', 'Australia'],
    // Japan
    [24.0, 46.0, 122.0, 146.0, '119', 'Japan'],
    // Brazil
    [-34.0, 5.5, -74.0, -34.0, '192', 'Brazil'],
    // Middle East (Saudi Arabia, UAE, etc.)
    [12.0, 32.0, 34.0, 63.0, '999', 'Middle East'],
    // Africa (most nations)
    [-35.0, 37.5, -17.5, 52.0, '112', 'Africa'],
  ];

  /// Returns the emergency number and country/region name for the given coordinates.
  Map<String, String> getEmergencyInfo(double lat, double lon) {
    for (final region in _regionMap) {
      final minLat = region[0] as double;
      final maxLat = region[1] as double;
      final minLon = region[2] as double;
      final maxLon = region[3] as double;
      final number = region[4] as String;
      final name = region[5] as String;

      if (lat >= minLat && lat <= maxLat && lon >= minLon && lon <= maxLon) {
        return {'number': number, 'region': name};
      }
    }
    // Global fallback
    return {'number': '112', 'region': 'International'};
  }

  /// Detects location, resolves correct emergency number, and launches the dialer.
  Future<EmergencySOSResult> callEmergency() async {
    // Check & request location permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    String number = '112';
    String region = 'International';

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      try {
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
          timeLimit: const Duration(seconds: 5),
        );
        final info = getEmergencyInfo(pos.latitude, pos.longitude);
        number = info['number']!;
        region = info['region']!;
      } catch (_) {
        // Use fallback if location times out
      }
    }

    final uri = Uri.parse('tel:$number');
    bool launched = false;
    try {
      launched = await launchUrl(uri);
    } catch (_) {
      launched = false;
    }

    return EmergencySOSResult(number: number, region: region, launched: launched);
  }
}

class EmergencySOSResult {
  final String number;
  final String region;
  final bool launched;
  const EmergencySOSResult({required this.number, required this.region, required this.launched});
}
