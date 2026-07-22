using JWT.DTOs.BaoTecherRequests;
using JWT.DTOs.Exam;
using JWT.Exceptions;
using JWT.Models;
using JWT.Repositories.Contracts;
using JWT.Services.Contracts;

namespace JWT.Services
{
    public class BaoTecherRequestService : IBaoTecherRequestService
    {
        private const string PendingStatus = "Pending";
        private const long MaxCertificationFileSize = 5 * 1024 * 1024;
        private static readonly HashSet<string> AllowedCertificationExtensions = new(StringComparer.OrdinalIgnoreCase)
        {
            ".pdf",
            ".jpg",
            ".png"
        };

        private readonly IBaoTecherRequestRepository _baoTecherRequestRepository;
        private readonly IWebHostEnvironment _environment;

        public BaoTecherRequestService(
            IBaoTecherRequestRepository baoTecherRequestRepository,
            IWebHostEnvironment environment)
        {
            _baoTecherRequestRepository = baoTecherRequestRepository;
            _environment = environment;
        }

        public async Task<BaoTecherRequestResponseDto> CreateAsync(
            BaoTecherRequestCreateDto request,
            string? currentUserId,
            string? currentUserRole)
        {
            var (studentId, tokenRole) = GetCurrentUser(currentUserId, currentUserRole);

            var user = await _baoTecherRequestRepository.GetUserWithRoleAsync(studentId)
                ?? throw new UnauthorizedException("Không tìm thấy user hiện tại.");

            var role = user.Role?.RoleName ?? tokenRole;

            if (role != "Student" && role != "Teacher")
            {
                throw new ForbiddenException("Chỉ Student hoặc Teacher mới được gửi yêu cầu.");
            }

            if (role == "Admin")
            {
                throw new ForbiddenException("User đã là Admin.");
            }

            if (string.IsNullOrWhiteSpace(request.Reason))
            {
                throw new BadRequestException("Reason không được rỗng.");
            }

            if (!await _baoTecherRequestRepository.SubjectExistsAsync(request.SubjectId))
            {
                throw new NotFoundException("Không tìm thấy subject.");
            }

            if (await _baoTecherRequestRepository.TeacherSubjectExistsAsync(studentId, request.SubjectId))
            {
                throw new ConflictException("Teacher đã được phân công môn học này.");
            }

            if (await _baoTecherRequestRepository.HasPendingRequestAsync(studentId, request.SubjectId))
            {
                throw new ConflictException("User đang có request Pending cho môn học này.");
            }

            var now = DateTime.Now;
            var certificationUrl = await SaveCertificationFileAsync(request.CertificationFile, studentId);
            var teacherRequest = new TeacherRequest
            {
                StudentId = studentId,
                SubjectId = request.SubjectId,
                CertificationUrl = certificationUrl,
                Reason = request.Reason.Trim(),
                Status = PendingStatus,
                CreatedAt = now
            };

            var createdRequest = await _baoTecherRequestRepository.AddRequestAsync(teacherRequest);
            await CreateAdminNotificationsAsync(createdRequest, user, now);

            var loadedRequest = await _baoTecherRequestRepository.GetRequestByIdAsync(createdRequest.TeacherRequestId)
                ?? createdRequest;

            return MapToResponse(loadedRequest);
        }

        public async Task<PagedResultDto<BaoTecherRequestResponseDto>> GetRequestsAsync(
            BaoTecherRequestFilterDto filter,
            string? currentUserId,
            string? currentUserRole)
        {
            EnsureAdmin(currentUserId, currentUserRole);
            ValidateFilter(filter);

            return await _baoTecherRequestRepository.GetRequestsAsync(filter);
        }

        public async Task<BaoTecherRequestResponseDto> GetRequestByIdAsync(
            int requestId,
            string? currentUserId,
            string? currentUserRole)
        {
            EnsureAdmin(currentUserId, currentUserRole);

            var request = await _baoTecherRequestRepository.GetRequestByIdAsync(requestId)
                ?? throw new NotFoundException("Không tìm thấy teacher request.");

            return MapToResponse(request);
        }

        public async Task<List<BaoTecherRequestAvailableSubjectDto>> GetAvailableSubjectsAsync(
            string? currentUserId,
            string? currentUserRole)
        {
            var (userId, role) = GetCurrentUser(currentUserId, currentUserRole);

            if (role == "Admin")
            {
                throw new ForbiddenException("Admin không cần gửi teacher request.");
            }

            return await _baoTecherRequestRepository.GetAvailableSubjectsAsync(userId);
        }

        public async Task<List<BaoTecherRequestResponseDto>> GetMyRequestsAsync(
            string? currentUserId,
            string? currentUserRole)
        {
            var (userId, _) = GetCurrentUser(currentUserId, currentUserRole);

            return await _baoTecherRequestRepository.GetUserRequestsAsync(userId);
        }

        public async Task<BaoTecherRequestResponseDto> ApproveAsync(
            int requestId,
            string? currentUserId,
            string? currentUserRole)
        {
            var (adminId, _) = GetCurrentUser(currentUserId, currentUserRole);
            EnsureAdmin(currentUserId, currentUserRole);

            var request = await _baoTecherRequestRepository.GetRequestForReviewAsync(requestId)
                ?? throw new NotFoundException("Không tìm thấy teacher request.");

            EnsurePendingRequest(request);
            EnsureRequestStudentCanBeReviewed(request);

            if (!await _baoTecherRequestRepository.SubjectExistsAsync(request.SubjectId))
            {
                throw new BadRequestException("Subject khong con hoat dong hoac da bi xoa.");
            }

            var teacherRole = await _baoTecherRequestRepository.GetRoleByNameAsync("Teacher")
                ?? throw new NotFoundException("Không tìm thấy role Teacher.");

            var now = DateTime.Now;
            request.Status = "Approved";
            request.ReviewedBy = adminId;
            request.ReviewedAt = now;
            request.Student!.RoleId = teacherRole.RoleId;
            request.Student.UpdatedAt = now;

            if (!await _baoTecherRequestRepository.TeacherSubjectExistsAsync(request.StudentId, request.SubjectId))
            {
                _baoTecherRequestRepository.AddTeacherSubject(new TeacherSubject
                {
                    TeacherId = request.StudentId,
                    SubjectId = request.SubjectId,
                    AssignedAt = now,
                    IsActive = true
                });
            }

            await _baoTecherRequestRepository.SaveChangesAsync();
            await CreateStudentNotificationAsync(
                request.StudentId,
                "Yêu cầu trở thành Teacher đã được duyệt",
                "Yêu cầu trở thành Teacher của bạn đã được Admin duyệt.",
                now);

            var loadedRequest = await _baoTecherRequestRepository.GetRequestByIdAsync(requestId)
                ?? request;

            return MapToResponse(loadedRequest);
        }

        public async Task<BaoTecherRequestResponseDto> RejectAsync(
            int requestId,
            BaoTecherRequestRejectDto requestDto,
            string? currentUserId,
            string? currentUserRole)
        {
            var (adminId, _) = GetCurrentUser(currentUserId, currentUserRole);
            EnsureAdmin(currentUserId, currentUserRole);

            var request = await _baoTecherRequestRepository.GetRequestForReviewAsync(requestId)
                ?? throw new NotFoundException("Không tìm thấy teacher request.");

            EnsurePendingRequest(request);
            EnsureRequestStudentCanBeReviewed(request);

            var now = DateTime.Now;
            request.Status = "Rejected";
            request.AdminNote = requestDto.AdminNote;
            request.ReviewedBy = adminId;
            request.ReviewedAt = now;

            await _baoTecherRequestRepository.SaveChangesAsync();
            await CreateStudentNotificationAsync(
                request.StudentId,
                "Yêu cầu trở thành Teacher đã bị từ chối",
                string.IsNullOrWhiteSpace(requestDto.AdminNote)
                    ? "Yêu cầu trở thành Teacher của bạn đã bị Admin từ chối."
                    : $"Yêu cầu trở thành Teacher của bạn đã bị Admin từ chối. Lý do: {requestDto.AdminNote}",
                now);

            var loadedRequest = await _baoTecherRequestRepository.GetRequestByIdAsync(requestId)
                ?? request;

            return MapToResponse(loadedRequest);
        }

        public async Task<BaoTecherRequestResponseDto> CancelAsync(
            int requestId,
            string? currentUserId,
            string? currentUserRole)
        {
            var (userId, role) = GetCurrentUser(currentUserId, currentUserRole);

            if (role == "Admin")
            {
                throw new ForbiddenException("Admin khong the huy teacher request cua user.");
            }

            var request = await _baoTecherRequestRepository.GetUserRequestForUpdateAsync(requestId, userId)
                ?? throw new NotFoundException("Khong tim thay teacher request cua user hien tai.");

            EnsurePendingRequest(request);

            var now = DateTime.Now;
            request.Status = "Cancelled";
            request.AdminNote = "User cancelled this request.";
            request.ReviewedAt = now;

            await _baoTecherRequestRepository.SaveChangesAsync();

            var loadedRequest = await _baoTecherRequestRepository.GetRequestByIdAsync(requestId)
                ?? request;

            return MapToResponse(loadedRequest);
        }

        private async Task CreateAdminNotificationsAsync(
            TeacherRequest request,
            User student,
            DateTime now)
        {
            var adminIds = await _baoTecherRequestRepository.GetAdminIdsAsync();
            var notifications = adminIds
                .Select(adminId => new Notification
                {
                    UserId = adminId,
                    Title = "Yêu cầu trở thành Teacher mới",
                    Message = $"{student.FullName} đã gửi yêu cầu trở thành Teacher.",
                    Type = "TeacherRequest",
                    IsRead = false,
                    CreatedAt = now
                })
                .ToList();

            await _baoTecherRequestRepository.AddNotificationsAsync(notifications);
        }

        private async Task CreateStudentNotificationAsync(
            int studentId,
            string title,
            string message,
            DateTime now)
        {
            await _baoTecherRequestRepository.AddNotificationsAsync(new List<Notification>
            {
                new()
                {
                    UserId = studentId,
                    Title = title,
                    Message = message,
                    Type = "TeacherRequest",
                    IsRead = false,
                    CreatedAt = now
                }
            });
        }

        private async Task<string?> SaveCertificationFileAsync(
            IFormFile? certificationFile,
            int studentId)
        {
            if (certificationFile == null || certificationFile.Length == 0)
            {
                return null;
            }

            if (certificationFile.Length > MaxCertificationFileSize)
            {
                throw new BadRequestException("Certification file tối đa 5MB.");
            }

            var extension = Path.GetExtension(certificationFile.FileName);

            if (string.IsNullOrWhiteSpace(extension) ||
                !AllowedCertificationExtensions.Contains(extension))
            {
                throw new BadRequestException("Certification file chỉ chấp nhận pdf, jpg hoặc png.");
            }

            var webRootPath = _environment.WebRootPath;

            if (string.IsNullOrWhiteSpace(webRootPath))
            {
                webRootPath = Path.Combine(_environment.ContentRootPath, "wwwroot");
            }

            var relativeFolder = Path.Combine("uploads", "certifications");
            var uploadFolder = Path.Combine(webRootPath, relativeFolder);
            Directory.CreateDirectory(uploadFolder);

            var safeFileName = $"{studentId}_{DateTime.Now:yyyyMMddHHmmss}_{Guid.NewGuid():N}{extension.ToLowerInvariant()}";
            var filePath = Path.Combine(uploadFolder, safeFileName);

            await using var stream = new FileStream(filePath, FileMode.CreateNew);
            await certificationFile.CopyToAsync(stream);

            return $"/uploads/certifications/{safeFileName}";
        }

        private static (int UserId, string Role) GetCurrentUser(
            string? currentUserId,
            string? currentUserRole)
        {
            if (string.IsNullOrWhiteSpace(currentUserId) ||
                string.IsNullOrWhiteSpace(currentUserRole) ||
                !int.TryParse(currentUserId, out var userId))
            {
                throw new UnauthorizedException("Không tìm thấy thông tin người dùng trong token.");
            }

            return (userId, currentUserRole.Trim());
        }

        private static void EnsureAdmin(string? currentUserId, string? currentUserRole)
        {
            var (_, role) = GetCurrentUser(currentUserId, currentUserRole);

            if (role != "Admin")
            {
                throw new ForbiddenException("Chỉ Admin mới được xem teacher requests.");
            }
        }

        private static void ValidateFilter(BaoTecherRequestFilterDto filter)
        {
            if (filter.PageNumber <= 0 || filter.PageSize <= 0)
            {
                throw new BadRequestException("PageNumber và PageSize phải lớn hơn 0.");
            }

            if (!string.IsNullOrWhiteSpace(filter.Status) &&
                filter.Status != "Pending" &&
                filter.Status != "Approved" &&
                filter.Status != "Rejected" &&
                filter.Status != "Cancelled")
            {
                throw new BadRequestException("Status chỉ được là Pending, Approved hoặc Rejected.");
            }
        }

        private static void EnsurePendingRequest(TeacherRequest request)
        {
            if (request.Status != PendingStatus)
            {
                throw new BadRequestException("Request đã được Approved hoặc Rejected.");
            }
        }

        private static void EnsureRequestStudentCanBeReviewed(TeacherRequest request)
        {
            if (request.Student == null)
            {
                throw new NotFoundException("User không còn tồn tại.");
            }

            if (request.Student.IsDeleted || !request.Student.IsActive)
            {
                throw new ForbiddenException("User đã bị xóa hoặc không còn hoạt động.");
            }
        }

        private static BaoTecherRequestResponseDto MapToResponse(TeacherRequest request)
        {
            return new BaoTecherRequestResponseDto
            {
                TeacherRequestId = request.TeacherRequestId,
                StudentId = request.StudentId,
                StudentName = request.Student?.FullName ?? string.Empty,
                StudentEmail = request.Student?.Email ?? string.Empty,
                SubjectId = request.SubjectId,
                SubjectName = request.Subject?.SubjectName ?? string.Empty,
                CertificationUrl = request.CertificationUrl,
                Reason = request.Reason,
                Status = request.Status,
                AdminNote = request.AdminNote,
                ReviewedBy = request.ReviewedBy,
                ReviewerName = request.Reviewer?.FullName,
                ReviewedAt = request.ReviewedAt,
                CreatedAt = request.CreatedAt
            };
        }
    }
}
