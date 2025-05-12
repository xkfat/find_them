import 'package:find_them/data/models/enum.dart';
import 'package:find_them/data/models/case.dart';

class CaseDetail {
  final int id;
  final String fullName;
  final int age;
  final Gender gender;
  final String photo;
  final int daysMissing;
  final CaseStatus status;
  final DateTime lastSeenDate;
  final String lastSeenLocation;
  final String description;
  
  CaseDetail({
    required this.id,
    required this.fullName,
    required this.age,
    required this.gender,
    required this.photo,
    required this.daysMissing,
    required this.status,
    required this.lastSeenDate,
    required this.lastSeenLocation,
    required this.description,
  });
  
  factory CaseDetail.fromCase(Case case_) {
    return CaseDetail(
      id: case_.id!,
      fullName: case_.fullName,
      age: case_.age,
      gender: case_.gender,
      photo: case_.photo,
      daysMissing: case_.daysMissing,
      status: case_.status,
      lastSeenDate: case_.lastSeenDate,
      lastSeenLocation: case_.lastSeenLocation,
      description: case_.description,
    );
  }
  
  String get formattedLastSeenDate => 
      '${lastSeenDate.day.toString().padLeft(2, '0')}/${lastSeenDate.month.toString().padLeft(2, '0')}/${lastSeenDate.year}';
}