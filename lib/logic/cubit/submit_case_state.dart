part of 'submit_case_cubit.dart';

sealed class SubmitCaseState extends Equatable {
  const SubmitCaseState();

  @override
  List<Object?> get props => [];
}

final class SubmitCaseInitial extends SubmitCaseState {}
final class SubmitCaseLoading extends SubmitCaseState {}
final class SubmitCaseLoaded extends SubmitCaseState {
    final Case submittedCase;
  
  const SubmitCaseLoaded(this.submittedCase);
  
  @override
  List<Object?> get props => [submittedCase];
}

final class SubmitCaseError extends SubmitCaseState {
  final String message;
  
  const SubmitCaseError(this.message);
  
  @override
  List<Object?> get props => [message];
}