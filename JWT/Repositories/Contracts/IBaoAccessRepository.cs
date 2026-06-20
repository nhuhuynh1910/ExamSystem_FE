using JWT.Models;

namespace JWT.Repositories.Contracts
{
    public interface IBaoAccessRepository
    {
        Task<Exam?> GetTargetAsync(int id);

        Task<bool> IsStudentEnrolledAsync(int studentId, int subjectId);

        Task<int> CountAttemptsAsync(int targetId, int studentId);

        Task<ExamAttempt?> GetInProgressAttemptAsync(int targetId, int studentId);

        Task<int> GetNextAttemptNumberAsync(int targetId, int studentId);

        Task<List<ExamQuestion>> GetTargetQuestionsAsync(int targetId);

        Task<ExamAttempt> AddAttemptAsync(ExamAttempt attempt, List<AttemptQuestion> questions);

        Task<ExamAttempt?> GetAttemptDetailAsync(int attemptId);

        Task<ExamAttempt?> GetAttemptForAnswerAsync(int attemptId);

        Task<StudentAnswer> SaveAnswerAsync(
            StudentAnswer answer,
            List<int> selectedOptionIds,
            bool isNewAnswer);

        Task<ExamAttempt?> GetAttemptForSubmitAsync(int attemptId);

        Task<ExamAttempt> SubmitAttemptAsync(ExamAttempt attempt);

        Task<ExamAttempt?> GetStudentResultAttemptAsync(int targetId, int studentId);

        Task<List<ExamAttempt>> GetRankingAttemptsAsync(int targetId);
    }
}
