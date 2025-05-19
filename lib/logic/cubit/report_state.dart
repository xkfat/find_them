part of 'report_cubit.dart';

abstract class ReportState extends Equatable {
  const ReportState();

  @override
  List<Object?> get props => [];
}

class ReportInitial extends ReportState {}

class ReportSubmitting extends ReportState {}

class ReportSubmitSuccess extends ReportState {}

class ReportSubmitFailure extends ReportState {
  final String message;

  const ReportSubmitFailure(this.message);

  @override
  List<Object?> get props => [message];
}