import '../models/exam_model.dart';
import '../models/exam_question_model.dart';
import '../models/subject_model.dart';
import '../../question/models/question_model.dart';

abstract class ExamState {
  final List<SubjectModel> subjects;
  final List<ExamModel> exams;
  final ExamModel? selectedExam;
  final List<ExamQuestionModel> examQuestions; // Danh sách câu hỏi ĐÃ CHỌN trong đề

  /// Danh sách ngân hàng câu hỏi gốc của môn học (Được nạp từ Question Feature)
  /// Dùng làm cầu nối dữ liệu phụ trợ để tính toán phân tách trên UI
  final List<QuestionModel> tempBankQuestions;

  final bool isLoading;
  final String? message;
  final String? error;

  const ExamState({
    this.subjects = const [],
    this.exams = const [],
    this.selectedExam,
    this.examQuestions = const [],
    this.tempBankQuestions = const [],
    this.isLoading = false,
    this.message,
    this.error,
  });

  /// Getter tự động lọc danh sách câu hỏi ĐÃ CHỌN dạng QuestionModel từ ngân hàng câu hỏi gốc
  List<QuestionModel> get selectedQuestions {
    if (tempBankQuestions.isEmpty) return const [];
    final selectedIds = examQuestions.map((eq) => eq.questionId).toSet();
    return tempBankQuestions.where((q) => selectedIds.contains(q.questionId)).toList();
  }

  /// Getter tự động lọc danh sách câu hỏi CHƯA CHỌN dạng QuestionModel từ ngân hàng câu hỏi gốc
  List<QuestionModel> get unselectedQuestions {
    if (tempBankQuestions.isEmpty) return tempBankQuestions;
    final selectedIds = examQuestions.map((eq) => eq.questionId).toSet();
    return tempBankQuestions.where((q) => !selectedIds.contains(q.questionId)).toList();
  }
}

class ExamInitial extends ExamState {
  const ExamInitial();
}

class ExamLoading extends ExamState {
  const ExamLoading({
    super.subjects,
    super.exams,
    super.selectedExam,
    super.examQuestions,
    super.tempBankQuestions,
  }) : super(isLoading: true);
}

class SubjectsLoaded extends ExamState {
  const SubjectsLoaded({
    required List<SubjectModel> subjects,
    List<ExamModel> exams = const [],
    ExamModel? selectedExam,
    List<ExamQuestionModel> examQuestions = const [],
    List<QuestionModel> tempBankQuestions = const [],
  }) : super(
    subjects: subjects,
    exams: exams,
    selectedExam: selectedExam,
    examQuestions: examQuestions,
    tempBankQuestions: tempBankQuestions,
  );
}

class ExamsLoaded extends ExamState {
  const ExamsLoaded({
    required List<ExamModel> exams,
    List<SubjectModel> subjects = const [],
    ExamModel? selectedExam,
    List<ExamQuestionModel> examQuestions = const [],
    List<QuestionModel> tempBankQuestions = const [],
  }) : super(
    exams: exams,
    subjects: subjects,
    selectedExam: selectedExam,
    examQuestions: examQuestions,
    tempBankQuestions: tempBankQuestions,
  );
}

class ExamDetailLoaded extends ExamState {
  const ExamDetailLoaded({
    required ExamModel exam,
    required List<ExamQuestionModel> questions,
    List<SubjectModel> subjects = const [],
    List<ExamModel> exams = const [],
    List<QuestionModel> tempBankQuestions = const [],
  }) : super(
    selectedExam: exam,
    examQuestions: questions,
    subjects: subjects,
    exams: exams,
    tempBankQuestions: tempBankQuestions,
  );
}

class ExamOperationSuccess extends ExamState {
  const ExamOperationSuccess({
    required String message,
    List<SubjectModel> subjects = const [],
    List<ExamModel> exams = const [],
    ExamModel? selectedExam,
    List<ExamQuestionModel> examQuestions = const [],
    List<QuestionModel> tempBankQuestions = const [],
  }) : super(
    message: message,
    subjects: subjects,
    exams: exams,
    selectedExam: selectedExam,
    examQuestions: examQuestions,
    tempBankQuestions: tempBankQuestions,
  );
}

class ExamError extends ExamState {
  const ExamError({
    required String error,
    List<SubjectModel> subjects = const [],
    List<ExamModel> exams = const [],
    ExamModel? selectedExam,
    List<ExamQuestionModel> examQuestions = const [],
    List<QuestionModel> tempBankQuestions = const [],
  }) : super(
    error: error,
    subjects: subjects,
    exams: exams,
    selectedExam: selectedExam,
    examQuestions: examQuestions,
    tempBankQuestions: tempBankQuestions,
  );
}