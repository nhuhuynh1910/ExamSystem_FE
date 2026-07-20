import 'question_api.dart';

import '../models/question_model.dart';
import '../../exam/models/subject_model.dart';


class QuestionRepository {

  final QuestionApi _api = QuestionApi();



  //================ SUBJECT =================


  Future<List<SubjectModel>> getSubjects() =>
      _api.getSubjects();



  Future<List<SubjectModel>> getTeacherSubjects() =>
      _api.getTeacherSubjects();




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


    return _api.getQuestions(

      pageNumber: pageNumber,

      pageSize: pageSize,

      subjectId: subjectId,

      difficulty: difficulty,

      status: status,

      questionType: questionType,

      search: search,

    );

  }




  Future<QuestionModel> createQuestion(

      Map<String,dynamic> data

      ) =>

      _api.createQuestion(data);





  Future<QuestionModel> updateQuestion(

      int id,

      Map<String,dynamic> data

      ) =>

      _api.updateQuestion(

          id,

          data

      );





  Future<void> deleteQuestion(

      int id

      ) =>

      _api.deleteQuestion(id);





  Future<void> publishQuestion(

      int id

      ) =>

      _api.publishQuestion(id);





  Future<void> draftQuestion(

      int id

      ) =>

      _api.draftQuestion(id);






  //================ OPTION =================



  Future<void> addOption(

      int questionId,

      Map<String,dynamic> data

      ) =>

      _api.addOption(

          questionId,

          data

      );





  Future<void> updateOption(

      int optionId,

      Map<String,dynamic> data

      ) =>

      _api.updateOption(

          optionId,

          data

      );





  Future<void> deleteOption(

      int optionId

      ) =>

      _api.deleteOption(optionId);

}