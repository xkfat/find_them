import 'package:dio/dio.dart';
import 'package:find_them/data/models/report.dart';
import 'api_service.dart';
import 'package:find_them/core/constants/api_constants.dart';

class ReportService {
  late Dio dio;

  ReportService(ApiService apiService) {
    dio = apiService.dio;
  }

  Future<Report?> submitReport(Report report) async {
    try {
      Response response = await dio.post(
        ApiConstants.submitReport,
        data: report.toJson(),
      );

      return Report.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }
}
