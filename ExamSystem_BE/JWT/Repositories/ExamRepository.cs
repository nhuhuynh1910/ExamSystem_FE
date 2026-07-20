using JWT.Data;
using JWT.DTOs.Exam;
using JWT.Exceptions;
using JWT.Models;
using JWT.Repositories.Contracts;
using Microsoft.EntityFrameworkCore;
using System.Linq.Expressions;

namespace JWT.Repositories
{
    public class ExamRepository : IExamRepository
    {
        private readonly ExamDb _context;

        public ExamRepository(ExamDb context)
        {
            _context = context;
        }

        public async Task<PagedResultDto<ExamResponseDto>> GetPagedExamsAsync(
            ExamFilterRequestDto filter,
            int? teacherId,
            bool includeAll,
            bool publishedOnly)
        {
            var query = _context.Exams
                .AsNoTracking()
                .Where(e => !e.IsDeleted);

            if (filter.SubjectId.HasValue)
                query = query.Where(e => e.SubjectId == filter.SubjectId.Value);

            if (publishedOnly)
                query = query.Where(e => e.Status == "Published");

            if (!includeAll && teacherId.HasValue)
            {
                var currentTeacherId = teacherId.Value;

                query = query.Where(e =>
                    e.TeacherId == currentTeacherId ||
                    _context.TeacherSubjects.Any(ts =>
                        ts.TeacherId == currentTeacherId &&
                        ts.SubjectId == e.SubjectId &&
                        ts.IsActive));
            }

            var totalItems = await query.CountAsync();

            var items = await query
                .OrderByDescending(e => e.CreatedAt)
                .Skip((filter.PageNumber - 1) * filter.PageSize)
                .Take(filter.PageSize)
                .Select(ExamResponseSelector)
                .ToListAsync();

            return new PagedResultDto<ExamResponseDto>
            {
                Items = items,
                PageNumber = filter.PageNumber,
                PageSize = filter.PageSize,
                TotalItems = totalItems,
                TotalPages = (int)Math.Ceiling(totalItems / (double)filter.PageSize)
            };
        }

        public async Task<PagedResultDto<ExamResponseDto>> GetTeacherOwnedExamsAsync(
            TeacherExamFilterRequestDto filter,
            int teacherId)
        {
            var query = _context.Exams
                .AsNoTracking()
                .Where(e => !e.IsDeleted && e.TeacherId == teacherId);

            if (filter.SubjectId.HasValue)
                query = query.Where(e => e.SubjectId == filter.SubjectId.Value);

            if (!string.IsNullOrWhiteSpace(filter.Status))
            {
                var status = filter.Status.Trim();
                query = query.Where(e => e.Status == status);
            }

            var totalItems = await query.CountAsync();

            var items = await query
                .OrderByDescending(e => e.CreatedAt)
                .Skip((filter.PageNumber - 1) * filter.PageSize)
                .Take(filter.PageSize)
                .Select(ExamResponseSelector)
                .ToListAsync();

            return new PagedResultDto<ExamResponseDto>
            {
                Items = items,
                PageNumber = filter.PageNumber,
                PageSize = filter.PageSize,
                TotalItems = totalItems,
                TotalPages = (int)Math.Ceiling(totalItems / (double)filter.PageSize)
            };
        }

        public async Task<ExamResponseDto?> GetExamByIdAsync(int examId)
        {
            return await _context.Exams
                .AsNoTracking()
                .Where(e => e.ExamId == examId && !e.IsDeleted)
                .Select(ExamResponseSelector)
                .FirstOrDefaultAsync();
        }

        public async Task<Exam?> GetExamEntityByIdAsync(int examId)
        {
            return await _context.Exams
                .FirstOrDefaultAsync(e => e.ExamId == examId && !e.IsDeleted);
        }

        public async Task<Exam?> GetExamEntityIncludingDeletedByIdAsync(int examId)
        {
            return await _context.Exams
                .FirstOrDefaultAsync(e => e.ExamId == examId);
        }

        public async Task<Question?> GetQuestionByIdAsync(int questionId)
        {
            return await _context.Questions
                .AsNoTracking()
                .FirstOrDefaultAsync(q => q.QuestionId == questionId && !q.IsDeleted);
        }

        public async Task<ExamResponseDto> AddExamAsync(Exam exam)
        {
            _context.Exams.Add(exam);
            await _context.SaveChangesAsync();

            return await GetExamByIdAsync(exam.ExamId)
                ?? throw new InvalidOperationException("Cannot load created exam.");
        }

        public async Task<ExamResponseDto> UpdateExamAsync(Exam exam)
        {
            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                throw new ConflictException("Du lieu de thi da bi thay doi boi nguoi dung khac.");
            }

            return await GetExamByIdAsync(exam.ExamId)
                ?? throw new InvalidOperationException("Cannot load updated exam.");
        }

        public async Task<bool> ExamNameExistsAsync(string examName, int? excludedExamId = null)
        {
            var normalizedExamName = examName.Trim().ToLower();

            return await _context.Exams
                .AsNoTracking()
                .AnyAsync(e =>
                    !e.IsDeleted &&
                    e.ExamName.ToLower() == normalizedExamName &&
                    (!excludedExamId.HasValue || e.ExamId != excludedExamId.Value));
        }

        public async Task<bool> IsTeacherAssignedToSubjectAsync(int teacherId, int subjectId)
        {
            return await _context.TeacherSubjects
                .AsNoTracking()
                .AnyAsync(ts =>
                    ts.TeacherId == teacherId &&
                    ts.SubjectId == subjectId &&
                    ts.IsActive);
        }

        public async Task<bool> ExamQuestionExistsAsync(int examId, int questionId)
        {
            return await _context.ExamQuestions
                .AsNoTracking()
                .AnyAsync(eq => eq.ExamId == examId && eq.QuestionId == questionId);
        }

        public async Task<bool> HasExamQuestionsAsync(int examId)
        {
            return await _context.ExamQuestions
                .AsNoTracking()
                .AnyAsync(eq =>
                    eq.ExamId == examId &&
                    eq.Question != null &&
                    !eq.Question.IsDeleted);
        }

        public async Task<int> GetNextQuestionOrderAsync(int examId)
        {
            var maxOrder = await _context.ExamQuestions
                .AsNoTracking()
                .Where(eq => eq.ExamId == examId)
                .Select(eq => (int?)eq.QuestionOrder)
                .MaxAsync();

            return (maxOrder ?? 0) + 1;
        }

        public async Task<ExamQuestion> AddExamQuestionAsync(ExamQuestion examQuestion)
        {
            _context.ExamQuestions.Add(examQuestion);
            await _context.SaveChangesAsync();

            return examQuestion;
        }

        public async Task<ExamQuestion?> GetExamQuestionAsync(int examId, int questionId)
        {
            return await _context.ExamQuestions
                .FirstOrDefaultAsync(eq => eq.ExamId == examId && eq.QuestionId == questionId);
        }

        public async Task RemoveExamQuestionAsync(ExamQuestion examQuestion)
        {
            _context.ExamQuestions.Remove(examQuestion);
            await _context.SaveChangesAsync();
        }

        public async Task RebalanceExamQuestionScoresAsync(int examId, decimal totalScore)
        {
            var examQuestions = await _context.ExamQuestions
                .Include(eq => eq.Question)
                .Where(eq =>
                    eq.ExamId == examId &&
                    eq.Question != null &&
                    !eq.Question.IsDeleted)
                .OrderBy(eq => eq.QuestionOrder)
                .ThenBy(eq => eq.ExamQuestionId)
                .ToListAsync();

            if (examQuestions.Count == 0)
            {
                return;
            }

            var baseScore = Math.Round(totalScore / examQuestions.Count, 2, MidpointRounding.AwayFromZero);
            var assignedScore = 0m;

            for (var index = 0; index < examQuestions.Count; index++)
            {
                var score = index == examQuestions.Count - 1
                    ? totalScore - assignedScore
                    : baseScore;

                examQuestions[index].Score = score;
                assignedScore += score;
            }

            await _context.SaveChangesAsync();
        }

        public async Task<List<ExamQuestionResponseDto>> GetExamQuestionsAsync(int examId)
        {
            return await _context.ExamQuestions
                .AsNoTracking()
                .Where(eq => eq.ExamId == examId &&
                    eq.Question != null &&
                    !eq.Question.IsDeleted)
                .OrderBy(eq => eq.QuestionOrder)
                .Select(eq => new ExamQuestionResponseDto
                {
                    ExamQuestionId = eq.ExamQuestionId,
                    QuestionId = eq.QuestionId,
                    QuestionOrder = eq.QuestionOrder,
                    Score = eq.Score,
                    Content = eq.Question != null ? eq.Question.Content : string.Empty,
                    QuestionType = eq.Question != null ? eq.Question.QuestionType : string.Empty,
                    Difficulty = eq.Question != null ? eq.Question.Difficulty : string.Empty,
                    Explanation = eq.Question != null ? eq.Question.Explanation : null,
                    Options = eq.Question != null
                        ? eq.Question.QuestionOptions
                            .Where(o => !o.IsDeleted)
                            .OrderBy(o => o.OptionOrder)
                            .Select(o => new ExamQuestionOptionResponseDto
                            {
                                OptionId = o.OptionId,
                                OptionText = o.OptionText,
                                IsCorrect = o.IsCorrect,
                                OptionOrder = o.OptionOrder
                            })
                            .ToList()
                        : new List<ExamQuestionOptionResponseDto>()
                })
                .ToListAsync();
        }

        private static readonly Expression<Func<Exam, ExamResponseDto>> ExamResponseSelector = e =>
            new ExamResponseDto
            {
                ExamId = e.ExamId,
                SubjectId = e.SubjectId,
                SubjectName = e.Subject != null ? e.Subject.SubjectName : null,
                TeacherId = e.TeacherId,
                ExamName = e.ExamName,
                Description = e.Description,
                ExamImageUrl = e.ExamImageUrl,
                DurationMinutes = e.DurationMinutes,
                StartTime = e.StartTime,
                EndTime = e.EndTime,
                PassingScore = e.PassingScore,
                MaxAttempts = e.MaxAttempts,
                IsPrivate = e.IsPrivate,
                AccessCode = e.AccessCode,
                ShuffleQuestions = e.ShuffleQuestions,
                ShowAnswerAfterSubmit = e.ShowAnswerAfterSubmit,
                Status = e.Status,
                CreatedAt = e.CreatedAt,
                UpdatedAt = e.UpdatedAt
            };
    }
}
