import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/storage_manager.dart';
import '../domain/question_service.dart';
import '../../exam/models/subject_model.dart';
import 'question_event.dart';
import 'question_state.dart';

class QuestionBloc extends Bloc<QuestionEvent, QuestionState> {
  final QuestionService _service;

  QuestionBloc(this._service) : super(const QuestionInitial()) {
    on<LoadSubjectsEvent>(_onLoadSubjects);
    on<LoadQuestionsEvent>(_onLoadQuestions);
    on<PublishQuestionEvent>(_onPublishQuestion);
    on<DraftQuestionEvent>(_onDraftQuestion);
    on<DeleteQuestionEvent>(_onDeleteQuestion);
    on<CreateQuestionEvent>(_onCreateQuestion);
    on<UpdateQuestionEvent>(_onUpdateQuestion);
  }

  Future<void> _onLoadSubjects(LoadSubjectsEvent event, Emitter<QuestionState> emit) async {
    emit(QuestionLoading(questions: state.questions, subjects: state.subjects));
    try {
      final role = await StorageManager.getRole();
      List<SubjectModel> subjects;

      final normalizedRole = role?.toLowerCase();
      if (normalizedRole == 'teacher' || normalizedRole == 'admin') {
        subjects = await _service.getTeacherSubjects();
      } else {
        subjects = await _service.getSubjects();
      }

      emit(SubjectsLoaded(subjects: subjects, questions: state.questions));
    } catch (e) {
      emit(QuestionError(e.toString(), questions: state.questions, subjects: state.subjects));
    }
  }

  Future<void> _onLoadQuestions(LoadQuestionsEvent event, Emitter<QuestionState> emit) async {
    emit(QuestionLoading(questions: state.questions, subjects: state.subjects));
    try {
      Map<String, dynamic> params = Map.from(event.queryParameters ?? {});

      // Nếu là Teacher và không chọn môn cụ thể, chúng ta cần đảm bảo
      // Backend chỉ trả về câu hỏi thuộc các môn của Teacher này.
      // Hầu hết Backend sẽ tự xử lý dựa trên Token, nhưng nếu cần
      // truyền danh sách SubjectId từ client thì code sẽ nằm ở đây.

      final questions = await _service.getQuestions(
        subjectId: params['subjectId'],
        difficulty: params['difficulty'],
        status: params['status'],
        search: params['search'],
        pageNumber: params['pageNumber'] ?? 1,
        pageSize: params['pageSize'] ?? 50,
      );
      emit(QuestionsLoaded(questions: questions, subjects: state.subjects));
    } catch (e) {
      emit(QuestionError(e.toString(), questions: state.questions, subjects: state.subjects));
    }
  }

  Future<void> _onPublishQuestion(PublishQuestionEvent event, Emitter<QuestionState> emit) async {
    emit(QuestionLoading(questions: state.questions, subjects: state.subjects));
    try {
      await _service.publishQuestion(event.questionId);
      emit(QuestionSuccess('Đã công khai câu hỏi', questions: state.questions, subjects: state.subjects));
      add(const LoadQuestionsEvent());
    } catch (e) {
      emit(QuestionError(e.toString(), questions: state.questions, subjects: state.subjects));
    }
  }

  Future<void> _onDraftQuestion(DraftQuestionEvent event, Emitter<QuestionState> emit) async {
    emit(QuestionLoading(questions: state.questions, subjects: state.subjects));
    try {
      await _service.draftQuestion(event.questionId);
      emit(QuestionSuccess('Đã chuyển câu hỏi về nháp', questions: state.questions, subjects: state.subjects));
      add(const LoadQuestionsEvent());
    } catch (e) {
      emit(QuestionError(e.toString(), questions: state.questions, subjects: state.subjects));
    }
  }

  Future<void> _onCreateQuestion(CreateQuestionEvent event, Emitter<QuestionState> emit) async {
    emit(QuestionLoading(questions: state.questions, subjects: state.subjects));
    try {
      await _service.createQuestionWithOptions(event.data, event.options);
      emit(QuestionSuccess('Tạo câu hỏi thành công', questions: state.questions, subjects: state.subjects));
      add(const LoadQuestionsEvent());
    } catch (e) {
      emit(QuestionError(e.toString(), questions: state.questions, subjects: state.subjects));
    }
  }

  Future<void> _onDeleteQuestion(DeleteQuestionEvent event, Emitter<QuestionState> emit) async {
    emit(QuestionLoading(questions: state.questions, subjects: state.subjects));
    try {
      await _service.deleteQuestion(event.questionId);
      emit(QuestionSuccess('Đã xóa câu hỏi', questions: state.questions, subjects: state.subjects));
      add(const LoadQuestionsEvent());
    } catch (e) {
      emit(QuestionError(e.toString(), questions: state.questions, subjects: state.subjects));
    }
  }

  Future<void> _onUpdateQuestion(UpdateQuestionEvent event, Emitter<QuestionState> emit) async {
    emit(QuestionLoading(questions: state.questions, subjects: state.subjects));
    try {
      await _service.updateQuestion(event.questionId, event.data);
      for (var id in event.deletedOptionIds) {
        await _service.deleteOption(id);
      }
      for (var opt in event.updatedOptions) {
        final id = opt['optionId'];
        await _service.updateOption(id, opt);
      }
      for (var opt in event.newOptions) {
        await _service.addOption(event.questionId, opt);
      }
      emit(QuestionSuccess('Cập nhật câu hỏi thành công', questions: state.questions, subjects: state.subjects));
      add(const LoadQuestionsEvent());
    } catch (e) {
      emit(QuestionError(e.toString(), questions: state.questions, subjects: state.subjects));
    }
  }
}
