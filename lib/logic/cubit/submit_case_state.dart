part of 'submit_case_cubit.dart';

sealed class SubmitCaseState extends Equatable {
  const SubmitCaseState();

  @override
  List<Object> get props => [];
}

final class SubmitCaseInitial extends SubmitCaseState {}
final class SubmitCaseLoading extends SubmitCaseState {}
final class SubmitCaseLoaded extends SubmitCaseState {}
class SubmitCaseerreur extends SubmitCaseState {
   String msg;
   SubmitCaseerreur(this.msg);
}