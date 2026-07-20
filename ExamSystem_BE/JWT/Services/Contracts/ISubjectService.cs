using JWT.DTOs.Subjects;

namespace JWT.Services.Contracts
{
    public interface ISubjectService
    {
        Task<List<SubjectResponseDto>> GetSubjectsAsync(string? currentUserRole);
        Task<SubjectResponseDto> GetSubjectByIdAsync(int subjectId, string? currentUserRole);
        Task<SubjectResponseDto> CreateSubjectAsync(SubjectCreateDto request, string? currentUserId, string? currentUserRole);
        Task<SubjectResponseDto> UpdateSubjectAsync(int subjectId, SubjectUpdateDto request, string? currentUserId, string? currentUserRole);
        Task DeleteSubjectAsync(int subjectId, string? currentUserId, string? currentUserRole);

        Task<EnrollmentResponseDto> EnrollSubjectAsync(int subjectId, string? currentUserId, string? currentUserRole);
        Task<List<EnrollmentResponseDto>> GetStudentSubjectsAsync(int studentId, string? currentUserId, string? currentUserRole);
        Task<List<StudentInSubjectDto>> GetSubjectStudentsAsync(int subjectId, string? currentUserId, string? currentUserRole);
        Task UnenrollSubjectAsync(int subjectId, string? currentUserId, string? currentUserRole);

        // Teacher assignment management
        Task<TeacherInSubjectDto> AssignTeacherAsync(int subjectId, int teacherId, string? currentUserId, string? currentUserRole);
        Task UnassignTeacherAsync(int subjectId, int teacherId, string? currentUserId, string? currentUserRole);
        Task<List<TeacherSubjectResponseDto>> GetTeacherSubjectsAsync(string? currentUserId, string? currentUserRole);
        Task<List<TeacherInSubjectDto>> GetSubjectTeachersAsync(int subjectId, string? currentUserId, string? currentUserRole);
    }
}