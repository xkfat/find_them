import 'package:find_them/data/models/case.dart';

class CaseUpdate {
  final int? id;
  final int caseId;
  final Case? case_; 
  final String message;
  final DateTime timestamp;

  CaseUpdate({
    this.id,
    required this.caseId,
    this.case_,
    required this.message,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory CaseUpdate.fromJson(Map<String, dynamic> json) {
    return CaseUpdate(
      id: json['id'],
      caseId: json['case'],
      case_: null, 
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic> {
      'case': caseId,
      'message': message,
    };

    if (id != null) {
      map['id'] = id;
    }

    return map;
  }

  String get formattedDate =>
      '${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')}/${timestamp.year}';
      
  CaseUpdate copyWith({
    int? id,
    int? caseId,
    Case? case_,
    String? message,
    DateTime? timestamp,
  }) {
    return CaseUpdate(
      id: id ?? this.id,
      caseId: caseId ?? this.caseId,
      case_: case_ ?? this.case_,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}