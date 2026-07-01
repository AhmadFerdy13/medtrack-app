import 'package:equatable/equatable.dart';
import '../data/models/schedule_model.dart';

/// State untuk ScheduleBloc.
abstract class ScheduleState extends Equatable {
  const ScheduleState();

  @override
  List<Object?> get props => [];
}

class ScheduleInitial extends ScheduleState {}

class ScheduleLoading extends ScheduleState {}

class ScheduleLoaded extends ScheduleState {
  final List<ScheduleModel> schedules;

  const ScheduleLoaded(this.schedules);

  @override
  List<Object?> get props => [schedules];
}

class ScheduleSuccess extends ScheduleState {
  final String message;

  const ScheduleSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ScheduleError extends ScheduleState {
  final String message;

  const ScheduleError(this.message);

  @override
  List<Object?> get props => [message];
}
