class SubjectModel {
  final int subjectId;
  final String subjectName;
  final String? description;
  final bool isActive;

  SubjectModel({
    required this.subjectId,
    required this.subjectName,
    this.description,
    required this.isActive,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      subjectId: json['subjectId'] ?? json['SubjectId'] ?? 0,
      subjectName: json['subjectName'] ?? json['SubjectName'] ?? 'Unknown Subject',
      description: json['description'] ?? json['Description'],
      isActive: json['isActive'] ?? json['IsActive'] ?? false,
    );
  }
}
