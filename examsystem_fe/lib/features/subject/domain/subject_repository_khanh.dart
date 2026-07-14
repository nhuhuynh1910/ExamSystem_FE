import '../data/subject_api_khanh.dart';
import '../models/subject_model_khanh.dart';

class SubjectRepositoryKhanh {
  final SubjectApiKhanh api;

  SubjectRepositoryKhanh(this.api);

  Future<List<SubjectModelKhanh>> getAssignedTeachingSubjects() {
    return api.getAssignedTeachingSubjects();
  }
}