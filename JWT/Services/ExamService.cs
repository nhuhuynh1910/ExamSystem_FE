using JWT.DTOs.Exam;
using JWT.Exceptions;
using JWT.Models;
using JWT.Repositories.Contracts;
using JWT.Services.Contracts;

namespace JWT.Services
{
    public class ExamService : IExamService
    {
        private const string DraftStatus = "Draft";
        private const string PublishedStatus = "Published";
        private const string ClosedStatus = "Closed";
        private const long MaxExamImageFileSize = 5 * 1024 * 1024;
        private static readonly HashSet<string> AllowedExamImageExtensions = new(StringComparer.OrdinalIgnoreCase)
        {
            ".jpg",
            ".jpeg",
            ".png",
            ".webp"
        };

        private readonly IExamRepository _examRepository;
        private readonly IWebHostEnvironment _environment;

        public ExamService(
            IExamRepository examRepository,
            IWebHostEnvironment environment)
        {
            _examRepository = examRepository;
            _environment = environment;
        }

        public async Task<PagedResultDto<ExamResponseDto>> GetExamsAsync(
            ExamFilterRequestDto filter,
            string? currentUserId,
            string? currentUserRole)
        {
            var (_, role) = GetCurrentUser(currentUserId, currentUserRole);

            if (filter.PageNumber <= 0 || filter.PageSize <= 0)
            {
                throw new BadRequestException("PageNumber va PageSize phai lon hon 0.");
            }

            var userId = int.Parse(currentUserId!);

            return role switch
            {
                "Admin" => await _examRepository.GetPagedExamsAsync(
                    filter,
                    teacherId: null,
                    includeAll: true,
                    publishedOnly: false),

                "Teacher" => await _examRepository.GetPagedExamsAsync(
                    filter,
                    teacherId: userId,
                    includeAll: false,
                    publishedOnly: false),

                "Student" => await GetPublishedExamsForStudentAsync(filter),

                _ => throw new ForbiddenException("Vai tro nguoi dung khong hop le.")
            };
        }

        public async Task<PagedResultDto<ExamResponseDto>> GetTeacherExamsAsync(
            TeacherExamFilterRequestDto filter,
            string? currentUserId,
            string? currentUserRole)
        {
            var (teacherId, role) = GetCurrentUser(currentUserId, currentUserRole);

            if (role != "Teacher")
            {
                throw new ForbiddenException("Chi giao vien moi duoc xem danh sach de thi cua minh.");
            }

            if (filter.PageNumber <= 0 || filter.PageSize <= 0)
            {
                throw new BadRequestException("PageNumber va PageSize phai lon hon 0.");
            }

            ValidateExamStatusFilter(filter.Status);

            return await _examRepository.GetTeacherOwnedExamsAsync(filter, teacherId);
        }

        public async Task<ExamResponseDto> GetExamByIdAsync(
            int examId,
            string? currentUserId,
            string? currentUserRole)
        {
            var (userId, role) = GetCurrentUser(currentUserId, currentUserRole);
            var exam = await GetExistingExamDtoAsync(examId);

            return role switch
            {
                "Admin" => exam,
                "Teacher" => await GetExamForTeacherAsync(exam, userId),
                "Student" => GetExamForStudent(exam),
                _ => throw new ForbiddenException("Vai tro nguoi dung khong hop le.")
            };
        }

        public async Task<ExamResponseDto> CreateExamAsync(
            ExamCreateDto request,
            string? currentUserId,
            string? currentUserRole)
        {
            var (userId, role) = GetCurrentUser(currentUserId, currentUserRole);

            if (role != "Teacher" && role != "Admin")
            {
                throw new ForbiddenException("Chi giao vien hoac admin moi duoc tao de thi.");
            }

            ValidateExamData(request);
            await EnsureExamNameIsUniqueAsync(request.ExamName);

            if (role == "Teacher")
            {
                await EnsureTeacherAssignedToSubjectAsync(userId, request.SubjectId);
            }

            var examImageUrl = await SaveExamImageAsync(request.ExamImage, userId);

            var exam = new Exam
            {
                SubjectId = request.SubjectId,
                TeacherId = userId,
                ExamName = request.ExamName.Trim(),
                Description = request.Description,
                ExamImageUrl = examImageUrl,
                DurationMinutes = request.DurationMinutes,
                StartTime = request.StartTime,
                EndTime = request.EndTime,
                TotalScore = request.TotalScore,
                PassingScore = request.PassingScore,
                MaxAttempts = request.MaxAttempts,
                IsPrivate = request.IsPrivate,
                AccessCode = request.AccessCode,
                ShuffleQuestions = request.ShuffleQuestions,
                ShowAnswerAfterSubmit = request.ShowAnswerAfterSubmit,
                Status = DraftStatus,
                IsDeleted = false,
                CreatedBy = userId,
                CreatedAt = DateTime.Now
            };

            return await _examRepository.AddExamAsync(exam);
        }

        public async Task<ExamResponseDto> UpdateExamAsync(
            int examId,
            ExamUpdateDto request,
            string? currentUserId,
            string? currentUserRole)
        {
            var (userId, role) = GetCurrentUser(currentUserId, currentUserRole);

            if (role != "Teacher" && role != "Admin")
            {
                throw new ForbiddenException("Chi giao vien hoac admin moi duoc cap nhat de thi.");
            }

            ValidateExamData(request);

            var exam = await GetExistingExamEntityAsync(examId);

            if (role == "Teacher" && exam.TeacherId != userId)
            {
                throw new ForbiddenException("Giao vien chi duoc sua de thi do chinh minh tao.");
            }

            await EnsureExamNameIsUniqueAsync(request.ExamName, examId);

            if (role == "Teacher")
            {
                await EnsureTeacherAssignedToSubjectAsync(userId, request.SubjectId);
            }

            exam.SubjectId = request.SubjectId;
            exam.ExamName = request.ExamName.Trim();
            exam.Description = request.Description;

            if (request.ExamImage != null && request.ExamImage.Length > 0)
            {
                exam.ExamImageUrl = await SaveExamImageAsync(request.ExamImage, userId);
            }

            exam.DurationMinutes = request.DurationMinutes;
            exam.StartTime = request.StartTime;
            exam.EndTime = request.EndTime;
            exam.TotalScore = request.TotalScore;
            exam.PassingScore = request.PassingScore;
            exam.MaxAttempts = request.MaxAttempts;
            exam.IsPrivate = request.IsPrivate;
            exam.AccessCode = request.AccessCode;
            exam.ShuffleQuestions = request.ShuffleQuestions;
            exam.ShowAnswerAfterSubmit = request.ShowAnswerAfterSubmit;
            exam.UpdatedBy = userId;
            exam.UpdatedAt = DateTime.Now;

            return await _examRepository.UpdateExamAsync(exam);
        }

        public async Task DeleteExamAsync(
            int examId,
            string? currentUserId,
            string? currentUserRole)
        {
            var (userId, role) = GetCurrentUser(currentUserId, currentUserRole);
            var exam = await GetExistingExamEntityAsync(examId);

            if (role != "Teacher" && role != "Admin")
            {
                throw new ForbiddenException("Chi giao vien hoac admin moi duoc xoa de thi.");
            }

            if (role == "Teacher")
            {
                EnsureTeacherOwnsExam(exam, userId);
            }

            exam.IsDeleted = true;
            exam.Status = ClosedStatus;
            exam.UpdatedBy = userId;
            exam.UpdatedAt = DateTime.Now;

            await _examRepository.UpdateExamAsync(exam);
        }

        public async Task<ExamResponseDto> UpdateExamStatusAsync(
            int examId,
            ExamStatusUpdateDto request,
            string? currentUserId,
            string? currentUserRole)
        {
            var (userId, role) = GetCurrentUser(currentUserId, currentUserRole);

            if (role != "Admin" && role != "Teacher")
            {
                throw new ForbiddenException("Chi giao vien tao de thi hoac admin moi duoc cap nhat trang thai de thi.");
            }

            var exam = await _examRepository.GetExamEntityIncludingDeletedByIdAsync(examId)
                ?? throw new NotFoundException("Khong tim thay de thi.");

            if (role == "Teacher")
            {
                EnsureTeacherOwnsExam(exam, userId);
            }

            var normalizedStatus = NormalizeExamStatus(request.Status);

            if (normalizedStatus == PublishedStatus &&
                !await _examRepository.HasExamQuestionsAsync(examId))
            {
                throw new BadRequestException("De thi phai co it nhat mot cau hoi truoc khi xuat ban.");
            }

            exam.IsDeleted = false;
            exam.Status = normalizedStatus;
            exam.UpdatedBy = userId;
            exam.UpdatedAt = DateTime.Now;

            return await _examRepository.UpdateExamAsync(exam);
        }

        public async Task<ExamQuestionResponseDto> AddQuestionToExamAsync(
            int examId,
            AddExamQuestionDto request,
            string? currentUserId,
            string? currentUserRole)
        {
            var (userId, role) = GetCurrentUser(currentUserId, currentUserRole);

            if (role != "Teacher" && role != "Admin")
            {
                throw new ForbiddenException("Chi giao vien hoac admin moi duoc them cau hoi vao de thi.");
            }

            var exam = await GetExistingExamEntityAsync(examId);

            if (role == "Teacher")
            {
                EnsureTeacherOwnsExam(exam, userId);
            }

            EnsureExamIsDraft(exam);

            var question = await _examRepository.GetQuestionByIdAsync(request.QuestionId);

            if (question == null)
            {
                throw new NotFoundException("Khong tim thay cau hoi.");
            }

            if (question.Status != PublishedStatus)
            {
                throw new BadRequestException("Chi duoc them cau hoi da duoc cong bo vao de thi.");
            }

            if (question.SubjectId != exam.SubjectId)
            {
                throw new BadRequestException("Cau hoi phai thuoc cung mon hoc voi de thi.");
            }

            if (await _examRepository.ExamQuestionExistsAsync(examId, request.QuestionId))
            {
                throw new ConflictException("Khong cho add trung question vao exam.");
            }

            var examQuestion = new ExamQuestion
            {
                ExamId = examId,
                QuestionId = request.QuestionId,
                QuestionOrder = request.QuestionOrder ?? await _examRepository.GetNextQuestionOrderAsync(examId),
                Score = request.Score ?? question.Score,
                CreatedAt = DateTime.Now
            };

            await _examRepository.AddExamQuestionAsync(examQuestion);

            var questions = await _examRepository.GetExamQuestionsAsync(examId);
            return questions.First(q => q.QuestionId == request.QuestionId);
        }

        public async Task RemoveQuestionFromExamAsync(
            int examId,
            int questionId,
            string? currentUserId,
            string? currentUserRole)
        {
            var (userId, role) = GetCurrentUser(currentUserId, currentUserRole);

            if (role != "Teacher" && role != "Admin")
            {
                throw new ForbiddenException("Chi giao vien hoac admin moi duoc xoa cau hoi khoi de thi.");
            }

            var exam = await GetExistingExamEntityAsync(examId);

            if (role == "Teacher")
            {
                EnsureTeacherOwnsExam(exam, userId);
            }

            EnsureExamIsDraft(exam);

            var examQuestion = await _examRepository.GetExamQuestionAsync(examId, questionId);

            if (examQuestion == null)
            {
                throw new NotFoundException("Khong tim thay cau hoi trong de thi.");
            }

            await _examRepository.RemoveExamQuestionAsync(examQuestion);
        }

        public async Task<ExamResponseDto> PublishExamAsync(
            int examId,
            string? currentUserId,
            string? currentUserRole)
        {
            var (userId, role) = GetCurrentUser(currentUserId, currentUserRole);
            var exam = await GetExistingExamEntityAsync(examId);
            EnsureCanManageExamStatus(exam, userId, role);

            if (exam.Status != DraftStatus)
            {
                throw new BadRequestException("Chi de thi dang Draft moi duoc xuat ban.");
            }

            if (!await _examRepository.HasExamQuestionsAsync(examId))
            {
                throw new BadRequestException("De thi phai co it nhat mot cau hoi truoc khi xuat ban.");
            }

            exam.Status = PublishedStatus;
            exam.UpdatedBy = userId;
            exam.UpdatedAt = DateTime.Now;

            return await _examRepository.UpdateExamAsync(exam);
        }

        public async Task<ExamResponseDto> CloseExamAsync(
            int examId,
            string? currentUserId,
            string? currentUserRole)
        {
            var (userId, role) = GetCurrentUser(currentUserId, currentUserRole);
            var exam = await GetExistingExamEntityAsync(examId);
            EnsureCanManageExamStatus(exam, userId, role);

            exam.Status = ClosedStatus;
            exam.UpdatedBy = userId;
            exam.UpdatedAt = DateTime.Now;

            return await _examRepository.UpdateExamAsync(exam);
        }

        public async Task<List<ExamQuestionResponseDto>> GetExamQuestionsAsync(
            int examId,
            string? currentUserId,
            string? currentUserRole)
        {
            var (userId, role) = GetCurrentUser(currentUserId, currentUserRole);
            var exam = await GetExistingExamDtoAsync(examId);

            _ = role switch
            {
                "Admin" => true,
                "Teacher" => await CanTeacherViewExamAsync(exam, userId),
                "Student" => CanStudentViewExamQuestions(exam),
                _ => throw new ForbiddenException("Vai tro nguoi dung khong hop le.")
            };

            var questions = await _examRepository.GetExamQuestionsAsync(examId);

            if (role == "Student")
            {
                HideCorrectAnswers(questions);
            }

            return questions;
        }

        private static (int UserId, string Role) GetCurrentUser(
            string? currentUserId,
            string? currentUserRole)
        {
            if (string.IsNullOrWhiteSpace(currentUserId) ||
                string.IsNullOrWhiteSpace(currentUserRole) ||
                !int.TryParse(currentUserId, out var userId))
            {
                throw new UnauthorizedException("Khong tim thay thong tin nguoi dung trong token.");
            }

            return (userId, currentUserRole.Trim());
        }

        private async Task<PagedResultDto<ExamResponseDto>> GetPublishedExamsForStudentAsync(
            ExamFilterRequestDto filter)
        {
            var result = await _examRepository.GetPagedExamsAsync(
                filter,
                teacherId: null,
                includeAll: true,
                publishedOnly: true);

            foreach (var exam in result.Items)
            {
                exam.AccessCode = null;
            }

            return result;
        }

        private async Task<ExamResponseDto> GetExistingExamDtoAsync(int examId)
        {
            return await _examRepository.GetExamByIdAsync(examId)
                ?? throw new NotFoundException("Khong tim thay de thi.");
        }

        private async Task<Exam> GetExistingExamEntityAsync(int examId)
        {
            return await _examRepository.GetExamEntityByIdAsync(examId)
                ?? throw new NotFoundException("Khong tim thay de thi.");
        }

        private static ExamResponseDto GetExamForStudent(ExamResponseDto exam)
        {
            if (exam.Status != PublishedStatus)
            {
                throw new ForbiddenException("Hoc sinh chi duoc xem de thi da duoc cong bo.");
            }

            exam.AccessCode = null;
            return exam;
        }

        private async Task<ExamResponseDto> GetExamForTeacherAsync(
            ExamResponseDto exam,
            int teacherId)
        {
            if (!await CanTeacherViewExamAsync(exam, teacherId))
            {
                throw new ForbiddenException("Giao vien khong co quyen xem de thi nay.");
            }

            return exam;
        }

        private async Task<bool> CanTeacherViewExamAsync(ExamResponseDto exam, int teacherId)
        {
            if (exam.TeacherId == teacherId)
            {
                return true;
            }

            return await _examRepository.IsTeacherAssignedToSubjectAsync(teacherId, exam.SubjectId);
        }

        private async Task EnsureTeacherAssignedToSubjectAsync(int teacherId, int subjectId)
        {
            if (!await _examRepository.IsTeacherAssignedToSubjectAsync(teacherId, subjectId))
            {
                throw new ForbiddenException("Giao vien chua duoc phan cong phu trach mon hoc nay.");
            }
        }

        private async Task EnsureExamNameIsUniqueAsync(string examName, int? excludedExamId = null)
        {
            if (await _examRepository.ExamNameExistsAsync(examName, excludedExamId))
            {
                throw new ConflictException("Ten de thi da ton tai.");
            }
        }

        private static void EnsureTeacherOwnsExam(Exam exam, int teacherId)
        {
            if (exam.TeacherId != teacherId)
            {
                throw new ForbiddenException("Giao vien chi duoc thao tac tren de thi do chinh minh tao.");
            }
        }

        private static void EnsureExamIsDraft(Exam exam)
        {
            if (exam.Status != DraftStatus)
            {
                throw new BadRequestException("Chi duoc thao tac cau hoi khi de thi dang Draft.");
            }
        }

        private static void EnsureCanManageExamStatus(Exam exam, int userId, string role)
        {
            _ = role switch
            {
                "Admin" => true,
                "Teacher" when exam.TeacherId == userId => true,
                "Teacher" => throw new ForbiddenException("Giao vien chi duoc thao tac tren de thi do chinh minh tao."),
                _ => throw new ForbiddenException("Vai tro nguoi dung khong hop le.")
            };
        }

        private static void ValidateExamStatusFilter(string? status)
        {
            if (string.IsNullOrWhiteSpace(status))
            {
                return;
            }

            _ = NormalizeExamStatus(status);
        }

        private static string NormalizeExamStatus(string? status)
        {
            if (string.IsNullOrWhiteSpace(status))
            {
                throw new BadRequestException("Status khong duoc de trong.");
            }

            var normalizedStatus = status.Trim();

            if (normalizedStatus != DraftStatus &&
                normalizedStatus != PublishedStatus &&
                normalizedStatus != ClosedStatus)
            {
                throw new BadRequestException("Status chi chap nhan Draft, Published hoac Closed.");
            }

            return normalizedStatus;
        }

        private static bool CanStudentViewExamQuestions(ExamResponseDto exam)
        {
            var now = DateTime.Now;

            if (exam.Status != PublishedStatus || now < exam.StartTime || now > exam.EndTime)
            {
                throw new ForbiddenException("Hoc sinh chi duoc xem cau hoi trong thoi gian lam bai.");
            }

            return true;
        }

        private static void ValidateExamData(ExamUpdateDto request)
        {
            ValidateExamFields(
                request.ExamName,
                request.StartTime,
                request.EndTime,
                request.DurationMinutes,
                request.PassingScore,
                request.TotalScore,
                request.IsPrivate,
                request.AccessCode);
        }

        private static void ValidateExamData(ExamCreateDto request)
        {
            ValidateExamFields(
                request.ExamName,
                request.StartTime,
                request.EndTime,
                request.DurationMinutes,
                request.PassingScore,
                request.TotalScore,
                request.IsPrivate,
                request.AccessCode);
        }

        private static void ValidateExamFields(
            string examName,
            DateTime startTime,
            DateTime endTime,
            int durationMinutes,
            decimal passingScore,
            decimal totalScore,
            bool isPrivate,
            string? accessCode)
        {
            if (string.IsNullOrWhiteSpace(examName))
            {
                throw new BadRequestException("Ten de thi khong duoc de trong.");
            }

            if (startTime >= endTime)
            {
                throw new BadRequestException("StartTime phai nho hon EndTime.");
            }

            if (durationMinutes <= 0)
            {
                throw new BadRequestException("DurationMinutes phai lon hon 0.");
            }

            if (passingScore > totalScore)
            {
                throw new BadRequestException("PassingScore khong duoc lon hon TotalScore.");
            }

            if (isPrivate && string.IsNullOrWhiteSpace(accessCode))
            {
                throw new BadRequestException("De thi Private bat buoc phai co AccessCode.");
            }
        }

        private async Task<string> SaveExamImageAsync(IFormFile? examImage, int teacherId)
        {
            if (examImage == null || examImage.Length == 0)
            {
                throw new BadRequestException("Anh bia de thi la bat buoc.");
            }

            if (examImage.Length > MaxExamImageFileSize)
            {
                throw new BadRequestException("Anh bia de thi toi da 5MB.");
            }

            var extension = Path.GetExtension(examImage.FileName);

            if (string.IsNullOrWhiteSpace(extension) ||
                !AllowedExamImageExtensions.Contains(extension))
            {
                throw new BadRequestException("Anh bia de thi chi chap nhan jpg, jpeg, png hoac webp.");
            }

            if (!await IsValidImageFileAsync(examImage, extension))
            {
                throw new BadRequestException("File anh bia de thi khong dung dinh dang anh hop le.");
            }

            var webRootPath = _environment.WebRootPath;

            if (string.IsNullOrWhiteSpace(webRootPath))
            {
                webRootPath = Path.Combine(_environment.ContentRootPath, "wwwroot");
            }

            var relativeFolder = Path.Combine("uploads", "exams");
            var uploadFolder = Path.Combine(webRootPath, relativeFolder);
            Directory.CreateDirectory(uploadFolder);

            var safeFileName = $"{teacherId}_{DateTime.Now:yyyyMMddHHmmss}_{Guid.NewGuid():N}{extension.ToLowerInvariant()}";
            var filePath = Path.Combine(uploadFolder, safeFileName);

            await using var stream = new FileStream(filePath, FileMode.CreateNew);
            await examImage.CopyToAsync(stream);

            return $"/uploads/exams/{safeFileName}";
        }

        private static async Task<bool> IsValidImageFileAsync(IFormFile file, string extension)
        {
            var buffer = new byte[12];

            await using var stream = file.OpenReadStream();
            var bytesRead = await stream.ReadAsync(buffer);

            return extension.ToLowerInvariant() switch
            {
                ".jpg" or ".jpeg" => bytesRead >= 3 &&
                    buffer[0] == 0xFF &&
                    buffer[1] == 0xD8 &&
                    buffer[2] == 0xFF,

                ".png" => bytesRead >= 8 &&
                    buffer[0] == 0x89 &&
                    buffer[1] == 0x50 &&
                    buffer[2] == 0x4E &&
                    buffer[3] == 0x47 &&
                    buffer[4] == 0x0D &&
                    buffer[5] == 0x0A &&
                    buffer[6] == 0x1A &&
                    buffer[7] == 0x0A,

                ".webp" => bytesRead >= 12 &&
                    buffer[0] == 0x52 &&
                    buffer[1] == 0x49 &&
                    buffer[2] == 0x46 &&
                    buffer[3] == 0x46 &&
                    buffer[8] == 0x57 &&
                    buffer[9] == 0x45 &&
                    buffer[10] == 0x42 &&
                    buffer[11] == 0x50,

                _ => false
            };
        }

        private static void HideCorrectAnswers(List<ExamQuestionResponseDto> questions)
        {
            foreach (var question in questions)
            {
                question.Explanation = null;

                foreach (var option in question.Options)
                {
                    option.IsCorrect = null;
                }
            }
        }
    }
}
