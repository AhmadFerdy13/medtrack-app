import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/medicine_repository.dart';
import '../../../core/network/api_service.dart';
import 'medicine_event.dart';
import 'medicine_state.dart';

/// BLoC untuk mengelola state data obat.
class MedicineBloc extends Bloc<MedicineEvent, MedicineState> {
  final MedicineRepository _repository = MedicineRepository();

  MedicineBloc() : super(MedicineInitial()) {
    on<MedicineLoadAll>(_onLoadAll);
    on<MedicineCreate>(_onCreate);
    on<MedicineUpdate>(_onUpdate);
    on<MedicineDelete>(_onDelete);
  }

  Future<void> _onLoadAll(MedicineLoadAll event, Emitter<MedicineState> emit) async {
    emit(MedicineLoading());
    try {
      final medicines = await _repository.getMedicines();
      emit(MedicineLoaded(medicines));
    } on ApiException catch (e) {
      emit(MedicineError(e.message));
    } catch (e) {
      emit(const MedicineError('Gagal memuat data obat'));
    }
  }

  Future<void> _onCreate(MedicineCreate event, Emitter<MedicineState> emit) async {
    emit(MedicineLoading());
    try {
      await _repository.createMedicine(event.medicine);
      emit(const MedicineSuccess('Obat berhasil ditambahkan'));
      // Reload data setelah berhasil
      final medicines = await _repository.getMedicines();
      emit(MedicineLoaded(medicines));
    } on ApiException catch (e) {
      emit(MedicineError(e.message));
    } catch (e) {
      emit(const MedicineError('Gagal menambah obat'));
    }
  }

  Future<void> _onUpdate(MedicineUpdate event, Emitter<MedicineState> emit) async {
    emit(MedicineLoading());
    try {
      await _repository.updateMedicine(event.id, event.medicine);
      emit(const MedicineSuccess('Obat berhasil diperbarui'));
      final medicines = await _repository.getMedicines();
      emit(MedicineLoaded(medicines));
    } on ApiException catch (e) {
      emit(MedicineError(e.message));
    } catch (e) {
      emit(const MedicineError('Gagal memperbarui obat'));
    }
  }

  Future<void> _onDelete(MedicineDelete event, Emitter<MedicineState> emit) async {
    emit(MedicineLoading());
    try {
      await _repository.deleteMedicine(event.id);
      emit(const MedicineSuccess('Obat berhasil dihapus'));
      final medicines = await _repository.getMedicines();
      emit(MedicineLoaded(medicines));
    } on ApiException catch (e) {
      emit(MedicineError(e.message));
    } catch (e) {
      emit(const MedicineError('Gagal menghapus obat'));
    }
  }
}
