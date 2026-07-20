import '../models/add_exam_question_request.dart';
import '../models/exam_create_request.dart';
import '../models/exam_update_request.dart';

abstract class ExamEvent {
  const ExamEvent();
}

//==========================================================
// SUBJECT (MÔN HỌC)
//==========================================================

/// Lấy danh sách môn học dựa trên vai trò (Admin, Teacher, Student)
class LoadSubjectsEvent extends ExamEvent {
  const LoadSubjectsEvent();
}

/// Giảng viên lấy danh sách môn học mình được phân công giảng dạy
class LoadTeacherSubjectsEvent extends ExamEvent {
  const LoadTeacherSubjectsEvent();
}

/// Học sinh lấy danh sách môn học đã tham gia (Join)
class LoadStudentSubjectsEvent extends ExamEvent {
  final int studentId;

  const LoadStudentSubjectsEvent(this.studentId);
}


//==========================================================
// EXAM (ĐỀ THI)
//==========================================================

/// Học sinh hoặc Admin lấy danh sách đề thi (có phân trang & lọc môn học)
/// Học sinh chỉ thấy đề thi dạng 'Published' [cite: 441]
class LoadExamsEvent extends ExamEvent {
  final int? subjectId;
  final int pageNumber;
  final int pageSize;

  const LoadExamsEvent({
    this.subjectId,
    this.pageNumber = 1,
    this.pageSize = 10,
  });
}

/// Giảng viên lấy danh sách đề thi do chính mình tạo
/// Hỗ trợ lọc theo trạng thái (Draft, Published, Closed) và môn học [cite: 448]
class LoadTeacherExamsEvent extends ExamEvent {
  final String? status;
  final int? subjectId;
  final int pageNumber;
  final int pageSize;

  const LoadTeacherExamsEvent({
    this.status,
    this.subjectId,
    this.pageNumber = 1,
    this.pageSize = 10,
  });
}

/// Lấy chi tiết thông tin một đề thi theo ID
class LoadExamDetailEvent extends ExamEvent {
  final int examId;

  const LoadExamDetailEvent(this.examId);
}

/// Tạo mới đề thi dạng nháp (Draft) [cite: 463]
class CreateExamEvent extends ExamEvent {
  final ExamCreateRequest request;
  final List<AddExamQuestionRequest>? questions;

  const CreateExamEvent(this.request, {this.questions});
}

/// Cập nhật thông tin chung của đề thi (Tên, cấu hình thời gian,...) [cite: 471]
class UpdateExamEvent extends ExamEvent {
  final int examId;
  final ExamUpdateRequest request;

  const UpdateExamEvent(
      this.examId,
      this.request,
      );
}

/// Xóa mềm đề thi (Đưa IsDeleted = true và Status = Closed từ Backend) [cite: 483]
class DeleteExamEvent extends ExamEvent {
  final int examId;

  const DeleteExamEvent(this.examId);
}

/// Khôi phục đề thi đã xóa mềm về dạng Draft (Dành riêng cho Admin/Teacher sở hữu) [cite: 231, 305]
class RestoreExamEvent extends ExamEvent {
  final int examId;

  const RestoreExamEvent(this.examId);
}

/// Kích hoạt đề thi công khai để học sinh có thể nhìn thấy và làm bài [cite: 518]
/// LƯU Ý: Nếu quá StartTime, Backend sẽ ném lỗi và Bloc sẽ chuyển trạng thái ExamError.
class PublishExamEvent extends ExamEvent {
  final int examId;

  const PublishExamEvent(this.examId);
}

/// Đóng đề thi, dừng không cho học sinh tham gia nữa [cite: 526]
class CloseExamEvent extends ExamEvent {
  final int examId;

  const CloseExamEvent(this.examId);
}

/// Cập nhật trạng thái đề thi tùy chọn (Draft/Published/Closed) trực tiếp qua Body [cite: 489]
class UpdateExamStatusEvent extends ExamEvent {
  final int examId;
  final String status;

  const UpdateExamStatusEvent(
      this.examId,
      this.status,
      );
}


//==========================================================
// EXAM QUESTION (CÂU HỎI TRONG ĐỀ THI)
//==========================================================

/// Tải danh sách các câu hỏi hiện đang có trong đề thi (Phục vụ tab "Đã chọn") [cite: 363, 364]
class LoadExamQuestionsEvent extends ExamEvent {
  final int examId;

  const LoadExamQuestionsEvent(this.examId);
}

/// BỔ SUNG: Tải toàn bộ ngân hàng câu hỏi của môn học thuộc đề thi này
/// Phục vụ cho màn hình quản lý câu hỏi: đối chiếu và hiển thị danh sách "Chưa chọn"
class LoadBankQuestionsForExamEvent extends ExamEvent {
  final int examId;
  final int subjectId;

  const LoadBankQuestionsForExamEvent({
    required this.examId,
    required this.subjectId,
  });
}

/// Thêm câu hỏi từ ngân hàng câu hỏi hệ thống vào đề thi (Chỉ khi đề thi đang ở dạng Draft) [cite: 218, 501]
class AddQuestionToExamEvent extends ExamEvent {
  final int examId;
  final AddExamQuestionRequest request;

  const AddQuestionToExamEvent(
      this.examId,
      this.request,
      );
}

/// Gỡ câu hỏi ra khỏi đề thi (Không xóa câu hỏi gốc trong ngân hàng) [cite: 366]
class RemoveQuestionFromExamEvent extends ExamEvent {
  final int examId;
  final int questionId;

  const RemoveQuestionFromExamEvent(
      this.examId,
      this.questionId,
      );
}