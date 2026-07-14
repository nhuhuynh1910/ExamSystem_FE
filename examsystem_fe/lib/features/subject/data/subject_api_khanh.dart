import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import '../models/subject_model_khanh.dart';

class SubjectApiKhanh {
  Future<List<SubjectModelKhanh>> getSubjects() async {
    final response = await DioClient.instance.get('/subjects');

    final data = response.data;

    if (data is List) {
      return data
          .map((e) => SubjectModelKhanh.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    if (data is Map<String, dynamic> && data['data'] is List) {
      return (data['data'] as List)
          .map((e) => SubjectModelKhanh.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  Future<bool> canTeacherViewSubjectStudents(int subjectId) async {
    try {
      await DioClient.instance.get('/subjects/$subjectId/students');
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        return false;
      }
      return false;
    }
  }

  Future<List<SubjectModelKhanh>> getAssignedTeachingSubjects() async {
    final subjects = await getSubjects();
    final List<SubjectModelKhanh> assignedSubjects = [];

    for (final subject in subjects) {
      final canView = await canTeacherViewSubjectStudents(subject.subjectId);

      if (canView) {
        assignedSubjects.add(subject);
      }
    }

    return assignedSubjects;
  }
}