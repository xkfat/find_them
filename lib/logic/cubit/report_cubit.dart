import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:find_them/data/repositories/report_repo.dart';

part 'report_state.dart';

class ReportCubit extends Cubit<ReportState> {
  final ReportRepository _reportRepository;

  ReportCubit(this._reportRepository) : super(ReportInitial());

  Future<void> submitReport({
    required int caseId,
    required String note,

  }) async {
    emit(ReportSubmitting());
    try {
      final success = await _reportRepository.submitReport(
        caseId: caseId,
        note: note,

      );
      
      if (success) {
        emit(ReportSubmitSuccess());
      } else {
        emit(ReportSubmitFailure("Failed to submit report"));
      }
    } catch (e) {
      emit(ReportSubmitFailure(e.toString()));
    }
  }
}