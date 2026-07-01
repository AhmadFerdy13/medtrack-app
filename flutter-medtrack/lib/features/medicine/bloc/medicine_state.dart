import 'package:equatable/equatable.dart';
import '../data/models/medicine_model.dart';

/// State untuk MedicineBloc.
abstract class MedicineState extends Equatable {
  const MedicineState();

  @override
  List<Object?> get props => [];
}

class MedicineInitial extends MedicineState {}

class MedicineLoading extends MedicineState {}

class MedicineLoaded extends MedicineState {
  final List<MedicineModel> medicines;

  const MedicineLoaded(this.medicines);

  @override
  List<Object?> get props => [medicines];
}

class MedicineSuccess extends MedicineState {
  final String message;

  const MedicineSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class MedicineError extends MedicineState {
  final String message;

  const MedicineError(this.message);

  @override
  List<Object?> get props => [message];
}
