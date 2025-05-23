part of 'case_updates_cubit.dart';

sealed class CaseUpdatesState extends Equatable {
  const CaseUpdatesState();

  @override
  List<Object?> get props => [];
}

final class CaseUpdatesInitial extends CaseUpdatesState {}

final class CaseUpdatesLoading extends CaseUpdatesState {}

final class CaseUpdatesLoaded extends CaseUpdatesState {
  final SubmittedCase caseWithUpdates;

  const CaseUpdatesLoaded({required this.caseWithUpdates});

  @override
  List<Object?> get props => [caseWithUpdates];
}

final class CaseUpdatesError extends CaseUpdatesState {
  final String message;

  const CaseUpdatesError(this.message);

  @override
  List<Object?> get props => [message];
}