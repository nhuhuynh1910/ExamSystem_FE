class SubjectModelKhanh {
  final int subjectId;
  final String subjectName;

  SubjectModelKhanh({
    required this.subjectId,
    required this.subjectName,
  });

  factory SubjectModelKhanh.fromJson(Map<String, dynamic> json) {
    return SubjectModelKhanh(
      subjectId: json['subjectId'] ?? json['id'],
      subjectName: json['subjectName'] ?? json['name'] ?? json['title'] ?? '',
    );
  }
}