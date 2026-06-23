using JWT.DTOs.Questions.Requests;
using JWT.DTOs.Questions.Responses;
using JWT.Models;
using JWT.Repositories.Contracts;
using JWT.Services.Contracts;

namespace JWT.Services
{
    public class QuestionService : IQuestionService
    {
        private static readonly HashSet<string> ValidQuestionTypes = new(StringComparer.OrdinalIgnoreCase)
        {
            "MultipleChoice",
            "SingleChoice",
            "TrueFalse",
            "Essay"
        };

        private static readonly HashSet<string> ValidDifficulties = new(StringComparer.OrdinalIgnoreCase)
        {
            "Easy",
            "Medium",
            "Hard"
        };

        private readonly IQuestionRepository _questionRepository;
        private readonly ISubjectRepository _subjectRepository;
        private readonly ITeacherSubjectRepository _teacherSubjectRepository;

        public QuestionService(
            IQuestionRepository questionRepository,
            ISubjectRepository subjectRepository,
            ITeacherSubjectRepository teacherSubjectRepository)
        {
            _questionRepository = questionRepository;
            _subjectRepository = subjectRepository;
            _teacherSubjectRepository = teacherSubjectRepository;
        }

        public async Task<List<QuestionResponse>> GetQuestionsAsync(
            QuestionFilterRequest request,
            int currentUserId,
            string currentUserRole)
        {
            var questions = await _questionRepository.GetQuestionsAsync(
                request,
                currentUserId,
                currentUserRole);

            return questions
                .Select(q => MapToQuestionResponse(q, CanSeeCorrectAnswers(currentUserRole)))
                .ToList();
        }

        public async Task<QuestionResponse?> GetQuestionByIdAsync(
            int questionId,
            int currentUserId,
            string currentUserRole)
        {
            var question = await _questionRepository.GetQuestionByIdWithOptionsAsync(questionId);

            if (question == null)
            {
                return null;
            }

            if (!await CanViewQuestionAsync(question, currentUserId, currentUserRole))
            {
                throw new UnauthorizedAccessException("You are not allowed to view this question.");
            }

            return MapToQuestionResponse(question, CanSeeCorrectAnswers(currentUserRole));
        }

        public async Task<QuestionResponse> CreateQuestionAsync(
            CreateQuestionRequest request,
            int teacherId)
        {
            ValidateQuestionInput(request.Content, request.QuestionType, request.Difficulty, request.Score);

            var subject = await _subjectRepository.GetSubjectByIdAsync(request.SubjectId);

            if (subject == null)
            {
                throw new Exception("Subject not found.");
            }

            if (!subject.IsActive)
            {
                throw new Exception("Subject is inactive.");
            }

            var isAssigned = await _teacherSubjectRepository.IsAssignedAsync(teacherId, request.SubjectId);

            if (!isAssigned)
            {
                throw new UnauthorizedAccessException("Teacher is not assigned to this subject.");
            }

            var question = new Question
            {
                SubjectId = request.SubjectId,
                TeacherId = teacherId,
                Content = request.Content.Trim(),
                QuestionType = Normalize(request.QuestionType, ValidQuestionTypes),
                Difficulty = Normalize(request.Difficulty, ValidDifficulties),
                Score = request.Score,
                Explanation = request.Explanation,
                Status = "Draft",
                IsDeleted = false,
                CreatedBy = teacherId,
                CreatedAt = DateTime.UtcNow
            };

            await _questionRepository.AddQuestionAsync(question);
            await _questionRepository.SaveChangesAsync();

            return await GetQuestionByIdAsync(question.QuestionId, teacherId, "Teacher")
                   ?? throw new Exception("Question not found after created.");
        }

        public async Task<QuestionResponse> UpdateQuestionAsync(
            int questionId,
            UpdateQuestionRequest request,
            int teacherId)
        {
            var question = await _questionRepository.GetQuestionByIdAsync(questionId);

            if (question == null)
            {
                throw new Exception("Question not found.");
            }

            if (question.TeacherId != teacherId)
            {
                throw new UnauthorizedAccessException("You can only update your own question.");
            }

            if (await _questionRepository.IsQuestionUsedInPublishedExamAsync(questionId))
            {
                throw new Exception("Cannot update question because it is used in a published exam.");
            }

            ValidateRowVersion(request.RowVersion, question.RowVersion);
            ValidateQuestionInput(request.Content, request.QuestionType, request.Difficulty, request.Score);

            question.Content = request.Content.Trim();
            question.QuestionType = Normalize(request.QuestionType, ValidQuestionTypes);
            question.Difficulty = Normalize(request.Difficulty, ValidDifficulties);
            question.Score = request.Score;
            question.Explanation = request.Explanation;
            question.UpdatedBy = teacherId;
            question.UpdatedAt = DateTime.UtcNow;

            await _questionRepository.SaveChangesAsync();

            return await GetQuestionByIdAsync(questionId, teacherId, "Teacher")
                   ?? throw new Exception("Question not found after updated.");
        }

        public async Task DeleteQuestionAsync(int questionId, int teacherId)
        {
            var question = await _questionRepository.GetQuestionByIdAsync(questionId);

            if (question == null)
            {
                throw new Exception("Question not found.");
            }

            if (question.TeacherId != teacherId)
            {
                throw new UnauthorizedAccessException("You can only delete your own question.");
            }

            var isUsedInExam = await _questionRepository.IsQuestionUsedInExamAsync(questionId);

            if (isUsedInExam)
            {
                throw new Exception("Cannot delete question because it is being used in an exam.");
            }

            question.IsDeleted = true;
            question.UpdatedBy = teacherId;
            question.UpdatedAt = DateTime.UtcNow;

            await _questionRepository.SaveChangesAsync();
        }

        public async Task<QuestionOptionResponse> AddOptionAsync(
            int questionId,
            CreateQuestionOptionRequest request,
            int teacherId)
        {
            var question = await _questionRepository.GetQuestionByIdAsync(questionId);

            if (question == null)
            {
                throw new Exception("Question not found.");
            }

            if (question.TeacherId != teacherId)
            {
                throw new UnauthorizedAccessException("You can only add option to your own question.");
            }

            ValidateOptionText(request.OptionText);

            var option = new QuestionOption
            {
                QuestionId = questionId,
                OptionText = request.OptionText.Trim(),
                IsCorrect = request.IsCorrect,
                OptionOrder = request.OptionOrder,
                IsDeleted = false,
                CreatedAt = DateTime.UtcNow
            };

            await _questionRepository.AddOptionAsync(option);
            await _questionRepository.SaveChangesAsync();

            return MapToQuestionOptionResponse(option, includeCorrectAnswer: true);
        }

        public async Task<QuestionOptionResponse> UpdateOptionAsync(
            int optionId,
            UpdateQuestionOptionRequest request,
            int teacherId)
        {
            var option = await _questionRepository.GetOptionByIdAsync(optionId);

            if (option == null)
            {
                throw new Exception("Option not found.");
            }

            if (option.Question == null || option.Question.TeacherId != teacherId)
            {
                throw new UnauthorizedAccessException("You can only update option of your own question.");
            }

            if (await _questionRepository.IsQuestionUsedInPublishedExamAsync(option.QuestionId))
            {
                throw new Exception("Cannot update option because the question is used in a published exam.");
            }

            if (await _questionRepository.HasQuestionAttemptsAsync(option.QuestionId))
            {
                throw new Exception("Cannot update option because the question already has attempts.");
            }

            ValidateRowVersion(request.RowVersion, option.RowVersion);
            ValidateOptionText(request.OptionText);

            option.OptionText = request.OptionText.Trim();
            option.IsCorrect = request.IsCorrect;
            option.OptionOrder = request.OptionOrder;
            option.UpdatedAt = DateTime.UtcNow;

            await _questionRepository.SaveChangesAsync();

            return MapToQuestionOptionResponse(option, includeCorrectAnswer: true);
        }

        public async Task DeleteOptionAsync(int optionId, int teacherId)
        {
            var option = await _questionRepository.GetOptionByIdAsync(optionId);

            if (option == null)
            {
                throw new Exception("Option not found.");
            }

            if (option.Question == null || option.Question.TeacherId != teacherId)
            {
                throw new UnauthorizedAccessException("You can only delete option of your own question.");
            }

            if (option.Question.Status == "Published")
            {
                var hasCorrectOptionAfterDelete = option.IsCorrect
                    ? await _questionRepository.HasAnotherCorrectOptionAsync(
                        option.QuestionId,
                        option.OptionId)
                    : await _questionRepository.HasCorrectOptionAsync(option.QuestionId);

                if (!hasCorrectOptionAfterDelete)
                {
                    throw new Exception("Published question must have at least one correct option.");
                }
            }

            option.IsDeleted = true;
            option.UpdatedAt = DateTime.UtcNow;

            await _questionRepository.SaveChangesAsync();
        }

        public async Task PublishQuestionAsync(int questionId, int teacherId)
        {
            var question = await _questionRepository.GetQuestionByIdAsync(questionId);

            if (question == null)
            {
                throw new Exception("Question not found.");
            }

            if (question.TeacherId != teacherId)
            {
                throw new UnauthorizedAccessException("You can only publish your own question.");
            }

            if (string.IsNullOrWhiteSpace(question.Content))
            {
                throw new Exception("Question content is required.");
            }

            if (question.Score <= 0)
            {
                throw new Exception("Score must be greater than zero.");
            }

            var optionCount = await _questionRepository.CountOptionsAsync(questionId);

            if (optionCount == 0)
            {
                throw new Exception("Question must have at least one option before publishing.");
            }

            var hasCorrectOption = await _questionRepository.HasCorrectOptionAsync(questionId);

            if (!hasCorrectOption)
            {
                throw new Exception("Question must have at least one correct option before publishing.");
            }

            question.Status = "Published";
            question.UpdatedBy = teacherId;
            question.UpdatedAt = DateTime.UtcNow;

            await _questionRepository.SaveChangesAsync();
        }

        public async Task DraftQuestionAsync(int questionId, int teacherId)
        {
            var question = await _questionRepository.GetQuestionByIdAsync(questionId);

            if (question == null)
            {
                throw new Exception("Question not found.");
            }

            if (question.TeacherId != teacherId)
            {
                throw new UnauthorizedAccessException("You can only change status of your own question.");
            }

            if (await _questionRepository.IsQuestionUsedInPublishedExamAsync(questionId))
            {
                throw new Exception("Cannot move question to draft because it is used in a published exam.");
            }

            question.Status = "Draft";
            question.UpdatedBy = teacherId;
            question.UpdatedAt = DateTime.UtcNow;

            await _questionRepository.SaveChangesAsync();
        }

        private async Task<bool> CanViewQuestionAsync(
            Question question,
            int currentUserId,
            string currentUserRole)
        {
            if (currentUserRole == "Admin")
            {
                return true;
            }

            if (currentUserRole == "Teacher")
            {
                return question.TeacherId == currentUserId ||
                       await _teacherSubjectRepository.IsAssignedAsync(currentUserId, question.SubjectId);
            }

            return true;
        }

        private static bool CanSeeCorrectAnswers(string currentUserRole)
        {
            return currentUserRole == "Admin" || currentUserRole == "Teacher";
        }

        private static void ValidateQuestionInput(
            string content,
            string questionType,
            string difficulty,
            decimal score)
        {
            if (string.IsNullOrWhiteSpace(content))
            {
                throw new Exception("Question content is required.");
            }

            if (!ValidQuestionTypes.Contains(questionType))
            {
                throw new Exception("Question type is invalid.");
            }

            if (!ValidDifficulties.Contains(difficulty))
            {
                throw new Exception("Difficulty is invalid.");
            }

            if (score <= 0)
            {
                throw new Exception("Score must be greater than zero.");
            }
        }

        private static void ValidateOptionText(string optionText)
        {
            if (string.IsNullOrWhiteSpace(optionText))
            {
                throw new Exception("Option text is required.");
            }
        }

        private static void ValidateRowVersion(byte[]? requestRowVersion, byte[]? currentRowVersion)
        {
            if (requestRowVersion == null || currentRowVersion == null)
            {
                throw new Exception("RowVersion is required.");
            }

            if (!requestRowVersion.SequenceEqual(currentRowVersion))
            {
                throw new Exception("The record was modified by another request. Please reload and try again.");
            }
        }

        private static string Normalize(string value, HashSet<string> validValues)
        {
            return validValues.First(valid => valid.Equals(value, StringComparison.OrdinalIgnoreCase));
        }

        private static QuestionResponse MapToQuestionResponse(Question question, bool includeCorrectAnswers)
        {
            return new QuestionResponse
            {
                QuestionId = question.QuestionId,
                SubjectId = question.SubjectId,
                SubjectName = question.Subject?.SubjectName ?? string.Empty,
                TeacherId = question.TeacherId,
                TeacherName = question.Teacher?.FullName ?? string.Empty,
                Content = question.Content,
                QuestionType = question.QuestionType,
                Difficulty = question.Difficulty,
                Score = question.Score,
                Status = question.Status,
                Explanation = question.Explanation,
                CreatedAt = question.CreatedAt,
                UpdatedAt = question.UpdatedAt,
                RowVersion = question.RowVersion,
                Options = question.QuestionOptions?
                    .Where(o => !o.IsDeleted)
                    .OrderBy(o => o.OptionOrder)
                    .Select(o => MapToQuestionOptionResponse(o, includeCorrectAnswers))
                    .ToList() ?? new List<QuestionOptionResponse>()
            };
        }

        private static QuestionOptionResponse MapToQuestionOptionResponse(
            QuestionOption option,
            bool includeCorrectAnswer)
        {
            return new QuestionOptionResponse
            {
                OptionId = option.OptionId,
                QuestionId = option.QuestionId,
                OptionText = option.OptionText,
                IsCorrect = includeCorrectAnswer ? option.IsCorrect : null,
                OptionOrder = option.OptionOrder,
                RowVersion = option.RowVersion
            };
        }
    }
}
