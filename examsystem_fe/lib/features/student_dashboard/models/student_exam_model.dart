import '../../../features/teacher_dashboard/models/teacher_exam_model.dart';

/// Student dùng chung DTO ExamResponseDto từ BE → tái sử dụng TeacherExamModel.
///
/// Nếu sau này Student cần thêm field riêng (ví dụ: attemptStatus),
/// chỉ cần tạo class extend hoặc wrapper tại đây mà KHÔNG sửa TeacherExamModel.
typedef StudentExamModel = TeacherExamModel;
