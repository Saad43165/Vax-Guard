import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/user_profile_service.dart';

class UserProfileNotifier extends ChangeNotifier {
  UserProfile _profile = const UserProfile();

  UserProfileNotifier._();

  static UserProfileNotifier? _instance;
  static UserProfileNotifier get instance {
    _instance ??= UserProfileNotifier._();
    return _instance!;
  }

  UserProfile get profile => _profile;

  Future<void> load() async {
    _profile = await UserProfileService.getProfile();
    notifyListeners();
  }

  Future<void> updateProfile(UserProfile newProfile) async {
    await UserProfileService.saveProfile(newProfile);
    _profile = newProfile;
    notifyListeners();
  }
}
