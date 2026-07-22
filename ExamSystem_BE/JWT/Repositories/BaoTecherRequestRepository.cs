using JWT.Data;
using JWT.DTOs.BaoTecherRequests;
using JWT.DTOs.Exam;
using JWT.Models;
using JWT.Repositories.Contracts;
using Microsoft.EntityFrameworkCore;

namespace JWT.Repositories
{
    public class BaoTecherRequestRepository : IBaoTecherRequestRepository
    {
        private readonly ExamDb _context;

        public BaoTecherRequestRepository(ExamDb context)
        {
            _context = context;
        }

        public async Task<User?> GetUserWithRoleAsync(int userId)
        {
            return await _context.Users
                .AsNoTracking()
                .Include(user => user.Role)
                .FirstOrDefaultAsync(user =>
                    user.UserId == userId &&
                    !user.IsDeleted &&
                    user.IsActive);
        }

        public async Task<bool> SubjectExistsAsync(int subjectId)
        {
            return await _context.Subjects
                .AsNoTracking()
                .AnyAsync(subject =>
                    subject.SubjectId == subjectId &&
                    !subject.IsDeleted &&
                    subject.IsActive);
        }

        public async Task<bool> HasPendingRequestAsync(int studentId, int subjectId)
        {
            return await _context.TeacherRequests
                .AsNoTracking()
                .AnyAsync(request =>
                    request.StudentId == studentId &&
                    request.SubjectId == subjectId &&
                    request.Status == "Pending");
        }

        public async Task<List<BaoTecherRequestAvailableSubjectDto>> GetAvailableSubjectsAsync(int userId)
        {
            return await _context.Subjects
                .AsNoTracking()
                .Where(subject =>
                    subject.IsActive &&
                    !subject.IsDeleted &&
                    !_context.TeacherSubjects.Any(teacherSubject =>
                        teacherSubject.TeacherId == userId &&
                        teacherSubject.SubjectId == subject.SubjectId &&
                        teacherSubject.IsActive) &&
                    !_context.TeacherRequests.Any(request =>
                        request.StudentId == userId &&
                        request.SubjectId == subject.SubjectId &&
                        request.Status == "Pending"))
                .OrderBy(subject => subject.SubjectName)
                .Select(subject => new BaoTecherRequestAvailableSubjectDto
                {
                    SubjectId = subject.SubjectId,
                    SubjectName = subject.SubjectName,
                    Description = subject.Description
                })
                .ToListAsync();
        }

        public async Task<List<BaoTecherRequestResponseDto>> GetUserRequestsAsync(int userId)
        {
            return await _context.TeacherRequests
                .AsNoTracking()
                .Include(request => request.Student)
                .Include(request => request.Subject)
                .Include(request => request.Reviewer)
                .Where(request => request.StudentId == userId)
                .OrderByDescending(request => request.CreatedAt)
                .Select(request => new BaoTecherRequestResponseDto
                {
                    TeacherRequestId = request.TeacherRequestId,
                    StudentId = request.StudentId,
                    StudentName = request.Student != null ? request.Student.FullName : string.Empty,
                    StudentEmail = request.Student != null ? request.Student.Email : string.Empty,
                    SubjectId = request.SubjectId,
                    SubjectName = request.Subject != null ? request.Subject.SubjectName : string.Empty,
                    CertificationUrl = request.CertificationUrl,
                    Reason = request.Reason,
                    Status = request.Status,
                    AdminNote = request.AdminNote,
                    ReviewedBy = request.ReviewedBy,
                    ReviewerName = request.Reviewer != null ? request.Reviewer.FullName : null,
                    ReviewedAt = request.ReviewedAt,
                    CreatedAt = request.CreatedAt
                })
                .ToListAsync();
        }

        public async Task<TeacherRequest> AddRequestAsync(TeacherRequest request)
        {
            _context.TeacherRequests.Add(request);
            await _context.SaveChangesAsync();

            return request;
        }

        public async Task<TeacherRequest?> GetRequestByIdAsync(int requestId)
        {
            return await _context.TeacherRequests
                .AsNoTracking()
                .Include(request => request.Student)
                .Include(request => request.Subject)
                .Include(request => request.Reviewer)
                .FirstOrDefaultAsync(request => request.TeacherRequestId == requestId);
        }

        public async Task<TeacherRequest?> GetRequestForReviewAsync(int requestId)
        {
            return await _context.TeacherRequests
                .Include(request => request.Student)
                    .ThenInclude(student => student!.Role)
                .Include(request => request.Subject)
                .Include(request => request.Reviewer)
                .FirstOrDefaultAsync(request => request.TeacherRequestId == requestId);
        }

        public async Task<TeacherRequest?> GetUserRequestForUpdateAsync(int requestId, int userId)
        {
            return await _context.TeacherRequests
                .Include(request => request.Student)
                .Include(request => request.Subject)
                .Include(request => request.Reviewer)
                .FirstOrDefaultAsync(request =>
                    request.TeacherRequestId == requestId &&
                    request.StudentId == userId);
        }

        public async Task<PagedResultDto<BaoTecherRequestResponseDto>> GetRequestsAsync(
            BaoTecherRequestFilterDto filter)
        {
            var query = _context.TeacherRequests
                .AsNoTracking()
                .Include(request => request.Student)
                .Include(request => request.Subject)
                .Include(request => request.Reviewer)
                .AsQueryable();

            if (!string.IsNullOrWhiteSpace(filter.Status))
            {
                query = query.Where(request => request.Status == filter.Status.Trim());
            }

            var totalItems = await query.CountAsync();

            var items = await query
                .OrderByDescending(request => request.CreatedAt)
                .Skip((filter.PageNumber - 1) * filter.PageSize)
                .Take(filter.PageSize)
                .Select(request => new BaoTecherRequestResponseDto
                {
                    TeacherRequestId = request.TeacherRequestId,
                    StudentId = request.StudentId,
                    StudentName = request.Student != null ? request.Student.FullName : string.Empty,
                    StudentEmail = request.Student != null ? request.Student.Email : string.Empty,
                    SubjectId = request.SubjectId,
                    SubjectName = request.Subject != null ? request.Subject.SubjectName : string.Empty,
                    CertificationUrl = request.CertificationUrl,
                    Reason = request.Reason,
                    Status = request.Status,
                    AdminNote = request.AdminNote,
                    ReviewedBy = request.ReviewedBy,
                    ReviewerName = request.Reviewer != null ? request.Reviewer.FullName : null,
                    ReviewedAt = request.ReviewedAt,
                    CreatedAt = request.CreatedAt
                })
                .ToListAsync();

            return new PagedResultDto<BaoTecherRequestResponseDto>
            {
                Items = items,
                PageNumber = filter.PageNumber,
                PageSize = filter.PageSize,
                TotalItems = totalItems,
                TotalPages = (int)Math.Ceiling(totalItems / (double)filter.PageSize)
            };
        }

        public async Task<List<int>> GetAdminIdsAsync()
        {
            return await _context.Users
                .AsNoTracking()
                .Where(user =>
                    !user.IsDeleted &&
                    user.IsActive &&
                    user.Role != null &&
                    user.Role.RoleName == "Admin")
                .Select(user => user.UserId)
                .ToListAsync();
        }

        public async Task<Role?> GetRoleByNameAsync(string roleName)
        {
            return await _context.Roles
                .AsNoTracking()
                .FirstOrDefaultAsync(role => role.RoleName == roleName);
        }

        public async Task<bool> TeacherSubjectExistsAsync(int teacherId, int subjectId)
        {
            return await _context.TeacherSubjects
                .AsNoTracking()
                .AnyAsync(teacherSubject =>
                    teacherSubject.TeacherId == teacherId &&
                    teacherSubject.SubjectId == subjectId &&
                    teacherSubject.IsActive);
        }

        public void AddTeacherSubject(TeacherSubject teacherSubject)
        {
            _context.TeacherSubjects.Add(teacherSubject);
        }

        public async Task SaveChangesAsync()
        {
            await _context.SaveChangesAsync();
        }

        public async Task AddNotificationsAsync(List<Notification> notifications)
        {
            if (notifications.Count == 0)
            {
                return;
            }

            _context.Notifications.AddRange(notifications);
            await _context.SaveChangesAsync();
        }
    }
}
