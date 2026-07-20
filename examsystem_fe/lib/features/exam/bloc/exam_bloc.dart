import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../domain/exam_service.dart';
import '../models/exam_question_model.dart';
import '../../question/models/question_model.dart';
import '../../../core/network/api_constants.dart';
import 'exam_event.dart';
import 'exam_state.dart';
import '../../../core/network/dio_client.dart';
class ExamBloc extends Bloc<ExamEvent, ExamState> {
  final ExamService _examService;

  ExamBloc(this._examService) : super(const ExamInitial()) {
    on<LoadTeacherSubjectsEvent>(_onLoadTeacherSubjects);
    on<LoadStudentSubjectsEvent>(_onLoadStudentSubjects);
    on<LoadExamsEvent>(_onLoadExams);
    on<LoadTeacherExamsEvent>(_onLoadTeacherExams);
    on<LoadExamDetailEvent>(_onLoadExamDetail);
    on<CreateExamEvent>(_onCreateExam);
    on<UpdateExamEvent>(_onUpdateExam);
    on<DeleteExamEvent>(_onDeleteExam);
    on<RestoreExamEvent>(_onRestoreExam);
    on<PublishExamEvent>(_onPublishExam);
    on<CloseExamEvent>(_onCloseExam);
    on<UpdateExamStatusEvent>(_onUpdateExamStatus);
    on<LoadExamQuestionsEvent>(_onLoadExamQuestions);
    on<LoadBankQuestionsForExamEvent>(_onLoadBankQuestionsForExam);
    on<AddQuestionToExamEvent>(_onAddQuestion);
    on<RemoveQuestionFromExamEvent>(_onRemoveQuestion);
  }

  String _handleError(dynamic e) {
    if (e is DioException) {
      if (e.response?.data != null && e.response?.data is Map) {
        // Ưu tiên bắt message chi tiết từ HandleException của Backend (.NET)
        return e.response?.data['message'] ?? e.response?.data['Message'] ?? 'Đã xảy ra lỗi từ hệ thống.';
      }
      if (e.response?.statusCode == 403) return 'Bạn không có quyền thực hiện hành động này.';
      if (e.response?.statusCode == 400) return 'Dữ liệu yêu cầu không hợp lệ.';
    }
    return e.toString();
  }

  //==========================================================
  // SUBJECT HANDLERS
  //==========================================================

  Future<void> _onLoadTeacherSubjects(
      LoadTeacherSubjectsEvent event,
      Emitter<ExamState> emit,
      ) async {
    emit(
      ExamLoading(
        exams: state.exams,
        subjects: state.subjects,
        selectedExam: state.selectedExam,
        examQuestions: state.examQuestions,
        tempBankQuestions: state.tempBankQuestions,
      ),
    );

    try {
      // Lấy danh sách môn GV được duyệt dạy
      final subjects = await _examService.getTeacherSubjects();

      emit(
        SubjectsLoaded(
          subjects: subjects,
          exams: state.exams,
          tempBankQuestions: state.tempBankQuestions,
        ),
      );

      // Sau khi có môn -> load danh sách đề của GV
      add(
        LoadTeacherExamsEvent(),
      );

    } catch (e) {
      emit(
        ExamError(
          error: _handleError(e),
          exams: state.exams,
          subjects: state.subjects,
          selectedExam: state.selectedExam,
          examQuestions: state.examQuestions,
          tempBankQuestions: state.tempBankQuestions,
        ),
      );
    }
  }

  Future<void> _onLoadStudentSubjects(LoadStudentSubjectsEvent event, Emitter<ExamState> emit) async {
    emit(ExamLoading(exams: state.exams, subjects: state.subjects, selectedExam: state.selectedExam, examQuestions: state.examQuestions, tempBankQuestions: state.tempBankQuestions));
    try {
      final subjects = await _examService.getEnrolledSubjects(event.studentId);
      emit(SubjectsLoaded(subjects: subjects, exams: state.exams, tempBankQuestions: state.tempBankQuestions));
    } catch (e) {
      emit(ExamError(error: _handleError(e), exams: state.exams, subjects: state.subjects, selectedExam: state.selectedExam, examQuestions: state.examQuestions, tempBankQuestions: state.tempBankQuestions));
    }
  }

  //==========================================================
  // EXAM CRUD & LIST HANDLERS
  //==========================================================

  Future<void> _onLoadExams(LoadExamsEvent event, Emitter<ExamState> emit) async {
    emit(ExamLoading(exams: state.exams, subjects: state.subjects, selectedExam: state.selectedExam, examQuestions: state.examQuestions, tempBankQuestions: state.tempBankQuestions));
    try {
      final exams = await _examService.getExams(
        subjectId: event.subjectId,
        pageNumber: event.pageNumber,
        pageSize: event.pageSize,
      );
      emit(ExamsLoaded(exams: exams, subjects: state.subjects, tempBankQuestions: state.tempBankQuestions));
    } catch (e) {
      emit(ExamError(error: _handleError(e), exams: state.exams, subjects: state.subjects, selectedExam: state.selectedExam, examQuestions: state.examQuestions, tempBankQuestions: state.tempBankQuestions));
    }
  }

  Future<void> _onLoadTeacherExams(LoadTeacherExamsEvent event, Emitter<ExamState> emit) async {
    emit(ExamLoading(exams: state.exams, subjects: state.subjects, selectedExam: state.selectedExam, examQuestions: state.examQuestions, tempBankQuestions: state.tempBankQuestions));
    try {
      final exams = await _examService.getTeacherExams(
        status: event.status,
        subjectId: event.subjectId,
        pageNumber: event.pageNumber,
        pageSize: event.pageSize,
      );
      emit(ExamsLoaded(exams: exams, subjects: state.subjects, tempBankQuestions: state.tempBankQuestions));
    } catch (e) {
      emit(ExamError(error: _handleError(e), exams: state.exams, subjects: state.subjects, selectedExam: state.selectedExam, examQuestions: state.examQuestions, tempBankQuestions: state.tempBankQuestions));
    }
  }

  Future<void> _onLoadExamDetail(LoadExamDetailEvent event, Emitter<ExamState> emit) async {
    emit(ExamLoading(exams: state.exams, subjects: state.subjects, selectedExam: state.selectedExam, examQuestions: state.examQuestions, tempBankQuestions: state.tempBankQuestions));
    try {
      final exam = await _examService.getExamById(event.examId);
      final questions = await _examService.getExamQuestions(event.examId);

      emit(ExamDetailLoaded(
        exam: exam,
        questions: questions,
        subjects: state.subjects,
        exams: state.exams,
        tempBankQuestions: state.tempBankQuestions, // Duy trì ngân hàng câu hỏi phụ trợ nếu có
      ));
    } catch (e) {
      emit(ExamError(error: _handleError(e), exams: state.exams, subjects: state.subjects, selectedExam: state.selectedExam, examQuestions: state.examQuestions, tempBankQuestions: state.tempBankQuestions));
    }
  }

  Future<void> _onCreateExam(CreateExamEvent event, Emitter<ExamState> emit) async {
    emit(ExamLoading(exams: state.exams, subjects: state.subjects, selectedExam: state.selectedExam, examQuestions: state.examQuestions, tempBankQuestions: state.tempBankQuestions));
    try {
      final exam = await _examService.createExam(event.request);
      
      // Nếu có danh sách câu hỏi đi kèm, thêm chúng vào đề thi vừa tạo
      if (event.questions != null && event.questions!.isNotEmpty) {
        for (var qReq in event.questions!) {
          await _examService.addQuestionToExam(exam.examId, qReq);
        }
      }

      emit(ExamOperationSuccess(message: 'Tạo đề thi dạng bản nháp (Draft) thành công.', exams: state.exams, subjects: state.subjects, selectedExam: exam, examQuestions: const [], tempBankQuestions: state.tempBankQuestions));
    } catch (e) {
      emit(ExamError(error: _handleError(e), exams: state.exams, subjects: state.subjects, selectedExam: state.selectedExam, examQuestions: state.examQuestions, tempBankQuestions: state.tempBankQuestions));
    }
  }

  Future<void> _onUpdateExam(UpdateExamEvent event, Emitter<ExamState> emit) async {
    emit(ExamLoading(exams: state.exams, subjects: state.subjects, selectedExam: state.selectedExam, examQuestions: state.examQuestions, tempBankQuestions: state.tempBankQuestions));
    try {
      final updatedExam = await _examService.updateExam(event.examId, event.request);
      emit(ExamOperationSuccess(message: 'Cập nhật thông tin đề thi thành công', exams: state.exams, subjects: state.subjects, selectedExam: updatedExam, examQuestions: state.examQuestions, tempBankQuestions: state.tempBankQuestions));
      add(LoadExamDetailEvent(event.examId));
    } catch (e) {
      emit(ExamError(error: _handleError(e), exams: state.exams, subjects: state.subjects, selectedExam: state.selectedExam, examQuestions: state.examQuestions, tempBankQuestions: state.tempBankQuestions));
    }
  }

  Future<void> _onDeleteExam(DeleteExamEvent event, Emitter<ExamState> emit) async {
    emit(ExamLoading(exams: state.exams, subjects: state.subjects, selectedExam: state.selectedExam, examQuestions: state.examQuestions, tempBankQuestions: state.tempBankQuestions));
    try {
      await _examService.deleteExam(event.examId);
      emit(ExamOperationSuccess(message: 'Đã xóa đề thi thành công', exams: state.exams, subjects: state.subjects, selectedExam: state.selectedExam, examQuestions: state.examQuestions, tempBankQuestions: state.tempBankQuestions));
    } catch (e) {
      emit(ExamError(error: _handleError(e), exams: state.exams, subjects: state.subjects, selectedExam: state.selectedExam, examQuestions: state.examQuestions, tempBankQuestions: state.tempBankQuestions));
    }
  }

  Future<void> _onRestoreExam(RestoreExamEvent event, Emitter<ExamState> emit) async {
    emit(ExamLoading(exams: state.exams, subjects: state.subjects, selectedExam: state.selectedExam, examQuestions: state.examQuestions, tempBankQuestions: state.tempBankQuestions));
    try {
      final exam = await _examService.restoreExam(event.examId);
      emit(ExamOperationSuccess(message: 'Đã khôi phục đề thi về dạng bản nháp', exams: state.exams, subjects: state.subjects, selectedExam: exam, examQuestions: state.examQuestions, tempBankQuestions: state.tempBankQuestions));
    } catch (e) {
      emit(ExamError(error: _handleError(e), exams: state.exams, subjects: state.subjects, selectedExam: state.selectedExam, examQuestions: state.examQuestions, tempBankQuestions: state.tempBankQuestions));
    }
  }

  //==========================================================
  // WORKFLOW STATUS HANDLERS (PUBLISH / CLOSE)
  //==========================================================

  Future<void> _onPublishExam(PublishExamEvent event, Emitter<ExamState> emit) async {
    emit(ExamLoading(exams: state.exams, subjects: state.subjects, selectedExam: state.selectedExam, examQuestions: state.examQuestions, tempBankQuestions: state.tempBankQuestions));
    try {
      final exam = await _examService.publishExam(event.examId);
      emit(ExamOperationSuccess(message: 'Đã công bố đề thi thành công.', exams: state.exams, subjects: state.subjects, selectedExam: exam, examQuestions: state.examQuestions, tempBankQuestions: state.tempBankQuestions));
      add(LoadExamDetailEvent(event.examId));
    } catch (e) {
      // Nếu Backend trả về BadRequest (do quá thời gian StartTime), thông báo lỗi sẽ được đưa thẳng vào ExamError
      emit(ExamError(error: _handleError(e), exams: state.exams, subjects: state.subjects, selectedExam: state.selectedExam, examQuestions: state.examQuestions, tempBankQuestions: state.tempBankQuestions));
    }
  }

  Future<void> _onCloseExam(CloseExamEvent event, Emitter<ExamState> emit) async {
    emit(ExamLoading(exams: state.exams, subjects: state.subjects, selectedExam: state.selectedExam, examQuestions: state.examQuestions, tempBankQuestions: state.tempBankQuestions));
    try {
      final exam = await _examService.closeExam(event.examId);
      emit(ExamOperationSuccess(message: 'Đã đóng đề thi công khai', exams: state.exams, subjects: state.subjects, selectedExam: exam, examQuestions: state.examQuestions, tempBankQuestions: state.tempBankQuestions));
      add(LoadExamDetailEvent(event.examId));
    } catch (e) {
      emit(ExamError(error: _handleError(e), exams: state.exams, subjects: state.subjects, selectedExam: state.selectedExam, examQuestions: state.examQuestions, tempBankQuestions: state.tempBankQuestions));
    }
  }

  Future<void> _onUpdateExamStatus(UpdateExamStatusEvent event, Emitter<ExamState> emit) async {
    emit(ExamLoading(exams: state.exams, subjects: state.subjects, selectedExam: state.selectedExam, examQuestions: state.examQuestions, tempBankQuestions: state.tempBankQuestions));
    try {
      // Logic xử lý status chung thông qua API route cập nhật trạng thái
      add(LoadExamDetailEvent(event.examId));
    } catch (e) {
      emit(ExamError(error: _handleError(e), exams: state.exams, subjects: state.subjects, selectedExam: state.selectedExam, examQuestions: state.examQuestions, tempBankQuestions: state.tempBankQuestions));
    }
  }

  //==========================================================
  // EXAM QUESTIONS HANDLERS (MÀN HÌNH ĐÃ CHỌN / CHƯA CHỌN)
  //==========================================================

  Future<void> _onLoadBankQuestionsForExam(LoadBankQuestionsForExamEvent event, Emitter<ExamState> emit) async {
    emit(ExamLoading(exams: state.exams, subjects: state.subjects, selectedExam: state.selectedExam, examQuestions: state.examQuestions, tempBankQuestions: state.tempBankQuestions));
    try {
      final examQuestions = await _examService.getExamQuestions(event.examId);
      
      final response = await DioClient.instance.get(ApiConstants.questions, queryParameters: {'SubjectId': event.subjectId, 'Status': 'Published'});
      final List items = response.data is List ? response.data : (response.data['items'] ?? []);
      final bankQuestions = items.map((e) => QuestionModel.fromJson(e)).toList();
      
      emit(ExamDetailLoaded(
        exam: state.selectedExam ?? await _examService.getExamById(event.examId),
        questions: examQuestions,
        subjects: state.subjects,
        exams: state.exams,
        tempBankQuestions: bankQuestions,
      ));
    } catch (e) {
      emit(ExamError(error: _handleError(e), exams: state.exams, subjects: state.subjects, selectedExam: state.selectedExam, examQuestions: state.examQuestions));
    }
  }

  Future<void> _onLoadExamQuestions(LoadExamQuestionsEvent event, Emitter<ExamState> emit) async {
    emit(ExamLoading(exams: state.exams, subjects: state.subjects, selectedExam: state.selectedExam, examQuestions: state.examQuestions, tempBankQuestions: state.tempBankQuestions));
    try {
      // Lấy danh sách câu hỏi ĐÃ CHỌN nằm trong đề thi
      final questions = await _examService.getExamQuestions(event.examId);

      // Cập nhật lại trạng thái detail chi tiết
      emit(ExamDetailLoaded(
        exam: state.selectedExam ?? await _examService.getExamById(event.examId),
        questions: questions,
        subjects: state.subjects,
        exams: state.exams,
        tempBankQuestions: state.tempBankQuestions, // UI tự động chạy get lọc Đã chọn/Chưa chọn
      ));
    } catch (e) {
      emit(ExamError(error: _handleError(e), exams: state.exams, subjects: state.subjects, selectedExam: state.selectedExam, examQuestions: state.examQuestions, tempBankQuestions: state.tempBankQuestions));
    }
  }

  Future<void> _onAddQuestion(AddQuestionToExamEvent event, Emitter<ExamState> emit) async {
    try {
      await _examService.addQuestionToExam(event.examId, event.request);
      final updatedQuestions = await _examService.getExamQuestions(event.examId);
      final exam = state.selectedExam ?? await _examService.getExamById(event.examId);

      emit(ExamDetailLoaded(
        exam: exam,
        questions: updatedQuestions,
        subjects: state.subjects,
        exams: state.exams,
        tempBankQuestions: state.tempBankQuestions,
      ));
    } catch (e) {
      emit(ExamError(error: _handleError(e), exams: state.exams, subjects: state.subjects, selectedExam: state.selectedExam, examQuestions: state.examQuestions, tempBankQuestions: state.tempBankQuestions));
    }
  }

  Future<void> _onRemoveQuestion(RemoveQuestionFromExamEvent event, Emitter<ExamState> emit) async {
    try {
      await _examService.removeQuestionFromExam(event.examId, event.questionId);
      final updatedQuestions = await _examService.getExamQuestions(event.examId);
      final exam = state.selectedExam ?? await _examService.getExamById(event.examId);

      emit(ExamDetailLoaded(
        exam: exam,
        questions: updatedQuestions,
        subjects: state.subjects,
        exams: state.exams,
        tempBankQuestions: state.tempBankQuestions,
      ));
    } catch (e) {
      emit(ExamError(error: _handleError(e), exams: state.exams, subjects: state.subjects, selectedExam: state.selectedExam, examQuestions: state.examQuestions, tempBankQuestions: state.tempBankQuestions));
    }
  }
}