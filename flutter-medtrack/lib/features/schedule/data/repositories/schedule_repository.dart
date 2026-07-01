import '../models/schedule_model.dart';
import '../models/today_dose_model.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_service.dart';

/// Repository untuk mengelola jadwal minum obat.
class ScheduleRepository {
  final ApiService _apiService = ApiService();

  /// Mengambil daftar jadwal milik user.
  Future<List<ScheduleModel>> getSchedules() async {
    final response = await _apiService.get(ApiConstants.schedules);
    final List data = response['data'] ?? [];
    return data.map((e) => ScheduleModel.fromJson(e)).toList();
  }

  /// Mengambil detail jadwal berdasarkan ID.
  Future<ScheduleModel> getSchedule(int id) async {
    final response = await _apiService.get(ApiConstants.scheduleDetail(id));
    return ScheduleModel.fromJson(response['data']);
  }

  /// Menambah jadwal baru.
  Future<ScheduleModel> createSchedule(ScheduleModel schedule) async {
    final response = await _apiService.post(
      ApiConstants.schedules,
      body: schedule.toJson(),
    );
    return ScheduleModel.fromJson(response['data']);
  }

  /// Mengubah data jadwal.
  Future<ScheduleModel> updateSchedule(int id, ScheduleModel schedule) async {
    final response = await _apiService.put(
      ApiConstants.scheduleDetail(id),
      body: schedule.toJson(),
    );
    return ScheduleModel.fromJson(response['data']);
  }

  /// Menghapus jadwal.
  Future<void> deleteSchedule(int id) async {
    await _apiService.delete(ApiConstants.scheduleDetail(id));
  }

  Future<List<TodayDoseModel>> getTodayDoses() async {
    final response = await _apiService.get(ApiConstants.todaySchedules);
    if (response['success'] == true) {
      final List data = response['data'] ?? [];
      return data.map((json) => TodayDoseModel.fromJson(json)).toList();
    } else {
      throw ApiException(message: response['message'] ?? 'Gagal memuat jadwal hari ini', statusCode: 400);
    }
  }

  Future<void> confirmDose(int scheduleId, String time, String status) async {
    final response = await _apiService.post(ApiConstants.confirmDose, body: {
      'schedule_id': scheduleId,
      'time': time,
      'status': status,
    });
    if (response['success'] != true) {
      throw ApiException(message: response['message'] ?? 'Gagal memperbarui status obat', statusCode: 400);
    }
  }
}
