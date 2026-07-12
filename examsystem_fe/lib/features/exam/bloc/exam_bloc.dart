import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../../core/utils/token_storage.dart';
import '../domain/exam_service.dart';
import '../models/subject_model.dart';
import 'exam_event.dart';
import 'exam_state.dart';

class ExamBloc extends Bloc<ExamEvent, ExamState> {
  final ExamService _examService;

  ExamBloc(this._examService) : super(const ExamInitial()) {
    on<LoadSubjectsEvent>(_onLoadSubjects);
    on<LoadExamsEvent>(_onLoadExams);
    on<LoadTeacherExamsEvent>(_onLoadTeacherExams);
    on<LoadExamDetailEvent>(_onLoadExamDetail);
    on<CreateExamEvent>(_onCreateExam);
    on<UpdateExamEvent>(_onUpdateExam);
    on<DeleteExamEvent>(_onDeleteExam);
    on<RestoreExamEvent>(_onRestoreExam);
    on<PublishExamEvent>(_onPublishExam);
    on<CloseExamEvent>(_onCloseExam);
    on<AddQuestionToExamEvent>(_onAddQuestion);
    on<RemoveQuestionFromExamEvent>(_onRemoveQuestion);
  }

  String _handleError(dynamic e) {
    if (e is DioException) {
      if (e.response?.data != null && e.response?.data is Map) {
        return e.response?.data['message'] ?? e.message;
      }
      if (e.response?.statusCode == 403) return 'Bạn không có quyền thực hiện hành động này.';
      if (e.response?.statusCode == 400) return 'Dữ liệu không hợp lệ.';
    }
    return e.toString();
  }

  Future<void> _onLoadSubjects(LoadSubjectsEvent event, Emitter<ExamState> emit) async {
    emit(ExamLoading(exams: state.exams, subjects: state.subjects, selectedExam: state.selectedExam, examQuestions: state.examQuestions));
    try {
      final role = await TokenStorage.getRole();
      final userId = await TokenStorage.getUserId() ?? 0;
      
      List<SubjectModel> subjects;
      
      if (role == 'Admin') {
        subjects = await _examService.getSubjects();
      } else if (role == 'Teacher') {
        subjects = await _examService.getTeacherSubjects();
      } else {
        // Học sinh: Lấy các môn đã đăng ký học
        subjects = await _examService.getEnrolledSubjects(userId);
      }

      emit(SubjectsLoaded(subjects, exams: state.exams));
    } catch (e) {
      emit(ExamError(_handleError(e), exams: state.exams, subjects: state.subjects, selectedExam: state.selectedExam, examQuestions: state.examQuestions));
    }
  }

  Future<void> _onLoadExams(LoadExamsEvent event, Emitter<ExamState> emit) async {
    emit(ExamLoading(exams: state.exams, subjects: state.subjects, selectedExam: state.selectedExam, examQuestions: state.examQuestions));
    try {
      final exams = await _examService.getExams(
        subjectId: event.subjectId,
        pageNumber: event.pageNumber,
        pageSize: event.pageSize,
      );
      emit(ExamsLoaded(exams, subjects: state.subjects));
    } catch (e) {
      emit(ExamError(_handleError(e), exams: state.exams, subjects: state.subjects, selectedExam: state.selectedExam, examQuestions: state.examQuestions));
    }
  }

  Future<void> _onLoadTeacherExams(LoadTeacherExamsEvent event, Emitter<ExamState> emit) async {
    emit(ExamLoading(exams: state.exams, subjects: state.subjects, selectedExam: state.selectedExam, examQuestions: state.examQuestions));
    try {
      final exams = await _examService.getTeacherExams(
        status: event.status,
        subjectId: event.subjectId,
        pageNumber: event.pageNumber,
        pageSize: event.pageSize,
      );
      emit(ExamsLoaded(exams, subjects: state.subjects));
    } catch (e) {
      emit(ExamError(_handleError(e), exams: state.exams, subjects: state.subjects, selectedExam: state.selectedExam, examQuestions: state.examQuestions));
    }
  }

  Future<void> _onLoadExamDetail(LoadExamDetailEvent event, Emitter<ExamState> emit) async {
    emit(ExamLoading(exams: state.exams, subjects: state.subjects, selectedExam: state.selectedExam, examQuestions: state.examQuestions));
    try {
      final exam = await _examService.getExamById(event.examId);
      final questions = await _examService.getExamQuestions(event.examId);
      emit(ExamDetailLoaded(exam, questions: questions, subjects: state.subjects));
    } catch (e) {
      emit(ExamError(_handleError(e), exams: state.exams, subjects: state.subjects, selectedExam: state.selectedExam, examQuestions: state.examQuestions));
    }
  }

  Future<void> _onCreateExam(CreateExamEvent event, Emitter<ExamState> emit) async {
    emit(ExamLoading(exams: state.exams, subjects: state.subjects, selectedExam: state.selectedExam, examQuestions: state.examQuestions));
    try {
      await _examService.createExam(event.request);
      emit(ExamOperationSuccess('Tạo đề thi thành công', exams: state.exams, subjects: state.subjects, selectedExam: state.selectedExam, examQuestions: state.examQuestions));
      add(const LoadTeacherExamsEvent());
    } catch (e) {
      emit(ExamError(_handleError(e), exams: state.exams, subjects: state.subjects, selectedExam: state.selectedExam, examQuestions: state.examQuestions));
    }
  }

  Future<void> _onUpdateExam(UpdateExamEvent event, Emitter<ExamState> emit) async {
    emit(ExamLoading(exams: state.exams, subjects: state.subjects, selectedExam: state.selectedExam, examQuestions: state.examQuestions));
    try {
      await _examService.updateExam(event.examId, event.request);
      emit(ExamOperationSuccess('Cập nhật thành công', exams: state.exams, subjects: state.subjects, selectedExam: state.selectedExam, examQuestions: state.examQuestions));
      add(LoadExamDetailEvent(event.examId));
    } catch (e) {
      emit(ExamError(_handleError(e), exams: state.exams, subjects: state.subjects, selectedExam: state.selectedExam, examQuestions: state.examQuestions));
    }
  }

  Future<void> _onDeleteExam(DeleteExamEvent event, Emitter<ExamState> emit) async {
    emit(ExamLoading(exams: state.exams, subjects: state.subjects, selectedExam: state.selectedExam, examQuestions: state.examQuestions));
    try {
      await _examService.deleteExam(event.examId);
      emit(ExamOperationSuccess('Đã xóa đề thi', exams: state.exams, subjects: state.subjects, selectedExam: state.selectedExam, examQuestions: state.examQuestions));
      add(const LoadTeacherExamsEvent());
    } catch (e) {
      emit(ExamError(_handleError(e), exams: state.exams, subjects: state.subjects, selectedExam: state.selectedExam, examQuestions: state.examQuestions));
    }
  }

  Future<void> _onRestoreExam(RestoreExamEvent event, Emitter<ExamState> emit) async {
    emit(ExamLoading(exams: state.exams, subjects: state.subjects, selectedExam: state.selectedExam, examQuestions: state.examQuestions));
    try {
      await _examService.restoreExam(event.examId);
      emit(ExamOperationSuccess('Đã khôi phục đề thi', exams: state.exams, subjects: state.subjects, selectedExam: state.selectedExam, examQuestions: state.examQuestions));
      add(const LoadTeacherExamsEvent());
    } catch (e) {
      emit(ExamError(_handleError(e), exams: state.exams, subjects: state.subjects, selectedExam: state.selectedExam, examQuestions: state.examQuestions));
    }
  }

  Future<void> _onPublishExam(PublishExamEvent event, Emitter<ExamState> emit) async {
    emit(ExamLoading(exams: state.exams, subjects: state.subjects, selectedExam: state.selectedExam, examQuestions: state.examQuestions));
    try {
      await _examService.publishExam(event.examId);
      emit(ExamOperationSuccess('Đã xuất bản đề thi', exams: state.exams, subjects: state.subjects, selectedExam: state.selectedExam, examQuestions: state.examQuestions));
      add(LoadExamDetailEvent(event.examId));
    } catch (e) {
      emit(ExamError(_handleError(e), exams: state.exams, subjects: state.subjects, selectedExam: state.selectedExam, examQuestions: state.examQuestions));
    }
  }

  Future<void> _onCloseExam(CloseExamEvent event, Emitter<ExamState> emit) async {
    emit(ExamLoading(exams: state.exams, subjects: state.subjects, selectedExam: state.selectedExam, examQuestions: state.examQuestions));
    try {
      await _examService.closeExam(event.examId);
      emit(ExamOperationSuccess('Đã đóng đề thi', exams: state.exams, subjects: state.subjects, selectedExam: state.selectedExam, examQuestions: state.examQuestions));
      add(LoadExamDetailEvent(event.examId));
    } catch (e) {
      emit(ExamError(_handleError(e), exams: state.exams, subjects: state.subjects, selectedExam: state.selectedExam, examQuestions: state.examQuestions));
    }
  }

  Future<void> _onAddQuestion(AddQuestionToExamEvent event, Emitter<ExamState> emit) async {
    emit(ExamLoading(exams: state.exams, subjects: state.subjects, selectedExam: state.selectedExam, examQuestions: state.examQuestions));
    try {
      await _examService.addQuestionToExam(event.examId, event.request);
      emit(ExamOperationSuccess('Đã thêm câu hỏi vào đề', exams: state.exams, subjects: state.subjects, selectedExam: state.selectedExam, examQuestions: state.examQuestions));
      add(LoadExamDetailEvent(event.examId));
    } catch (e) {
      emit(ExamError(_handleError(e), exams: state.exams, subjects: state.subjects, selectedExam: state.selectedExam, examQuestions: state.examQuestions));
    }
  }

  Future<void> _onRemoveQuestion(RemoveQuestionFromExamEvent event, Emitter<ExamState> emit) async {
    emit(ExamLoading(exams: state.exams, subjects: state.subjects, selectedExam: state.selectedExam, examQuestions: state.examQuestions));
    try {
      await _examService.removeQuestionFromExam(event.examId, event.questionId);
      emit(ExamOperationSuccess('Đã gỡ câu hỏi khỏi đề', exams: state.exams, subjects: state.subjects, selectedExam: state.selectedExam, examQuestions: state.examQuestions));
      add(LoadExamDetailEvent(event.examId));
    } catch (e) {
      emit(ExamError(_handleError(e), exams: state.exams, subjects: state.subjects, selectedExam: state.selectedExam, examQuestions: state.examQuestions));
    }
  }
}
