import 'dart:developer';

import 'package:find_them/data/models/report.dart';
import 'package:find_them/data/services/api_service.dart';
import 'package:find_them/data/services/report_service.dart';

class ReportRepository {
  final ReportService _reportService;
  final ApiService _apiService;

  ReportRepository(this._reportService, {ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  Future<dynamic> submitReport({
    required int caseId,
    required String note,
  }) async {
        try {

         final token = await _apiService.getAccessToken();


    final report = Report(caseId: caseId, note: note);

    return await _reportService.submitReport(report, token: token);
 } catch (e) {
      log('Error submitting report: $e');
      return false;
    }
  }
}