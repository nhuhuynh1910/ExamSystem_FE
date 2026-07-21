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
        private readonly ITeacherSubjectRepository _teacherSubjectRepository;

        public SubjectService(
            ISubjectRepository subjectRepository,
            ITeacherSubjectRepository teacherSubjectRepository)
        {
            _subjectRepository = subjectRepository;
            _teacherSubjectRepository = teacherSubjectRepository;
        }

        public async Task<List<SubjectResponseDto>> GetSubjectsAsync(string? currentUserRole)
        {
            // Kiểm tra vai trò: Nếu là Admin thì hiển thị cả các môn học bị ẩn/tạm khóa (IsActive = false)
            var includeInactive = currentUserRole == "Admin";

            // Lấy danh sách môn học từ Repository
            var subjects = await _subjectRepository.GetSubjectsAsync(includeInactive);

            // Chuyển đổi danh sách Entity sang DTO trả về cho client
            return subjects.Select(MapToSubjectResponse).ToList();
        }

        public async Task<SubjectResponseDto> GetSubjectByIdAsync(int subjectId, string? currentUserRole)
        {
            // Tìm môn học theo ID trong CSDL
            var subject = await _subjectRepository.GetSubjectByIdAsync(subjectId);

            // Nếu không tìm thấy môn học -> Ném lỗi 404 Not Found
            if (subject == null)
                throw new NotFoundException("Subject not found.");

            // BẢO MẬT: Nếu người xem không phải Admin và môn học đang bị Ẩn (IsActive = false) -> Báo lỗi 404
            if (currentUserRole != "Admin" && !subject.IsActive)
                throw new NotFoundException("Subject not found.");

            // Chuyển đổi sang DTO trả về cho client
            return MapToSubjectResponse(subject);
        }

        public async Task<SubjectResponseDto> CreateSubjectAsync(
            SubjectCreateDto request,
            string? currentUserId,
            string? currentUserRole)
        {
            // 1. Phân quyền: Chỉ Admin mới có quyền tạo môn học mới
            if (currentUserRole != "Admin")
                throw new ForbiddenException("Only Admins can create a subject.");

            // 2. Ép kiểu ID của Admin từ Token JWT
            if (!int.TryParse(currentUserId, out var adminId))
                throw new UnauthorizedException("Invalid token.");

            // 3. Chuẩn hóa tên môn học (cắt bỏ khoảng trắng thừa ở đầu/cuối)
            var subjectName = request.SubjectName.Trim();

            // 4. Kiểm tra tên môn học không được để trống
            if (string.IsNullOrWhiteSpace(subjectName))
                throw new BadRequestException("The subject name can't be empty.");

            // 5. Kiểm tra trùng tên môn học trong CSDL
            if (await _subjectRepository.SubjectNameExistsAsync(subjectName))
                throw new ConflictException("The subject name already exists.");

            // 6. Khởi tạo đối tượng môn học mới
            var subject = new Subject
            {
                SubjectName = subjectName,                  // Tên môn học
                Description = request.Description?.Trim(),  // Mô tả môn học
                IsActive = true,                             // Mặc định kích hoạt
                IsDeleted = false,                           // Mặc định chưa bị xóa
                CreatedBy = adminId,                         // ID Admin thực hiện tạo
                CreatedAt = DateTime.UtcNow                  // Thời gian tạo (giờ UTC)
            };

            // 7. Lưu môn học mới vào Database
            var result = await _subjectRepository.AddSubjectAsync(subject);

            // 8. Chuyển đổi đối tượng vừa tạo sang DTO để trả về kết quả
            return MapToSubjectResponse(result);
        }

        public async Task<SubjectResponseDto> UpdateSubjectAsync(
            int subjectId,
            SubjectUpdateDto request,
            string? currentUserId,
            string? currentUserRole)
        {
            // 1. Phân quyền: Chỉ Admin mới có quyền cập nhật môn học
            if (currentUserRole != "Admin")
                throw new ForbiddenException("Only Admin can update the subject.");

            // 2. Giải mã và kiểm tra Admin ID từ Token JWT
            if (!int.TryParse(currentUserId, out var adminId))
                throw new UnauthorizedException("Invalid token.");

            // 3. Tìm môn học cần sửa trong CSDL
            var subject = await _subjectRepository.GetSubjectByIdAsync(subjectId);

            if (subject == null)
                throw new NotFoundException("Subject not found.");

            // 4. Chuẩn hóa tên môn học
            var subjectName = request.SubjectName.Trim();

            if (string.IsNullOrWhiteSpace(subjectName))
                throw new BadRequestException("The subject name can't be empty.");

            // 5. Kiểm tra tên mới có trùng với môn học KHÁC hay không (loại trừ chính subjectId đang sửa)
            if (await _subjectRepository.SubjectNameExistsAsync(subjectName, subjectId))
                throw new ConflictException("The subject name already exists.");

            // 6. Cập nhật các trường thông tin môn học
            subject.SubjectName = subjectName;                 // Tên môn mới
            subject.Description = request.Description?.Trim(); // Mô tả mới
            subject.IsActive = request.IsActive;               // Trạng thái (Ẩn/Hiện)
            subject.UpdatedBy = adminId;                        // ID Admin chỉnh sửa
            subject.UpdatedAt = DateTime.UtcNow;                 // Thời điểm chỉnh sửa

            // 7. Lưu thay đổi xuống CSDL
            var result = await _subjectRepository.UpdateSubjectAsync(subject);

            // 8. Trả về DTO thông tin môn học sau khi sửa
            return MapToSubjectResponse(result);
        }

        public async Task DeleteSubjectAsync(int subjectId, string? currentUserId, string? currentUserRole)
        {
            // 1. Phân quyền: Chỉ Admin mới được xóa môn học
            if (currentUserRole != "Admin")
                throw new ForbiddenException("Only Admin can delete the subject.");

            // 2. Lấy Admin ID từ Token JWT
            if (!int.TryParse(currentUserId, out var adminId))
                throw new UnauthorizedException("Invalid token.");

            // 3. Tìm môn học theo ID trong CSDL
            var subject = await _subjectRepository.GetSubjectByIdAsync(subjectId);

            if (subject == null)
                throw new NotFoundException("Subject not found.");

            // 4. Kiểm tra môn học có đang được sử dụng hay không (ví dụ: đã có đề thi, bài thi...)
            if (await _subjectRepository.IsSubjectInUseAsync(subjectId))
                throw new ConflictException("Cannot delete subject because it is currently in use.");

            // 5. XÓA MỀM (Soft Delete): Đánh dấu IsDeleted = true và ngưng hoạt động IsActive = false
            subject.IsDeleted = true;
            subject.IsActive = false;
            subject.UpdatedBy = adminId;         // Lưu Admin thực hiện xóa
            subject.UpdatedAt = DateTime.UtcNow;  // Thời gian thực hiện xóa

            // 6. Cập nhật trạng thái xóa mềm vào CSDL
            await _subjectRepository.UpdateSubjectAsync(subject);
        }

        public async Task<EnrollmentResponseDto> EnrollSubjectAsync(
            int subjectId,
            string? currentUserId,
            string? currentUserRole)
        {
            // 1. Phân quyền: Chỉ tài khoản role Student mới được đăng ký môn học
            if (currentUserRole != "Student")
                throw new ForbiddenException("Only students can enroll in subjects.");

            // 2. Đọc ID của sinh viên từ Token JWT
            if (!int.TryParse(currentUserId, out var studentId))
                throw new UnauthorizedException("Invalid token.");

            // 3. Kiểm tra thông tin Sinh viên thực tế trong CSDL
            var student = await _subjectRepository.GetUserByIdAsync(studentId);

            if (student == null || student.Role?.RoleName != "Student")
                throw new ForbiddenException("Only students can enroll in subjects.");

            // 4. Tìm kiếm môn học theo ID
            var subject = await _subjectRepository.GetSubjectByIdAsync(subjectId);

            if (subject == null)
                throw new NotFoundException("Subject not found.");

            // 5. Môn học đang bị ẩn/tạm khóa -> Không cho phép đăng ký
            if (!subject.IsActive)
                throw new BadRequestException("The subject is currently inactive.");

            // 6. Kiểm tra xem sinh viên đã từng có bản ghi đăng ký môn này chưa
            var existingEnrollment = await _subjectRepository.GetEnrollmentAsync(studentId, subjectId);

            // 6a. Nếu đang đăng ký và bản ghi đang còn hiệu lực -> Báo lỗi trùng 409
            if (existingEnrollment != null && !existingEnrollment.IsDeleted)
                throw new ConflictException("You have already enrolled in this subject.");

            // 6b. Nếu từng đăng ký nhưng ĐÃ HỦY (IsDeleted = true) -> Khôi phục lại bản ghi cũ
            if (existingEnrollment != null && existingEnrollment.IsDeleted)
            {
                existingEnrollment.IsDeleted = false;           // Mở lại trạng thái đăng ký
                existingEnrollment.EnrolledAt = DateTime.UtcNow; // Cập nhật ngày đăng ký mới
                await _subjectRepository.SaveChangesAsync();

                return MapToEnrollmentResponse(existingEnrollment);
            }

            // 7. Nếu chưa từng đăng ký -> Khởi tạo bản ghi Enrollment mới
            var enrollment = new Enrollment
            {
                StudentId = studentId,        // ID Sinh viên
                SubjectId = subjectId,        // ID Môn học
                EnrolledAt = DateTime.UtcNow,  // Thời gian đăng ký (UTC)
                IsDeleted = false             // Trạng thái hoạt động
            };

            // 8. Lưu bản ghi đăng ký mới vào CSDL
            var result = await _subjectRepository.AddEnrollmentAsync(enrollment);
            result.Subject = subject;  // Gắn thông tin môn học vào DTO trả về
            result.Student = student;  // Gắn thông tin sinh viên vào DTO trả về

            return MapToEnrollmentResponse(result);
        }

        public async Task<List<EnrollmentResponseDto>> GetStudentSubjectsAsync(
            int studentId,
            string? currentUserId,
            string? currentUserRole)
        {
            // 1. Giải mã ID người dùng từ Token JWT
            if (!int.TryParse(currentUserId, out var userId))
                throw new UnauthorizedException("Invalid token.");

            // 2. BẢO MẬT: Sinh viên chỉ được xem môn học của CHÍNH MÌNH (userId == studentId), ngoại trừ Admin
            if (currentUserRole != "Admin" && userId != studentId)
                throw new ForbiddenException("You can only view your own subject.");

            // 3. Kiểm tra thông tin sinh viên trong CSDL
            var student = await _subjectRepository.GetUserByIdAsync(studentId);

            if (student == null)
                throw new NotFoundException("Student not found.");

            // 4. Lấy danh sách các môn học mà sinh viên này đã đăng ký
            var enrollments = await _subjectRepository.GetStudentSubjectsAsync(studentId);

            // 5. Chuyển đổi sang danh sách DTO trả về cho client
            return enrollments.Select(MapToEnrollmentResponse).ToList();
        }

        public async Task<List<StudentInSubjectDto>> GetSubjectStudentsAsync(
            int subjectId,
            string? currentUserId,
            string? currentUserRole)
        {
            // 1. Lấy UserId của người gọi API từ Token JWT
            if (!int.TryParse(currentUserId, out var userId))
                throw new UnauthorizedException("Invalid token.");

            // 2. Phân quyền: Chỉ Admin hoặc Teacher mới được xem danh sách sinh viên
            if (currentUserRole != "Admin" && currentUserRole != "Teacher")
                throw new ForbiddenException("Only Admin or Teacher can see the student list.");

            // 3. Kiểm tra môn học có tồn tại không
            var subject = await _subjectRepository.GetSubjectByIdAsync(subjectId);

            if (subject == null)
                throw new NotFoundException("Subject not found.");

            // 4. RÀO CẢN BẢO MẬT DÀNH CHO GIÁO VIÊN:
            // Giáo viên chỉ được phép xem sinh viên của môn học MÌNH ĐƯỢC PHÂN CÔNG DẠY
            if (currentUserRole == "Teacher")
            {
                var isAssigned = await _subjectRepository.IsTeacherAssignedToSubjectAsync(userId, subjectId);

                if (!isAssigned)
                    throw new ForbiddenException("Teacher can only view students in assigned subjects.");
            }

            // 5. Lấy danh sách các sinh viên đã enroll môn học này từ CSDL
            var enrollments = await _subjectRepository.GetSubjectStudentsAsync(subjectId);

            // 6. Mapping từng sinh viên sang DTO StudentInSubjectDto để trả về client
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
            // 1. Phân quyền: Chỉ Sinh viên mới có quyền hủy đăng ký môn học
            if (currentUserRole != "Student")
                throw new ForbiddenException("Only students can unenroll from a subject.");

            // 2. Ép kiểu ID sinh viên từ Token JWT
            if (!int.TryParse(currentUserId, out var studentId))
                throw new UnauthorizedException("Invalid token.");

            // 3. Tìm bản ghi đăng ký của sinh viên với môn học này trong CSDL
            var enrollment = await _subjectRepository.GetEnrollmentAsync(studentId, subjectId);

            // 4. Nếu không tìm thấy hoặc đã hủy trước đó -> Báo lỗi 404
            if (enrollment == null || enrollment.IsDeleted)
                throw new NotFoundException("You haven't enrolled in this subject yet.");

            // 5. Hủy đăng ký bằng cách đánh dấu xóa mềm IsDeleted = true
            enrollment.IsDeleted = true;

            // 6. Lưu cập nhật xuống CSDL
            await _subjectRepository.SaveChangesAsync();
        }

        public async Task<TeacherInSubjectDto> AssignTeacherAsync(
            int subjectId,
            int teacherId,
            string? currentUserId,
            string? currentUserRole)
        {
            // 1. Phân quyền: Chỉ Admin mới có quyền gán Giáo viên vào môn học
            if (currentUserRole != "Admin")
                throw new ForbiddenException("Only Admin can assign teachers to subjects.");

            // 2. Tìm môn học theo ID trong CSDL
            var subject = await _subjectRepository.GetSubjectByIdAsync(subjectId)
                ?? throw new NotFoundException("Subject not found.");

            // 3. Tìm giáo viên theo ID trong CSDL
            var teacher = await _subjectRepository.GetUserByIdAsync(teacherId)
                ?? throw new NotFoundException("Teacher not found.");

            // 4. Kiểm tra xem tài khoản này có đúng role Teacher hay không
            if (teacher.Role?.RoleName != "Teacher")
                throw new BadRequestException("The specified user is not a Teacher.");

            // 5. Kiểm tra xem giáo viên đã từng được gán môn này chưa
            var existing = await _teacherSubjectRepository.GetByTeacherAndSubjectAsync(teacherId, subjectId);

            if (existing != null)
            {
                // 5a. Nếu đã gán và đang hoạt động -> Báo lỗi trùng 409
                if (existing.IsActive)
                    throw new ConflictException("This teacher is already assigned to the subject.");

                // 5b. Nếu từng bị hủy gán trước đó -> Kích hoạt lại (IsActive = true)
                existing.IsActive = true;
                existing.AssignedAt = DateTime.UtcNow; // Cập nhật thời điểm gán lại
                await _teacherSubjectRepository.SaveChangesAsync();
                return MapToTeacherInSubjectDto(existing, teacher);
            }

            // 6. Nếu chưa từng gán -> Khởi tạo bản ghi phân công TeacherSubject mới
            var ts = new TeacherSubject
            {
                TeacherId = teacherId,
                SubjectId = subjectId,
                AssignedAt = DateTime.UtcNow,
                IsActive = true
            };

            // 7. Lưu bản ghi phân công mới vào CSDL
            await _teacherSubjectRepository.AddAsync(ts);
            await _teacherSubjectRepository.SaveChangesAsync();

            ts.Teacher = teacher;
            ts.Subject = subject;

            // 8. Chuyển đổi sang DTO trả về cho client
            return MapToTeacherInSubjectDto(ts, teacher);
        }

        public async Task UnassignTeacherAsync(
            int subjectId,
            int teacherId,
            string? currentUserId,
            string? currentUserRole)
        {
            // 1. Phân quyền: Chỉ Admin mới có quyền gỡ giáo viên khỏi môn học
            if (currentUserRole != "Admin")
                throw new ForbiddenException("Only Admin can unassign teachers from subjects.");

            // 2. Tìm bản ghi phân công giữa Giáo viên và Môn học
            var ts = await _teacherSubjectRepository.GetByTeacherAndSubjectAsync(teacherId, subjectId)
                ?? throw new NotFoundException("This teacher is not assigned to the subject.");

            // 3. Nếu bản ghi ngưng hoạt động (IsActive = false) -> Báo lỗi 404
            if (!ts.IsActive)
                throw new NotFoundException("This teacher is not assigned to the subject.");

            // 4. Ngưng phân công bằng cách đánh dấu IsActive = false
            ts.IsActive = false;

            // 5. Lưu thay đổi xuống CSDL
            await _teacherSubjectRepository.SaveChangesAsync();
        }

        public async Task<List<TeacherSubjectResponseDto>> GetTeacherSubjectsAsync(
            string? currentUserId,
            string? currentUserRole)
        {
            // 1. Phân quyền: Chỉ Teacher hoặc Admin mới xem được danh sách môn học được phân công
            if (currentUserRole != "Teacher" && currentUserRole != "Admin")
                throw new ForbiddenException("Only Teacher or Admin can view assigned subjects.");

            // 2. Đọc ID của giáo viên từ Token JWT
            if (!int.TryParse(currentUserId, out var teacherId))
                throw new UnauthorizedException("Invalid token.");

            // 3. Lấy danh sách phân công môn học của giáo viên này từ CSDL
            var assignments = await _teacherSubjectRepository.GetTeacherSubjectsAsync(teacherId);

            // 4. Chuyển đổi danh sách sang DTO trả về cho client
            return assignments.Select(ts => new TeacherSubjectResponseDto
            {
                TeacherSubjectId = ts.TeacherSubjectId,
                SubjectId = ts.SubjectId,
                SubjectName = ts.Subject?.SubjectName ?? string.Empty,
                Description = ts.Subject?.Description,
                IsActive = ts.Subject?.IsActive ?? false,
                AssignedAt = ts.AssignedAt
            }).ToList();
        }

        public async Task<List<TeacherInSubjectDto>> GetSubjectTeachersAsync(
            int subjectId,
            string? currentUserId,
            string? currentUserRole)
        {
            // 1. Phân quyền: Chỉ Admin hoặc Teacher mới được xem danh sách giáo viên của môn học
            if (currentUserRole != "Admin" && currentUserRole != "Teacher")
                throw new ForbiddenException("Only Admin or Teacher can view the teacher list.");

            // 2. Tìm môn học theo ID trong CSDL
            var subject = await _subjectRepository.GetSubjectByIdAsync(subjectId)
                ?? throw new NotFoundException("Subject not found.");

            // 3. Lấy danh sách giáo viên được phân công giảng dạy môn học này từ CSDL
            var assignments = await _teacherSubjectRepository.GetTeachersBySubjectAsync(subjectId);

            // 4. Map sang DTO trả về cho client
            return assignments.Select(ts => MapToTeacherInSubjectDto(ts, ts.Teacher)).ToList();
        }

        // Hàm phụ trợ: Map từ Entity Subject sang SubjectResponseDto
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

        // Hàm phụ trợ: Map từ Entity TeacherSubject sang TeacherInSubjectDto
        private static TeacherInSubjectDto MapToTeacherInSubjectDto(TeacherSubject ts, User teacher)
        {
            return new TeacherInSubjectDto
            {
                TeacherSubjectId = ts.TeacherSubjectId,
                TeacherId = ts.TeacherId,
                FullName = teacher.FullName ?? string.Empty,
                Email = teacher.Email ?? string.Empty,
                AssignedAt = ts.AssignedAt,
                IsActive = ts.IsActive
            };
        }

        // Hàm phụ trợ: Map từ Entity Enrollment sang EnrollmentResponseDto
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