
enum Gender { male, female }

enum CaseStatus { missing, found, underInvestigation }

enum SubmissionStatus { active, inProgress, closed, rejected }

enum ReportStatus { pending, unverified, verified, false_ }

enum NotificationType {
  system,
  missingPerson,
  report,
  locationRequest,
  locationResponse,
  caseUpdate,
  locationAlert,
}

enum Language { english, french, arabic }

enum Theme { light, dark }

enum MarkerType { missingPerson, user, friend }


class AgeRange {
  final int min;
  final int max;
  final String label;

  const AgeRange({required this.min, required this.max, required this.label});
  static const AgeRange child = AgeRange(min: 0, max: 18, label: '0 - 18');
  static const AgeRange youngAdult = AgeRange(
    min: 18,
    max: 25,
    label: '18 - 25',
  );
  static const AgeRange adult = AgeRange(min: 25, max: 100, label: '+ 25');

  Map<String, String> toQueryParams() {
    return {
      'age_min': min.toString(),
      'age_max': max.toString()
    };
  }
}

class DateRange {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? label;
  
  const DateRange({
    this.startDate,
    this.endDate,
    this.label,
  });

  static DateRange last7Days() {
    final now = DateTime.now();
    return DateRange(
      startDate: now.subtract(const Duration(days: 7)),
      endDate: now,
      label: 'Last 7 days'
    );
  }
  
  static DateRange last30Days() {
    final now = DateTime.now();
    return DateRange(
      startDate: now.subtract(const Duration(days: 30)),
      endDate: now,
      label: 'Last 30 days'
    );
  }
  
  static DateRange last3Months() {
    final now = DateTime.now();
    return DateRange(
      startDate: DateTime(now.year, now.month - 3, now.day),
      endDate: now,
      label: 'Last 3 months'
    );
  }
  
  static DateRange custom({required DateTime startDate, required DateTime endDate}) {
    return DateRange(
      startDate: startDate,
      endDate: endDate,
      label: 'Custom range'
    );
  }
    Map<String, String> toQueryParams() {
    final params = <String, String>{};
    
    if (startDate != null) {
      params['date_reported_start'] = formatDateForApi(startDate!);
    }
    
    if (endDate != null) {
      params['date_reported_end'] = formatDateForApi(endDate!);
    }
    
    return params;
  }
  
  static String formatDateForApi(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}


class LocationSharingStatus {
  final bool isSharing;
  final bool canSeeOther;
  final String buttonType; 

  const LocationSharingStatus({
    required this.isSharing,
    required this.canSeeOther,
    required this.buttonType,
  });
  static const LocationSharingStatus notSharingCannotSee =
      LocationSharingStatus(
        isSharing: false,
        canSeeOther: false,
        buttonType: 'accept',
      );

  static const LocationSharingStatus notSharingCanSee = LocationSharingStatus(
    isSharing: false,
    canSeeOther: true,
    buttonType: 'accept',
  );

  static const LocationSharingStatus sharingCannotSee = LocationSharingStatus(
    isSharing: true,
    canSeeOther: false,
    buttonType: 'alert',
  );

  static const LocationSharingStatus sharingCanSee = LocationSharingStatus(
    isSharing: true,
    canSeeOther: true,
    buttonType: 'alert',
  );
}

extension GenderExtension on Gender {
  String get value {
    switch (this) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
    }
  }

  static Gender fromValue(String value) {
    return Gender.values.firstWhere(
      (e) => e.value == value,
      orElse: () => Gender.male,
    );
  }
 String toQueryParam() {
    return value;
  }
}

extension CaseStatusExtension on CaseStatus {
  String get value {
    switch (this) {
      case CaseStatus.missing:
        return 'missing';
      case CaseStatus.found:
        return 'found';
      case CaseStatus.underInvestigation:
        return 'under_investigation';
    }
  }

  static CaseStatus fromValue(String value) {
    if (value.toLowerCase() == 'investigating') {
      return CaseStatus.underInvestigation;
    }

    return CaseStatus.values.firstWhere(
      (e) => e.value.toLowerCase() == value.toLowerCase(),
      orElse: () => CaseStatus.missing,
    );
  }

  String toQueryParam() {
    return value;
  }
}

extension SubmissionStatusExtension on SubmissionStatus {
  String get value {
    switch (this) {
      case SubmissionStatus.active:
        return 'active';
      case SubmissionStatus.inProgress:
        return 'in_progress';
      case SubmissionStatus.closed:
        return 'closed';
      case SubmissionStatus.rejected:
        return 'rejected';
    }
  }

  static SubmissionStatus fromValue(String value) {
    return SubmissionStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SubmissionStatus.inProgress,
    );
  }
}

extension ReportStatusExtension on ReportStatus {
  String get value {
    switch (this) {
      case ReportStatus.pending:
        return 'new';
      case ReportStatus.unverified:
        return 'unverified';
      case ReportStatus.verified:
        return 'verified';
      case ReportStatus.false_:
        return 'false';
    }
  }

  static ReportStatus fromValue(String value) {
    return ReportStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ReportStatus.pending,
    );
  }
}

extension NotificationTypeExtension on NotificationType {
  String get value {
    switch (this) {
      case NotificationType.system:
        return 'system';
      case NotificationType.missingPerson:
        return 'missing_person';
      case NotificationType.report:
        return 'report';
      case NotificationType.locationRequest:
        return 'location_request';
      case NotificationType.locationResponse:
        return 'location_response';
      case NotificationType.caseUpdate:
        return 'case_update';
      case NotificationType.locationAlert:
        return 'location_alert';
    }
  }

  static NotificationType fromValue(String value) {
    return NotificationType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => NotificationType.system,
    );
  }
}

extension LanguageExtension on Language {
  String get value {
    switch (this) {
      case Language.english:
        return 'english';
      case Language.french:
        return 'french';
      case Language.arabic:
        return 'arabic';
    }
  }

  static Language fromValue(String value) {
    return Language.values.firstWhere(
      (e) => e.value == value,
      orElse: () => Language.english,
    );
  }


   String get code {
    switch (this) {
      case Language.english:
        return 'en';
      case Language.french:
        return 'fr';
      case Language.arabic:
        return 'ar';
    }
  }
    String get displayName {
    switch (this) {
      case Language.english:
        return 'English';
      case Language.french:
        return 'Français';
      case Language.arabic:
        return 'العربية';
    }
  }
}

extension ThemeExtension on Theme {
  String get value {
    switch (this) {
      case Theme.light:
        return 'light';
      case Theme.dark:
        return 'dark';
    }
  }

  static Theme fromValue(String value) {
    return Theme.values.firstWhere(
      (e) => e.value == value,
      orElse: () => Theme.light,
    );
  }
}

class CaseFilter {
  final Gender? gender;
  final CaseStatus? status;
  final AgeRange? ageRange;
  final DateRange? dateRange;
  
  CaseFilter({
    this.gender,
    this.status,
    this.ageRange,
    this.dateRange,
  });
 CaseFilter copyWith({
    Gender? gender,
    CaseStatus? status,
    AgeRange? ageRange,
    DateRange? dateRange,
  }) {
    return CaseFilter(
      gender: gender ?? this.gender,
      status: status ?? this.status,
      ageRange: ageRange ?? this.ageRange,
      dateRange: dateRange ?? this.dateRange,
    );
  }
 Map<String, String> toQueryParams() {
    final params = <String, String>{};
    
    if (gender != null) {
      params['gender'] = gender!.toQueryParam();
    }
    
    if (status != null) {
      params['status'] = status!.toQueryParam();
    }
    if (ageRange != null) {
      params.addAll(ageRange!.toQueryParams());
    }
    
    if (dateRange != null) {
      params.addAll(dateRange!.toQueryParams());
    }
    
    return params;
  }
  
  bool get isEmpty => gender == null && status == null && ageRange == null && dateRange == null;
}