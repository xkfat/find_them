import 'package:find_them/data/models/user.dart';
import 'package:find_them/data/models/enum.dart';
import 'package:find_them/data/models/case_update.dart';

class Case {
  final int? id;
  final String firstName;
  final String lastName;
  final int age;
  final Gender gender;
  final String photo;
  final String description;
  final DateTime lastSeenDate;
  final String lastSeenLocation;
  final double? latitude;
  final double? longitude;
  final User? reporter;
  final CaseStatus status;
  final DateTime dateReported;
  final SubmissionStatus submissionStatus;
  final List<CaseUpdate>? updates;

  Case({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.age,
    required this.gender,
    required this.photo,
    this.description = '',
    required this.lastSeenDate,
    required this.lastSeenLocation,
    this.latitude,
    this.longitude,
    this.reporter,
    this.status = CaseStatus.missing,
    DateTime? dateReported,
    this.submissionStatus = SubmissionStatus.inProgress,
    this.updates,
  }) : dateReported = dateReported ?? DateTime.now();

  factory Case.fromJson(Map<String, dynamic> json) {
    return Case(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      age: json['age'],
      gender: GenderExtension.fromValue(json['gender']),
      photo: json['photo'],
      description: json['description'] ?? '',
      lastSeenDate: DateTime.parse(json['last_seen_date']),
      lastSeenLocation: json['last_seen_location'],
      latitude:
          json['latitude'] != null ? double.parse(json['latitude'].toString()) : null,
      longitude:
          json['longitude'] != null ? double.parse(json['longitude'].toString()) : null,
      reporter: json['reporter'] != null 
    ? (json['reporter'] is String 
        ? User(id: null, username: json['reporter'], firstName: '', lastName: '', email: '', phoneNumber: '')  
        : User.fromJson(json['reporter'] as Map<String, dynamic>))
    : null,      
      status: CaseStatusExtension.fromValue(json['status'] ?? 'missing'),
      dateReported: DateTime.parse(json['date_reported']),
      submissionStatus: SubmissionStatusExtension.fromValue(
        json['submission_status'] ?? 'in_progress',
      ),
      updates:
          json['updates'] != null
              ? (json['updates'] as List)
                  .map((e) => CaseUpdate.fromJson(e))
                  .toList()
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic> {
      'first_name': firstName,
      'last_name': lastName,
      'age': age,
      'gender': gender.value,
      'photo': photo,
      'description': description,
      'last_seen_date': lastSeenDate.toIso8601String().split('T').first,
      'last_seen_location': lastSeenLocation,
      'status': status.value,
      'submission_status': submissionStatus.value,
    };

    if (id != null) {
      map['id'] = id;
    }

    if (latitude != null) {
      map['latitude'] = latitude;
    }

    if (longitude != null) {
      map['longitude'] = longitude;
    }

    if (reporter != null) {
      map['reporter'] = reporter!.id;
    }

    return map;
  }

  String get fullName => '$firstName $lastName';

  int get daysMissing {
    final today = DateTime.now();
    return today.difference(lastSeenDate).inDays;
  }

  int get currentAge {
    final yearsMissing = DateTime.now().year - lastSeenDate.year;
    return yearsMissing > 0 ? age + yearsMissing : age;
  }
  

  
}