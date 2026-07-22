using JWT.DTOs.BaoAccess;
using JWT.Exceptions;
using JWT.Models;
using JWT.Repositories.Contracts;
using JWT.Services.Contracts;

namespace JWT.Services
{
    public class BaoAccessService : IBaoAccessService
    {
        private const string PublishedStatus = "Published";
        private const string InProgressStatus = "InProgress";
        private const string SubmittedStatus = "Submitted";
        private const string ExpiredStatus = "Expired";

        private readonly IBaoAccessRepository _baoAccessRepository;

        public BaoAccessService(IBaoAccessRepository baoAccessRepository)
        {
            _baoAccessRepository = baoAccessRepository;
        }

        public async Task<BaoAccessResponseDto> CheckAccessAsync(
            int targetId,
            BaoAccessRequestDto request,
            string? currentUserId,
            string? currentUserRole)
        {
            var (studentId, role) = GetCurrentUser(currentUserId, currentUserRole);

            if (role != "Student")
            {
                throw new ForbiddenException("Chỉ Student mới có thể join.");
            }

            var target = await _baoAccessRepository.GetTargetAsync(targetId)
                ?? throw new NotFoundException("Không tìm thấy đề thi.");

            if (target.Status != PublishedStatus)
            {
                throw new ForbiddenException("Đề thi chưa được publish.");
            }

            var now = DateTime.Now;

            if (now < target.StartTime)
            {
                throw new ForbiddenException("Chưa đến thời gian thi.");
            }

            if (now > target.EndTime)
            {
                throw new ForbiddenException("Đã qua thời gian thi.");
            }

            if (!await _baoAccessRepository.IsStudentEnrolledAsync(studentId, target.SubjectId))
            {
                throw new ForbiddenException("Student chưa enroll subject của đề thi.");
            }

            if (target.IsPrivate && !AccessCodeMatches(request.AccessCode, target.AccessCode))
            {
                throw new ForbiddenException("AccessCode không đúng.");
            }

            var attemptsUsed = await _baoAccessRepository.CountAttemptsAsync(targetId, studentId);

            if (attemptsUsed >= target.MaxAttempts)
            {
                throw new ConflictException("Student đã vượt MaxAttempts.");
            }

            return new BaoAccessResponseDto
            {
                CanAccess = true,
                AttemptsUsed = attemptsUsed,
                MaxAttempts = target.MaxAttempts,
                RemainingAttempts = target.MaxAttempts - attemptsUsed,
                CheckedAt = now
            };
        }

        public async Task<BaoStartResponseDto> StartAsync(
            int targetId,
            BaoAccessRequestDto request,
            string? currentUserId,
            string? currentUserRole)
        {
            var (studentId, role) = GetCurrentUser(currentUserId, currentUserRole);

            if (role != "Student")
            {
                throw new ForbiddenException("Chỉ Student mới được bắt đầu làm bài.");
            }

            var target = await _baoAccessRepository.GetTargetAsync(targetId)
                ?? throw new NotFoundException("Không tìm thấy đề thi.");

            EnsureCanStart(target);

            if (target.IsPrivate && !AccessCodeMatches(request.AccessCode, target.AccessCode))
            {
                throw new ForbiddenException("AccessCode không đúng.");
            }

            if (!await _baoAccessRepository.IsStudentEnrolledAsync(studentId, target.SubjectId))
            {
                throw new ForbiddenException("Student chưa enroll subject của đề thi.");
            }

            var inProgressAttempt = await _baoAccessRepository.GetInProgressAttemptAsync(targetId, studentId);

            if (inProgressAttempt != null)
            {
                return MapStartResponse(inProgressAttempt, isResume: true);
            }

            var attemptsUsed = await _baoAccessRepository.CountAttemptsAsync(targetId, studentId);

            if (attemptsUsed >= target.MaxAttempts)
            {
                throw new ConflictException("Student đã vượt MaxAttempts.");
            }

            var targetQuestions = await _baoAccessRepository.GetTargetQuestionsAsync(targetId);

            if (targetQuestions.Count == 0)
            {
                throw new BadRequestException("Đề thi chưa có câu hỏi published.");
            }

            if (target.ShuffleQuestions)
            {
                targetQuestions = targetQuestions
                    .OrderBy(_ => Random.Shared.Next())
                    .ToList();
            }

            var now = DateTime.Now;
            var attempt = new ExamAttempt
            {
                ExamId = targetId,
                StudentId = studentId,
                AttemptNumber = await _baoAccessRepository.GetNextAttemptNumberAsync(targetId, studentId),
                StartTime = now,
                Score = 0,
                IsPassed = false,
                Status = InProgressStatus,
                IsAutoSubmitted = false,
                CreatedAt = now
            };

            var totalQuestions = targetQuestions.Count;
            var defaultQuestionScore = totalQuestions > 0 ? 10m / totalQuestions : 0m;

            var attemptQuestions = targetQuestions
                .Select((question, index) => new AttemptQuestion
                {
                    QuestionId = question.QuestionId,
                    QuestionOrder = index + 1,
                    Score = defaultQuestionScore
                })
                .ToList();

            var createdAttempt = await _baoAccessRepository.AddAttemptAsync(attempt, attemptQuestions);
            createdAttempt.AttemptQuestions = attemptQuestions;

            return MapStartResponse(createdAttempt, isResume: false);
        }

        public async Task<BaoAttemptDetailResponseDto> GetAttemptAsync(
            int attemptId,
            string? currentUserId,
            string? currentUserRole)
        {
            var (userId, role) = GetCurrentUser(currentUserId, currentUserRole);

            var attempt = await _baoAccessRepository.GetAttemptDetailAsync(attemptId)
                ?? throw new NotFoundException("Không tìm thấy lần làm bài.");

            EnsureCanViewAttempt(attempt, userId, role);

            return MapAttemptDetail(attempt);
        }

        public async Task<BaoSaveAnswerResponseDto> SaveAnswerAsync(
            int attemptId,
            BaoSaveAnswerRequestDto request,
            string? currentUserId,
            string? currentUserRole)
        {
            var (studentId, role) = GetCurrentUser(currentUserId, currentUserRole);

            if (role != "Student")
            {
                throw new ForbiddenException("Chỉ Student mới được lưu câu trả lời.");
            }

            if (request.QuestionId <= 0)
            {
                throw new BadRequestException("QuestionId không hợp lệ.");
            }

            var selectedOptionIds = request.SelectedOptionIds
                .Distinct()
                .ToList();

            if (selectedOptionIds.Count == 0)
            {
                throw new BadRequestException("Phải chọn ít nhất một option.");
            }

            var attempt = await _baoAccessRepository.GetAttemptForAnswerAsync(attemptId)
                ?? throw new NotFoundException("Không tìm thấy lần làm bài.");

            if (attempt.StudentId != studentId)
            {
                throw new ForbiddenException("Attempt không thuộc Student hiện tại.");
            }

            if (attempt.Status != InProgressStatus)
            {
                throw new BadRequestException("Chỉ được lưu câu trả lời khi attempt đang InProgress.");
            }

            EnsureAttemptStillOpen(attempt);

            var attemptQuestion = attempt.AttemptQuestions
                .FirstOrDefault(question => question.QuestionId == request.QuestionId)
                ?? throw new BadRequestException("Question không thuộc AttemptQuestions.");

            var validOptionIds = attemptQuestion.Question?.QuestionOptions
                .Where(option => !option.IsDeleted)
                .Select(option => option.OptionId)
                .ToHashSet() ?? new HashSet<int>();

            if (selectedOptionIds.Any(optionId => !validOptionIds.Contains(optionId)))
            {
                throw new BadRequestException("Option chọn phải thuộc Question đó.");
            }

            var correctOptionIds = attemptQuestion.Question?.QuestionOptions
                .Where(option => !option.IsDeleted && option.IsCorrect)
                .Select(option => option.OptionId)
                .ToHashSet() ?? new HashSet<int>();

            var selectedOptionSet = selectedOptionIds.ToHashSet();
            var isCorrect = correctOptionIds.SetEquals(selectedOptionSet);
            var now = DateTime.Now;

            var answer = attempt.StudentAnswers
                .FirstOrDefault(existingAnswer => existingAnswer.QuestionId == request.QuestionId);

            var isNewAnswer = answer == null;

            answer ??= new StudentAnswer
            {
                AttemptId = attemptId,
                QuestionId = request.QuestionId
            };

            var totalQuestions = attempt.AttemptQuestions.Count;
            var questionScore = totalQuestions > 0 ? 10m / totalQuestions : 0m;

            answer.AnsweredAt = now;
            answer.IsCorrect = isCorrect;
            answer.ScoreAwarded = isCorrect ? questionScore : 0m;

            var savedAnswer = await _baoAccessRepository.SaveAnswerAsync(
                answer,
                selectedOptionIds,
                isNewAnswer);

            return new BaoSaveAnswerResponseDto
            {
                StudentAnswerId = savedAnswer.StudentAnswerId,
                AttemptId = savedAnswer.AttemptId,
                QuestionId = savedAnswer.QuestionId,
                SelectedOptionIds = selectedOptionIds,
                AnsweredAt = savedAnswer.AnsweredAt
            };
        }

        public async Task<BaoSubmitResponseDto> SubmitAsync(
            int attemptId,
            BaoSubmitRequestDto request,
            string? currentUserId,
            string? currentUserRole)
        {
            var (studentId, role) = GetCurrentUser(currentUserId, currentUserRole);

            if (role != "Student")
            {
                throw new ForbiddenException("Chỉ Student mới được nộp bài.");
            }

            var attempt = await _baoAccessRepository.GetAttemptForSubmitAsync(attemptId)
                ?? throw new NotFoundException("Không tìm thấy lần làm bài.");

            if (attempt.StudentId != studentId)
            {
                throw new ForbiddenException("Attempt không thuộc Student hiện tại.");
            }

            if (attempt.Status != InProgressStatus)
            {
                throw new BadRequestException("Attempt đã được nộp hoặc không còn InProgress.");
            }

            var now = DateTime.Now;
            var isExpired = IsAttemptExpired(attempt, now);
            var totalScore = GradeAttempt(attempt);

            attempt.SubmitTime = now;
            attempt.Score = totalScore;
            attempt.IsPassed = totalScore >= (attempt.Exam?.PassingScore ?? 0);
            attempt.Status = isExpired ? ExpiredStatus : SubmittedStatus;
            attempt.IsAutoSubmitted = request.IsAutoSubmitted || isExpired;
            attempt.UpdatedAt = now;

            var submittedAttempt = await _baoAccessRepository.SubmitAttemptAsync(attempt);

            return new BaoSubmitResponseDto
            {
                AttemptId = submittedAttempt.AttemptId,
                ExamId = submittedAttempt.ExamId,
                AttemptNumber = submittedAttempt.AttemptNumber,
                Status = submittedAttempt.Status,
                StartTime = submittedAttempt.StartTime,
                SubmitTime = submittedAttempt.SubmitTime ?? now,
                Score = submittedAttempt.Score,
                PassingScore = submittedAttempt.Exam?.PassingScore ?? 0,
                TotalScore = submittedAttempt.Exam?.TotalScore ?? 0,
                IsPassed = submittedAttempt.IsPassed,
                IsAutoSubmitted = submittedAttempt.IsAutoSubmitted,
                AnsweredQuestions = submittedAttempt.StudentAnswers.Count,
                TotalQuestions = submittedAttempt.AttemptQuestions.Count
            };
        }

        public async Task<BaoResultResponseDto> GetResultAsync(
            int targetId,
            string? currentUserId,
            string? currentUserRole)
        {
            var (studentId, role) = GetCurrentUser(currentUserId, currentUserRole);

            if (role != "Student")
            {
                throw new ForbiddenException("Chỉ Student mới được xem kết quả của mình.");
            }

            var target = await _baoAccessRepository.GetTargetAsync(targetId)
                ?? throw new NotFoundException("Không tìm thấy đề thi.");

            var attempt = await _baoAccessRepository.GetStudentResultAttemptAsync(targetId, studentId)
                ?? throw new NotFoundException("Không tìm thấy attempt đã nộp của Student.");

            if (attempt.Status != SubmittedStatus && attempt.Status != ExpiredStatus)
            {
                throw new BadRequestException("Attempt chưa được nộp.");
            }

            return MapResult(target, attempt);
        }

        public async Task<BaoRankingResponseDto> GetRankingAsync(int targetId, int top)
        {
            var target = await _baoAccessRepository.GetTargetAsync(targetId)
                ?? throw new NotFoundException("Không tìm thấy đề thi.");

            var take = top <= 0 ? 5 : Math.Min(top, 100);
            var attempts = await _baoAccessRepository.GetRankingAttemptsAsync(targetId);

            var bestAttempts = attempts
                .GroupBy(attempt => attempt.StudentId)
                .Select(group => group
                    .OrderByDescending(attempt => attempt.Score)
                    .ThenBy(attempt => GetSubmitDurationSeconds(attempt))
                    .ThenBy(attempt => attempt.SubmitTime)
                    .First())
                .OrderByDescending(attempt => attempt.Score)
                .ThenBy(attempt => GetSubmitDurationSeconds(attempt))
                .ThenBy(attempt => attempt.SubmitTime)
                .Take(take)
                .Select((attempt, index) => new BaoRankingItemDto
                {
                    Rank = index + 1,
                    StudentId = attempt.StudentId,
                    StudentName = attempt.Student?.FullName ?? string.Empty,
                    Username = attempt.Student?.Username ?? string.Empty,
                    AttemptId = attempt.AttemptId,
                    AttemptNumber = attempt.AttemptNumber,
                    Score = attempt.Score,
                    IsPassed = attempt.IsPassed,
                    StartTime = attempt.StartTime,
                    SubmitTime = attempt.SubmitTime!.Value,
                    SubmitDurationSeconds = GetSubmitDurationSeconds(attempt)
                })
                .ToList();

            return new BaoRankingResponseDto
            {
                ExamId = target.ExamId,
                ExamName = target.ExamName,
                Top = take,
                Items = bestAttempts
            };
        }

        private static (int UserId, string Role) GetCurrentUser(
            string? currentUserId,
            string? currentUserRole)
        {
            if (string.IsNullOrWhiteSpace(currentUserId) ||
                string.IsNullOrWhiteSpace(currentUserRole) ||
                !int.TryParse(currentUserId, out var userId))
            {
                throw new UnauthorizedException("Không tìm thấy thông tin người dùng trong Token!");
            }

            return (userId, currentUserRole.Trim());
        }

        private static bool AccessCodeMatches(string? requestAccessCode, string? storedAccessCode)
        {
            return !string.IsNullOrWhiteSpace(requestAccessCode) &&
                string.Equals(
                    requestAccessCode.Trim(),
                    storedAccessCode,
                    StringComparison.Ordinal);
        }

        private static void EnsureCanStart(Exam target)
        {
            if (target.Status != PublishedStatus)
            {
                throw new ForbiddenException("Đề thi chưa được publish.");
            }

            var now = DateTime.Now;

            if (now < target.StartTime)
            {
                throw new ForbiddenException("Chưa đến thời gian thi.");
            }

            if (now > target.EndTime)
            {
                throw new ForbiddenException("Đã qua thời gian thi.");
            }
        }

        private static void EnsureAttemptStillOpen(ExamAttempt attempt)
        {
            var now = DateTime.Now;
            var attemptEndTime = attempt.StartTime.AddMinutes(attempt.Exam?.DurationMinutes ?? 0);
            var examEndTime = attempt.Exam?.EndTime;

            if (now > attemptEndTime || (examEndTime.HasValue && now > examEndTime.Value))
            {
                throw new ForbiddenException("Đã quá thời gian làm bài.");
            }
        }

        private static bool IsAttemptExpired(ExamAttempt attempt, DateTime now)
        {
            var attemptEndTime = attempt.StartTime.AddMinutes(attempt.Exam?.DurationMinutes ?? 0);
            var examEndTime = attempt.Exam?.EndTime;

            return now > attemptEndTime ||
                (examEndTime.HasValue && now > examEndTime.Value);
        }

        private static decimal GradeAttempt(ExamAttempt attempt)
        {
            var answersByQuestion = attempt.StudentAnswers
                .ToDictionary(answer => answer.QuestionId);

            var totalQuestions = attempt.AttemptQuestions.Count;
            var correctCount = 0;

            foreach (var attemptQuestion in attempt.AttemptQuestions)
            {
                if (!answersByQuestion.TryGetValue(attemptQuestion.QuestionId, out var answer))
                {
                    continue;
                }

                var selectedOptionIds = answer.StudentAnswerOptions
                    .Select(option => option.OptionId)
                    .ToHashSet();

                var correctOptionIds = attemptQuestion.Question?.QuestionOptions
                    .Where(option => !option.IsDeleted && option.IsCorrect)
                    .Select(option => option.OptionId)
                    .ToHashSet() ?? new HashSet<int>();

                var isCorrect = correctOptionIds.SetEquals(selectedOptionIds);
                if (isCorrect)
                {
                    correctCount++;
                }

                answer.IsCorrect = isCorrect;
            }

            var questionScore = totalQuestions > 0 ? 10m / totalQuestions : 0m;
            var totalScore = totalQuestions > 0 ? (10m * correctCount) / totalQuestions : 0m;

            foreach (var attemptQuestion in attempt.AttemptQuestions)
            {
                if (answersByQuestion.TryGetValue(attemptQuestion.QuestionId, out var answer))
                {
                    answer.ScoreAwarded = answer.IsCorrect ? questionScore : 0m;
                }
            }

            return totalScore;
        }

        private static BaoStartResponseDto MapStartResponse(
            ExamAttempt attempt,
            bool isResume)
        {
            return new BaoStartResponseDto
            {
                AttemptId = attempt.AttemptId,
                ExamId = attempt.ExamId,
                AttemptNumber = attempt.AttemptNumber,
                StartTime = attempt.StartTime,
                Status = attempt.Status,
                QuestionCount = attempt.AttemptQuestions.Count,
                IsResume = isResume
            };
        }

        private static void EnsureCanViewAttempt(
            ExamAttempt attempt,
            int userId,
            string role)
        {
            _ = role switch
            {
                "Admin" => true,
                "Student" when attempt.StudentId == userId => true,
                "Student" => throw new ForbiddenException("Student chỉ được xem lần làm bài của chính mình."),
                "Teacher" when attempt.Exam != null && attempt.Exam.TeacherId == userId => true,
                "Teacher" => throw new ForbiddenException("Teacher chỉ được xem lần làm bài thuộc đề thi của mình."),
                _ => throw new ForbiddenException("Vai trò người dùng không hợp lệ.")
            };
        }

        private static BaoAttemptDetailResponseDto MapAttemptDetail(ExamAttempt attempt)
        {
            var canViewCorrectAnswers = attempt.Status != InProgressStatus &&
                (attempt.Exam?.ShowAnswerAfterSubmit ?? false);

            var answersByQuestion = attempt.StudentAnswers
                .ToDictionary(answer => answer.QuestionId);

            return new BaoAttemptDetailResponseDto
            {
                AttemptId = attempt.AttemptId,
                ExamId = attempt.ExamId,
                ExamName = attempt.Exam?.ExamName ?? string.Empty,
                StudentId = attempt.StudentId,
                AttemptNumber = attempt.AttemptNumber,
                StartTime = attempt.StartTime,
                SubmitTime = attempt.SubmitTime,
                Status = attempt.Status,
                Score = canViewCorrectAnswers ? attempt.Score : null,
                IsPassed = canViewCorrectAnswers ? attempt.IsPassed : null,
                ShowAnswerAfterSubmit = attempt.Exam?.ShowAnswerAfterSubmit ?? false,
                CanViewCorrectAnswers = canViewCorrectAnswers,
                Questions = attempt.AttemptQuestions
                    .OrderBy(question => question.QuestionOrder)
                    .Select(question => MapAttemptQuestion(
                        question,
                        answersByQuestion.TryGetValue(question.QuestionId, out var answer) ? answer : null,
                        canViewCorrectAnswers))
                    .ToList()
            };
        }

        private static BaoAttemptQuestionDto MapAttemptQuestion(
            AttemptQuestion attemptQuestion,
            StudentAnswer? answer,
            bool canViewCorrectAnswers)
        {
            var selectedOptionIds = answer?.StudentAnswerOptions
                .Select(option => option.OptionId)
                .ToHashSet() ?? new HashSet<int>();

            return new BaoAttemptQuestionDto
            {
                AttemptQuestionId = attemptQuestion.AttemptQuestionId,
                QuestionId = attemptQuestion.QuestionId,
                QuestionOrder = attemptQuestion.QuestionOrder,
                Content = attemptQuestion.Question?.Content ?? string.Empty,
                QuestionType = attemptQuestion.Question?.QuestionType ?? string.Empty,
                Difficulty = attemptQuestion.Question?.Difficulty ?? string.Empty,
                Score = attemptQuestion.Score,
                Explanation = canViewCorrectAnswers ? attemptQuestion.Question?.Explanation : null,
                HasAnswer = answer != null,
                IsCorrect = canViewCorrectAnswers && answer != null ? answer.IsCorrect : null,
                ScoreAwarded = canViewCorrectAnswers && answer != null ? answer.ScoreAwarded : null,
                SelectedOptionIds = selectedOptionIds.ToList(),
                Options = attemptQuestion.Question?.QuestionOptions
                    .Where(option => !option.IsDeleted)
                    .OrderBy(option => option.OptionOrder)
                    .Select(option => new BaoAttemptOptionDto
                    {
                        OptionId = option.OptionId,
                        OptionText = option.OptionText,
                        OptionOrder = option.OptionOrder,
                        IsCorrect = canViewCorrectAnswers ? option.IsCorrect : null,
                        IsSelected = selectedOptionIds.Contains(option.OptionId)
                    })
                    .ToList() ?? new List<BaoAttemptOptionDto>()
            };
        }

        private static BaoResultResponseDto MapResult(Exam target, ExamAttempt attempt)
        {
            var canViewCorrectAnswers = target.ShowAnswerAfterSubmit;
            var answersByQuestion = attempt.StudentAnswers
                .ToDictionary(answer => answer.QuestionId);

            return new BaoResultResponseDto
            {
                ExamId = target.ExamId,
                ExamName = target.ExamName,
                AttemptId = attempt.AttemptId,
                AttemptNumber = attempt.AttemptNumber,
                Score = attempt.Score,
                TotalScore = target.TotalScore,
                PassingScore = target.PassingScore,
                IsPassed = attempt.IsPassed,
                StartTime = attempt.StartTime,
                SubmitTime = attempt.SubmitTime,
                DurationSeconds = GetSubmitDurationSeconds(attempt),
                Status = attempt.Status,
                ShowAnswerAfterSubmit = target.ShowAnswerAfterSubmit,
                CanViewCorrectAnswers = canViewCorrectAnswers,
                Questions = attempt.AttemptQuestions
                    .OrderBy(question => question.QuestionOrder)
                    .Select(question => MapAttemptQuestion(
                        question,
                        answersByQuestion.TryGetValue(question.QuestionId, out var answer) ? answer : null,
                        canViewCorrectAnswers))
                    .ToList()
            };
        }

        private static double GetSubmitDurationSeconds(ExamAttempt attempt)
        {
            return ((attempt.SubmitTime ?? DateTime.Now) - attempt.StartTime)
                .TotalSeconds;
        }
    }
}
