import 'package:flutter/material.dart';

enum AppStep { landing, intake, analyzing, result }

class QuestionModel {
  final String id;
  final String label;
  final String placeholder;
  final IconData icon;
  final Color color;
  final List<String> suggestions;

  const QuestionModel({
    required this.id,
    required this.label,
    required this.placeholder,
    required this.icon,
    required this.color,
    required this.suggestions,
  });
}

class AnimalBiteModels {
  static const List<QuestionModel> questions = [
    QuestionModel(
      id: 'animal',
      label: 'Which animal bit you?',
      placeholder: 'e.g. dog, cat, bat…',
      icon: Icons.pets_rounded,
      color: Color(0xFFDC2626),
      suggestions: ['Dog', 'Cat', 'Bat', 'Fox', 'Raccoon', 'Skunk', 'Rabbit', 'Squirrel', 'Rat'],
    ),
    QuestionModel(
      id: 'time',
      label: 'How long ago did the bite occur?',
      placeholder: 'e.g. 30 minutes, 2 hours…',
      icon: Icons.schedule_rounded,
      color: Color(0xFFD97706),
      suggestions: ['< 30 min', '1 hour', '2 hours', '5 hours', 'Yesterday', '2 days ago'],
    ),
    QuestionModel(
      id: 'location',
      label: 'Where on the body is the bite?',
      placeholder: 'e.g. hand, leg, face…',
      icon: Icons.accessibility_new_rounded,
      color: Color(0xFF7C3AED),
      suggestions: ['Hand', 'Arm', 'Leg', 'Foot', 'Face', 'Neck', 'Torso', 'Finger'],
    ),
    QuestionModel(
      id: 'depth',
      label: 'How deep does the wound appear?',
      placeholder: 'e.g. scratch, deep puncture…',
      icon: Icons.cut_rounded,
      color: Color(0xFFDC2626),
      suggestions: ['Scratch', 'Broke skin', 'Superficial', 'Deep puncture', 'Tear', 'Laceration'],
    ),
    QuestionModel(
      id: 'bleeding',
      label: 'Is it bleeding?',
      placeholder: 'e.g. no, minor, heavy…',
      icon: Icons.water_drop_rounded,
      color: Color(0xFFDC2626),
      suggestions: ['No bleeding', 'Minor', 'Moderate', 'Heavy', 'Stopped'],
    ),
    QuestionModel(
      id: 'animal_status',
      label: 'Do you know the animal\'s status?',
      placeholder: 'e.g. vaccinated, stray…',
      icon: Icons.vaccines_rounded,
      color: Color(0xFF059669),
      suggestions: ['Vaccinated', 'Stray', 'Unknown', 'Wild', 'Domestic', 'Foaming at mouth'],
    ),
    QuestionModel(
      id: 'region',
      label: 'What country or region are you in?',
      placeholder: 'e.g. USA, India, Europe…',
      icon: Icons.public_rounded,
      color: Color(0xFF0891B2),
      suggestions: ['USA', 'India', 'Southeast Asia', 'Europe', 'Africa', 'South America'],
    ),
  ];
}