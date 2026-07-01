import '../../../medicine/data/models/medicine_model.dart';

/// Model data jadwal minum obat.
class ScheduleModel {
  final int? id;
  final int medicineId;
  final MedicineModel? medicine;
  final String startDate;
  final String? endDate;
  final List<String> times;
  final String frequency;
  final String? notes;

  ScheduleModel({
    this.id,
    required this.medicineId,
    this.medicine,
    required this.startDate,
    this.endDate,
    required this.times,
    required this.frequency,
    this.notes,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id'],
      medicineId: json['medicine_id'],
      medicine: json['medicine'] != null
          ? MedicineModel.fromJson(json['medicine'])
          : null,
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'],
      times: json['times'] != null ? List<String>.from(json['times']) : [],
      frequency: json['frequency'] ?? '',
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medicine_id': medicineId,
      'start_date': startDate,
      'end_date': endDate,
      'times': times,
      'frequency': frequency,
      'notes': notes,
    };
  }

  /// Label frekuensi yang user-friendly.
  String get frequencyLabel {
    switch (frequency) {
      case 'once_daily':
        return 'Sekali Sehari';
      case 'twice_daily':
        return 'Dua Kali Sehari';
      case 'three_times_daily':
        return 'Tiga Kali Sehari';
      case 'as_needed':
        return 'Sesuai Kebutuhan';
      default:
        return frequency;
    }
  }

}
