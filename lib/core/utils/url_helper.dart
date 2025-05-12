import 'package:find_them/core/constants/api_constants.dart';

class UrlHelper {
  static String getUrlWithId(String baseEndpoint, int id, [String? suffix]) {
    String url = baseEndpoint + '$id/';
    if (suffix != null) {
      url += suffix;
    }
    return url;
  }
  
  static String getCaseUrl(int caseId) {
    return getUrlWithId(ApiConstants.cases, caseId);
  }
  
  static String getCaseUpdatesUrl(int caseId) {
    return getUrlWithId(ApiConstants.cases, caseId, 'updates');
  }
  
  // Add more helper methods as needed
}