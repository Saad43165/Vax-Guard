import 'package:hive/hive.dart';

part 'vaccine_record.g.dart';

@HiveType(typeId: 0)
class VaccineRecord extends HiveObject {
  @HiveField(0)
  String vaccineName;

  @HiveField(1)
  DateTime vaccinationDate;

  @HiveField(2)
  String lotNumber;

  @HiveField(3)
  String? administeredBy;

  @HiveField(4)
  String? notes;

  @HiveField(5)
  bool isCompleted;

  @HiveField(6)
  DateTime? nextDoseDate;

  @HiveField(7)
  String? doseNumber;

  @HiveField(8)
  String? clinicName;

  @HiveField(9)
  String id;

  VaccineRecord({
    required this.id,
    required this.vaccineName,
    required this.vaccinationDate,
    required this.lotNumber,
    this.administeredBy,
    this.notes,
    this.isCompleted = false,
    this.nextDoseDate,
    this.doseNumber,
    this.clinicName,
  });
}