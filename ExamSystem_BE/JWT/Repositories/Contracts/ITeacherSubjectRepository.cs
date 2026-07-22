using JWT.Models;

namespace JWT.Repositories.Contracts
{
    public interface ITeacherSubjectRepository
    {
        Task AddAsync(TeacherSubject teacherSubject);

        Task<TeacherSubject?> GetByTeacherAndSubjectAsync(
            int teacherId,
            int subjectId);

        Task<bool> IsAssignedAsync(
            int teacherId,
            int subjectId);

        Task<IEnumerable<TeacherSubject>> GetTeacherSubjectsAsync(
            int teacherId);

        Task<IEnumerable<TeacherSubject>> GetTeachersBySubjectAsync(
            int subjectId);

        Task SaveChangesAsync();
    }
}