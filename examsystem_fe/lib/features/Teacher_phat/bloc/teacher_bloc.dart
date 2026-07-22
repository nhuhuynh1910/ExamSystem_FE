import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/teacher_repository.dart';
import 'teacher_event.dart';
import 'teacher_state.dart';

class TeacherBloc extends Bloc<TeacherEvent, TeacherState> {
  final TeacherRepository _repository;

  TeacherBloc(this._repository) : super(TeacherInitial()) {
    on<LoadAssignedCourses>(_onLoadAssignedCourses);
    on<LoadCourseRoster>(_onLoadCourseRoster);
  }

  Future<void> _onLoadAssignedCourses(
    LoadAssignedCourses event,
    Emitter<TeacherState> emit,
  ) async {
    emit(TeacherLoading());
    try {
      final courses = await _repository.fetchAssignedCourses();
      emit(AssignedCoursesLoaded(courses));
    } catch (e) {
      emit(TeacherFailure(e.toString()));
    }
  }

  Future<void> _onLoadCourseRoster(
    LoadCourseRoster event,
    Emitter<TeacherState> emit,
  ) async {
    emit(TeacherLoading());
    try {
      final students = await _repository.fetchCourseRoster(event.subjectId);
      emit(CourseRosterLoaded(students));
    } catch (e) {
      emit(TeacherFailure(e.toString()));
    }
  }
}
