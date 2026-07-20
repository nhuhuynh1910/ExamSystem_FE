import '../data/question_repository.dart';
import '../models/question_model.dart';
import '../../exam/models/subject_model.dart';


class QuestionService {

  final QuestionRepository _repository;


  QuestionService(this._repository);



  //================ SUBJECT =================


  Future<List<SubjectModel>> getSubjects() =>
      _repository.getSubjects();



  Future<List<SubjectModel>> getTeacherSubjects() =>
      _repository.getTeacherSubjects();





  //================ QUESTION =================


  Future<List<QuestionModel>> getQuestions({

    int pageNumber = 1,

    int pageSize = 10,

    int? subjectId,

    String? difficulty,

    String? status,

    String? questionType,

    String? search,

  }) {


    return _repository.getQuestions(

      pageNumber: pageNumber,

      pageSize: pageSize,

      subjectId: subjectId,

      difficulty: difficulty,

      status: status,

      questionType: questionType,

      search: search,

    );

  }





  Future<void> publishQuestion(int id) =>

      _repository.publishQuestion(id);





  Future<void> draftQuestion(int id) =>

      _repository.draftQuestion(id);





  Future<void> deleteQuestion(int id) =>

      _repository.deleteQuestion(id);






  //================ CREATE + OPTIONS =================



  Future<void> createQuestionWithOptions(

      Map<String,dynamic> qData,

      List<Map<String,dynamic>> options

      ) async {


    final question = await _repository.createQuestion(qData);



    for(final opt in options){

      await _repository.addOption(

        question.questionId,

        opt,

      );

    }

  }






  Future<void> updateQuestion(

      int id,

      Map<String,dynamic> data

      ) =>

      _repository.updateQuestion(

          id,

          data

      );






  Future<void> addOption(

      int questionId,

      Map<String,dynamic> data

      ) =>

      _repository.addOption(

          questionId,

          data

      );





  Future<void> updateOption(

      int optionId,

      Map<String,dynamic> data

      ) =>

      _repository.updateOption(

          optionId,

          data

      );





  Future<void> deleteOption(

      int optionId

      ) =>

      _repository.deleteOption(optionId);

}