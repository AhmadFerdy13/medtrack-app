import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/schedule_repository.dart';
import '../../../core/network/api_service.dart';
import '../../../core/services/notification_service.dart';
import '../data/models/schedule_model.dart';
import 'schedule_event.dart';
import 'schedule_state.dart';

/// BLoC untuk mengelola state jadwal minum obat.
class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  final ScheduleRepository _repository = ScheduleRepository();
  final NotificationService _notificationService = NotificationService();

  ScheduleBloc() : super(ScheduleInitial()) {
    on<ScheduleLoadAll>(_onLoadAll);
    on<ScheduleCreate>(_onCreate);
    on<ScheduleUpdate>(_onUpdate);
    on<ScheduleDelete>(_onDelete);
  }

  void _scheduleAlarms(ScheduleModel schedule) {
    if (schedule.id == null) return;
    
    // Hapus alarm lama jika ada
    _cancelAlarms(schedule.id!);

    for (int i = 0; i < schedule.times.length; i++) {
      final timeStr = schedule.times[i];
      final parts = timeStr.split(':');
      if (parts.length == 2) {
        final hour = int.tryParse(parts[0]) ?? 0;
        final minute = int.tryParse(parts[1]) ?? 0;
        
        final notificationId = (schedule.id! * 100) + i;
        final medName = schedule.medicine?.name ?? 'Obat Anda';

        _notificationService.scheduleDailyNotification(
          id: notificationId,
          title: 'Waktunya Minum Obat!',
          body: 'Saatnya meminum $medName sesuai jadwal.',
          hour: hour,
          minute: minute,
        );
      }
    }
  }

  void _cancelAlarms(int scheduleId) {
    // Asumsi maksimal 10 waktu per jadwal untuk membatalkan
    for (int i = 0; i < 10; i++) {
      _notificationService.cancelNotification((scheduleId * 100) + i);
    }
  }

  Future<void> _onLoadAll(ScheduleLoadAll event, Emitter<ScheduleState> emit) async {
    emit(ScheduleLoading());
    try {
      final schedules = await _repository.getSchedules();
      emit(ScheduleLoaded(schedules));
    } on ApiException catch (e) {
      emit(ScheduleError(e.message));
    } catch (e) {
      emit(const ScheduleError('Gagal memuat jadwal'));
    }
  }

  Future<void> _onCreate(ScheduleCreate event, Emitter<ScheduleState> emit) async {
    emit(ScheduleLoading());
    try {
      await _repository.createSchedule(event.schedule);
      emit(const ScheduleSuccess('Jadwal berhasil ditambahkan'));
      
      final schedules = await _repository.getSchedules();
      
      // Update alarm for the newly created schedule
      if (schedules.isNotEmpty) {
        _scheduleAlarms(schedules.first);
      }
      
      emit(ScheduleLoaded(schedules));
    } on ApiException catch (e) {
      emit(ScheduleError(e.message));
    } catch (e) {
      emit(const ScheduleError('Gagal menambah jadwal'));
    }
  }

  Future<void> _onUpdate(ScheduleUpdate event, Emitter<ScheduleState> emit) async {
    emit(ScheduleLoading());
    try {
      await _repository.updateSchedule(event.id, event.schedule);
      emit(const ScheduleSuccess('Jadwal berhasil diperbarui'));
      
      final schedules = await _repository.getSchedules();
      
      // Update alarm for the updated schedule
      final updated = schedules.firstWhere((s) => s.id == event.id, orElse: () => schedules.first);
      _scheduleAlarms(updated);

      emit(ScheduleLoaded(schedules));
    } on ApiException catch (e) {
      emit(ScheduleError(e.message));
    } catch (e) {
      emit(const ScheduleError('Gagal memperbarui jadwal'));
    }
  }

  Future<void> _onDelete(ScheduleDelete event, Emitter<ScheduleState> emit) async {
    emit(ScheduleLoading());
    try {
      await _repository.deleteSchedule(event.id);
      _cancelAlarms(event.id);
      
      emit(const ScheduleSuccess('Jadwal berhasil dihapus'));
      final schedules = await _repository.getSchedules();
      emit(ScheduleLoaded(schedules));
    } on ApiException catch (e) {
      emit(ScheduleError(e.message));
    } catch (e) {
      emit(const ScheduleError('Gagal menghapus jadwal'));
    }
  }
}
