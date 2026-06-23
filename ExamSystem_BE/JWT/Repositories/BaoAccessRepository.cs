using JWT.Data;
using JWT.Models;
using JWT.Repositories.Contracts;
using Microsoft.EntityFrameworkCore;

namespace JWT.Repositories
{
    public class BaoAccessRepository : IBaoAccessRepository
    {
        private readonly ExamDb _context;

        public BaoAccessRepository(ExamDb context)
        {
            _context = context;
        }

        public async Task<Exam?> GetTargetAsync(int id)
        {
            return await _context.Exams
                .AsNoTracking()
                .FirstOrDefaultAsync(e => e.ExamId == id && !e.IsDeleted);
        }

        public async Task<bool> IsStudentEnrolledAsync(int studentId, int subjectId)
        {
            return await _context.Enrollments
                .AsNoTracking()
                .AnyAsync(e =>
                    e.StudentId == studentId &&
                    e.SubjectId == subjectId &&
                    !e.IsDeleted);
        }

        public async Task<int> CountAttemptsAsync(int targetId, int studentId)
        {
            return await _context.ExamAttempts
                .AsNoTracking()
                .CountAsync(a =>
                    a.ExamId == targetId &&
                    a.StudentId == studentId);
        }

        public async Task<ExamAttempt?> GetInProgressAttemptAsync(int targetId, int studentId)
        {
            return await _context.ExamAttempts
                .AsNoTracking()
                .Include(a => a.AttemptQuestions)
                .FirstOrDefaultAsync(a =>
                    a.ExamId == targetId &&
                    a.StudentId == studentId &&
                    a.Status == "InProgress");
        }

        public async Task<int> GetNextAttemptNumberAsync(int targetId, int studentId)
        {
            var maxAttemptNumber = await _context.ExamAttempts
                .AsNoTracking()
                .Where(a =>
                    a.ExamId == targetId &&
                    a.StudentId == studentId)
                .Select(a => (int?)a.AttemptNumber)
                .MaxAsync();

            return (maxAttemptNumber ?? 0) + 1;
        }

        public async Task<List<ExamQuestion>> GetTargetQuestionsAsync(int targetId)
        {
            return await _context.ExamQuestions
                .AsNoTracking()
                .Where(eq =>
                    eq.ExamId == targetId &&
                    eq.Question != null &&
                    !eq.Question.IsDeleted &&
                    eq.Question.Status == "Published")
                .OrderBy(eq => eq.QuestionOrder)
                .ToListAsync();
        }

        public async Task<ExamAttempt> AddAttemptAsync(
            ExamAttempt attempt,
            List<AttemptQuestion> questions)
        {
            var strategy = _context.Database.CreateExecutionStrategy();

            await strategy.ExecuteAsync(async () =>
            {
                await using var transaction = await _context.Database.BeginTransactionAsync();

                _context.ExamAttempts.Add(attempt);
                await _context.SaveChangesAsync();

                foreach (var question in questions)
                {
                    question.AttemptId = attempt.AttemptId;
                }

                _context.AttemptQuestions.AddRange(questions);
                await _context.SaveChangesAsync();
                await transaction.CommitAsync();
            });

            return attempt;
        }

        public async Task<ExamAttempt?> GetAttemptDetailAsync(int attemptId)
        {
            return await _context.ExamAttempts
                .AsNoTracking()
                .Include(a => a.Exam)
                .Include(a => a.AttemptQuestions)
                    .ThenInclude(aq => aq.Question)
                        .ThenInclude(q => q!.QuestionOptions)
                .Include(a => a.StudentAnswers)
                    .ThenInclude(sa => sa.StudentAnswerOptions)
                .FirstOrDefaultAsync(a => a.AttemptId == attemptId);
        }

        public async Task<ExamAttempt?> GetAttemptForAnswerAsync(int attemptId)
        {
            return await _context.ExamAttempts
                .Include(a => a.Exam)
                .Include(a => a.AttemptQuestions)
                    .ThenInclude(aq => aq.Question)
                        .ThenInclude(q => q!.QuestionOptions)
                .Include(a => a.StudentAnswers)
                    .ThenInclude(sa => sa.StudentAnswerOptions)
                .FirstOrDefaultAsync(a => a.AttemptId == attemptId);
        }

        public async Task<StudentAnswer> SaveAnswerAsync(
            StudentAnswer answer,
            List<int> selectedOptionIds,
            bool isNewAnswer)
        {
            var strategy = _context.Database.CreateExecutionStrategy();

            await strategy.ExecuteAsync(async () =>
            {
                await using var transaction = await _context.Database.BeginTransactionAsync();

                if (isNewAnswer)
                {
                    _context.StudentAnswers.Add(answer);
                    await _context.SaveChangesAsync();
                }
                else
                {
                    _context.StudentAnswerOptions.RemoveRange(answer.StudentAnswerOptions);
                    answer.StudentAnswerOptions.Clear();
                    await _context.SaveChangesAsync();
                }

                answer.StudentAnswerOptions = selectedOptionIds
                    .Select(optionId => new StudentAnswerOption
                    {
                        StudentAnswerId = answer.StudentAnswerId,
                        OptionId = optionId
                    })
                    .ToList();

                _context.StudentAnswerOptions.AddRange(answer.StudentAnswerOptions);
                await _context.SaveChangesAsync();
                await transaction.CommitAsync();
            });

            return answer;
        }

        public async Task<ExamAttempt?> GetAttemptForSubmitAsync(int attemptId)
        {
            return await _context.ExamAttempts
                .Include(a => a.Exam)
                .Include(a => a.AttemptQuestions)
                    .ThenInclude(aq => aq.Question)
                        .ThenInclude(q => q!.QuestionOptions)
                .Include(a => a.StudentAnswers)
                    .ThenInclude(sa => sa.StudentAnswerOptions)
                .FirstOrDefaultAsync(a => a.AttemptId == attemptId);
        }

        public async Task<ExamAttempt> SubmitAttemptAsync(ExamAttempt attempt)
        {
            var strategy = _context.Database.CreateExecutionStrategy();

            await strategy.ExecuteAsync(async () =>
            {
                await using var transaction = await _context.Database.BeginTransactionAsync();
                await _context.SaveChangesAsync();
                await transaction.CommitAsync();
            });

            return attempt;
        }

        public async Task<ExamAttempt?> GetStudentResultAttemptAsync(int targetId, int studentId)
        {
            return await _context.ExamAttempts
                .AsNoTracking()
                .Include(a => a.Exam)
                .Include(a => a.AttemptQuestions)
                    .ThenInclude(aq => aq.Question)
                        .ThenInclude(q => q!.QuestionOptions)
                .Include(a => a.StudentAnswers)
                    .ThenInclude(sa => sa.StudentAnswerOptions)
                .Where(a =>
                    a.ExamId == targetId &&
                    a.StudentId == studentId &&
                    (a.Status == "Submitted" || a.Status == "Expired"))
                .OrderByDescending(a => a.SubmitTime)
                .FirstOrDefaultAsync();
        }

        public async Task<List<ExamAttempt>> GetRankingAttemptsAsync(int targetId)
        {
            return await _context.ExamAttempts
                .AsNoTracking()
                .Include(a => a.Exam)
                .Include(a => a.Student)
                .Where(a =>
                    a.ExamId == targetId &&
                    a.Status == "Submitted" &&
                    a.SubmitTime.HasValue)
                .ToListAsync();
        }
    }
}
