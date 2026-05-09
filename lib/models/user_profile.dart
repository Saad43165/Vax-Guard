class UserProfile {
  final String name;
  final int? age;
  final String? sex;
  final bool isPregnant;
  final bool hasDiabetes;
  final bool hasHypertension;
  final bool hasHeartDisease;
  final bool hasAsthma;
  final bool hasKidneyDisease;
  final bool isImmunocompromised;
  final bool hasCompletedOnboarding;

  const UserProfile({
    this.name = '',
    this.age,
    this.sex,
    this.isPregnant = false,
    this.hasDiabetes = false,
    this.hasHypertension = false,
    this.hasHeartDisease = false,
    this.hasAsthma = false,
    this.hasKidneyDisease = false,
    this.isImmunocompromised = false,
    this.hasCompletedOnboarding = false,
  });

  bool get hasAnyCondition =>
      hasDiabetes ||
      hasHypertension ||
      hasHeartDisease ||
      hasAsthma ||
      hasKidneyDisease ||
      isImmunocompromised;

  bool get isHighRisk {
    if (age != null && age! >= 65) return true;
    if (isPregnant) return true;
    if (hasHeartDisease) return true;
    if (isImmunocompromised) return true;
    if (hasKidneyDisease) return true;
    return false;
  }

  UserProfile copyWith({
    String? name,
    int? age,
    String? sex,
    bool? isPregnant,
    bool? hasDiabetes,
    bool? hasHypertension,
    bool? hasHeartDisease,
    bool? hasAsthma,
    bool? hasKidneyDisease,
    bool? isImmunocompromised,
    bool? hasCompletedOnboarding,
  }) {
    return UserProfile(
      name: name ?? this.name,
      age: age ?? this.age,
      sex: sex ?? this.sex,
      isPregnant: isPregnant ?? this.isPregnant,
      hasDiabetes: hasDiabetes ?? this.hasDiabetes,
      hasHypertension: hasHypertension ?? this.hasHypertension,
      hasHeartDisease: hasHeartDisease ?? this.hasHeartDisease,
      hasAsthma: hasAsthma ?? this.hasAsthma,
      hasKidneyDisease: hasKidneyDisease ?? this.hasKidneyDisease,
      isImmunocompromised: isImmunocompromised ?? this.isImmunocompromised,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'age': age,
    'sex': sex,
    'isPregnant': isPregnant,
    'hasDiabetes': hasDiabetes,
    'hasHypertension': hasHypertension,
    'hasHeartDisease': hasHeartDisease,
    'hasAsthma': hasAsthma,
    'hasKidneyDisease': hasKidneyDisease,
    'isImmunocompromised': isImmunocompromised,
    'hasCompletedOnboarding': hasCompletedOnboarding,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    name: json['name'] as String? ?? '',
    age: json['age'] as int?,
    sex: json['sex'] as String?,
    isPregnant: json['isPregnant'] as bool? ?? false,
    hasDiabetes: json['hasDiabetes'] as bool? ?? false,
    hasHypertension: json['hasHypertension'] as bool? ?? false,
    hasHeartDisease: json['hasHeartDisease'] as bool? ?? false,
    hasAsthma: json['hasAsthma'] as bool? ?? false,
    hasKidneyDisease: json['hasKidneyDisease'] as bool? ?? false,
    isImmunocompromised: json['isImmunocompromised'] as bool? ?? false,
    hasCompletedOnboarding: json['hasCompletedOnboarding'] as bool? ?? false,
  );
}
