import 'dart:developer';
import 'dart:io';
import 'package:find_them/data/models/case.dart';
import 'package:find_them/data/models/enum.dart';
import 'package:find_them/data/services/api_service.dart';
import 'package:find_them/data/services/case_service.dart';

class CaseRepository {
  final CaseService _caseService;
  final ApiService _apiService;

  CaseRepository(this._caseService) : _apiService = ApiService();

  Future<String?> getAuthToken() async {
    return await _apiService.getAccessToken();
  }

  Future<List<Case>> getCases({
    String? name,
    String? lastSeenLocation,
    String? nameOrLocation,
    int? ageMin,
    int? ageMax,
    String? gender,
    String? status,
    String? startDate,
    String? endDate,
  }) async {
    final cases = await _caseService.getCases(
      name: name,
      lastSeenLocation: lastSeenLocation,
      nameOrLocation: nameOrLocation,
      ageMin: ageMin,
      ageMax: ageMax,
      gender: gender,
      status: status,
      startDate: startDate,
      endDate: endDate,
    );
    return cases
        .where((c) => c.submissionStatus.value != 'in_progress')
        .toList();
  }

  Future<Case> getCaseById(int id) async {
    return await _caseService.getCaseById(id);
  }

  Future<Case> submitCase({
    required String firstName,
    required String lastName,
    required int age,
    required String gender,
    required File photo,
    required String description,
    required DateTime lastSeenDate,
    required String lastSeenLocation,
    required String contactPhone,
    double? latitude,
    double? longitude,
  }) async {
    final String? authToken = await getAuthToken();
    log("Retrieved auth token: ${authToken ?? 'null'}");

    return await _caseService.submitCase(
      firstName: firstName,
      lastName: lastName,
      age: age,
      gender: gender,
      photo: photo,
      description: description,
      lastSeenDate: lastSeenDate,
      lastSeenLocation: lastSeenLocation,
      latitude: latitude,
      longitude: longitude,
      contactPhone: contactPhone,
      authToken: authToken,
    );
  }
}
