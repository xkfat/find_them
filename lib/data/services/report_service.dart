import 'dart:convert';
import 'package:find_them/data/models/report.dart';
import 'package:http/http.dart' as http;

class ReportService {
  final String baseUrl;
  final http.Client _httpClient;

  ReportService({
    this.baseUrl = 'http://10.0.2.2:8000/api',
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  Future<bool> submitReport(Report report, {String? token}) async {
    try {
      final headers = {'Content-Type': 'application/json'};

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await _httpClient.post(
        Uri.parse('$baseUrl/reports/submit/'),
        headers: headers,
        body: json.encode(report.toJson()),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        throw Exception(
          'Failed to submit report: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error submitting report: $e');
    }
  }
}
