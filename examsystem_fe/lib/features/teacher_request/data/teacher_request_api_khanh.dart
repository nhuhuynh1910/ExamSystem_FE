import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';

import '../../../core/network/dio_client.dart';
import '../models/available_subject_request_model_khanh.dart';
import '../models/teacher_request_model_khanh.dart';

class TeacherRequestApiKhanh {
  Future<List<AvailableSubjectRequestModelKhanh>> getAvailableSubjects() async {
    final response = await DioClient.instance.get(
      '/teacher-requests/available-subjects',
    );

    final data = response.data;

    if (data is List) {
      return data
          .map(
            (e) => AvailableSubjectRequestModelKhanh.fromJson(
          e as Map<String, dynamic>,
        ),
      )
          .toList();
    }

    return [];
  }

  Future<TeacherRequestModelKhanh> createTeacherRequest({
    required int subjectId,
    required String reason,
    PlatformFile? certificationFile,
  }) async {
    final formData = FormData.fromMap({
      'SubjectId': subjectId,
      'Reason': reason,
      if (certificationFile != null && certificationFile.bytes != null)
        'CertificationFile': MultipartFile.fromBytes(
          certificationFile.bytes!,
          filename: certificationFile.name,
        ),
    });

    final response = await DioClient.instance.post(
      '/teacher-requests',
      data: formData,
    );

    return TeacherRequestModelKhanh.fromJson(response.data);
  }
  Future<List<TeacherRequestModelKhanh>> getMyRequests() async {
    final response = await DioClient.instance.get(
      '/teacher-requests/my-requests',
    );

    final data = response.data;

    if (data is List) {
      return data
          .map((e) => TeacherRequestModelKhanh.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return [];
  }
  Future<List<TeacherRequestModelKhanh>> getAdminRequests({
    String? status,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    final response = await DioClient.instance.get(
      '/admin/teacher-requests',
      queryParameters: {
        'pageNumber': pageNumber,
        'pageSize': pageSize,
        if (status != null && status.isNotEmpty) 'status': status,
      },
    );

    final data = response.data;

    if (data is Map<String, dynamic>) {
      final items = data['items'] ?? data['data'];

      if (items is List) {
        return items
            .map((e) => TeacherRequestModelKhanh.fromJson(e))
            .toList();
      }
    }

    if (data is List) {
      return data
          .map((e) => TeacherRequestModelKhanh.fromJson(e))
          .toList();
    }

    return [];
  }

  Future<TeacherRequestModelKhanh> approveRequest(int requestId) async {
    final response = await DioClient.instance.put(
      '/admin/teacher-requests/$requestId/approve',
    );

    return TeacherRequestModelKhanh.fromJson(response.data);
  }

  Future<TeacherRequestModelKhanh> rejectRequest({
    required int requestId,
    String? adminNote,
  }) async {
    final response = await DioClient.instance.put(
      '/admin/teacher-requests/$requestId/reject',
      data: {
        'adminNote': adminNote,
      },
    );

    return TeacherRequestModelKhanh.fromJson(response.data);
  }
}