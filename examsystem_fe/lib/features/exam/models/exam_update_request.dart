import 'package:dio/dio.dart';
import 'dart:typed_data';

class ExamUpdateRequest {
  final int subjectId;
  final String examName;
  final String? description;
  final String? examImagePath;
  final Uint8List? examImageBytes; // Hỗ trợ Web và Mobile
  final String? examImageName;
  final int durationMinutes;
  final DateTime startTime;
  final DateTime endTime;
  final double totalScore;
  final double passingScore;
  final int maxAttempts;
  final bool isPrivate;
  final String? accessCode;
  final bool shuffleQuestions;
  final bool showAnswerAfterSubmit;

  const ExamUpdateRequest({
    required this.subjectId,
    required this.examName,
    this.description,
    this.examImagePath,
    this.examImageBytes,
    this.examImageName,
    required this.durationMinutes,
    required this.startTime,
    required this.endTime,
    required this.totalScore,
    required this.passingScore,
    required this.maxAttempts,
    required this.isPrivate,
    this.accessCode,
    required this.shuffleQuestions,
    required this.showAnswerAfterSubmit,
  });

  Map<String, dynamic> toJson() {
    return {
      'SubjectId': subjectId,
      'ExamName': examName,
      'Description': description,
      'DurationMinutes': durationMinutes,
      'StartTime': startTime.toIso8601String(),
      'EndTime': endTime.toIso8601String(),
      'TotalScore': totalScore,
      'PassingScore': passingScore,
      'MaxAttempts': maxAttempts,
      'IsPrivate': isPrivate,
      'AccessCode': accessCode,
      'ShuffleQuestions': shuffleQuestions,
      'ShowAnswerAfterSubmit': showAnswerAfterSubmit,
    };
  }

  Future<FormData> toFormData() async {
    final Map<String, dynamic> map = toJson();
    if (examImageBytes != null) {
      map['ExamImage'] = MultipartFile.fromBytes(
        examImageBytes!,
        filename: examImageName ?? 'exam_image.jpg',
      );
    } else if (examImagePath != null && examImagePath!.isNotEmpty) {
      map['ExamImage'] = await MultipartFile.fromFile(examImagePath!);
    }
    return FormData.fromMap(map);
  }
}
