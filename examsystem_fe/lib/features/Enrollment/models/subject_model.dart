import 'dart:convert';

/// SubjectModel — Đại diện cho 1 môn học trong hệ thống.
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

  String get courseCode {
    final index = subjectName.indexOf(' - ');
    if (index != -1) {
      return subjectName.substring(0, index).trim();
    }
    return 'SUBJ$subjectId';
  }

  String get courseNameOnly {
    final index = subjectName.indexOf(' - ');
    if (index != -1) {
      return subjectName.substring(index + 3).trim();
    }
    return subjectName;
  }

  int get courseCredits {
    final data = _parseJsonDescription();
    if (data != null && data['credits'] != null) {
      return int.tryParse(data['credits'].toString()) ?? 3;
    }
    return 3;
  }

  String get courseCategory {
    final data = _parseJsonDescription();
    if (data != null && data['category'] != null) {
      return data['category'].toString();
    }
    return 'Core';
  }

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

