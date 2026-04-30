import '../services/sqlite_service.dart';

class MedicineReminder {
  final int? id;
  final String medicineName;
  final String dosage;
  final String frequency;
  final String time;
  final DateTime startDate;
  final DateTime? endDate;
  final String? notes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  MedicineReminder({
    this.id,
    required this.medicineName,
    required this.dosage,
    required this.frequency,
    required this.time,
    required this.startDate,
    this.endDate,
    this.notes,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'medicine_name': medicineName,
      'dosage': dosage,
      'frequency': frequency,
      'time': time,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'notes': notes,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  static MedicineReminder fromMap(Map<String, dynamic> map) {
    return MedicineReminder(
      id: map['id'] as int?,
      medicineName: map['medicine_name'] as String,
      dosage: map['dosage'] as String,
      frequency: map['frequency'] as String,
      time: map['time'] as String,
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: map['end_date'] != null ? DateTime.parse(map['end_date'] as String) : null,
      notes: map['notes'] as String?,
      isActive: (map['is_active'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}

class MedicineReminderService {
  static MedicineReminderService? _instance;

  MedicineReminderService._();

  static MedicineReminderService get instance {
    _instance ??= MedicineReminderService._();
    return _instance!;
  }

  Future<int> addReminder(MedicineReminder reminder) async {
    final db = SQLiteService.instance;
    return await db.insert('medicine_reminders', reminder.toMap());
  }

  Future<List<MedicineReminder>> getAllReminders() async {
    final db = SQLiteService.instance;
    final results = await db.query('medicine_reminders', orderBy: 'time ASC');
    return results.map((map) => MedicineReminder.fromMap(map)).toList();
  }

  Future<List<MedicineReminder>> getActiveReminders() async {
    final db = SQLiteService.instance;
    final results = await db.query(
      'medicine_reminders',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'time ASC',
    );
    return results.map((map) => MedicineReminder.fromMap(map)).toList();
  }

  Future<void> updateReminder(MedicineReminder reminder) async {
    final db = SQLiteService.instance;
    await db.update(
      'medicine_reminders',
      {...reminder.toMap(), 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [reminder.id],
    );
  }

  Future<void> deleteReminder(int id) async {
    final db = SQLiteService.instance;
    await db.delete(
      'medicine_reminders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> toggleReminder(int id, bool isActive) async {
    final db = SQLiteService.instance;
    await db.update(
      'medicine_reminders',
      {
        'is_active': isActive ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}