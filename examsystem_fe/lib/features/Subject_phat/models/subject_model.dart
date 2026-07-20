import 'dart:convert';

/// SubjectModel — Đại diện cho môn học trong feature Subject.
class SubjectModel {
  final int subjectId;
  final String subjectName;
  final String? description;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SubjectModel({
    required this.subjectId,
    required this.subjectName,
    this.description,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  // ─── Getters cho trường mở rộng định dạng ───────────────────────────────

  /// Lấy mã môn học (ví dụ: SWE102) từ subjectName.
  String get courseCode {
    final index = subjectName.indexOf(' - ');
    if (index != -1) {
      return subjectName.substring(0, index).trim();
    }
    return 'SUBJ$subjectId';
  }

  /// Lấy tên môn học (đã lọc bỏ mã môn).
  String get courseNameOnly {
    final index = subjectName.indexOf(' - ');
    if (index != -1) {
      return subjectName.substring(index + 3).trim();
    }
    return subjectName;
  }

  /// Lấy số tín chỉ từ JSON trong description, mặc định là 3.
  int get courseCredits {
    final data = _parseJsonDescription();
    if (data != null && data['credits'] != null) {
      return int.tryParse(data['credits'].toString()) ?? 3;
    }
    return 3;
  }

  /// Lấy phân loại môn học từ JSON trong description, mặc định là 'Core'.
  String get courseCategory {
    final data = _parseJsonDescription();
    if (data != null && data['category'] != null) {
      return data['category'].toString();
    }
    return 'Core';
  }

  /// Lấy mô tả gốc (đã bóc tách khỏi cấu trúc JSON).
  String get cleanDescription {
    final data = _parseJsonDescription();
    if (data != null && data['description'] != null) {
      return data['description'].toString();
    }
    return description ?? '';
  }

  Map<String, dynamic>? _parseJsonDescription() {
    if (description == null) return null;
    final trimmed = description!.trim();
    if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
      try {
        return jsonDecode(trimmed) as Map<String, dynamic>;
      } catch (_) {}
    }
    return null;
  }

  // ─── Định dạng dữ liệu trước khi gửi lên API ─────────────────────────────

  static String toFormattedSubjectName(String code, String name) {
    return '${code.trim().toUpperCase()} - ${name.trim()}';
  }

  static String toFormattedDescription({
    required int credits,
    required String category,
    required String rawDesc,
  }) {
    return jsonEncode({
      'credits': credits,
      'category': category,
      'description': rawDesc.trim(),
    });
  }

  // ─── JSON Serialization ──────────────────────────────────────────────────

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      subjectId: json['subjectId'] as int? ?? 0,
      subjectName: json['subjectName'] as String? ?? '',
      description: json['description'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subjectId': subjectId,
      'subjectName': subjectName,
      'description': description,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

