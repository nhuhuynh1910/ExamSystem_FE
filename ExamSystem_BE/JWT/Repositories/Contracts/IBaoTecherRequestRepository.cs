using JWT.DTOs.BaoTecherRequests;
using JWT.DTOs.Exam;
using JWT.Models;

namespace JWT.Repositories.Contracts
{
    public interface IBaoTecherRequestRepository
    {
        Task<User?> GetUserWithRoleAsync(int userId);

        Task<bool> SubjectExistsAsync(int subjectId);

        Task<bool> HasPendingRequestAsync(int studentId, int subjectId);

        Task<List<BaoTecherRequestAvailableSubjectDto>> GetAvailableSubjectsAsync(int userId);

        Task<List<BaoTecherRequestResponseDto>> GetUserRequestsAsync(int userId);

        Task<TeacherRequest> AddRequestAsync(TeacherRequest request);

        Task<TeacherRequest?> GetRequestByIdAsync(int requestId);

        Task<TeacherRequest?> GetRequestForReviewAsync(int requestId);

        Task<TeacherRequest?> GetUserRequestForUpdateAsync(int requestId, int userId);

        Task<PagedResultDto<BaoTecherRequestResponseDto>> GetRequestsAsync(BaoTecherRequestFilterDto filter);

        Task<Role?> GetRoleByNameAsync(string roleName);

        Task<bool> TeacherSubjectExistsAsync(int teacherId, int subjectId);

        void AddTeacherSubject(TeacherSubject teacherSubject);

        Task SaveChangesAsync();

        Task<List<int>> GetAdminIdsAsync();

        Task AddNotificationsAsync(List<Notification> notifications);
    }
}
