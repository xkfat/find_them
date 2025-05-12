import 'package:find_them/data/models/user.dart';
import 'package:find_them/data/models/case.dart';
import 'package:find_them/data/models/enum.dart';

class Report {
  final int? id;
  final User? user;
  final int caseId;
  final Case? casee;
  final String note;
  final DateTime dateSubmitted;
  final ReportStatus reportStatus;

  Report({
    this.id,
    this.user,
    required this.caseId,
    this.casee,
    required this.note,
    DateTime? dateSubmitted,
    this.reportStatus = ReportStatus.pending,
  }) : dateSubmitted = dateSubmitted ?? DateTime.now();

  factory Report.createNew({
    required int caseId,
    Case? caseObject,
    User? currentUser,
    required String note,
  }) {
    return Report(
      caseId: caseId,
      casee: caseObject,
      user: currentUser,
      note: note,
    );
  }

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      caseId: json['case'],
      casee:
          json['case_object'] != null
              ? Case.fromJson(json['case_object'])
              : null,
      note: json['note'],
      dateSubmitted: DateTime.parse(json['date_submitted']),
      reportStatus: ReportStatusExtension.fromValue(
        json['report_status'] ?? 'new',
      ),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'case': caseId,
      'note': note,
      'date_submitted': dateSubmitted.toIso8601String(),
      'report_status': reportStatus.value,
    };

    if (id != null) {
      map['id'] = id;
    }

    if (user != null) {
      map['user'] = user!.id;
    }

    return map;
  }



  String get formattedDate =>
      '${dateSubmitted.day.toString().padLeft(2, '0')}/${dateSubmitted.month.toString().padLeft(2, '0')}/${dateSubmitted.year}';

  Report copyWith({
    int? id,
    User? user,
    int? caseId,
    Case? casee,
    String? note,
    DateTime? dateSubmitted,
    ReportStatus? reportStatus,
  }) {
    return Report(
      id: id ?? this.id,
      user: user ?? this.user,
      caseId: caseId ?? this.caseId,
      casee: casee ?? this.casee,
      note: note ?? this.note,
      dateSubmitted: dateSubmitted ?? this.dateSubmitted,
      reportStatus: reportStatus ?? this.reportStatus,
    );
  }
}
