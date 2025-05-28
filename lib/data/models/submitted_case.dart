
import 'dart:developer';

import 'package:find_them/data/models/enum.dart';

class SubmittedCase {
  final int id;
  final String firstName;
  final String lastName;
  final String fullName;
  final DateTime submittedDate;
  final SubmissionStatus status;
  final LatestUpdate? latestUpdate;
  final List<CaseUpdateItem> allUpdates; 
  
  SubmittedCase({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.submittedDate,
    required this.status,
    this.latestUpdate,
    this.allUpdates = const [], 
  });
  
  factory SubmittedCase.fromJson(Map<String, dynamic> json) {
    return SubmittedCase(
      id: json['id'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      fullName: json['full_name'] ?? '',
      submittedDate: DateTime.parse(json['date_reported']),
      status: SubmissionStatusExtension.fromValue(json['submission_status']),
      latestUpdate: json['latest_update'] != null 
          ? LatestUpdate.fromJson(json['latest_update']) 
          : null,
      allUpdates: const [], 
    );
  }

  factory SubmittedCase.fromJsonWithUpdates(Map<String, dynamic> json) {
    try {
      final List<CaseUpdateItem> updates = [];
      
      if (json['updates'] != null && json['updates'] is List) {
        final updatesList = json['updates'] as List;
        for (var updateJson in updatesList) {
          if (updateJson is Map<String, dynamic>) {
            updates.add(CaseUpdateItem.fromJson(updateJson));
          }
        }
      }
      
      updates.sort((a, b) => b.date.compareTo(a.date));
      
      return SubmittedCase(
        id: json['id'] as int,
        firstName: json['first_name'] as String? ?? '',
        lastName: json['last_name'] as String? ?? '',
        fullName: json['full_name'] as String? ?? '',
        submittedDate: DateTime.parse(json['date_reported'] as String),
        status: SubmissionStatusExtension.fromValue(json['submission_status'] as String),
        latestUpdate: json['latest_update'] != null 
            ? LatestUpdate.fromJson(json['latest_update'] as Map<String, dynamic>) 
            : null,
        allUpdates: updates, 
      );
    } catch (e) {
      log('Error parsing SubmittedCase with updates: $e');
      log('JSON: $json');
      rethrow;
    }
  }
  
  String get formattedSubmissionDate => 
      '${submittedDate.day.toString().padLeft(2, '0')}/${submittedDate.month.toString().padLeft(2, '0')}/${submittedDate.year}';

  List<CaseUpdateItem> get updates {
    if (allUpdates.isNotEmpty) {
      return allUpdates;
    }
    if (latestUpdate == null) return [];
    return [
      CaseUpdateItem(
        message: latestUpdate!.message,
        date: latestUpdate!.parsedDate,
      )
    ];
  }
}

class LatestUpdate {
  final String message;
  final String date;
  
  LatestUpdate({
    required this.message,
    required this.date,
  });
  
  factory LatestUpdate.fromJson(Map<String, dynamic> json) {
    return LatestUpdate(
      message: json['message'] ?? '',
      date: json['date'] ?? '',
    );
  }
  
  DateTime get parsedDate {
    try {
      final parts = date.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    } catch (e) {
      log('Error parsing date: $date, error: $e');
    }
    return DateTime.now();
  }
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
    
    final messageStr = json['message']?.toString() ?? '';
    if (messageStr.contains('found safe')) {
      status = SubmissionStatus.closed;
    } else if (messageStr.contains('investigating')) {
      status = SubmissionStatus.inProgress;
    } else if (messageStr.toLowerCase().contains('verified')) {
      status = SubmissionStatus.active;
    }
    
    return CaseUpdateItem(
      message: messageStr,
      date: DateTime.parse(json['timestamp'] as String),
      status: status,
    );
  }
  
  String get formattedDate => 
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}