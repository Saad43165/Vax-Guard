import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

class OutbreakAlert {
  final String id;
  final String disease;
  final String region;
  final String description;
  final String severity;
  final DateTime reportedAt;
  final List<String> preventionTips;

  const OutbreakAlert({
    required this.id,
    required this.disease,
    required this.region,
    required this.description,
    required this.severity,
    required this.reportedAt,
    required this.preventionTips,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'disease': disease,
    'region': region,
    'description': description,
    'severity': severity,
    'reportedAt': reportedAt.toIso8601String(),
    'preventionTips': preventionTips,
  };

  factory OutbreakAlert.fromJson(Map<String, dynamic> json) => OutbreakAlert(
    id: json['id'],
    disease: json['disease'],
    region: json['region'],
    description: json['description'],
    severity: json['severity'],
    reportedAt: DateTime.parse(json['reportedAt']),
    preventionTips: List<String>.from(json['preventionTips']),
  );
}

class LiveOutbreakService {
  LiveOutbreakService._();
  static final LiveOutbreakService instance = LiveOutbreakService._();

  static const String _cacheKey = 'cached_outbreaks';
  static const String _cacheTimeKey = 'outbreaks_cached_at';

  final List<OutbreakAlert> _mockDatabase = [
    OutbreakAlert(
      id: 'OB-001',
      disease: 'dengue_fever',
      region: 'southeast_asia',
      description: 'Significant spike in Dengue cases due to heavy monsoon rains. Hospitals in the region are on high alert for severe hemorrhagic manifestations.',
      severity: 'critical',
      reportedAt: DateTime.now().subtract(const Duration(hours: 2)),
      preventionTips: [
        'Eliminate standing water around your home',
        'Use mosquito repellent (DEET-based)',
        'Wear long-sleeved clothing at dawn and dusk',
        'Use mosquito nets while sleeping',
      ],
    ),
    OutbreakAlert(
      id: 'OB-002',
      disease: 'hantavirus_pulmonary',
      region: 'north_america_rural',
      description: 'Cluster detected in rural communities. Traced to deer mouse exposure in poorly ventilated cabins and barns. Early detection is critical for survival.',
      severity: 'high',
      reportedAt: DateTime.now().subtract(const Duration(hours: 14)),
      preventionTips: [
        'Ventilate closed spaces (cabins, sheds) for 30 min before entering',
        'Wet-mop with disinfectant instead of sweeping rodent droppings',
        'Seal all holes and gaps in building foundations',
        'Store food in rodent-proof containers',
      ],
    ),
    OutbreakAlert(
      id: 'OB-003',
      disease: 'influenza_a',
      region: 'global',
      description: 'Early seasonal surge of H1N1 strain detected. WHO recommends immediate vaccination for high-risk groups including the elderly and children.',
      severity: 'moderate',
      reportedAt: DateTime.now().subtract(const Duration(days: 1)),
      preventionTips: [
        'Get the annual influenza vaccine',
        'Wash hands frequently with soap for at least 20 seconds',
        'Avoid close contact with sick individuals',
        'Stay home if you have a fever',
      ],
    ),
    OutbreakAlert(
      id: 'OB-004',
      disease: 'cholera',
      region: 'subsaharan_africa',
      description: 'Localized outbreaks linked to contaminated water sources following severe flooding. Rapid rehydration is mandatory for affected individuals.',
      severity: 'high',
      reportedAt: DateTime.now().subtract(const Duration(days: 2)),
      preventionTips: [
        'Drink only boiled or sealed bottled water',
        'Wash hands with soap before eating and after using the toilet',
        'Cook seafood and other foods thoroughly',
        'Seek immediate medical attention for severe diarrhea',
      ],
    ),
    OutbreakAlert(
      id: 'OB-005',
      disease: 'mpox',
      region: 'central_west_africa',
      description: 'Sustained community transmission reported. Public health surveillance has been intensified in urban hubs.',
      severity: 'moderate',
      reportedAt: DateTime.now().subtract(const Duration(days: 3)),
      preventionTips: [
        'Avoid close skin-to-skin contact with infected persons',
        'Avoid handling materials (bedding, clothing) of infected persons',
        'Wash hands frequently',
        'Isolate if you have suspicious rash or lesions',
      ],
    ),
  ];

  /// Fetches outbreaks. Returns cached data instantly if offline or cache is fresh.
  Future<List<OutbreakAlert>> fetchActiveOutbreaks({bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();

    // Check cache freshness (cache is valid for 1 hour)
    final cachedTimeStr = prefs.getString(_cacheTimeKey);
    final cachedTime = cachedTimeStr != null ? DateTime.tryParse(cachedTimeStr) : null;
    final isCacheFresh = cachedTime != null &&
        DateTime.now().difference(cachedTime).inHours < 1;

    if (!forceRefresh && isCacheFresh) {
      return _loadFromCache(prefs);
    }

    try {
      // Simulate network fetch with delay
      await Future.delayed(const Duration(seconds: 2));

      // In production: replace with HTTP GET to CDC/WHO API
      var results = List<OutbreakAlert>.from(_mockDatabase);

      try {
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
          timeLimit: const Duration(seconds: 3),
        );
        final userRegion = _determineRegion(pos.latitude, pos.longitude);
        
        final filtered = results.where((alert) => alert.region == userRegion || alert.region == 'Global').toList();
        if (filtered.length > 1) {
          results = filtered;
        }
      } catch (_) {
        // Fallback to all mock data if location fails
      }

      results.sort((a, b) => b.reportedAt.compareTo(a.reportedAt));

      // Save to cache
      await _saveToCache(prefs, results);

      return results;
    } catch (_) {
      // Offline fallback: return cached data or empty list
      final cached = await _loadFromCache(prefs);
      return cached.isNotEmpty ? cached : _mockDatabase;
    }
  }

  Future<void> _saveToCache(SharedPreferences prefs, List<OutbreakAlert> alerts) async {
    final jsonList = alerts.map((a) => jsonEncode(a.toJson())).toList();
    await prefs.setStringList(_cacheKey, jsonList);
    await prefs.setString(_cacheTimeKey, DateTime.now().toIso8601String());
  }

  Future<List<OutbreakAlert>> _loadFromCache(SharedPreferences prefs) async {
    final jsonList = prefs.getStringList(_cacheKey) ?? [];
    try {
      return jsonList.map((j) => OutbreakAlert.fromJson(jsonDecode(j) as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Returns the most critical outbreak from cache for proximity notification checks.
  Future<OutbreakAlert?> getMostCriticalAlert() async {
    final alerts = await fetchActiveOutbreaks();
    if (alerts.isEmpty) return null;

    const priority = ['critical', 'high', 'moderate', 'low'];
    alerts.sort((a, b) {
      final aIdx = priority.indexOf(a.severity);
      final bIdx = priority.indexOf(b.severity);
      return aIdx.compareTo(bIdx);
    });
    return alerts.first;
  }

  static String _determineRegion(double lat, double lon) {
    if (lat >= 15 && lat <= 72 && lon >= -168 && lon <= -52) return 'North America';
    if (lat >= -35 && lat <= 37 && lon >= -20 && lon <= 55) {
      if (lat >= -10 && lat <= 15 && lon <= 30) return 'Central/West Africa';
      return 'Sub-Saharan Africa';
    }
    if (lat >= 5 && lat <= 38 && lon >= 68 && lon <= 98) return 'South Asia (IND/PAK)';
    if (lat >= -10 && lat <= 25 && lon >= 95 && lon <= 150) return 'Southeast Asia';
    
    return 'Global';
  }

}
