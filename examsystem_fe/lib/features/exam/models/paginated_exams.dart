import 'exam_model.dart';

/// Map từ PaginatedResponse<`ExamDto`> - wrapper phân trang của GET /api/exams.
class PaginatedExams {
  final List<ExamModel> items;
  final int pageNumber;
  final int pageSize;
  final int totalItems;
  final int totalPages;

  const PaginatedExams({
    required this.items,
    required this.pageNumber,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
  });

  factory PaginatedExams.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return PaginatedExams(
      items:      rawItems.map((e) => ExamModel.fromJson(e as Map<String, dynamic>)).toList(),
      pageNumber: json['pageNumber'] as int,
      pageSize:   json['pageSize']   as int,
      totalItems: json['totalItems'] as int,
      totalPages: json['totalPages'] as int,
    );
  }
}
