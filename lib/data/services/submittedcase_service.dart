import 'package:dio/dio.dart';
import 'package:find_them/data/models/submitted_case.dart';
import 'api_service.dart';
import 'package:find_them/core/constants/api_constants.dart';

class SubmittedCaseService {
  late Dio dio;

  SubmittedCaseService(ApiService apiService) {
    dio = apiService.dio;
  }

  Future<List<SubmittedCase>> getSubmittedCases() async {
    try {
      Response response = await dio.get(ApiConstants.submittedCases);
      
      return (response.data as List)
          .map((json) => SubmittedCase.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }
  
  Future<SubmittedCase?> getSubmittedCaseWithUpdates(int caseId) async {
    try {
      String url = ApiConstants.caseWithUpdates.replaceAll('{id}', caseId.toString());
      Response response = await dio.get(url);
      
      return SubmittedCase.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }
}