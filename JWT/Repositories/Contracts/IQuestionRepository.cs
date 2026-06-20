using JWT.DTOs.Questions.Requests;
using JWT.Models;

namespace JWT.Repositories.Contracts
{
    public interface IQuestionRepository
    {
        Task<List<Question>> GetQuestionsAsync(
            QuestionFilterRequest request,
            int currentUserId,
            string currentUserRole);

        Task<Question?> GetQuestionByIdAsync(int questionId);

        Task<Question?> GetQuestionByIdWithOptionsAsync(int questionId);

        Task AddQuestionAsync(Question question);

        Task<QuestionOption?> GetOptionByIdAsync(int optionId);

        Task AddOptionAsync(QuestionOption option);

        Task<bool> IsQuestionUsedInExamAsync(int questionId);

        Task<bool> IsQuestionUsedInPublishedExamAsync(int questionId);

        Task<bool> HasQuestionAttemptsAsync(int questionId);

        Task<bool> HasCorrectOptionAsync(int questionId);

        Task<bool> HasAnotherCorrectOptionAsync(int questionId, int excludedOptionId);

        Task<int> CountOptionsAsync(int questionId);

        Task SaveChangesAsync();
    }
}
