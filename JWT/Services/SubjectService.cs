using JWT.DTOs.Subjects;
using JWT.Exceptions;
using JWT.Models;
using JWT.Repositories.Contracts;
using JWT.Services.Contracts;

namespace JWT.Services
{
    public class SubjectService : ISubjectService
    {
        private readonly ISubjectRepository _subjectRepository;

        public SubjectService(ISubjectRepository subjectRepository)
        {
            _subjectRepository = subjectRepository;
        }

        public async Task<List<SubjectResponseDto>> GetSubjectsAsync(string? currentUserRole)
        {
            var includeInactive = currentUserRole == "Admin";

            var subjects = await _subjectRepository.GetSubjectsAsync(includeInactive);

            return subjects.Select(MapToSubjectResponse).ToList();
        }

        public async Task<SubjectResponseDto> GetSubjectByIdAsync(int subjectId, string? currentUserRole)
        {
            var subject = await _subjectRepository.GetSubjectByIdAsync(subjectId);

            if (subject == null)
                throw new NotFoundException("Subject not found.");

            if (currentUserRole != "Admin" && !subject.IsActive)
                throw new NotFoundException("Subject not found.");

            return MapToSubjectResponse(subject);
        }

        public async Task<SubjectResponseDto> CreateSubjectAsync(
            SubjectCreateDto request,
            string? currentUserId,
            string? currentUserRole)
        {
            if (currentUserRole != "Admin")
                throw new ForbiddenException("Only Admins can create a subject.");

            if (!int.TryParse(currentUserId, out var adminId))
                throw new UnauthorizedException("Invalid token.");

            var subjectName = request.SubjectName.Trim();

            if (string.IsNullOrWhiteSpace(subjectName))
                throw new BadRequestException("The subject name can't be empty.");

            if (await _subjectRepository.SubjectNameExistsAsync(subjectName))
                throw new ConflictException("The subject name already exists.");

            var subject = new Subject
            {
                SubjectName = subjectName,
                Description = request.Description?.Trim(),
                IsActive = true,
                IsDeleted = false,
                CreatedBy = adminId,
                CreatedAt = DateTime.UtcNow
            };

            var result = await _subjectRepository.AddSubjectAsync(subject);

            return MapToSubjectResponse(result);
        }

        public async Task<SubjectResponseDto> UpdateSubjectAsync(
            int subjectId,
            SubjectUpdateDto request,
            string? currentUserId,
            string? currentUserRole)
        {
            if (currentUserRole != "Admin")
                throw new ForbiddenException("Only Admin can update the subject.");

            if (!int.TryParse(currentUserId, out var adminId))
                throw new UnauthorizedException("Invalid token.");

            var subject = await _subjectRepository.GetSubjectByIdAsync(subjectId);

            if (subject == null)
                throw new NotFoundException("Subject not found.");

            var subjectName = request.SubjectName.Trim();

            if (string.IsNullOrWhiteSpace(subjectName))
                throw new BadRequestException("The subject name can't be empty.");

            if (await _subjectRepository.SubjectNameExistsAsync(subjectName, subjectId))
                throw new ConflictException("The subject name already exists.");

            subject.SubjectName = subjectName;
            subject.Description = request.Description?.Trim();
            subject.IsActive = request.IsActive;
            subject.UpdatedBy = adminId;
            subject.UpdatedAt = DateTime.UtcNow;

            var result = await _subjectRepository.UpdateSubjectAsync(subject);

            return MapToSubjectResponse(result);
        }

        public async Task DeleteSubjectAsync(int subjectId, string? currentUserId, string? currentUserRole)
        {
            if (currentUserRole != "Admin")
                throw new ForbiddenException("Only Admin can delete the subject.");

            if (!int.TryParse(currentUserId, out var adminId))
                throw new UnauthorizedException("Invalid token.");

            var subject = await _subjectRepository.GetSubjectByIdAsync(subjectId);

            if (subject == null)
                throw new NotFoundException("Subject not found.");
            if (await _subjectRepository.IsSubjectInUseAsync(subjectId))
                throw new ConflictException("Cannot delete subject because it is currently in use.");

            subject.IsDeleted = true;
            subject.IsActive = false;
            subject.UpdatedBy = adminId;
            subject.UpdatedAt = DateTime.UtcNow;

            await _subjectRepository.UpdateSubjectAsync(subject);
        }

        public async Task<EnrollmentResponseDto> EnrollSubjectAsync(
            int subjectId,
            string? currentUserId,
            string? currentUserRole)
        {
            if (currentUserRole != "Student")
                throw new ForbiddenException("Only students can enroll in subjects.");

            if (!int.TryParse(currentUserId, out var studentId))
                throw new UnauthorizedException("Invalid token.");

            var student = await _subjectRepository.GetUserByIdAsync(studentId);

            if (student == null || student.Role?.RoleName != "Student")
                throw new ForbiddenException("Only students can enroll in subjects.");

            var subject = await _subjectRepository.GetSubjectByIdAsync(subjectId);

            if (subject == null)
                throw new NotFoundException("Subject not found.");

            if (!subject.IsActive)
                throw new BadRequestException("The subject is currently inactive.");

            var existingEnrollment = await _subjectRepository.GetEnrollmentAsync(studentId, subjectId);

            if (existingEnrollment != null && !existingEnrollment.IsDeleted)
                throw new ConflictException("You have already enrolled in this subject.");

            if (existingEnrollment != null && existingEnrollment.IsDeleted)
            {
                existingEnrollment.IsDeleted = false;
                existingEnrollment.EnrolledAt = DateTime.UtcNow;
                await _subjectRepository.SaveChangesAsync();

                return MapToEnrollmentResponse(existingEnrollment);
            }

            var enrollment = new Enrollment
            {
                StudentId = studentId,
                SubjectId = subjectId,
                EnrolledAt = DateTime.UtcNow,
                IsDeleted = false
            };

            var result = await _subjectRepository.AddEnrollmentAsync(enrollment);
            result.Subject = subject;
            result.Student = student;

            return MapToEnrollmentResponse(result);
        }

        public async Task<List<EnrollmentResponseDto>> GetStudentSubjectsAsync(
            int studentId,
            string? currentUserId,
            string? currentUserRole)
        {
            if (!int.TryParse(currentUserId, out var userId))
                throw new UnauthorizedException("Invalid token.");

            if (currentUserRole != "Admin" && userId != studentId)
                throw new ForbiddenException("You can only view your own subject.");

            var student = await _subjectRepository.GetUserByIdAsync(studentId);

            if (student == null)
                throw new NotFoundException("Student not found.");

            var enrollments = await _subjectRepository.GetStudentSubjectsAsync(studentId);

            return enrollments.Select(MapToEnrollmentResponse).ToList();
        }

        public async Task<List<StudentInSubjectDto>> GetSubjectStudentsAsync(
    int subjectId,
    string? currentUserId,
    string? currentUserRole)
        {
            if (!int.TryParse(currentUserId, out var userId))
                throw new UnauthorizedException("Invalid token.");

            if (currentUserRole != "Admin" && currentUserRole != "Teacher")
                throw new ForbiddenException("Only Admin or Teacher can see the student list.");

            var subject = await _subjectRepository.GetSubjectByIdAsync(subjectId);

            if (subject == null)
                throw new NotFoundException("Subject not found.");

            if (currentUserRole == "Teacher")
            {
                var isAssigned = await _subjectRepository.IsTeacherAssignedToSubjectAsync(userId, subjectId);

                if (!isAssigned)
                    throw new ForbiddenException("Teacher can only view students in assigned subjects.");
            }

            var enrollments = await _subjectRepository.GetSubjectStudentsAsync(subjectId);

            return enrollments.Select(e => new StudentInSubjectDto
            {
                StudentId = e.StudentId,
                FullName = e.Student?.FullName ?? string.Empty,
                Email = e.Student?.Email ?? string.Empty,
                EnrolledAt = e.EnrolledAt
            }).ToList();
        }

        public async Task UnenrollSubjectAsync(
            int subjectId,
            string? currentUserId,
            string? currentUserRole)
        {
            if (currentUserRole != "Student")
                throw new ForbiddenException("Only students can unenroll from a subject.");

            if (!int.TryParse(currentUserId, out var studentId))
                throw new UnauthorizedException("Invalid token.");

            var enrollment = await _subjectRepository.GetEnrollmentAsync(studentId, subjectId);

            if (enrollment == null || enrollment.IsDeleted)
                throw new NotFoundException("You haven't enrolled in this subject yet.");

            enrollment.IsDeleted = true;

            await _subjectRepository.SaveChangesAsync();
        }

        private static SubjectResponseDto MapToSubjectResponse(Subject subject)
        {
            return new SubjectResponseDto
            {
                SubjectId = subject.SubjectId,
                SubjectName = subject.SubjectName,
                Description = subject.Description,
                IsActive = subject.IsActive,
                CreatedAt = subject.CreatedAt,
                UpdatedAt = subject.UpdatedAt
            };
        }

        private static EnrollmentResponseDto MapToEnrollmentResponse(Enrollment enrollment)
        {
            return new EnrollmentResponseDto
            {
                EnrollmentId = enrollment.EnrollmentId,
                StudentId = enrollment.StudentId,
                SubjectId = enrollment.SubjectId,
                SubjectName = enrollment.Subject?.SubjectName ?? string.Empty,
                EnrolledAt = enrollment.EnrolledAt
            };
        }
    }
}