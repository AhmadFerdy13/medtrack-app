import 'package:equatable/equatable.dart';

abstract class TodayDoseEvent extends Equatable {
  const TodayDoseEvent();

  @override
  List<Object> get props => [];
}

class TodayDoseLoad extends TodayDoseEvent {}

class TodayDoseConfirm extends TodayDoseEvent {
  final int scheduleId;
  final String time;
  final String status;

  const TodayDoseConfirm({
    required this.scheduleId,
    required this.time,
    required this.status,
  });

  @override
  List<Object> get props => [scheduleId, time, status];
}
