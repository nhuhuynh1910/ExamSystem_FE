import 'package:file_picker/file_picker.dart';

import '../data/teacher_request_api_khanh.dart';
import '../models/available_subject_request_model_khanh.dart';
import '../models/teacher_request_model_khanh.dart';

class TeacherRequestRepositoryKhanh {
  final TeacherRequestApiKhanh api;

  TeacherRequestRepositoryKhanh(this.api);

  Future<List<AvailableSubjectRequestModelKhanh>>
  getAvailableSubjects() {
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
}