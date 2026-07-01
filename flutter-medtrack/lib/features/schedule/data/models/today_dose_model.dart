import '../../../medicine/data/models/medicine_model.dart';

class TodayDoseModel {
  final int scheduleId;
  final MedicineModel medicine;
  final String time;
  final String status;
  final String frequency;
  final String? notes;

  TodayDoseModel({
    required this.scheduleId,
    required this.medicine,
    required this.time,
    required this.status,
    required this.frequency,
    this.notes,
  });

  factory TodayDoseModel.fromJson(Map<String, dynamic> json) {
    return TodayDoseModel(
      scheduleId: json['schedule_id'],
      medicine: MedicineModel.fromJson(json['medicine']),
      time: json['time'],
      status: json['status'],
      frequency: json['frequency'],
      notes: json['notes'],
    );
  }
}
