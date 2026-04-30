// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vaccine_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VaccineRecordAdapter extends TypeAdapter<VaccineRecord> {
  @override
  final int typeId = 0;

  @override
  VaccineRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VaccineRecord(
      id: fields[9] as String,
      vaccineName: fields[0] as String,
      vaccinationDate: fields[1] as DateTime,
      lotNumber: fields[2] as String,
      administeredBy: fields[3] as String?,
      notes: fields[4] as String?,
      isCompleted: fields[5] as bool,
      nextDoseDate: fields[6] as DateTime?,
      doseNumber: fields[7] as String?,
      clinicName: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, VaccineRecord obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.vaccineName)
      ..writeByte(1)
      ..write(obj.vaccinationDate)
      ..writeByte(2)
      ..write(obj.lotNumber)
      ..writeByte(3)
      ..write(obj.administeredBy)
      ..writeByte(4)
      ..write(obj.notes)
      ..writeByte(5)
      ..write(obj.isCompleted)
      ..writeByte(6)
      ..write(obj.nextDoseDate)
      ..writeByte(7)
      ..write(obj.doseNumber)
      ..writeByte(8)
      ..write(obj.clinicName)
      ..writeByte(9)
      ..write(obj.id);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VaccineRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
