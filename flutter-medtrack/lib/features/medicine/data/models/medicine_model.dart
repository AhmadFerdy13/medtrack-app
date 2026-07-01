/// Model data obat.
class MedicineModel {
  final int? id;
  final int? userId;
  final String name;
  final String type;
  final String dosage;
  final String unit;
  final String? usageInstruction;
  final String? notes;
  final String? createdAt;
  final String? updatedAt;

  MedicineModel({
    this.id,
    this.userId,
    required this.name,
    required this.type,
    required this.dosage,
    required this.unit,
    this.usageInstruction,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory MedicineModel.fromJson(Map<String, dynamic> json) {
    return MedicineModel(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      dosage: json['dosage'] ?? '',
      unit: json['unit'] ?? '',
      usageInstruction: json['usage_instruction'],
      notes: json['notes'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'dosage': dosage,
      'unit': unit,
      'usage_instruction': usageInstruction,
      'notes': notes,
    };
  }

  /// Label jenis obat yang user-friendly.
  String get typeLabel {
    switch (type) {
      case 'tablet':
        return 'Tablet';
      case 'capsule':
        return 'Kapsul';
      case 'syrup':
        return 'Sirup';
      case 'injection':
        return 'Injeksi';
      case 'ointment':
        return 'Salep';
      default:
        return type;
    }
  }
}
