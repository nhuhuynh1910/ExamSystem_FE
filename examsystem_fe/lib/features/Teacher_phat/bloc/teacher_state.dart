import '../models/teacher_course_model.dart';
import '../models/teacher_student_model.dart';

sealed class TeacherState {}

final class TeacherInitial extends TeacherState {}

final class TeacherLoading extends TeacherState {}

final class AssignedCoursesLoaded extends TeacherState {
  final List<TeacherCourseModel> courses;
  AssignedCoursesLoaded(this.courses);
}

final class CourseRosterLoaded extends TeacherState {
  final List<TeacherStudentModel> students;
  CourseRosterLoaded(this.students);
}

final class TeacherFailure extends TeacherState {
  final String errorMessage;
  TeacherFailure(this.errorMessage);
}
