import 'package:equatable/equatable.dart';
import '../data/models/medicine_model.dart';

/// Event untuk MedicineBloc.
abstract class MedicineEvent extends Equatable {
  const MedicineEvent();

  @override
  List<Object?> get props => [];
}

/// Ambil daftar obat.
class MedicineLoadAll extends MedicineEvent {}

/// Tambah obat baru.
class MedicineCreate extends MedicineEvent {
  final MedicineModel medicine;

  const MedicineCreate(this.medicine);

  @override
  List<Object?> get props => [medicine];
}

/// Update obat.
class MedicineUpdate extends MedicineEvent {
  final int id;
  final MedicineModel medicine;

  const MedicineUpdate(this.id, this.medicine);

  @override
  List<Object?> get props => [id, medicine];
}

/// Hapus obat.
class MedicineDelete extends MedicineEvent {
  final int id;

  const MedicineDelete(this.id);

  @override
  List<Object?> get props => [id];
}
