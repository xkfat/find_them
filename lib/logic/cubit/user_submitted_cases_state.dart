part of 'user_submitted_cases_cubit.dart';

sealed class UserSubmittedCasesState extends Equatable {
  const UserSubmittedCasesState();

  @override
  List<Object?> get props => [];
}

final class UserSubmittedCasesInitial extends UserSubmittedCasesState {}

final class UserSubmittedCasesLoading extends UserSubmittedCasesState {}

final class UserSubmittedCasesLoaded extends UserSubmittedCasesState {
  final List<SubmittedCase> cases;
  
  const UserSubmittedCasesLoaded({required this.cases});
  
  @override
  List<Object?> get props => [cases];
}

final class UserSubmittedCasesError extends UserSubmittedCasesState {
  final String message;
  
  const UserSubmittedCasesError(this.message);
  
  @override
  List<Object?> get props => [message];
}