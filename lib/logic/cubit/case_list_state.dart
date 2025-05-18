part of 'case_list_cubit.dart';

sealed class CaseListState extends Equatable {
  const CaseListState();

  @override
  List<Object?> get props => [];
}

final class CaseListInitial extends CaseListState {}

class CaseLoading extends CaseListState {}

class CaseLoaded extends CaseListState {
  final List<Case> cases;

  const CaseLoaded(this.cases);

  @override
  List<Object?> get props => [cases];
}

class CaseDetailLoaded extends CaseListState {
  final Case caseData;

  const CaseDetailLoaded(this.caseData);

  @override
  List<Object?> get props => [caseData];
}

class CaseError extends CaseListState {
  final String message;

  const CaseError(this.message);

  @override
  List<Object?> get props => [message];
}
