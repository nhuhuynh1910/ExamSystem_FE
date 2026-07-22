using JWT.Data;
using JWT.Models;
using JWT.Repositories.Contracts;
using Microsoft.EntityFrameworkCore;

namespace JWT.Repositories
{
    public class TeacherSubjectRepository : ITeacherSubjectRepository
    {
        private readonly ExamDb _context;

        public TeacherSubjectRepository(ExamDb context)
        {
            _context = context;
        }

        public async Task AddAsync(TeacherSubject teacherSubject)
        {
            await _context.TeacherSubjects.AddAsync(teacherSubject);
        }

        public async Task<TeacherSubject?> GetByTeacherAndSubjectAsync(
            int teacherId,
            int subjectId)
        {
            return await _context.TeacherSubjects
                .Include(x => x.Teacher)
                .Include(x => x.Subject)
                .FirstOrDefaultAsync(x =>
                    x.TeacherId == teacherId &&
                    x.SubjectId == subjectId);
        }

        public async Task<bool> IsAssignedAsync(
            int teacherId,
            int subjectId)
        {
            return await _context.TeacherSubjects
                .AnyAsync(x =>
                    x.TeacherId == teacherId &&
                    x.SubjectId == subjectId &&
                    x.IsActive);
        }

        public async Task<IEnumerable<TeacherSubject>> GetTeacherSubjectsAsync(
            int teacherId)
        {
            return await _context.TeacherSubjects
                .Include(x => x.Subject)
                .Where(x =>
                    x.TeacherId == teacherId &&
                    x.IsActive)
                .ToListAsync();
        }

        public async Task<IEnumerable<TeacherSubject>> GetTeachersBySubjectAsync(
            int subjectId)
        {
            return await _context.TeacherSubjects
                .Include(x => x.Teacher)
                .Include(x => x.Subject)
                .Where(x =>
                    x.SubjectId == subjectId &&
                    x.IsActive)
                .ToListAsync();
        }

        public async Task SaveChangesAsync()
        {
            await _context.SaveChangesAsync();
        }
    }
}