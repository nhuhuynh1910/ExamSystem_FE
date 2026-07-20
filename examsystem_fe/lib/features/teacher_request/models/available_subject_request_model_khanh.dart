class AvailableSubjectRequestModelKhanh {
  final int subjectId;
  final String subjectName;
  final String? description;

  AvailableSubjectRequestModelKhanh({
    required this.subjectId,
    required this.subjectName,
    this.description,
  });

  factory AvailableSubjectRequestModelKhanh.fromJson(
      Map<String, dynamic> json,
      ) {
    return AvailableSubjectRequestModelKhanh(
      subjectId: json['subjectId'] ?? 0,
      subjectName: json['subjectName'] ?? '',
      description: json['description'],
    );
  }
}