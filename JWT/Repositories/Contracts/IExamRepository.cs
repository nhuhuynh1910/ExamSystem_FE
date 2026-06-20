using JWT.DTOs.Exam;
using JWT.Models;

namespace JWT.Repositories.Contracts
{
    public interface IExamRepository
    {
        Task<PagedResultDto<ExamResponseDto>> GetPagedExamsAsync(
            ExamFilterRequestDto filter,
            int? teacherId,
            bool includeAll,
            bool publishedOnly);

        Task<PagedResultDto<ExamResponseDto>> GetTeacherOwnedExamsAsync(
            TeacherExamFilterRequestDto filter,
            int teacherId);

        Task<ExamResponseDto?> GetExamByIdAsync(int examId);

        Task<Exam?> GetExamEntityByIdAsync(int examId);

        Task<Exam?> GetExamEntityIncludingDeletedByIdAsync(int examId);

        Task<Question?> GetQuestionByIdAsync(int questionId);

        Task<ExamResponseDto> AddExamAsync(Exam exam);

        Task<ExamResponseDto> UpdateExamAsync(Exam exam);

        Task<bool> ExamNameExistsAsync(string examName, int? excludedExamId = null);

        Task<bool> IsTeacherAssignedToSubjectAsync(int teacherId, int subjectId);

        Task<bool> ExamQuestionExistsAsync(int examId, int questionId);

        Task<bool> HasExamQuestionsAsync(int examId);

        Task<int> GetNextQuestionOrderAsync(int examId);

        Task<ExamQuestion> AddExamQuestionAsync(ExamQuestion examQuestion);

        Task<ExamQuestion?> GetExamQuestionAsync(int examId, int questionId);

        Task RemoveExamQuestionAsync(ExamQuestion examQuestion);

        Task<List<ExamQuestionResponseDto>> GetExamQuestionsAsync(int examId);
    }
}
