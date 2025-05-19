import 'package:find_them/data/models/report.dart';
import 'package:find_them/data/services/report_service.dart';

class ReportRepository {
  final ReportService _reportService;

  ReportRepository(this._reportService);

  Future<bool> submitReport({
    required int caseId,
    required String note,

  }) async {
    final report = Report(
      caseId: caseId,
      note: note,
    );
    
    return await _reportService.submitReport(report);
  }
}