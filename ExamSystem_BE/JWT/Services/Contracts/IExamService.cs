using JWT.DTOs.Exam;

namespace JWT.Services.Contracts
{
    public interface IExamService
    {
        Task<PagedResultDto<ExamResponseDto>> GetExamsAsync(
            ExamFilterRequestDto filter,
            string? currentUserId,
            string? currentUserRole);

        Task<PagedResultDto<ExamResponseDto>> GetTeacherExamsAsync(
            TeacherExamFilterRequestDto filter,
            string? currentUserId,
            string? currentUserRole);

        Task<ExamResponseDto> GetExamByIdAsync(
            int examId,
            string? currentUserId,
            string? currentUserRole);

        Task<ExamResponseDto> CreateExamAsync(
            ExamCreateDto request,
            string? currentUserId,
            string? currentUserRole);

        Task<ExamResponseDto> UpdateExamAsync(
            int examId,
            ExamUpdateDto request,
            string? currentUserId,
            string? currentUserRole);

        Task DeleteExamAsync(
            int examId,
            string? currentUserId,
            string? currentUserRole);

        Task<ExamResponseDto> UpdateExamStatusAsync(
            int examId,
            ExamStatusUpdateDto request,
            string? currentUserId,
            string? currentUserRole);

        Task<ExamQuestionResponseDto> AddQuestionToExamAsync(
            int examId,
            AddExamQuestionDto request,
            string? currentUserId,
            string? currentUserRole);

        Task RemoveQuestionFromExamAsync(
            int examId,
            int questionId,
            string? currentUserId,
            string? currentUserRole);

        Task<ExamResponseDto> PublishExamAsync(
            int examId,
            string? currentUserId,
            string? currentUserRole);

        Task<ExamResponseDto> CloseExamAsync(
            int examId,
            string? currentUserId,
            string? currentUserRole);

        Task<List<ExamQuestionResponseDto>> GetExamQuestionsAsync(
            int examId,
            string? currentUserId,
            string? currentUserRole);
    }
}
