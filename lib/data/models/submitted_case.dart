import 'package:find_them/data/models/enum.dart';

class SubmittedCase {
  final int id;
  final String fullName;
  final DateTime submittedDate;
  final SubmissionStatus status;
  final List<CaseUpdateItem> updates;
  
  SubmittedCase({
    required this.id,
    required this.fullName,
    required this.submittedDate,
    required this.status,
    required this.updates,
  });
  
  factory SubmittedCase.fromJson(Map<String, dynamic> json) {
    return SubmittedCase(
      id: json['id'],
      fullName: json['full_name'],
      submittedDate: DateTime.parse(json['date_reported']),
      status: SubmissionStatusExtension.fromValue(json['submission_status']),
      updates: json['updates'] != null
          ? (json['updates'] as List).map((e) => CaseUpdateItem.fromJson(e)).toList()
          : [],
    );
  }
  
  String get formattedSubmissionDate => 
      '${submittedDate.day.toString().padLeft(2, '0')}/${submittedDate.month.toString().padLeft(2, '0')}/${submittedDate.year}';
}

class CaseUpdateItem {
  final String message;
  final DateTime date;
  final SubmissionStatus? status; 
  
  CaseUpdateItem({
    required this.message,
    required this.date,
    this.status,
  });
  
  factory CaseUpdateItem.fromJson(Map<String, dynamic> json) {
    SubmissionStatus? status;
    
    if (json['message'].toString().contains('found safe')) {
      status = SubmissionStatus.closed;
    } else if (json['message'].toString().contains('investigating')) {
      status = SubmissionStatus.inProgress;
    } else if (json['message'].toString().toLowerCase().contains('verified')) {
      status = SubmissionStatus.active;
    }
    
    return CaseUpdateItem(
      message: json['message'],
      date: DateTime.parse(json['timestamp']),
      status: status,
    );
  }
  
  String get formattedDate => 
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}