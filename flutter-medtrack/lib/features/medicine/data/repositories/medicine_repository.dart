import '../models/medicine_model.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_service.dart';

/// Repository untuk mengelola data obat.
class MedicineRepository {
  final ApiService _apiService = ApiService();

  /// Mengambil daftar obat milik user.
  Future<List<MedicineModel>> getMedicines() async {
    final response = await _apiService.get(ApiConstants.medicines);
    final List data = response['data'] ?? [];
    return data.map((e) => MedicineModel.fromJson(e)).toList();
  }

  /// Mengambil detail obat berdasarkan ID.
  Future<MedicineModel> getMedicine(int id) async {
    final response = await _apiService.get(ApiConstants.medicineDetail(id));
    return MedicineModel.fromJson(response['data']);
  }

  /// Menambah obat baru.
  Future<MedicineModel> createMedicine(MedicineModel medicine) async {
    final response = await _apiService.post(
      ApiConstants.medicines,
      body: medicine.toJson(),
    );
    return MedicineModel.fromJson(response['data']);
  }

  /// Mengubah data obat.
  Future<MedicineModel> updateMedicine(int id, MedicineModel medicine) async {
    final response = await _apiService.put(
      ApiConstants.medicineDetail(id),
      body: medicine.toJson(),
    );
    return MedicineModel.fromJson(response['data']);
  }

  /// Menghapus obat.
  Future<void> deleteMedicine(int id) async {
    await _apiService.delete(ApiConstants.medicineDetail(id));
  }
}
