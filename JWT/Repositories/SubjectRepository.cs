using JWT.Data;
using JWT.Models;
using JWT.Repositories.Contracts;
using Microsoft.EntityFrameworkCore;

namespace JWT.Repositories
{
    public class SubjectRepository : ISubjectRepository
    {
        private readonly ExamDb _context;

        public SubjectRepository(ExamDb context)
        {
            _context = context;
        }

        public async Task<List<Subject>> GetSubjectsAsync(bool includeInactive)
        {
            var query = _context.Subjects
                .Where(s => !s.IsDeleted);

            if (!includeInactive)
                query = query.Where(s => s.IsActive);

            return await query
                .OrderByDescending(s => s.CreatedAt)
                .ToListAsync();
        }

        public async Task<Subject?> GetSubjectByIdAsync(int subjectId)
        {
            return await _context.Subjects
                .FirstOrDefaultAsync(s => s.SubjectId == subjectId && !s.IsDeleted);
        }

        public async Task<bool> SubjectNameExistsAsync(string subjectName, int? excludeSubjectId = null)
        {
            var query = _context.Subjects
                .Where(s => !s.IsDeleted && s.SubjectName.ToLower() == subjectName.ToLower());

            if (excludeSubjectId.HasValue)
                query = query.Where(s => s.SubjectId != excludeSubjectId.Value);

            return await query.AnyAsync();
        }

        public async Task<Subject> AddSubjectAsync(Subject subject)
        {
            await _context.Subjects.AddAsync(subject);
            await _context.SaveChangesAsync();
            return subject;
        }

        public async Task<Subject> UpdateSubjectAsync(Subject subject)
        {
            _context.Subjects.Update(subject);
            await _context.SaveChangesAsync();
            return subject;
        }

        public async Task<User?> GetUserByIdAsync(int userId)
        {
            return await _context.Users
                .Include(u => u.Role)
                .FirstOrDefaultAsync(u => u.UserId == userId && !u.IsDeleted);
        }

        public async Task<Enrollment?> GetEnrollmentAsync(int studentId, int subjectId)
        {
            return await _context.Enrollments
                .Include(e => e.Subject)
                .Include(e => e.Student)
                .FirstOrDefaultAsync(e => e.StudentId == studentId && e.SubjectId == subjectId);
        }

        public async Task<Enrollment> AddEnrollmentAsync(Enrollment enrollment)
        {
            await _context.Enrollments.AddAsync(enrollment);
            await _context.SaveChangesAsync();
            return enrollment;
        }

        public async Task<List<Enrollment>> GetStudentSubjectsAsync(int studentId)
        {
            return await _context.Enrollments
                .Include(e => e.Subject)
                .Where(e => e.StudentId == studentId && !e.IsDeleted && e.Subject != null && !e.Subject.IsDeleted)
                .OrderByDescending(e => e.EnrolledAt)
                .ToListAsync();
        }

        public async Task<List<Enrollment>> GetSubjectStudentsAsync(int subjectId)
        {
            return await _context.Enrollments
                .Include(e => e.Student)
                .Where(e => e.SubjectId == subjectId && !e.IsDeleted && e.Student != null && !e.Student.IsDeleted)
                .OrderByDescending(e => e.EnrolledAt)
                .ToListAsync();
        }
        public async Task<bool> IsTeacherAssignedToSubjectAsync(int teacherId, int subjectId)
        {
            return await _context.TeacherSubjects.AnyAsync(ts =>
                ts.TeacherId == teacherId &&
                ts.SubjectId == subjectId &&
                ts.IsActive);
        }

        public async Task<bool> IsSubjectInUseAsync(int subjectId)
        {
            var hasActiveEnrollment = await _context.Enrollments.AnyAsync(e =>
                e.SubjectId == subjectId &&
                !e.IsDeleted);

            var hasActiveQuestion = await _context.Questions.AnyAsync(q =>
                q.SubjectId == subjectId &&
                !q.IsDeleted);

            var hasActiveExam = await _context.Exams.AnyAsync(e =>
                e.SubjectId == subjectId &&
                !e.IsDeleted);

            return hasActiveEnrollment || hasActiveQuestion || hasActiveExam;
        }

        public async Task SaveChangesAsync()
        {
            await _context.SaveChangesAsync();
        }
    }
}