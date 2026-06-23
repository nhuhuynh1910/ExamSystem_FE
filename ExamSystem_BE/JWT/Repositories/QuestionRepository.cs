using JWT.Data;
using JWT.DTOs.Questions.Requests;
using JWT.Models;
using JWT.Repositories.Contracts;
using Microsoft.EntityFrameworkCore;

namespace JWT.Repositories
{
    public class QuestionRepository : IQuestionRepository
    {
        private readonly ExamDb _context;

        public QuestionRepository(ExamDb context)
        {
            _context = context;
        }

        public async Task<List<Question>> GetQuestionsAsync(
            QuestionFilterRequest request,
            int currentUserId,
            string currentUserRole)
        {
            var query = _context.Questions
                .Include(q => q.Subject)
                .Include(q => q.Teacher)
                .Include(q => q.QuestionOptions.Where(o => !o.IsDeleted))
                .Where(q => !q.IsDeleted)
                .AsQueryable();

            if (currentUserRole == "Teacher")
            {
                query = query.Where(q =>
                    q.TeacherId == currentUserId ||
                    _context.TeacherSubjects.Any(ts =>
                        ts.TeacherId == currentUserId &&
                        ts.SubjectId == q.SubjectId &&
                        ts.IsActive));
            }

            if (request.SubjectId.HasValue)
            {
                query = query.Where(q => q.SubjectId == request.SubjectId.Value);
            }

            if (!string.IsNullOrWhiteSpace(request.Difficulty))
            {
                query = query.Where(q => q.Difficulty == request.Difficulty);
            }

            if (!string.IsNullOrWhiteSpace(request.Status))
            {
                query = query.Where(q => q.Status == request.Status);
            }

            if (!string.IsNullOrWhiteSpace(request.QuestionType))
            {
                query = query.Where(q => q.QuestionType == request.QuestionType);
            }

            if (!string.IsNullOrWhiteSpace(request.Search))
            {
                var keyword = request.Search.Trim();

                query = query.Where(q => q.Content.Contains(keyword));
            }

            var pageNumber = request.PageNumber <= 0 ? 1 : request.PageNumber;
            var pageSize = request.PageSize <= 0 ? 10 : request.PageSize;

            return await query
                .OrderByDescending(q => q.CreatedAt)
                .Skip((pageNumber - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();
        }

        public async Task<Question?> GetQuestionByIdAsync(int questionId)
        {
            return await _context.Questions
                .Include(q => q.Subject)
                .Include(q => q.Teacher)
                .FirstOrDefaultAsync(q =>
                    q.QuestionId == questionId &&
                    !q.IsDeleted);
        }

        public async Task<Question?> GetQuestionByIdWithOptionsAsync(int questionId)
        {
            return await _context.Questions
                .Include(q => q.Subject)
                .Include(q => q.Teacher)
                .Include(q => q.QuestionOptions.Where(o => !o.IsDeleted))
                .FirstOrDefaultAsync(q =>
                    q.QuestionId == questionId &&
                    !q.IsDeleted);
        }

        public async Task AddQuestionAsync(Question question)
        {
            await _context.Questions.AddAsync(question);
        }

        public async Task<QuestionOption?> GetOptionByIdAsync(int optionId)
        {
            return await _context.QuestionOptions
                .Include(o => o.Question)
                .FirstOrDefaultAsync(o =>
                    o.OptionId == optionId &&
                    o.Question != null &&
                    !o.Question.IsDeleted &&
                    !o.IsDeleted);
        }

        public async Task AddOptionAsync(QuestionOption option)
        {
            await _context.QuestionOptions.AddAsync(option);
        }

        public async Task<bool> IsQuestionUsedInExamAsync(int questionId)
        {
            return await _context.ExamQuestions
                .AnyAsync(eq => eq.QuestionId == questionId);
        }

        public async Task<bool> IsQuestionUsedInPublishedExamAsync(int questionId)
        {
            return await _context.ExamQuestions
                .AnyAsync(eq =>
                    eq.QuestionId == questionId &&
                    eq.Exam != null &&
                    !eq.Exam.IsDeleted &&
                    eq.Exam.Status == "Published");
        }

        public async Task<bool> HasQuestionAttemptsAsync(int questionId)
        {
            return await _context.AttemptQuestions
                .AnyAsync(aq => aq.QuestionId == questionId);
        }

        public async Task<bool> HasCorrectOptionAsync(int questionId)
        {
            return await _context.QuestionOptions
                .AnyAsync(o =>
                    o.QuestionId == questionId &&
                    o.IsCorrect &&
                    !o.IsDeleted);
        }

        public async Task<bool> HasAnotherCorrectOptionAsync(int questionId, int excludedOptionId)
        {
            return await _context.QuestionOptions
                .AnyAsync(o =>
                    o.QuestionId == questionId &&
                    o.OptionId != excludedOptionId &&
                    o.IsCorrect &&
                    !o.IsDeleted);
        }

        public async Task<int> CountOptionsAsync(int questionId)
        {
            return await _context.QuestionOptions
                .CountAsync(o =>
                    o.QuestionId == questionId &&
                    !o.IsDeleted);
        }

        public async Task SaveChangesAsync()
        {
            await _context.SaveChangesAsync();
        }
    }
}
