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
      print("Full JSON: $json");

      int? parsedId;
      try {
        parsedId = json['id'];
        print("Parsed ID: $parsedId");
      } catch (e) {
        print("Error parsing ID: $e");
      }

      String firstName;
      try {
        firstName = json['first_name'] ?? '';
        print("Parsed firstName: $firstName");
      } catch (e) {
        print("Error parsing firstName: $e");
        firstName = '';
      }

      String lastName;
      try {
        lastName = json['last_name'] ?? '';
        print("Parsed lastName: $lastName");
      } catch (e) {
        print("Error parsing lastName: $e");
        lastName = '';
      }

      int age;
      try {
        age = json['age'] ?? 0;
        print("Parsed age: $age");
      } catch (e) {
        print("Error parsing age: $e");
        age = 0;
      }

      Gender gender;
      try {
        gender = GenderExtension.fromValue(json['gender'] ?? 'Male');
        print("Parsed gender: $gender");
      } catch (e) {
        print("Error parsing gender: $e");
        gender = GenderExtension.fromValue('Male');
      }

      String photo;
      try {
        photo = json['photo'] ?? '';
        print("Parsed photo: $photo");
      } catch (e) {
        print("Error parsing photo: $e");
        photo = '';
      }

      String description;
      try {
        description = json['description'] ?? '';
        print("Parsed description: $description");
      } catch (e) {
        print("Error parsing description: $e");
        description = '';
      }

      DateTime lastSeenDate;
      try {
        lastSeenDate = DateTime.parse(json['last_seen_date']);
        print("Parsed lastSeenDate: $lastSeenDate");
      } catch (e) {
        print("Error parsing lastSeenDate: $e");
        lastSeenDate = DateTime.now();
      }

      String lastSeenLocation;
      try {
        lastSeenLocation = json['last_seen_location'] ?? '';
        print("Parsed lastSeenLocation: $lastSeenLocation");
      } catch (e) {
        print("Error parsing lastSeenLocation: $e");
        lastSeenLocation = '';
      }

      double? latitude;
      try {
        latitude =
            json['latitude'] == null
                ? null
                : double.tryParse(json['latitude'].toString());
        print("Parsed latitude: $latitude");
      } catch (e) {
        print("Error parsing latitude: $e");
        latitude = null;
      }

      double? longitude;
      try {
        longitude =
            json['longitude'] == null
                ? null
                : double.tryParse(json['longitude'].toString());
        print("Parsed longitude: $longitude");
      } catch (e) {
        print("Error parsing longitude: $e");
        longitude = null;
      }

      String? contactPhone;
      try {
        contactPhone = json['contact_phone'];
        print("Parsed contactPhone: $contactPhone");
      } catch (e) {
        print("Error parsing contactPhone: $e");
        contactPhone = null;
      }

      CaseStatus status;
      try {
        status = CaseStatusExtension.fromValue(json['status'] ?? 'missing');
        print("Parsed status: $status");
      } catch (e) {
        print("Error parsing status: $e");
        status = CaseStatus.missing;
      }

      DateTime dateReported;
      try {
        dateReported = DateTime.parse(json['date_reported']);
        print("Parsed dateReported: $dateReported");
      } catch (e) {
        print("Error parsing dateReported: $e");
        dateReported = DateTime.now();
      }

      SubmissionStatus submissionStatus;
      try {
        submissionStatus = SubmissionStatusExtension.fromValue(
          json['submission_status'] ?? 'in_progress',
        );
        print("Parsed submissionStatus: $submissionStatus");
      } catch (e) {
        print("Error parsing submissionStatus: $e");
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
        print("Parsed reporter: ${reporter?.username}");
      } catch (e) {
        print("Error parsing reporter: $e");
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
        print("Parsed updates count: ${updates?.length}");
      } catch (e) {
        print("Error parsing updates: $e");
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
      print("OVERALL ERROR in Case.fromJson: $e");
      print("Problem JSON: $json");
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
