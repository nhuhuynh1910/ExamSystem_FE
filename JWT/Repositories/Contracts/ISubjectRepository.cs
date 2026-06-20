using JWT.Models;

namespace JWT.Repositories.Contracts
{
    public interface ISubjectRepository
    {
        Task<List<Subject>> GetSubjectsAsync(bool includeInactive);
        Task<Subject?> GetSubjectByIdAsync(int subjectId);
        Task<bool> SubjectNameExistsAsync(string subjectName, int? excludeSubjectId = null);
        Task<Subject> AddSubjectAsync(Subject subject);
        Task<Subject> UpdateSubjectAsync(Subject subject);

        Task<User?> GetUserByIdAsync(int userId);
        Task<Enrollment?> GetEnrollmentAsync(int studentId, int subjectId);
        Task<Enrollment> AddEnrollmentAsync(Enrollment enrollment);
        Task<List<Enrollment>> GetStudentSubjectsAsync(int studentId);
        Task<List<Enrollment>> GetSubjectStudentsAsync(int subjectId);
        Task<bool> IsTeacherAssignedToSubjectAsync(int teacherId, int subjectId);
        Task<bool> IsSubjectInUseAsync(int subjectId);
        Task SaveChangesAsync();
    }
}