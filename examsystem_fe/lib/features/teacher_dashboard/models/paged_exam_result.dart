import 'teacher_exam_model.dart';

/// Wrapper cho `PagedResultDto<ExamResponseDto>` từ BE.
///
/// Response JSON:
/// {
///   "items": [...],
///   "pageNumber": 1,
///   "pageSize": 50,
///   "totalItems": 6,
///   "totalPages": 1
/// }
class PagedExamResult {
  final List<TeacherExamModel> items;
  final int pageNumber;
  final int pageSize;
  final int totalItems;
  final int totalPages;

  const PagedExamResult({
    required this.items,
    required this.pageNumber,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
  });

  factory PagedExamResult.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List<dynamic>?) ?? [];
    return PagedExamResult(
      items: itemsList
          .map((e) => TeacherExamModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      pageNumber: json['pageNumber'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 10,
      totalItems: json['totalItems'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
    );
  }
}
