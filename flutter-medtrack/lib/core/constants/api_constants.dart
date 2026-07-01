/// Konstanta API untuk koneksi ke backend Laravel.
class ApiConstants {
  // Base URL — sesuaikan dengan environment.
  // Untuk BlueStacks emulator, gunakan IP host machine.
  // Untuk device fisik, gunakan IP LAN host.
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // ── Auth Endpoints ──
  static const String register = '$baseUrl/auth/register';
  static const String login = '$baseUrl/auth/login';
  static const String logout = '$baseUrl/auth/logout';
  static const String me = '$baseUrl/auth/me';
  static const String refresh = '$baseUrl/auth/refresh';

  // ── Medicine Endpoints ──
  static const String medicines = '$baseUrl/medicines';
  static String medicineDetail(int id) => '$baseUrl/medicines/$id';

  // ── Medication Schedule Endpoints ──
  static const String schedules = '$baseUrl/medication-schedules';
  static String scheduleDetail(int id) => '$baseUrl/medication-schedules/$id';
  
  static const String todaySchedules = '$baseUrl/today-schedules';
  static const String confirmDose = '$baseUrl/medication-logs/confirm';
}
