import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/question_service.dart';
import 'question_event.dart';
import 'question_state.dart';

class QuestionBloc extends Bloc<QuestionEvent, QuestionState> {
  final QuestionService _service;

  QuestionBloc(this._service) : super(QuestionInitial()) {
    on<LoadSubjectsEvent>(_onLoadSubjects);
    on<LoadQuestionsEvent>(_onLoadQuestions);
    on<PublishQuestionEvent>(_onPublishQuestion);
    on<DraftQuestionEvent>(_onDraftQuestion);
    on<CreateQuestionEvent>(_onCreateQuestion);
  }

  Future<void> _onLoadSubjects(LoadSubjectsEvent event, Emitter<QuestionState> emit) async {
    emit(QuestionLoading(questions: state.questions, subjects: state.subjects));
    try {
      final subjects = await _service.getSubjects();
      emit(SubjectsLoaded(subjects, questions: state.questions));
    } catch (e) {
      emit(QuestionError(e.toString(), questions: state.questions, subjects: state.subjects));
    }
  }

  Future<void> _onLoadQuestions(LoadQuestionsEvent event, Emitter<QuestionState> emit) async {
    emit(QuestionLoading(questions: state.questions, subjects: state.subjects));
    try {
      final questions = await _service.getQuestions(queryParameters: event.queryParameters);
      emit(QuestionsLoaded(questions, subjects: state.subjects));
    } catch (e) {
      emit(QuestionError(e.toString(), questions: state.questions, subjects: state.subjects));
    }
  }

  Future<void> _onPublishQuestion(PublishQuestionEvent event, Emitter<QuestionState> emit) async {
    emit(QuestionLoading(questions: state.questions, subjects: state.subjects));
    try {
      await _service.publishQuestion(event.questionId);
      emit(QuestionOperationSuccess('Đã công khai câu hỏi', questions: state.questions, subjects: state.subjects));
      add(const LoadQuestionsEvent());
    } catch (e) {
      emit(QuestionError(e.toString(), questions: state.questions, subjects: state.subjects));
    }
  }

  Future<void> _onDraftQuestion(DraftQuestionEvent event, Emitter<QuestionState> emit) async {
    emit(QuestionLoading(questions: state.questions, subjects: state.subjects));
    try {
      await _service.draftQuestion(event.questionId);
      emit(QuestionOperationSuccess('Đã chuyển câu hỏi về nháp', questions: state.questions, subjects: state.subjects));
      add(const LoadQuestionsEvent());
    } catch (e) {
      emit(QuestionError(e.toString(), questions: state.questions, subjects: state.subjects));
    }
  }

  Future<void> _onCreateQuestion(CreateQuestionEvent event, Emitter<QuestionState> emit) async {
    emit(QuestionLoading(questions: state.questions, subjects: state.subjects));
    try {
      await _service.createQuestionWithOptions(event.data, event.options);
      emit(QuestionOperationSuccess('Tạo câu hỏi thành công', questions: state.questions, subjects: state.subjects));
      add(const LoadQuestionsEvent());
    } catch (e) {
      emit(QuestionError(e.toString(), questions: state.questions, subjects: state.subjects));
    }
  }
}
