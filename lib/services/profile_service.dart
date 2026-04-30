import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class CareProfile {
  final String id;
  final String name;

  const CareProfile({required this.id, required this.name});

  Map<String, dynamic> toMap() => {'id': id, 'name': name};

  static CareProfile fromMap(Map<String, dynamic> map) {
    return CareProfile(
      id: (map['id'] as String?) ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: (map['name'] as String?) ?? 'Profile',
    );
  }
}

class ProfileService {
  ProfileService._();
  static const _profilesKey = 'care_profiles';
  static const _selectedKey = 'selected_care_profile';

  static final ProfileService instance = ProfileService._();

  Future<List<CareProfile>> getProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_profilesKey);
    if (raw == null || raw.isEmpty) return const [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return decoded
        .whereType<Map>()
        .map((m) => CareProfile.fromMap(Map<String, dynamic>.from(m)))
        .toList();
  }

  Future<void> saveProfiles(List<CareProfile> profiles) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _profilesKey,
      jsonEncode(profiles.map((p) => p.toMap()).toList()),
    );
  }

  Future<String?> getSelectedProfileId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedKey);
  }

  Future<void> setSelectedProfileId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedKey, id);
  }
}
