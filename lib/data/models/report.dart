
class Report {
  final int caseId;
  final String note;

  Report({required this.caseId, required this.note});

  Map<String, dynamic> toJson() {
    return {'missing_person': caseId, 'note': note};
  }
}
