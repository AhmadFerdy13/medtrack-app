import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/schedule_repository.dart';
import '../../../core/network/api_service.dart';
import 'today_dose_event.dart';
import 'today_dose_state.dart';

class TodayDoseBloc extends Bloc<TodayDoseEvent, TodayDoseState> {
  final ScheduleRepository _repository = ScheduleRepository();

  TodayDoseBloc() : super(TodayDoseInitial()) {
    on<TodayDoseLoad>(_onLoad);
    on<TodayDoseConfirm>(_onConfirm);
  }

  Future<void> _onLoad(TodayDoseLoad event, Emitter<TodayDoseState> emit) async {
    emit(TodayDoseLoading());
    try {
      final doses = await _repository.getTodayDoses();
      emit(TodayDoseLoaded(doses));
    } on ApiException catch (e) {
      emit(TodayDoseError(e.message));
    } catch (e) {
      emit(const TodayDoseError('Gagal memuat jadwal hari ini'));
    }
  }

  Future<void> _onConfirm(TodayDoseConfirm event, Emitter<TodayDoseState> emit) async {
    emit(TodayDoseLoading());
    try {
      await _repository.confirmDose(event.scheduleId, event.time, event.status);
      emit(TodayDoseSuccess('Status berhasil diperbarui'));
      final doses = await _repository.getTodayDoses();
      emit(TodayDoseLoaded(doses));
    } on ApiException catch (e) {
      emit(TodayDoseError(e.message));
    } catch (e) {
      emit(const TodayDoseError('Gagal memperbarui status obat'));
    }
  }
}
