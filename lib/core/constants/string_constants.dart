// lib/constants/string_constants.dart

class StringConstants {
  // General
  static const String appName = 'Find Them';
  
  // Case Status Messages
  static const String missingStatus = 'Missing';
  static const String foundStatus = 'Found';
  static const String investigatingStatus = 'Under Investigation';
  
  // Submission Status
  static const String activeStatus = 'Active';
  static const String inProgressStatus = 'In Progress';
  static const String closedStatus = 'Closed';
  static const String rejectedStatus = 'Rejected';
  
  // Report Status
  static const String pendingStatus = 'Pending';
  static const String unverifiedStatus = 'Unverified';
  static const String verifiedStatus = 'Verified';
  static const String falseStatus = 'False';
  
  // Notification Types
  static const String systemNotification = 'System';
  static const String missingPersonNotification = 'Missing Person';
  static const String reportNotification = 'Report';
  static const String locationRequestNotification = 'Location Request';
  static const String locationResponseNotification = 'Location Response';
  static const String caseUpdateNotification = 'Case Update';
  static const String locationAlertNotification = 'Location Alert';
  
  // Location Sharing
  static const String acceptButton = 'Accept';
  static const String alertButton = 'Alert';
  
  // Authentication Messages
  static const String loginSuccess = 'Login successful';
  static const String loginFailed = 'Login failed';
  static const String registerSuccess = 'Registration successful';
  static const String registerFailed = 'Registration failed';
  static const String logoutSuccess = 'Logout successful';
  
  // Case Management
  static const String caseCreated = 'Case created successfully';
  static const String caseUpdated = 'Case updated successfully';
  static const String caseDeleted = 'Case deleted successfully';
  
  // Report Management
  static const String reportSubmitted = 'Report submitted successfully';
  static const String reportUpdated = 'Report updated successfully';
  
  // Location
  static const String locationUpdated = 'Location updated successfully';
  static const String locationPermissionRequired = 'Location permission is required';
  static const String locationSharingEnabled = 'Location sharing enabled';
  static const String locationSharingDisabled = 'Location sharing disabled';
  
  // Age Ranges
  static const String childRange = '0 - 18';
  static const String youngAdultRange = '18 - 25';
  static const String adultRange = '+ 25';
  
  // Date Ranges
  static const String last7Days = 'Last 7 days';
  static const String last30Days = 'Last 30 days';
  static const String last3Months = 'Last 3 months';
  static const String customRange = 'Custom range';
  
  // Form Validation
  static const String requiredField = 'This field is required';
  static const String invalidEmail = 'Please enter a valid email';
  static const String invalidPhone = 'Please enter a valid phone number';
  static const String passwordMismatch = 'Passwords do not match';
  static const String invalidAge = 'Please enter a valid age';
  
  // Button Labels
  static const String submit = 'Submit';
  static const String cancel = 'Cancel';
  static const String update = 'Update';
  static const String delete = 'Delete';
  static const String save = 'Save';
  static const String next = 'Next';
  static const String previous = 'Previous';
}