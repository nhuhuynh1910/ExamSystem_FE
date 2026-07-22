import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/subject_repository.dart';
import 'subject_event.dart';
import 'subject_state.dart';

class SubjectBloc extends Bloc<SubjectEvent, SubjectState> {
  final SubjectRepository _repository;

  SubjectBloc(this._repository) : super(SubjectInitial()) {
    on<LoadSubjects>(_onLoadSubjects);
    on<LoadSubjectDetail>(_onLoadSubjectDetail);
    on<CreateSubjectEvent>(_onCreateSubject);
    on<UpdateSubjectEvent>(_onUpdateSubject);
    on<DeleteSubjectEvent>(_onDeleteSubject);
    on<LoadSubjectStudents>(_onLoadSubjectStudents);
    on<LoadAllTeachers>(_onLoadAllTeachers);
    on<LoadSubjectTeachers>(_onLoadSubjectTeachers);
    on<AssignTeacher>(_onAssignTeacher);
    on<UnassignTeacher>(_onUnassignTeacher);
  }

  Future<void> _onLoadSubjects(
    LoadSubjects event,
    Emitter<SubjectState> emit,
  ) async {
    emit(SubjectLoading());
    try {
      final list = await _repository.fetchSubjects();
      emit(SubjectsLoaded(list));
    } catch (e) {
      emit(SubjectFailure(e.toString()));
    }
  }

  Future<void> _onLoadSubjectDetail(
    LoadSubjectDetail event,
    Emitter<SubjectState> emit,
  ) async {
    emit(SubjectLoading());
    try {
      final subject = await _repository.fetchSubjectById(event.subjectId);
      emit(SubjectDetailLoaded(subject));
    } catch (e) {
      emit(SubjectFailure(e.toString()));
    }
  }

  Future<void> _onCreateSubject(
    CreateSubjectEvent event,
    Emitter<SubjectState> emit,
  ) async {
    emit(SubjectLoading());
    try {
      await _repository.createSubject(
        subjectName: event.subjectName,
        description: event.description,
      );
      emit(SubjectActionSuccess('Đã tạo môn học thành công.'));
    } catch (e) {
      emit(SubjectFailure(e.toString()));
    }
  }

  Future<void> _onUpdateSubject(
    UpdateSubjectEvent event,
    Emitter<SubjectState> emit,
  ) async {
    emit(SubjectLoading());
    try {
      await _repository.updateSubject(
        subjectId: event.subjectId,
        subjectName: event.subjectName,
        description: event.description,
        isActive: event.isActive,
      );
      emit(SubjectActionSuccess('Đã cập nhật môn học thành công.'));
    } catch (e) {
      emit(SubjectFailure(e.toString()));
    }
  }

  Future<void> _onDeleteSubject(
    DeleteSubjectEvent event,
    Emitter<SubjectState> emit,
  ) async {
    emit(SubjectLoading());
    try {
      await _repository.deleteSubject(event.subjectId);
      emit(SubjectActionSuccess('Đã xóa môn học thành công.'));
    } catch (e) {
      emit(SubjectFailure(e.toString()));
    }
  }

  Future<void> _onLoadSubjectStudents(
    LoadSubjectStudents event,
    Emitter<SubjectState> emit,
  ) async {
    emit(SubjectLoading());
    try {
      final students = await _repository.fetchSubjectStudents(event.subjectId);
      emit(SubjectStudentsLoaded(students));
    } catch (e) {
      emit(SubjectFailure(e.toString()));
    }
  }

  /// Load đồng thời: danh sách tất cả GV + GV đang được gán vào môn hiện tại.
  /// Dùng cho màn hình Admin Gán GV — cần 2 danh sách cùng lúc để render UI.
  Future<void> _onLoadAllTeachers(
    LoadAllTeachers event,
    Emitter<SubjectState> emit,
  ) async {
    emit(SubjectLoading());
    try {
      final results = await Future.wait([
        _repository.fetchAllTeachers(),
        _repository.fetchSubjectTeachers(event.subjectId),
      ]);
      emit(AllTeachersLoaded(
        allTeachers: results[0] as dynamic,
        assignedTeachers: results[1] as dynamic,
      ));
    } catch (e) {
      emit(SubjectFailure(e.toString()));
    }
  }

  Future<void> _onLoadSubjectTeachers(
    LoadSubjectTeachers event,
    Emitter<SubjectState> emit,
  ) async {
    emit(SubjectLoading());
    try {
      final teachers = await _repository.fetchSubjectTeachers(event.subjectId);
      emit(SubjectTeachersLoaded(teachers));
    } catch (e) {
      emit(SubjectFailure(e.toString()));
    }
  }

  Future<void> _onAssignTeacher(
    AssignTeacher event,
    Emitter<SubjectState> emit,
  ) async {
    try {
      await _repository.assignTeacher(event.subjectId, event.teacherId);
      emit(SubjectTeacherActionSuccess('Đã gán giáo viên thành công.'));
    } catch (e) {
      emit(SubjectFailure(e.toString()));
    }
  }

  Future<void> _onUnassignTeacher(
    UnassignTeacher event,
    Emitter<SubjectState> emit,
  ) async {
    try {
      await _repository.unassignTeacher(event.subjectId, event.teacherId);
      emit(SubjectTeacherActionSuccess('Đã gỡ giáo viên thành công.'));
    } catch (e) {
      emit(SubjectFailure(e.toString()));
    }
  }
}
