import 'package:file_picker/file_picker.dart';

import '../data/teacher_request_api_khanh.dart';
import '../models/available_subject_request_model_khanh.dart';
import '../models/teacher_request_model_khanh.dart';

class TeacherRequestRepositoryKhanh {
  final TeacherRequestApiKhanh api;

  TeacherRequestRepositoryKhanh(this.api);

  Future<List<AvailableSubjectRequestModelKhanh>> getAvailableSubjects() {
    return api.getAvailableSubjects();
  }

  Future<TeacherRequestModelKhanh> createTeacherRequest({
    required int subjectId,
    required String reason,
    PlatformFile? certificationFile,
  }) {
    return api.createTeacherRequest(
      subjectId: subjectId,
      reason: reason,
      certificationFile: certificationFile,
    );
  }

  Future<List<TeacherRequestModelKhanh>> getMyRequests() {
    return api.getMyRequests();
  }

  Future<List<TeacherRequestModelKhanh>> getAdminRequests({
    String? status,
    int pageNumber = 1,
    int pageSize = 20,
  }) {
    return api.getAdminRequests(
      status: status,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }

  Future<TeacherRequestModelKhanh> approveRequest(int requestId) {
    return api.approveRequest(requestId);
  }

  Future<TeacherRequestModelKhanh> rejectRequest({
    required int requestId,
    String? adminNote,
  }) {
    return api.rejectRequest(
      requestId: requestId,
      adminNote: adminNote,
    );
  }
}
