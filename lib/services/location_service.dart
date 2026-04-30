import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../utils/app_constants.dart';

class Hospital {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String phone;
  final bool isEmergency;
  final String type;
  double? distanceKm;

  Hospital({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phone,
    required this.isEmergency,
    required this.type,
    this.distanceKm,
  });
}

class LocationService {
  static LocationService? _instance;
  static Position? _currentPosition;

  LocationService._();

  static LocationService get instance {
    _instance ??= LocationService._();
    return _instance!;
  }

  Position? get currentPosition => _currentPosition;

  Future<Position?> getCurrentPosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled.');
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permissions denied.');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permissions permanently denied.');
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      ).then((pos) {
        _currentPosition = pos;
        return pos;
      });
    } catch (e) {
      debugPrint('Error getting location: $e');
      return null;
    }
  }

  Future<List<Hospital>> getNearbyHospitals({
    double? latitude,
    double? longitude,
  }) async {
    final lat = latitude ?? AppConstants.defaultLatitude;
    final lng = longitude ?? AppConstants.defaultLongitude;

    // Mock hospital data with realistic locations near the given coordinates
    final mockHospitals = [
      Hospital(
        id: '1',
        name: 'City General Hospital',
        address: '123 Medical Center Drive',
        latitude: lat + 0.015,
        longitude: lng + 0.02,
        phone: '+1-555-0100',
        isEmergency: true,
        type: 'General Hospital',
      ),
      Hospital(
        id: '2',
        name: 'St. Mary\'s Medical Center',
        address: '456 Healthcare Blvd',
        latitude: lat - 0.01,
        longitude: lng + 0.03,
        phone: '+1-555-0200',
        isEmergency: true,
        type: 'Medical Center',
      ),
      Hospital(
        id: '3',
        name: 'Community Health Clinic',
        address: '789 Wellness Ave',
        latitude: lat + 0.025,
        longitude: lng - 0.015,
        phone: '+1-555-0300',
        isEmergency: false,
        type: 'Health Clinic',
      ),
      Hospital(
        id: '4',
        name: 'Urgent Care Plus',
        address: '321 Quick Care Street',
        latitude: lat - 0.02,
        longitude: lng - 0.01,
        phone: '+1-555-0400',
        isEmergency: false,
        type: 'Urgent Care',
      ),
      Hospital(
        id: '5',
        name: 'Children\'s Medical Center',
        address: '654 Pediatric Way',
        latitude: lat + 0.035,
        longitude: lng + 0.01,
        phone: '+1-555-0500',
        isEmergency: true,
        type: 'Children\'s Hospital',
      ),
      Hospital(
        id: '6',
        name: 'Regional Vaccination Clinic',
        address: '987 Immunization Lane',
        latitude: lat - 0.03,
        longitude: lng + 0.025,
        phone: '+1-555-0600',
        isEmergency: false,
        type: 'Vaccination Clinic',
      ),
    ];

    // Calculate distances
    for (final hospital in mockHospitals) {
      hospital.distanceKm = _calculateDistance(
        lat,
        lng,
        hospital.latitude,
        hospital.longitude,
      );
    }

    // Sort by distance
    mockHospitals.sort((a, b) =>
        (a.distanceKm ?? double.infinity)
            .compareTo(b.distanceKm ?? double.infinity));

    return mockHospitals;
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000.0;
  }

  String formatDistance(double? distanceKm) {
    if (distanceKm == null) return 'Unknown';
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()} m away';
    }
    return '${distanceKm.toStringAsFixed(1)} km away';
  }
}
