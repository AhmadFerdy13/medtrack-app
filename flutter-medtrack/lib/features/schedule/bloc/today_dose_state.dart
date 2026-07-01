import 'package:equatable/equatable.dart';
import '../data/models/today_dose_model.dart';

abstract class TodayDoseState extends Equatable {
  const TodayDoseState();

  @override
  List<Object?> get props => [];
}

class TodayDoseInitial extends TodayDoseState {}

class TodayDoseLoading extends TodayDoseState {}

class TodayDoseLoaded extends TodayDoseState {
  final List<TodayDoseModel> doses;

  const TodayDoseLoaded(this.doses);

  @override
  List<Object?> get props => [doses];
}

class TodayDoseError extends TodayDoseState {
  final String message;

  const TodayDoseError(this.message);

  @override
  List<Object?> get props => [message];
}

class TodayDoseSuccess extends TodayDoseState {
  final String message;

  const TodayDoseSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
