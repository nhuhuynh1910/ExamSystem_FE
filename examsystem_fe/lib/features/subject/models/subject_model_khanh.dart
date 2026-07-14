class SubjectModelKhanh {
  final int subjectId;
  final String subjectName;
  final String? description;
  final bool isActive;

  SubjectModelKhanh({
    required this.subjectId,
    required this.subjectName,
    this.description,
    required this.isActive,
  });

  factory SubjectModelKhanh.fromJson(Map<String, dynamic> json) {
    return SubjectModelKhanh(
      subjectId: json['subjectId'] ?? 0,
      subjectName: json['subjectName'] ?? '',
      description: json['description'],
      isActive: json['isActive'] ?? false,
    );
  }
}