import 'package:dio/dio.dart';
import 'package:find_them/data/models/case.dart';
import 'package:find_them/data/models/case_update.dart';
import 'package:find_them/data/models/enum.dart';
import 'api_service.dart';
import 'package:find_them/core/constants/api_constants.dart';

class CaseService {
  late Dio dio;

  CaseService(ApiService apiService) {
    dio = apiService.dio;
  }

  Future<List<Case>> getCases({CaseFilter? filter}) async {
    try {
      final queryParams = filter?.toQueryParams();

      Response response = await dio.get(
        ApiConstants.cases,
        queryParameters: queryParams,
      );
      return (response.data as List)
          .map((json) => Case.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }
  Future<Case?> getCase(int id) async {
    try {
      Response response = await dio.get('${ApiConstants.cases}/$id/');
      return Case.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }


   Future<Case?> createCase(Case case_) async {
    try {
      var data = case_.toJson();
      
      if (case_.photo.startsWith('file://')) {
        final filePath = case_.photo.replaceFirst('file://', '');
        
        FormData formData = FormData.fromMap(data);
        formData.files.add(
          MapEntry('photo', await MultipartFile.fromFile(filePath)),
        );
        
        Response response = await dio.post(
          ApiConstants.cases,
          data: formData,
        );
        
        return Case.fromJson(response.data);
      } else {
        Response response = await dio.post(
          ApiConstants.cases,
          data: data,
        );
        
        return Case.fromJson(response.data);
      }
    } catch (e) {
      return null;
    }
  }
  
  Future<Case?> updateCase(Case case_) async {
    try {
      if (case_.id == null) {
        throw Exception('Case ID is required for updates');
      }
      
      var data = case_.toJson();
      
      if (case_.photo.startsWith('file://')) {
        final filePath = case_.photo.replaceFirst('file://', '');
        
        FormData formData = FormData.fromMap(data);
        formData.files.add(
          MapEntry('photo', await MultipartFile.fromFile(filePath)),
        );
        
        Response response = await dio.put(
          '${ApiConstants.cases}/${case_.id}/',
          data: formData,
        );
        
        return Case.fromJson(response.data);
      } else {
        Response response = await dio.put(
          '${ApiConstants.cases}/${case_.id}/',
          data: data,
        );
        
        return Case.fromJson(response.data);
      }
    } catch (e) {
      return null;
    }
  }
  
  Future<bool> deleteCase(int id) async {
    try {
      await dio.delete('${ApiConstants.cases}/$id/');
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Future<List<Case>> searchCases(String query) async {
    try {
      Response response = await dio.get(
        ApiConstants.caseSearch,
        queryParameters: {'q': query},
      );
      
      return (response.data as List)
          .map((json) => Case.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }
  
  Future<CaseUpdate?> addCaseUpdate(CaseUpdate update) async {
    try {
      Response response = await dio.post(
        ApiConstants.caseUpdates,
        data: update.toJson(),
      );
      
      return CaseUpdate.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }
  
  Future<List<CaseUpdate>> getCaseUpdates(int caseId) async {
    try {
      Response response = await dio.get(
        ApiConstants.caseUpdates,
        queryParameters: {'case': caseId.toString()},
      );
      
      return (response.data as List)
          .map((json) => CaseUpdate.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }
}












