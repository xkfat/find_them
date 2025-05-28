import 'dart:developer';

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
  final String? contactPhone; 

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
    this.contactPhone,
  }) : dateReported = dateReported ?? DateTime.now();

  factory Case.fromJson(Map<String, dynamic> json) {
    try {
      log("Full JSON: $json");

      int? parsedId;
      try {
        parsedId = json['id'];
        log("Parsed ID: $parsedId");
      } catch (e) {
        log("Error parsing ID: $e");
      }

      String firstName;
      try {
        firstName = json['first_name'] ?? '';
        log("Parsed firstName: $firstName");
      } catch (e) {
        log("Error parsing firstName: $e");
        firstName = '';
      }

      String lastName;
      try {
        lastName = json['last_name'] ?? '';
        log("Parsed lastName: $lastName");
      } catch (e) {
        log("Error parsing lastName: $e");
        lastName = '';
      }

      int age;
      try {
        age = json['age'] ?? 0;
        log("Parsed age: $age");
      } catch (e) {
        log("Error parsing age: $e");
        age = 0;
      }

      Gender gender;
      try {
        gender = GenderExtension.fromValue(json['gender'] ?? 'Male');
        log("Parsed gender: $gender");
      } catch (e) {
        log("Error parsing gender: $e");
        gender = GenderExtension.fromValue('Male');
      }

      String photo;
      try {
        photo = json['photo'] ?? '';
        log("Parsed photo: $photo");
      } catch (e) {
        log("Error parsing photo: $e");
        photo = '';
      }

      String description;
      try {
        description = json['description'] ?? '';
        log("Parsed description: $description");
      } catch (e) {
        log("Error parsing description: $e");
        description = '';
      }

      DateTime lastSeenDate;
      try {
        lastSeenDate = DateTime.parse(json['last_seen_date']);
        log("Parsed lastSeenDate: $lastSeenDate");
      } catch (e) {
        log("Error parsing lastSeenDate: $e");
        lastSeenDate = DateTime.now();
      }

      String lastSeenLocation;
      try {
        lastSeenLocation = json['last_seen_location'] ?? '';
        log("Parsed lastSeenLocation: $lastSeenLocation");
      } catch (e) {
        log("Error parsing lastSeenLocation: $e");
        lastSeenLocation = '';
      }

      double? latitude;
      try {
        latitude =
            json['latitude'] == null
                ? null
                : double.tryParse(json['latitude'].toString());
        log("Parsed latitude: $latitude");
      } catch (e) {
        log("Error parsing latitude: $e");
        latitude = null;
      }

      double? longitude;
      try {
        longitude =
            json['longitude'] == null
                ? null
                : double.tryParse(json['longitude'].toString());
        log("Parsed longitude: $longitude");
      } catch (e) {
        log("Error parsing longitude: $e");
        longitude = null;
      }

      String? contactPhone;
      try {
        contactPhone = json['contact_phone'];
        log("Parsed contactPhone: $contactPhone");
      } catch (e) {
        log("Error parsing contactPhone: $e");
        contactPhone = null;
      }

      CaseStatus status;
      try {
        status = CaseStatusExtension.fromValue(json['status'] ?? 'missing');
        log("Parsed status: $status");
      } catch (e) {
        log("Error parsing status: $e");
        status = CaseStatus.missing;
      }

      DateTime dateReported;
      try {
        dateReported = DateTime.parse(json['date_reported']);
        log("Parsed dateReported: $dateReported");
      } catch (e) {
        log("Error parsing dateReported: $e");
        dateReported = DateTime.now();
      }

      SubmissionStatus submissionStatus;
      try {
        submissionStatus = SubmissionStatusExtension.fromValue(
          json['submission_status'] ?? 'in_progress',
        );
        log("Parsed submissionStatus: $submissionStatus");
      } catch (e) {
        log("Error parsing submissionStatus: $e");
        submissionStatus = SubmissionStatus.inProgress;
      }

      User? reporter;
      try {
        reporter =
            json['reporter'] != null
                ? (json['reporter'] is String
                    ? User(
                      id: null,
                      username: json['reporter'],
                      firstName: '',
                      lastName: '',
                      email: '',
                      phoneNumber: '',
                    )
                    : User.fromJson(json['reporter'] as Map<String, dynamic>))
                : null;
        log("Parsed reporter: ${reporter?.username}");
      } catch (e) {
        log("Error parsing reporter: $e");
        reporter = null;
      }

      List<CaseUpdate>? updates;
      try {
        updates =
            json['updates'] != null
                ? (json['updates'] as List)
                    .map((e) => CaseUpdate.fromJson(e))
                    .toList()
                : null;
        log("Parsed updates count: ${updates?.length}");
      } catch (e) {
        log("Error parsing updates: $e");
        updates = null;
      }

      return Case(
        id: parsedId,
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
        reporter: reporter,
        status: status,
        dateReported: dateReported,
        submissionStatus: submissionStatus,
        updates: updates,
                contactPhone: contactPhone,

      );
    } catch (e) {
      log("OVERALL ERROR in Case.fromJson: $e");
      log("Problem JSON: $json");
      rethrow;
    }
  }
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
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
            'contact_phone': contactPhone,

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
