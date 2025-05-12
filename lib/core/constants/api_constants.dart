class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:8000/api/';
  static const String mediaBaseUrl = 'http://10.0.2.2:8000/media/';


static const String tokenRefresh = 'token/refresh/';
static const String tokenObtain = 'token/';

  //Auth + user
  static const String login = 'accounts/login/';
  static const String logout = 'accounts/logout/';
  static const String signup = 'accounts/signup/';
  static const String profile = 'accounts/profile/';
  static const String changePassword = 'accounts/profile/change-password/';

  //Case
  static const String cases = 'cases/';
  static const String submittedCases = 'cases/submitted-cases/';
static const String caseDetails = 'cases/'; 
static const String caseUpdates = 'cases/{id}/updates/';
static const String caseWithUpdates = 'cases/{id}/with-updates/';
 static const String addCaseUpdate = 'cases/{id}/add-update/';
  static const String caseSearch = 'cases/';
  
  
  
  //Reports
  static const String submitReport = 'comments/submit/';
static const String listReports = 'comments/';
 static const String reportDetail = 'comments/{id}/';
 static const String updateReportStatus = 'comments/{id}/update-status/';



  //Notifications
  static const String notifications = 'notifications/';
static const String viewNotification = 'notifications/{id}/';
static const String sendNotification = 'notifications/send/'; 
static const String allNotifications = 'notifications/all/';



  // Location Sharing
  static const String locationRequests = 'location-sharing/requests/';
  static const String sendLocationRequest = 'location-sharing/requests/send/';
static const String respondToRequest = 'location-sharing/requests/{id}/respond/';

  static const String friends = 'location-sharing/friends/';
  static const String removeFriend = 'location-sharing/friends/{id}/remove/';
  static const String friendsLocations = 'location-sharing/locations/';
  static const String updateLocation = 'location-sharing/locations/update/';
static const String sendAlert = 'location-sharing/friends/{id}/alert/';
  //Setttings
  static const String sharingSettings = 'location-sharing/settings/';
  static const String selectedFriends = 'location-sharing/settings/selected-friends/';
  static const String currentSharingSettings = 'location-sharing/settings/current/';

  // Media
  static const String profilePhotosPath = 'profiles/';
  static const String casePhotosPath = 'cases_photos/';

  // Default images
  static const String defaultProfileImage = 'assets/images/default_profile.png';
  static const String defaultCaseImage = 'assets/images/default_case.png';
  static const String loadingImage = 'assets/images/loading.png';
}
