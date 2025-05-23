import 'package:find_them/data/models/submitted_case.dart';
import 'package:find_them/data/services/api_service.dart';
import 'package:find_them/data/services/submitted_cases_service.dart';

class SubmittedCaseRepository {
  final SubmittedCaseService _service;
  final ApiService _apiService;

  SubmittedCaseRepository(this._service) : _apiService = ApiService();

  Future<String?> getAuthToken() async {
    return await _apiService.getAccessToken();
  }

  Future<List<SubmittedCase>> getSubmittedCases() async {
    try {
      final token = await getAuthToken();
      return await _service.getSubmittedCases(token: token);
    } catch (e) {
      throw Exception('Failed to get submitted cases: $e');
    }
  }

  Future<SubmittedCase> getCaseDetails(int caseId) async {
    try {
      final token = await getAuthToken();
      return await _service.getCaseDetails(caseId, token: token);
    } catch (e) {
      throw Exception('Failed to get case details: $e');
    }
  }

  Future<SubmittedCase> getCaseWithUpdates(int caseId) async {
    try {
      final token = await getAuthToken();
      return await _service.getCaseDetails(caseId, token: token);
    } catch (e) {
      throw Exception('Failed to get case with updates: $e');
    }
  }

  Future<List<CaseUpdateItem>> getCaseUpdates(int caseId) async {
    try {
      final token = await getAuthToken();
      return await _service.getCaseUpdates(caseId, token: token);
    } catch (e) {
      throw Exception('Failed to get case updates: $e');
    }
  }
}
