import 'package:equatable/equatable.dart';
import '../data/models/schedule_model.dart';

/// Event untuk ScheduleBloc.
abstract class ScheduleEvent extends Equatable {
  const ScheduleEvent();

  @override
  List<Object?> get props => [];
}

/// Ambil semua jadwal.
class ScheduleLoadAll extends ScheduleEvent {}

/// Tambah jadwal baru.
class ScheduleCreate extends ScheduleEvent {
  final ScheduleModel schedule;

  const ScheduleCreate(this.schedule);

  @override
  List<Object?> get props => [schedule];
}

/// Update jadwal.
class ScheduleUpdate extends ScheduleEvent {
  final int id;
  final ScheduleModel schedule;

  const ScheduleUpdate(this.id, this.schedule);

  @override
  List<Object?> get props => [id, schedule];
}

/// Hapus jadwal.
class ScheduleDelete extends ScheduleEvent {
  final int id;

  const ScheduleDelete(this.id);

  @override
  List<Object?> get props => [id];
}
