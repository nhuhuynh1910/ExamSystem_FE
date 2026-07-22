using JWT.DTOs.Questions.Requests;
using JWT.DTOs.Questions.Responses;

namespace JWT.Services.Contracts
{
    public interface IQuestionService
    {
        Task<List<QuestionResponse>> GetQuestionsAsync(
            QuestionFilterRequest request,
            int currentUserId,
            string currentUserRole);

        Task<QuestionResponse?> GetQuestionByIdAsync(
            int questionId,
            int currentUserId,
            string currentUserRole);

        Task<QuestionResponse> CreateQuestionAsync(CreateQuestionRequest request, int teacherId);

        Task<QuestionResponse> UpdateQuestionAsync(int questionId, UpdateQuestionRequest request, int teacherId);

        Task DeleteQuestionAsync(int questionId, int teacherId);

        Task<QuestionOptionResponse> AddOptionAsync(int questionId, CreateQuestionOptionRequest request, int teacherId);

        Task<QuestionOptionResponse> UpdateOptionAsync(int optionId, UpdateQuestionOptionRequest request, int teacherId);

        Task DeleteOptionAsync(int optionId, int teacherId);

        Task PublishQuestionAsync(int questionId, int teacherId);

        Task DraftQuestionAsync(int questionId, int teacherId);
    }
}
